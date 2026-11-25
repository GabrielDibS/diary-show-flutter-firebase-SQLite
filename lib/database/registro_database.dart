import 'package:sqflite/sqflite.dart';

import '../models/registro_model.dart';
import 'local_database.dart';

class RegistroDatabase {
  Future<Database> get _db => LocalDatabase.instance.database;

  Future<void> inserir(Registro registro) async {
    final db = await _db;
    await db.insert(
      LocalDatabase.nomeTabela,
      registro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizar(Registro registro) async {
    final db = await _db;
    await db.update(
      LocalDatabase.nomeTabela,
      registro.toMap(),
      where: 'id = ?',
      whereArgs: [registro.id],
    );
  }

  Future<Registro?> buscarPorId(String id) async {
    final db = await _db;
    final linhas = await db.query(
      LocalDatabase.nomeTabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Registro.fromMap(linhas.first);
  }

  Future<List<Registro>> listarPorUsuario(String userId) async {
    final db = await _db;
    final linhas = await db.query(
      LocalDatabase.nomeTabela,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dataEvento ASC',
    );
    return linhas.map(Registro.fromMap).toList();
  }

  Future<List<Registro>> listarPendentes(String userId) async {
    final db = await _db;
    final linhas = await db.query(
      LocalDatabase.nomeTabela,
      where: 'userId = ? AND synced = 0',
      whereArgs: [userId],
      orderBy: 'updatedAt ASC',
    );
    return linhas.map(Registro.fromMap).toList();
  }

  Future<int> contarPendentes(String userId) async {
    final db = await _db;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM ${LocalDatabase.nomeTabela} WHERE userId = ? AND synced = 0',
      [userId],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<void> excluir(String id) async {
    final db = await _db;
    await db.delete(
      LocalDatabase.nomeTabela,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
