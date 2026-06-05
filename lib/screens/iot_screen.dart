import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/mqtt_service.dart';
import '../widgets/iot_chart.dart';
import '../providers/alerta_provider.dart';

class IotScreen extends StatefulWidget {
  const IotScreen({super.key});

  @override
  State<IotScreen> createState() => _IotScreenState();
}

class _IotScreenState extends State<IotScreen> {
  double temperatura = 0;
  double umidade = 0;

  List<double> historico = [];

  final mqtt = MqttService();

  @override
  void initState() {
    super.initState();

    mqtt.onData = (temp, umi) {
      setState(() {
        temperatura = temp;
        umidade = umi;

        historico.add(temp);

        if (historico.length > 20) {
          historico.removeAt(0);
        }
      });

      /// 🔥 ALERTA AUTOMÁTICO
      context.read<AlertaProvider>().verificarTemperatura(temp);
    };

    mqtt.connect();
  }

  String status() {
    if (temperatura > 36) return "CRÍTICO";
    if (temperatura > 30) return "ATENÇÃO";
    return "NORMAL";
  }

  Color cor() {
    if (temperatura > 36) return Colors.red;
    if (temperatura > 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sensores'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 CARD PRINCIPAL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.black),

                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temperatura',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        '$temperatura °C',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    status(),
                    style: TextStyle(color: cor(), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 GRÁFICO REAL
            SizedBox(height: 200, child: IotChart(dados: historico)),

            const SizedBox(height: 20),

            Text(
              'Umidade: $umidade%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
