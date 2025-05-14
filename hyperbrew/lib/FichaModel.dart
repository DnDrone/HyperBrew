class Ficha {
  final int? id;
  final String nome;
  final String classe;
  final String raca;
  final String imagemPath;
  final String? descricao;
  final int forca;
  final int destreza;
  final int constituicao;
  final int inteligencia;
  final int sabedoria;
  final int carisma;
  final List<String> equipamentos;

  Ficha({
    this.id,
    required this.nome,
    required this.classe,
    required this.raca,
    required this.imagemPath,
    this.descricao,
    required this.forca,
    required this.destreza,
    required this.constituicao,
    required this.inteligencia,
    required this.sabedoria,
    required this.carisma,
    required this.equipamentos,
  });

  Ficha copyWith({
    int? id,
    String? nome,
    String? classe,
    String? raca,
    String? imagemPath,
    String? descricao,
    int? forca,
    int? destreza,
    int? constituicao,
    int? inteligencia,
    int? sabedoria,
    int? carisma,
    List<String>? equipamentos,
  }) {
    return Ficha(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      classe: classe ?? this.classe,
      raca: raca ?? this.raca,
      imagemPath: imagemPath ?? this.imagemPath,
      descricao: descricao ?? this.descricao,
      forca: forca ?? this.forca,
      destreza: destreza ?? this.destreza,
      constituicao: constituicao ?? this.constituicao,
      inteligencia: inteligencia ?? this.inteligencia,
      sabedoria: sabedoria ?? this.sabedoria,
      carisma: carisma ?? this.carisma,
      equipamentos: equipamentos ?? this.equipamentos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'classe': classe,
      'raca': raca,
      'imagemPath': imagemPath,
      'descricao': descricao,
      'forca': forca,
      'destreza': destreza,
      'constituicao': constituicao,
      'inteligencia': inteligencia,
      'sabedoria': sabedoria,
      'carisma': carisma,
      'equipamentos': equipamentos.join(','), // salva como string separada por vírgula
    };
  }

  factory Ficha.fromMap(Map<String, dynamic> map) {
    return Ficha(
      id: map['id'] as int?,
      nome: map['nome'] ?? '',
      classe: map['classe'] ?? '',
      raca: map['raca'] ?? '',
      imagemPath: map['imagemPath'] ?? '',
      descricao: map['descricao'],
      forca: map['forca'] ?? 0,
      destreza: map['destreza'] ?? 0,
      constituicao: map['constituicao'] ?? 0,
      inteligencia: map['inteligencia'] ?? 0,
      sabedoria: map['sabedoria'] ?? 0,
      carisma: map['carisma'] ?? 0,
      equipamentos: (map['equipamentos'] as String?)?.split(',') ?? [],
    );
  }

  set name(String name) {
    this.name = name;
  }
  set classe(String className) {
    this.classe = className;
  }

  set raca(String raceName) {
    this.raca = raceName;
  }

  set imagemPath(String path) {
    this.imagemPath = path;
  }
}