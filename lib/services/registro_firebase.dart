import 'dart:async';

import 'package:uuid/uuid.dart';

import '../database/registro_database.dart';
import '../models/registro_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'sync_service.dart';

class ListagemRegistros {
  final List<Registro> registros;
  final bool nuvemDisponivel;

  const ListagemRegistros(this.registros, {required this.nuvemDisponivel});
}

class RegistroRepository {
  final RegistroDatabase _helper = RegistroDatabase();
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  final SyncService _sync = SyncService.instance;

  String get _uid {
    final uid = _auth.uid;
    if (uid == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    return uid;
  }

  Registro novo({
    required String titulo,
    required String artista,
    required String local,
    required String descricao,
    required DateTime dataEvento,
    double? latitude,
    double? longitude,
    String? imagemPath,
  }) {
    final agora = DateTime.now();
    return Registro(
      id: const Uuid().v4(),
      userId: _uid,
      titulo: titulo,
      artista: artista,
      local: local,
      descricao: descricao,
      dataEvento: dataEvento,
      dataCriacao: agora,
      updatedAt: agora,
      latitude: latitude,
      longitude: longitude,
      imagemPath: imagemPath,
    );
  }

  Future<ListagemRegistros> listar() async {
    final uid = _uid;
    final locais = await _helper.listarPorUsuario(uid);
    final mapa = <String, Registro>{};
    var nuvemDisponivel = false;

    if (await _sync.estaOnline()) {
      try {
        final remotos = await _firestore.listar(uid);
        for (final registro in remotos) {
          mapa[registro.id] = registro;
        }
        nuvemDisponivel = true;
      } catch (_) {
        nuvemDisponivel = false;
      }
    }

    for (final local in locais) {
      if (local.excluido) {
        mapa.remove(local.id);
      } else {
        mapa[local.id] = local;
      }
    }

    final lista = mapa.values.toList()
      ..sort((a, b) => a.dataEvento.compareTo(b.dataEvento));
    return ListagemRegistros(lista, nuvemDisponivel: nuvemDisponivel);
  }

  Future<void> salvar(Registro registro) async {
    final pronto = registro.copyWith(synced: false, updatedAt: DateTime.now());
    final existente = await _helper.buscarPorId(pronto.id);
    if (existente == null) {
      await _helper.inserir(pronto);
    } else {
      await _helper.atualizar(pronto);
    }
    await _sync.atualizarPendentes();
    unawaited(_sync.sincronizar());
  }

  Future<void> excluir(Registro registro) async {
    final agora = DateTime.now();
    final marcado = registro.copyWith(
      synced: false,
      updatedAt: agora,
      deletedAt: agora,
    );
    final existente = await _helper.buscarPorId(marcado.id);
    if (existente == null) {
      await _helper.inserir(marcado);
    } else {
      await _helper.atualizar(marcado);
    }
    await _sync.atualizarPendentes();
    unawaited(_sync.sincronizar());
  }
}
