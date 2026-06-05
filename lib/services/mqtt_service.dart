import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final client = MqttServerClient('broker.hivemq.com', '');

  Function(double temp, double umi)? onData;

  Future<void> connect() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.connect();

    client.subscribe('obra/sensores', MqttQos.atLeastOnce);

    client.updates!.listen((event) {
      final recMess = event[0].payload as MqttPublishMessage;

      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      final dados = payload.split(',');

      double temp = double.parse(dados[0]);
      double umi = double.parse(dados[1]);

      if (onData != null) {
        onData!(temp, umi);
      }
    });
  }
}
