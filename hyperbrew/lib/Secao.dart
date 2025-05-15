import 'package:flutter/foundation.dart';

class Secao{
  int? id;
  String nome;
  String descricao;
  int mestreId;

  Secao({
    this.id,
    required this.nome,
    required this.descricao,
    required this.mestreId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'mestre_id': mestreId,
    };
  }

  factory Secao.fromMap(Map<String, dynamic> map) {
    return Secao(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      mestreId: map['mestre_id'] as int,
    );
  }

  @override
  String toString() {
    return 'Secao{id: $id, nome: $nome, descricao: $descricao, mestreId: $mestreId}';
  }
}