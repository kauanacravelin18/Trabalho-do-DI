import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  String? _nome;
  String? _email;

  String? get nome => _nome;

  bool get isAuth => _email != null;

  Future<bool> register(String nome, String email, String senha) async {
    try {
      final usuario = await DatabaseService.instance.buscarUsuarioPorEmail(
        email,
      );

      if (usuario != null) {
        return false;
      }

      await DatabaseService.instance.inserirUsuario({
        'nome': nome,
        'email': email,
        'senha': senha,
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String email, String senha) async {
    final usuario = await DatabaseService.instance.buscarUsuarioPorEmail(email);

    if (usuario == null) {
      return false;
    }

    if (usuario['senha'] != senha) {
      return false;
    }

    _nome = usuario['nome'];
    _email = usuario['email'];

    notifyListeners();

    return true;
  }

  Future<bool> resetSenha(String email, String novaSenha) async {
    return await DatabaseService.instance.atualizarSenha(email, novaSenha);
  }

  void logout() {
    _nome = null;
    _email = null;
    notifyListeners();
  }
}
