import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
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
  bool conectado = false;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    mqtt.onData = (temp, umi) {
      setState(() {
        temperatura = temp;
        umidade = umi;
        historico.add(temp);
        if (historico.length > 20) historico.removeAt(0);
        conectado = true;
      });
      context.read<AlertaProvider>().verificarTemperatura(temp);
    };
    mqtt.connect();
  }

  String get _status {
    if (temperatura > 36) return 'CRÍTICO';
    if (temperatura > 30) return 'ATENÇÃO';
    return 'NORMAL';
  }

  Color get _statusColor {
    if (temperatura > 36) return Colors.red;
    if (temperatura > 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'IoT – Sensores',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: conectado
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: conectado ? Colors.green : Colors.red),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: conectado ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  conectado ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: conectado ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card temperatura
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: amarelo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    color: Colors.black,
                    size: 44,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temperatura Atual',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        '${temperatura.toStringAsFixed(1)} °C',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            _status,
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card umidade
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Umidade',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        '${umidade.toStringAsFixed(1)} %',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    umidade > 80
                        ? 'ALTA'
                        : umidade < 30
                        ? 'BAIXA'
                        : 'NORMAL',
                    style: TextStyle(
                      color: umidade > 80 || umidade < 30
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Histórico de Temperatura',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 170,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: historico.isEmpty
                  ? const Center(
                      child: Text(
                        'Aguardando dados do sensor...',
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : CustomPaint(painter: _LiveChartPainter(historico)),
            ),

            const SizedBox(height: 22),

            // Alertas automáticos
            const Text(
              'Regras de Alerta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _regraAlerta(
              Icons.thermostat_rounded,
              'Temperatura > 36°C',
              'Alerta CRÍTICO disparado',
              Colors.red,
            ),
            const SizedBox(height: 8),
            _regraAlerta(
              Icons.thermostat_outlined,
              'Temperatura > 30°C',
              'Alerta de ATENÇÃO disparado',
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _regraAlerta(
              Icons.water_drop_rounded,
              'Umidade > 80%',
              'Alerta de umidade alta',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _regraAlerta(
    IconData icon,
    String titulo,
    String descricao,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                descricao,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveChartPainter extends CustomPainter {
  final List<double> dados;
  _LiveChartPainter(this.dados);

  @override
  void paint(Canvas canvas, Size size) {
    if (dados.length < 2) return;

    final min = dados.reduce((a, b) => a < b ? a : b) - 2;
    final max = dados.reduce((a, b) => a > b ? a : b) + 2;
    final range = max - min;
    final h = size.height - 16;

    final linePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFFFC107).withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fill = Path();

    for (int i = 0; i < dados.length; i++) {
      final x = (i / (dados.length - 1)) * size.width;
      final y = h - ((dados[i] - min) / range) * h;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, h);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, h);
    fill.close();

    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(path, linePaint);

    // Ponto atual com label
    final lx = size.width;
    final ly = h - ((dados.last - min) / range) * h;
    canvas.drawCircle(
      Offset(lx, ly),
      5,
      Paint()..color = const Color(0xFFFFC107),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${dados.last.toStringAsFixed(1)} °C',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(lx - tp.width - 8, ly - 16));
  }

  @override
  bool shouldRepaint(covariant _LiveChartPainter old) => old.dados != dados;
}
