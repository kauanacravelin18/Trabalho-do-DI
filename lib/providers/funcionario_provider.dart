import 'package:flutter/material.dart';
import '../models/funcionario.dart';
import '../services/database_service.dart';

class FuncionarioProvider with ChangeNotifier {
  final db = DatabaseService.instance;
  List<Funcionario> _funcionarios = [];

  List<Funcionario> get funcionarios => _funcionarios;

  Future<void> carregarFuncionarios() async {
    final data = await db.buscarFuncionarios();
    _funcionarios = data.map((e) => Funcionario.fromMap(e)).toList();
    notifyListeners();
  }

  bool validarEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  bool validarCpf(String cpf) {
    final d = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 11) return false;
    // Rejeita CPFs com todos os dígitos iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

    // Primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) soma += int.parse(d[i]) * (10 - i);
    int r1 = (soma * 10) % 11;
    if (r1 == 10 || r1 == 11) r1 = 0;
    if (r1 != int.parse(d[9])) return false;

    // Segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) soma += int.parse(d[i]) * (11 - i);
    int r2 = (soma * 10) % 11;
    if (r2 == 10 || r2 == 11) r2 = 0;
    if (r2 != int.parse(d[10])) return false;

    return true;
  }

  Future<String?> adicionarFuncionario({
    required String nome,
    required String telefone,
    required String cpf,
    required String email,
    required String funcao,
    String? obraId,
  }) async {
    if (!validarCpf(cpf)) return 'CPF inválido';
    if (!validarEmail(email)) return 'E-mail inválido';

    final cpfExiste = _funcionarios.any((f) =>
        f.cpf.replaceAll(RegExp(r'[^0-9]'), '') ==
        cpf.replaceAll(RegExp(r'[^0-9]'), ''));
    if (cpfExiste) return 'CPF já cadastrado';

    final novo = Funcionario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      telefone: telefone,
      cpf: cpf,
      email: email,
      funcao: funcao,
      obraId: obraId,
    );

    await db.inserirFuncionario(novo.toMap());
    _funcionarios.add(novo);
    notifyListeners();
    return null;
  }

  Future<String?> editarFuncionario({
    required String id,
    required String nome,
    required String telefone,
    required String cpf,
    required String email,
    required String funcao,
    String? obraId,
  }) async {
    final original = _funcionarios.firstWhere((f) => f.id == id);

    if (cpf.replaceAll(RegExp(r'[^0-9]'), '') !=
        original.cpf.replaceAll(RegExp(r'[^0-9]'), '')) {
      if (!validarCpf(cpf)) return 'CPF inválido';
      final cpfExiste = _funcionarios.any((f) =>
          f.id != id &&
          f.cpf.replaceAll(RegExp(r'[^0-9]'), '') ==
              cpf.replaceAll(RegExp(r'[^0-9]'), ''));
      if (cpfExiste) return 'CPF já cadastrado';
    }

    if (email != original.email) {
      if (!validarEmail(email)) return 'E-mail inválido';
    }

    final atualizado = original.copyWith(
      nome: nome,
      telefone: telefone,
      cpf: cpf,
      email: email,
      funcao: funcao,
      obraId: obraId,
    );

    await db.atualizarFuncionario(atualizado.toMap());
    final index = _funcionarios.indexWhere((f) => f.id == id);
    _funcionarios[index] = atualizado;
    notifyListeners();
    return null;
  }

  Future<void> removerFuncionario(String id) async {
    await db.deletarFuncionario(id);
    _funcionarios.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  Future<void> registrarBatida(String funcionarioId) async {
    final index = _funcionarios.indexWhere((f) => f.id == funcionarioId);
    if (index == -1) return;
    final f = _funcionarios[index];
    final novasBatidas = [...f.batidas, DateTime.now()];
    final atualizado = f.copyWith(batidas: novasBatidas);
    final batidasStr = novasBatidas.map((b) => b.toIso8601String()).join('|');
    await db.registrarBatida(funcionarioId, batidasStr);
    _funcionarios[index] = atualizado;
    notifyListeners();
  }

  int get totalFuncionarios => _funcionarios.length;
}