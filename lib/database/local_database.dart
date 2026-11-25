import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static const String nomeTabela = 'registros';

  Database? _db;

  Future<Database> get database async {
    final existente = _db;
    if (existente != null) return existente;

    final caminho = join(await getDatabasesPath(), 'diario_shows.db');
    final db = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, versao) async {
        await db.execute('''
          CREATE TABLE $nomeTabela (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            titulo TEXT NOT NULL,
            artista TEXT NOT NULL,
            local TEXT,
            descricao TEXT,
            dataEvento TEXT NOT NULL,
            dataCriacao TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            imagemPath TEXT,
            synced INTEGER NOT NULL DEFAULT 0,
            updatedAt TEXT NOT NULL,
            deletedAt TEXT
          )
        ''');
      },
    );
    _db = db;
    return db;
  }
}
