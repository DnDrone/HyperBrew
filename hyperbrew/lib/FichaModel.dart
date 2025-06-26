class Ficha {
  int? id;
  String nome;
  String classe;
  String raca;
  String imagemPath;
  String? descricao;
  int forca;
  int destreza;
  int constituicao;
  int inteligencia;
  int sabedoria;
  int carisma;
  List<String> equipamentos;
  String? userId; // Adicionado: ID do usuário proprietário da ficha

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
    this.userId, // Adicionado ao construtor
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
    String? userId, // Adicionado ao copyWith
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
      equipamentos: equipamentos ?? List.from(this.equipamentos),
      userId: userId ?? this.userId, // Adicionado ao copyWith
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
      'equipamentos': equipamentos.join(','),
      'userId': userId, // Adicionado ao toMap
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
      forca: map['forca'] is int ? map['forca'] : int.tryParse(map['forca'].toString()) ?? 0,
      destreza: map['destreza'] is int ? map['destreza'] : int.tryParse(map['destreza'].toString()) ?? 0,
      constituicao: map['constituicao'] is int ? map['constituicao'] : int.tryParse(map['constituicao'].toString()) ?? 0,
      inteligencia: map['inteligencia'] is int ? map['inteligencia'] : int.tryParse(map['inteligencia'].toString()) ?? 0,
      sabedoria: map['sabedoria'] is int ? map['sabedoria'] : int.tryParse(map['sabedoria'].toString()) ?? 0,
      carisma: map['carisma'] is int ? map['carisma'] : int.tryParse(map['carisma'].toString()) ?? 0,
      equipamentos: (map['equipamentos'] as String?)?.split(',').where((e) => e.trim().isNotEmpty).toList() ?? [],
      userId: map['userId'] as String?, // Adicionado ao fromMap
    );
  }
}
