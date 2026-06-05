class Funcionario {
  final String id;
  final String nome;
  final String funcao;
  final String? obraId;

  Funcionario({
    required this.id,
    required this.nome,
    required this.funcao,
    this.obraId,
  });
}