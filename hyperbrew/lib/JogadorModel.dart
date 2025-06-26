class Jogador {
  final int? id;
  final String nome;

  Jogador({this.id, required this.nome});

  Jogador copyWith({int? id, String? nome}) {
    return Jogador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory Jogador.fromMap(Map<String, dynamic> map) {
    return Jogador(
      id: map['id'] as int?,
      nome: map['nome'] as String,
    );
  }
}
