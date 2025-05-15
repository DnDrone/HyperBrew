import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Secao.dart';

class SecaoDataBase{
  static final instance = SecaoDataBase._init();
  static Database? _database;

  static const int _dbVersion = 1;

  SecaoDataBase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('secao.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('Banco de dados localizado em: $path');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    print("Criando a tabela de secao...");
    await db.execute('''
    CREATE TABLE secao (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      mestre_id INTEGER NOT NULL,
    )
    ''');
  }

  Future<int> create(Secao secao) async {
    final db = await instance.database;
    final id = await db.insert('secao', secao.toMap());
    return id;
  }

  Future<Secao?> readSecao(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'secao',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Secao.fromMap(result.first);
    }
    return null;
  }

  Future<List<Secao>> readAllSecao() async {
    final db = await instance.database;
    final result = await db.query('secao');
    return result.map((json) => Secao.fromMap(json)).toList();
  }

  Future<int> update(Secao secao) async {
    final db = await instance.database;
    return db.update(
      'secao',
      secao.toMap(),
      where: 'id = ?',
      whereArgs: [secao.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(
      'secao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}