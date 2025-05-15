import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'JogadorModel.dart';

class JogadorDatabase {
  static final JogadorDatabase instance = JogadorDatabase._init();
  static Database? _database;

  static const int _dbVersion = 1;

  JogadorDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jogador.db');
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
    print("Criando a tabela de jogadores...");
    await db.execute('''
      CREATE TABLE jogador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<Jogador> create(Jogador jogador) async {
    final db = await instance.database;
    final id = await db.insert('jogador', jogador.toMap());
    print('Jogador criado com ID: $id');
    return jogador.copyWith(id: id);
  }

  Future<Jogador?> readJogador(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'jogador',
      columns: ['id', 'nome', 'email'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Jogador.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Jogador>> readAllJogadores() async {
    final db = await instance.database;
    final result = await db.query('jogador');
    print('Jogadores carregados: ${result.length}');
    return result.map((json) => Jogador.fromMap(json)).toList();
  }

  Future<int> update(Jogador jogador) async {
    final db = await instance.database;
    return db.update(
      'jogador',
      jogador.toMap(),
      where: 'id = ?',
      whereArgs: [jogador.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('jogador', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
