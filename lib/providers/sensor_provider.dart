import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../providers/alerta_provider.dart';

class SensorProvider with ChangeNotifier {
  double _temperatura = 0;
  double _umidade = 0;
  List<double> _historico = [];
  bool _conectado = false;

  final MqttService _mqtt = MqttService();

  double get temperatura => _temperatura;
  double get umidade => _umidade;
  List<double> get historico => List.unmodifiable(_historico);
  bool get conectado => _conectado;

  String get statusTemperatura {
    if (_temperatura <= 0) return '—';
    if (_temperatura > 36) return 'CRÍTICO';
    if (_temperatura > 30) return 'ATENÇÃO';
    return 'Normal';
  }

  String get statusUmidade {
    if (_umidade <= 0) return '—';
    if (_umidade > 80) return 'ALTA';
    if (_umidade < 30) return 'BAIXA';
    return 'Normal';
  }

  double get minHistorico =>
      _historico.isEmpty ? 0 : _historico.reduce((a, b) => a < b ? a : b);
  double get maxHistorico =>
      _historico.isEmpty ? 0 : _historico.reduce((a, b) => a > b ? a : b);
  double get mediaHistorico => _historico.isEmpty
      ? 0
      : _historico.reduce((a, b) => a + b) / _historico.length;

  Future<void> iniciar(AlertaProvider alertaProvider) async {
    _mqtt.onData = (temp, umi) {
      _temperatura = temp;
      _umidade = umi;
      _conectado = true;

      _historico.add(temp);
      if (_historico.length > 20) _historico.removeAt(0);

      alertaProvider.verificarTemperatura(temp);
      notifyListeners();
    };

    await _mqtt.connect();
  }

  void desconectar() {
    _mqtt.disconnect();
    _conectado = false;
    notifyListeners();
  }
}
