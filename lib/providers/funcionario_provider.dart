import 'package:flutter/material.dart';
import '../models/funcionario.dart';

class FuncionarioProvider with ChangeNotifier {
  final List<Funcionario> _funcionarios = [];

  List<Funcionario> get funcionarios => _funcionarios;

  void adicionarFuncionario(String nome, String funcao, String? obraId) {
    _funcionarios.add(
      Funcionario(
        id: DateTime.now().toString(),
        nome: nome,
        funcao: funcao,
        obraId: obraId,
      ),
    );
    notifyListeners();
  }

  void removerFuncionario(String id) {
    _funcionarios.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  int totalFuncionarios() {
    return _funcionarios.length;
  }
}