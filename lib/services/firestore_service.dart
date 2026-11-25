import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/registro_model.dart';

class FirestoreService {
  static const Duration _tempoLimite = Duration(seconds: 15);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _colecao(String userId) {
    return _db.collection('users').doc(userId).collection('registros');
  }

  Future<List<Registro>> listar(String userId) async {
    final snapshot = await _colecao(userId).get().timeout(_tempoLimite);
    return snapshot.docs
        .map((doc) => Registro.fromFirestore(doc.id, userId, doc.data()))
        .toList();
  }

  Future<void> salvar(Registro registro) async {
    await _colecao(registro.userId)
        .doc(registro.id)
        .set(registro.toFirestore())
        .timeout(_tempoLimite);
  }

  Future<void> excluir(String userId, String id) async {
    await _colecao(userId).doc(id).delete().timeout(_tempoLimite);
  }
}
