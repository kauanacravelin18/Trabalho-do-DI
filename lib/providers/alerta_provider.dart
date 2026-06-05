import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../services/database_service.dart';

class AlertaProvider with ChangeNotifier {
  final db = DatabaseService.instance;

  List<Alerta> _alertas = [];

  List<Alerta> get alertas => _alertas;

  /// 🔥 CARREGAR DO BANCO
  Future<void> carregarAlertas() async {
    final data = await db.buscarAlertas();

    _alertas = data
        .map(
          (e) =>
              Alerta(mensagem: e['mensagem'], data: DateTime.parse(e['data'])),
        )
        .toList();

    notifyListeners();
  }

  /// 🔥 ADICIONAR ALERTA (SALVA NO BANCO)
  Future<void> adicionarAlerta(String mensagem) async {
    final agora = DateTime.now();

    await db.inserirAlerta({
      'mensagem': mensagem,
      'data': agora.toIso8601String(),
    });

    _alertas.insert(0, Alerta(mensagem: mensagem, data: agora));

    notifyListeners();
  }

  /// 🔥 LIMPAR ALERTAS
  Future<void> limparAlertas() async {
    await db.limparAlertasDB();

    _alertas.clear();
    notifyListeners();
  }

  /// 🔥 ALERTA AUTOMÁTICO
  void verificarTemperatura(double temp) {
    if (temp > 36) {
      adicionarAlerta("🔥 Temperatura CRÍTICA!");
    } else if (temp > 30) {
      adicionarAlerta("⚠️ Temperatura ALTA");
    }
  }
}
