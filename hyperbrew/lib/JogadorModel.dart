class Jogador {
  final int? id;
  final String nome;
  final String email;

  Jogador({
    this.id,
    required this.nome,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }

  factory Jogador.fromMap(Map<String, dynamic> map) {
    return Jogador(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
    );
  }

  Jogador copyWith({
    int? id,
    String? nome,
    String? email,
  }) {
    return Jogador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
    );
  }
}
