import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  String? _nome;
  String? _email;
  String? _telefone;
  int? _userId;

  String? get nome => _nome;
  String? get email => _email;
  String? get telefone => _telefone;
  int? get userId => _userId;   // ← linha adicionada
  bool get isAuth => _email != null;

  Future<bool> register(String nome, String email, String senha) async {
    try {
      final existe = await DatabaseService.instance.buscarUsuarioPorEmail(email);
      if (existe != null) return false;
      await DatabaseService.instance.inserirUsuario({
        'nome': nome,
        'email': email,
        'senha': senha,
        'telefone': '',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String email, String senha) async {
    final usuario =
        await DatabaseService.instance.buscarUsuarioPorEmail(email);
    if (usuario == null) return false;
    if (usuario['senha'] != senha) return false;
    _nome = usuario['nome'];
    _email = usuario['email'];
    _telefone = usuario['telefone'] ?? '';
    _userId = usuario['id'];
    notifyListeners();
    return true;
  }

  Future<bool> atualizarPerfil({
    required String nome,
    required String telefone,
    String? novaSenha,
  }) async {
    if (_email == null) return false;
    final dados = <String, dynamic>{
      'nome': nome,
      'telefone': telefone,
    };
    if (novaSenha != null && novaSenha.isNotEmpty) {
      dados['senha'] = novaSenha;
    }
    final ok =
        await DatabaseService.instance.atualizarUsuario(_email!, dados);
    if (ok) {
      _nome = nome;
      _telefone = telefone;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> resetSenha(String email, String novaSenha) async {
    return await DatabaseService.instance.atualizarSenha(email, novaSenha);
  }

  void logout() {
    _nome = null;
    _email = null;
    _telefone = null;
    _userId = null;
    notifyListeners();
  }
}