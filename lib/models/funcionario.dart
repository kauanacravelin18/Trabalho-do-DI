class Funcionario {
  final String id;
  final String nome;
  final String telefone;
  final String cpf;
  final String email;
  final String funcao;
  final String? obraId;
  final String? uid; // UID do cartão RFID
  final List<DateTime> batidas;

  Funcionario({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.cpf,
    required this.email,
    required this.funcao,
    this.obraId,
    this.uid,
    List<DateTime>? batidas,
  }) : batidas = batidas ?? [];

  Funcionario copyWith({
    String? nome,
    String? telefone,
    String? cpf,
    String? email,
    String? funcao,
    String? obraId,
    String? uid,
    List<DateTime>? batidas,
  }) {
    return Funcionario(
      id: id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      funcao: funcao ?? this.funcao,
      obraId: obraId ?? this.obraId,
      uid: uid ?? this.uid,
      batidas: batidas ?? this.batidas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'cpf': cpf,
      'email': email,
      'funcao': funcao,
      'obraId': obraId,
      'uid': uid,
      'batidas': batidas.map((b) => b.toIso8601String()).join('|'),
    };
  }

  factory Funcionario.fromMap(Map<String, dynamic> map) {
    final batidasRaw = (map['batidas'] as String?) ?? '';
    final batidas = batidasRaw.isEmpty
        ? <DateTime>[]
        : batidasRaw
              .split('|')
              .where((s) => s.isNotEmpty)
              .map((s) => DateTime.parse(s))
              .toList();
    return Funcionario(
      id: map['id'].toString(),
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      cpf: map['cpf'] ?? '',
      email: map['email'] ?? '',
      funcao: map['funcao'] ?? '',
      obraId: map['obraId']?.toString(),
      uid: map['uid']?.toString(),
      batidas: batidas,
    );
  }
}
