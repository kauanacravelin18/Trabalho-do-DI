class Obra {
  final String id;
  final String nome;
  final String endereco;
  final String responsavel;

  Obra({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.responsavel,
  });

  factory Obra.fromMap(Map<String, dynamic> map) {
    return Obra(
      id: map['id'].toString(),
      nome: map['nome'] ?? '',
      endereco: map['endereco'] ?? '',
      responsavel: map['responsavel'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'responsavel': responsavel,
    };
  }

  Obra copyWith({
    String? nome,
    String? endereco,
    String? responsavel,
  }) {
    return Obra(
      id: id,
      nome: nome ?? this.nome,
      endereco: endereco ?? this.endereco,
      responsavel: responsavel ?? this.responsavel,
    );
  }
}