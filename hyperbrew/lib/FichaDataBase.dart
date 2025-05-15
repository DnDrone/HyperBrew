import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'FichaModel.dart';

class FichaDatabase {
  static final FichaDatabase instance = FichaDatabase._init();
  static Database? _database;

  // Controle de versão do banco
  static const int _dbVersion = 2; // Incrementa essa versão quando fizer mudanças no esquema

  FichaDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fichas.db');
    return _database!;
  }

 Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  print('Banco de dados localizado em: $path');

  final db = await openDatabase(
    path,
    version: _dbVersion,
    onCreate: _createDB,
    onUpgrade: _onUpgrade,
  );

  // Verifica se a tabela 'notas' existe, e cria se não existir
  await _checkAndCreateNotasTable(db);

  return db;
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

   await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fichaId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data TEXT NOT NULL,
        FOREIGN KEY (fichaId) REFERENCES fichas(id)
      )
    ''');
  }



  // Atualizar o banco conforme versões
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE fichas ADD COLUMN descricao TEXT');
    // Cria tabela de notas se ainda não existir
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fichaId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data TEXT NOT NULL,
        FOREIGN KEY(fichaId) REFERENCES fichas(id) ON DELETE CASCADE
      )
    ''');
  }
}

Future<void> _checkAndCreateNotasTable(Database db) async {
  final tableExists = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='notas'"
  );

  if (tableExists.isEmpty) {
    print('Tabela "notas" não existe. Criando...');
    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fichaId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data TEXT NOT NULL,
        FOREIGN KEY(fichaId) REFERENCES fichas(id) ON DELETE CASCADE
      )
    ''');
    print('Tabela "notas" criada com sucesso!');
  } else {
    print('Tabela "notas" já existe.');
  }
}

// CRUD DAS NOTAS
Future<int> createNota(int fichaId, Map<String, dynamic> nota) async {
  final db = await instance.database;
  return await db.insert('notas', {
    'fichaId': fichaId,
    'titulo': nota['titulo'],
    'descricao': nota['descricao'],
    'data': nota['data'],
  });
}

Future<List<Map<String, dynamic>>> readNotas(int fichaId) async {
  final db = await instance.database;
  final result = await db.query(
    'notas',
    where: 'fichaId = ?',
    whereArgs: [fichaId],
    orderBy: 'data DESC',
  );
  return result;
}

Future<int> updateNota(int id, Map<String, dynamic> nota) async {
  final db = await instance.database;
  return await db.update(
    'notas',
    {
      'titulo': nota['titulo'],
      'descricao': nota['descricao'],
      'data': nota['data'],
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteNota(int id) async {
  final db = await instance.database;
  return await db.delete('notas', where: 'id = ?', whereArgs: [id]);
}




// CRUD DA FICHA 
  Future<Ficha> create(Ficha ficha) async {
    final db = await instance.database;
    final id = await db.insert('fichas', ficha.toMap());
    print('Ficha criada com ID: $id');
    return ficha.copyWith(id: id);
  }

  Future<Ficha?> readFicha(int id) async {
    final db = await instance.database;
    final maps = await db.query('fichas',
        columns: ['id', 'nome', 'classe', 'raca', 'imagemPath', 'descricao', 'forca', 'destreza', 'constituicao', 'inteligencia', 'sabedoria', 'carisma', 'equipamentos'],
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
    print('Fichas carregadas: ${result.length}');
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
