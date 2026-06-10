class Obra {
  final String id;
  final String nome;
  final String endereco;
  final String responsavel;
  final bool concluida;

  Obra({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.responsavel,
    this.concluida = false,
  });

  factory Obra.fromMap(Map<String, dynamic> map) {
    return Obra(
      id: map['id'].toString(),
      nome: map['nome'] ?? '',
      endereco: map['endereco'] ?? '',
      responsavel: map['responsavel'] ?? '',
      concluida: (map['concluida'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'responsavel': responsavel,
      'concluida': concluida ? 1 : 0,
    };
  }

  Obra copyWith({
    String? nome,
    String? endereco,
    String? responsavel,
    bool? concluida,
  }) {
    return Obra(
      id: id,
      nome: nome ?? this.nome,
      endereco: endereco ?? this.endereco,
      responsavel: responsavel ?? this.responsavel,
      concluida: concluida ?? this.concluida,
    );
  }
}
