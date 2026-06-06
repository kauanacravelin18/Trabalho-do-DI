import 'package:flutter/material.dart';
import '../models/obra.dart';
import '../services/database_service.dart';

class ObraProvider with ChangeNotifier {
  final db = DatabaseService.instance;
  List<Obra> _obras = [];

  List<Obra> get obras => _obras;

  Future<void> carregarObras() async {
    final data = await db.buscarObras();
    _obras = data.map((e) => Obra.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> adicionarObra(
      String nome, String endereco, String responsavel) async {
    final id = await db.inserirObra({
      'nome': nome,
      'endereco': endereco,
      'responsavel': responsavel,
    });
    _obras.add(Obra(
      id: id.toString(),
      nome: nome,
      endereco: endereco,
      responsavel: responsavel,
    ));
    notifyListeners();
  }

  Future<void> editarObra(
      String id, String nome, String endereco, String responsavel) async {
    await db.atualizarObra({
      'id': int.parse(id),
      'nome': nome,
      'endereco': endereco,
      'responsavel': responsavel,
    });
    final index = _obras.indexWhere((o) => o.id == id);
    if (index != -1) {
      _obras[index] =
          _obras[index].copyWith(nome: nome, endereco: endereco, responsavel: responsavel);
      notifyListeners();
    }
  }

  Future<void> removerObra(String id) async {
    await db.deletarObra(int.parse(id));
    _obras.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}