import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/funcionario_provider.dart';
import '../providers/obra_provider.dart';

class CartaoPontoScreen extends StatefulWidget {
  final String funcionarioId;
  const CartaoPontoScreen({super.key, required this.funcionarioId});

  @override
  State<CartaoPontoScreen> createState() => _CartaoPontoScreenState();
}

class _CartaoPontoScreenState extends State<CartaoPontoScreen> {
  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  List<String> _feriados = [];
  bool _carregandoFeriados = true;

  @override
  void initState() {
    super.initState();
    _carregarFeriados();
  }

  Future<void> _carregarFeriados() async {
    try {
      final url = Uri.parse(
          'https://api.invertexto.com/v1/holidays/2026?token=API-DI&state=PR');
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _feriados = data.map((e) => e['date'].toString()).toList();
          _carregandoFeriados = false;
        });
      } else {
        setState(() => _carregandoFeriados = false);
      }
    } catch (_) {
      setState(() => _carregandoFeriados = false);
    }
  }

  bool _ehFeriado(DateTime data) {
    final str =
        '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    return _feriados.contains(str);
  }

  bool _ehFimDeSemana(DateTime data) {
    return data.weekday == DateTime.saturday ||
        data.weekday == DateTime.sunday;
  }

  String _tipoEntrada(int index) {
    if (index % 4 == 0) return 'Entrada';
    if (index % 4 == 1) return 'Saída Almoço';
    if (index % 4 == 2) return 'Retorno Almoço';
    return 'Saída';
  }

  // Agrupa batidas por dia
  Map<String, List<DateTime>> _agruparPorDia(List<DateTime> batidas) {
    final Map<String, List<DateTime>> mapa = {};
    for (final b in batidas) {
      final chave =
          '${b.day.toString().padLeft(2, '0')}/${b.month.toString().padLeft(2, '0')}/${b.year}';
      mapa.putIfAbsent(chave, () => []).add(b);
    }
    return mapa;
  }

  // Calcula horas trabalhadas no dia
  String _calcularHoras(List<DateTime> batidas) {
    if (batidas.length < 2) return '--';
    Duration total = Duration.zero;
    final sorted = [...batidas]..sort((a, b) => a.compareTo(b));
    for (int i = 0; i + 1 < sorted.length; i += 2) {
      total += sorted[i + 1].difference(sorted[i]);
    }
    final h = total.inHours;
    final m = total.inMinutes % 60;
    return '${h}h${m.toString().padLeft(2, '0')}min';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FuncionarioProvider>();
    final obras = context.watch<ObraProvider>().obras;

    final f = provider.funcionarios.firstWhere(
      (f) => f.id == widget.funcionarioId,
      orElse: () => provider.funcionarios.first,
    );

    final nomeObra = f.obraId != null && obras.isNotEmpty
        ? obras
            .firstWhere((o) => o.id == f.obraId,
                orElse: () => obras.first)
            .nome
        : 'Não vinculado';

    final grupos = _agruparPorDia(f.batidas);
    final dias = grupos.keys.toList().reversed.toList();

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cartão Ponto',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _carregandoFeriados
          ? const Center(
              child: CircularProgressIndicator(color: amarelo))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card funcionário
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: amarelo,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.black.withOpacity(0.2),
                          child: Text(
                            f.nome[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.nome,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              Text(f.funcao,
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 13)),
                              Text('📍 $nomeObra',
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Resumo
                  Row(
                    children: [
                      Expanded(
                          child: _resumoCard(
                              'Total Batidas',
                              '${f.batidas.length}',
                              Icons.fingerprint_rounded)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _resumoCard(
                              'Dias registrados',
                              '${grupos.length}',
                              Icons.calendar_today_rounded)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text('Registros por dia',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  f.batidas.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    color: Colors.white24, size: 40),
                                SizedBox(height: 8),
                                Text('Nenhuma batida registrada',
                                    style:
                                        TextStyle(color: Colors.white38)),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: dias.map((dia) {
                            final batidasDia = grupos[dia]!
                              ..sort((a, b) => a.compareTo(b));
                            final dataRef = batidasDia.first;
                            final feriado = _ehFeriado(dataRef);
                            final fds = _ehFimDeSemana(dataRef);
                            final horas = _calcularHoras(batidasDia);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: feriado
                                      ? Colors.purple.withOpacity(0.5)
                                      : fds
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.white10,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Header do dia
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: feriado
                                          ? Colors.purple.withOpacity(0.2)
                                          : fds
                                              ? Colors.blue
                                                  .withOpacity(0.1)
                                              : Colors.white
                                                  .withOpacity(0.04),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(14)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.calendar_today_rounded,
                                            color: amarelo,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        Text(dia,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        if (feriado)
                                          _badge('Feriado', Colors.purple),
                                        if (fds && !feriado)
                                          _badge('Fim de semana', Colors.blue),
                                        const Spacer(),
                                        Text(horas,
                                            style: const TextStyle(
                                                color: amarelo,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),

                                  // Batidas do dia
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children:
                                          batidasDia.asMap().entries.map((e) {
                                        final hora =
                                            '${e.value.hour.toString().padLeft(2, '0')}:${e.value.minute.toString().padLeft(2, '0')}';
                                        final tipo =
                                            _tipoEntrada(e.key);
                                        final isEntrada =
                                            tipo == 'Entrada' ||
                                                tipo == 'Retorno Almoço';

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 6),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isEntrada
                                                    ? Icons
                                                        .login_rounded
                                                    : Icons
                                                        .logout_rounded,
                                                color: isEntrada
                                                    ? Colors.green
                                                    : Colors.orange,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(tipo,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 13)),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isEntrada
                                                      ? Colors.green
                                                          .withOpacity(0.15)
                                                      : Colors.orange
                                                          .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text(
                                                  hora,
                                                  style: TextStyle(
                                                    color: isEntrada
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _resumoCard(String label, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: amarelo, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(valor,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: cor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cor.withOpacity(0.4))),
      child:
          Text(texto, style: TextStyle(color: cor, fontSize: 10)),
    );
  }
}