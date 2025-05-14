class Ficha {
  int? id;
  String nome;
  String classe;
  String raca;
  String imagemPath;  // Usando String para caminho de imagem
  String? descricao;
  int forca;
  int destreza;
  int constituicao;
  int inteligencia;
  int sabedoria;
  int carisma;
  List<String> equipamentos;  // Lista de equipamentos como Strings

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

  // Método para criar uma cópia de Ficha com alterações em campos opcionais
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
      equipamentos: equipamentos ?? List.from(this.equipamentos),
    );
  }

  // Converte a ficha para um mapa para uso em banco de dados ou armazenamento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'classe': classe,
      'raca': raca,
      'imagemPath': imagemPath,  // Aqui o caminho da imagem
      'descricao': descricao,
      'forca': forca,
      'destreza': destreza,
      'constituicao': constituicao,
      'inteligencia': inteligencia,
      'sabedoria': sabedoria,
      'carisma': carisma,
      'equipamentos': equipamentos.join(','), // Equipamentos como string separada por vírgula
    };
  }

  // Construtor de fábrica para criar uma instância de Ficha a partir de um mapa
  factory Ficha.fromMap(Map<String, dynamic> map) {
    return Ficha(
      id: map['id'] as int?,
      nome: map['nome'] ?? '',
      classe: map['classe'] ?? '',
      raca: map['raca'] ?? '',
      imagemPath: map['imagemPath'] ?? '',  // Caminho da imagem
      descricao: map['descricao'],
      forca: map['forca'] is int ? map['forca'] : int.tryParse(map['forca'].toString()) ?? 0,
      destreza: map['destreza'] is int ? map['destreza'] : int.tryParse(map['destreza'].toString()) ?? 0,
      constituicao: map['constituicao'] is int ? map['constituicao'] : int.tryParse(map['constituicao'].toString()) ?? 0,
      inteligencia: map['inteligencia'] is int ? map['inteligencia'] : int.tryParse(map['inteligencia'].toString()) ?? 0,
      sabedoria: map['sabedoria'] is int ? map['sabedoria'] : int.tryParse(map['sabedoria'].toString()) ?? 0,
      carisma: map['carisma'] is int ? map['carisma'] : int.tryParse(map['carisma'].toString()) ?? 0,
      equipamentos: (map['equipamentos'] as String?)?.split(',').where((e) => e.trim().isNotEmpty).toList() ?? [],
    );
  }
}
