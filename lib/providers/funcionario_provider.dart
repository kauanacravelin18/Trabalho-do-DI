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
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

    int soma = 0;
    for (int i = 0; i < 9; i++) soma += int.parse(d[i]) * (10 - i);
    int r1 = (soma * 10) % 11;
    if (r1 == 10 || r1 == 11) r1 = 0;
    if (r1 != int.parse(d[9])) return false;

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
    String? uid,
  }) async {
    if (!validarCpf(cpf)) return 'CPF inválido';
    if (!validarEmail(email)) return 'E-mail inválido';

    final cpfExiste = _funcionarios.any(
      (f) =>
          f.cpf.replaceAll(RegExp(r'[^0-9]'), '') ==
          cpf.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (cpfExiste) return 'CPF já cadastrado';

    // Verifica se UID já está vinculado a outro funcionário
    if (uid != null && uid.isNotEmpty) {
      final uidExiste = _funcionarios.any(
        (f) => f.uid?.toLowerCase() == uid.toLowerCase(),
      );
      if (uidExiste) return 'UID já vinculado a outro funcionário';
    }

    final novo = Funcionario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      telefone: telefone,
      cpf: cpf,
      email: email,
      funcao: funcao,
      obraId: obraId,
      uid: uid?.isNotEmpty == true ? uid!.toLowerCase() : null,
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
    String? uid,
  }) async {
    final original = _funcionarios.firstWhere((f) => f.id == id);

    if (cpf.replaceAll(RegExp(r'[^0-9]'), '') !=
        original.cpf.replaceAll(RegExp(r'[^0-9]'), '')) {
      if (!validarCpf(cpf)) return 'CPF inválido';
      final cpfExiste = _funcionarios.any(
        (f) =>
            f.id != id &&
            f.cpf.replaceAll(RegExp(r'[^0-9]'), '') ==
                cpf.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (cpfExiste) return 'CPF já cadastrado';
    }

    if (email != original.email) {
      if (!validarEmail(email)) return 'E-mail inválido';
    }

    // Verifica se UID já está vinculado a outro funcionário
    if (uid != null && uid.isNotEmpty) {
      final uidExiste = _funcionarios.any(
        (f) => f.id != id && f.uid?.toLowerCase() == uid.toLowerCase(),
      );
      if (uidExiste) return 'UID já vinculado a outro funcionário';
    }

    final atualizado = original.copyWith(
      nome: nome,
      telefone: telefone,
      cpf: cpf,
      email: email,
      funcao: funcao,
      obraId: obraId,
      uid: uid?.isNotEmpty == true ? uid!.toLowerCase() : null,
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

  /// Chamado quando o ESP32 manda um UID via MQTT.
  /// Retorna o nome do funcionário encontrado, ou null se não vinculado.
  Future<String?> registrarBatidaPorUid(String uid) async {
    final uidLower = uid.toLowerCase().trim();
    final index = _funcionarios.indexWhere(
      (f) => f.uid?.toLowerCase() == uidLower,
    );
    if (index == -1) return null; // UID não vinculado

    final f = _funcionarios[index];
    final novasBatidas = [...f.batidas, DateTime.now()];
    final atualizado = f.copyWith(batidas: novasBatidas);
    final batidasStr = novasBatidas.map((b) => b.toIso8601String()).join('|');
    await db.registrarBatida(f.id, batidasStr);
    _funcionarios[index] = atualizado;
    notifyListeners();
    return f.nome; // Retorna o nome para exibir no alerta/snackbar
  }

  int get totalFuncionarios => _funcionarios.length;
}
