import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'FichaModel.dart';

class FichaDatabase {
  static final FichaDatabase instance = FichaDatabase._init();
  static Database? _database;

  FichaDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fichas.db');
    return _database!;
  }

 Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  print('Banco de dados localizado em: $path');  // Verifique o caminho

  return await openDatabase(
    path,
    version: 1,
    onCreate: _createDB,
  );
}


Future _createDB(Database db, int version) async {
  print("Criando a tabela de fichas...");
  await db.execute('''
  CREATE TABLE fichas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    classe TEXT NOT NULL,
    raca TEXT NOT NULL,
    imagemPath TEXT NOT NULL,
    descricao TEXT,
    forca INTEGER NOT NULL,
    destreza INTEGER NOT NULL,
    constituicao INTEGER NOT NULL,
    inteligencia INTEGER NOT NULL,
    sabedoria INTEGER NOT NULL,
    carisma INTEGER NOT NULL,
    equipamentos TEXT NOT NULL
  )
  ''');
}


 Future<Ficha> create(Ficha ficha) async {
  final db = await instance.database;
  final id = await db.insert('fichas', ficha.toMap());
  print('Ficha criada com ID: $id');  // Verifica fo ID
  return ficha.copyWith(id: id);
}


    Future<Ficha?> readFicha(int id) async {
    final db = await instance.database;
    final maps = await db.query('fichas',
        columns: ['id', 'nome', 'classe', 'raca', 'imagemPath'],
        where: 'id = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Ficha.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Ficha>> readAllFichas() async {
  final db = await instance.database;
  final result = await db.query('fichas');
  print('Fichas carregadas: ${result.length}');  // Verifique o número de fichas
  return result.map((json) => Ficha.fromMap(json)).toList();
}



Future<int> update(Ficha ficha) async {
    final db = await instance.database;
    return db.update('fichas', ficha.toMap(),
        where: 'id = ?', whereArgs: [ficha.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('fichas', where: 'id = ?', whereArgs: [id]);
  }

   Future close() async {
    final db = await instance.database;
    db.close();
  }
}