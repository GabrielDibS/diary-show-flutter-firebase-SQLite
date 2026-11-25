import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../database/registro_database.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final RegistroDatabase _helper = RegistroDatabase();
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();

  final ValueNotifier<bool> online = ValueNotifier<bool>(true);
  final ValueNotifier<int> pendentes = ValueNotifier<int>(0);
  final ValueNotifier<bool> sincronizando = ValueNotifier<bool>(false);
  final ValueNotifier<int> versao = ValueNotifier<int>(0);

  StreamSubscription<List<ConnectivityResult>>? _assinatura;
  bool _repetir = false;

  Future<void> iniciar() async {
    online.value = await estaOnline();

    _assinatura ??= Connectivity().onConnectivityChanged.listen((resultados) {
      final conectado = _temConexao(resultados);
      online.value = conectado;
      if (conectado) {
        sincronizar();
      }
    });

    await atualizarPendentes();
    if (online.value) {
      await sincronizar();
    }
  }

  bool _temConexao(List<ConnectivityResult> resultados) {
    return resultados.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> estaOnline() async {
    final resultados = await Connectivity().checkConnectivity();
    return _temConexao(resultados);
  }

  Future<void> atualizarPendentes() async {
    final uid = _auth.uid;
    pendentes.value = uid == null ? 0 : await _helper.contarPendentes(uid);
  }

  Future<void> sincronizar() async {
    if (sincronizando.value) {
      _repetir = true;
      return;
    }

    final uid = _auth.uid;
    if (uid == null) return;
    if (!await estaOnline()) return;

    sincronizando.value = true;
    try {
      do {
        _repetir = false;
        await _enviarPendentes(uid);
      } while (_repetir);
    } catch (_) {
      // Sem internet, tempo esgotado ou erro de permissão: os registros continuam pendentes no SQLite para a próxima tentativa.
    } finally {
      sincronizando.value = false;
      await atualizarPendentes();
      versao.value++;
    }
  }

  Future<void> _enviarPendentes(String uid) async {
    final lista = await _helper.listarPendentes(uid);

    for (final registro in lista) {
      if (registro.excluido) {
        await _firestore.excluir(uid, registro.id);
      } else {
        await _firestore.salvar(registro.copyWith(synced: true));
      }

      // Só apaga do SQLite se o registro não foi alterado durante o envio. Se foi, a versão mais nova continua pendente.
      final atual = await _helper.buscarPorId(registro.id);
      if (atual != null && atual.updatedAt == registro.updatedAt) {
        await _helper.excluir(registro.id);
      }
    }
  }
}
