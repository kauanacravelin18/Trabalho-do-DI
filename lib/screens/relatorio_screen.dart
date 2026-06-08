import 'package:flutter/material.dart';
import '../services/database_service.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  Map<String, dynamic>? _relatorio;
  List<Map<String, dynamic>> _historico = [];
  bool _carregando = true;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final rel = await DatabaseService.instance.obterRelatorioTemperatura();
    final hist = await DatabaseService.instance.buscarLeituras();
    if (mounted) {
      setState(() {
        _relatorio = rel;
        _historico = hist.take(50).toList();
        _carregando = false;
      });
    }
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
          'Relatório de Temperatura',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() => _carregando = true);
              _carregar();
            },
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: amarelo))
          : _relatorio == null
          ? const Center(
              child: Text(
                'Erro ao carregar dados.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : RefreshIndicator(
              color: amarelo,
              onRefresh: _carregar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Cards de agregação ──
                    _buildAggregationCards(),
                    const SizedBox(height: 24),

                    // ── Histórico ──
                    Row(
                      children: [
                        const Text(
                          'Últimas leituras',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: amarelo.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_historico.length}',
                            style: const TextStyle(
                              color: amarelo,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _historico.isEmpty
                        ? _buildVazio()
                        : Column(
                            children: _historico
                                .map((l) => _buildLeituraCard(l))
                                .toList(),
                          ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAggregationCards() {
    final quantidade = _relatorio!['quantidade'] ?? 0;
    final semDados = (quantidade == 0 || quantidade == '0');

    if (semDados) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.thermostat_rounded, color: Colors.white24, size: 44),
              SizedBox(height: 12),
              Text(
                'Nenhuma leitura registrada ainda.',
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 4),
              Text(
                'Abra a tela IoT para receber dados do sensor.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Total de leituras em destaque
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: amarelo,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Colors.black,
                size: 36,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total de leituras',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  Text(
                    '$quantidade',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid média / máx / mín
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'Média',
                '${(_relatorio!['media'] as num).toStringAsFixed(1)} °C',
                Icons.show_chart_rounded,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'Máxima',
                '${(_relatorio!['maximo'] as num).toStringAsFixed(1)} °C',
                Icons.arrow_upward_rounded,
                Colors.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'Mínima',
                '${(_relatorio!['minimo'] as num).toStringAsFixed(1)} °C',
                Icons.arrow_downward_rounded,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(String label, String valor, IconData icon, Color cor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cor, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeituraCard(Map<String, dynamic> leitura) {
    final temp = (leitura['temperatura'] as num).toDouble();
    final umi = (leitura['umidade'] as num).toDouble();
    final dataHora = leitura['dataHora'] as String;
    DateTime? dt;
    try {
      dt = DateTime.parse(dataHora);
    } catch (_) {}

    Color tempCor = Colors.green;
    if (temp > 36)
      tempCor = Colors.red;
    else if (temp > 30)
      tempCor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tempCor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.thermostat_rounded, color: tempCor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dt != null)
                  Text(
                    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
                    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${temp.toStringAsFixed(1)} °C',
                      style: TextStyle(
                        color: tempCor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blue,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${umi.toStringAsFixed(1)} %',
                      style: const TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVazio() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Nenhum registro encontrado.',
          style: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}
