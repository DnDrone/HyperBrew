import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'JogadorModel.dart';

class JogadorDatabase {
  static final JogadorDatabase instance = JogadorDatabase._init();
  static Database? _database;

  JogadorDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jogadores.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jogadores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Jogador jogador) async {
    final db = await instance.database;
    return await db.insert('jogadores', jogador.toMap());
  }

  Future<Jogador> create(Jogador jogador) async {
    final db = await instance.database;
    final id = await db.insert('jogadores', jogador.toMap());
    return jogador.copyWith(id: id);
  }

  Future<Jogador?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'jogadores',
      columns: ['id', 'nome'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Jogador.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Jogador>> readAll() async {
    final db = await instance.database;
    final result = await db.query('jogadores');
    return result.map((map) => Jogador.fromMap(map)).toList();
  }

  Future<int> update(Jogador jogador) async {
    final db = await instance.database;
    return db.update(
      'jogadores',
      jogador.toMap(),
      where: 'id = ?',
      whereArgs: [jogador.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(
      'jogadores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
