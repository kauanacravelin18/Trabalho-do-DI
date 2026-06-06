import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final client = MqttServerClient('broker.hivemq.com', 'obratech_app');

  // Callback: dados de temperatura e umidade do ESP32
  Function(double temp, double umi)? onData;

  // Callback: batida de ponto via RFID (recebe o ID do funcionário)
  Function(String funcionarioId)? onBatidaPonto;

  Future<void> connect() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    client.logging(on: false);

    try {
      await client.connect();
    } catch (_) {
      return;
    }

    // Tópico temperatura
    client.subscribe('obra/temperatura', MqttQos.atLeastOnce);
    // Tópico ponto RFID
    client.subscribe('obra/ponto', MqttQos.atLeastOnce);

    client.updates!.listen((event) {
      final msg = event[0];
      final payload = MqttPublishPayload.bytesToStringAsString(
        (msg.payload as MqttPublishMessage).payload.message,
      );
      final topico = msg.topic;

      if (topico == 'obra/temperatura') {
        final parts = payload.trim().split(',');
        final temp = parts.isNotEmpty ? double.tryParse(parts[0]) : null;
        final umi = parts.length > 1 ? double.tryParse(parts[1]) : null;
        if (temp != null && umi != null && onData != null) {
          onData!(temp, umi);
        }
      }

      if (topico == 'obra/ponto') {
        if (onBatidaPonto != null) {
          onBatidaPonto!(payload.trim());
        }
      }
    });
  }

  void disconnect() {
    client.disconnect();
  }
}