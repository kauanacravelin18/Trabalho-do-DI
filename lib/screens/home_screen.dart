import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/obra_provider.dart';
import '../providers/funcionario_provider.dart';
import '../providers/alerta_provider.dart';
import '../providers/sensor_provider.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObraProvider>().carregarObras();
      context.read<FuncionarioProvider>().carregarFuncionarios();
      context.read<AlertaProvider>().carregarAlertas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nome = context.watch<AuthProvider>().nome ?? 'Usuário';
    final obras = context.watch<ObraProvider>().obras;
    final obraAtual = obras.isNotEmpty ? obras.first : null;

    final List<Widget> telas = [
      _buildDashboard(nome, obraAtual),
      _buildObrasTab(),
      _buildSensoresTab(),
      _buildAlertasTab(),
      _buildFuncionariosTab(),
      _buildPerfilTab(context, nome),
    ];

    return Scaffold(
      backgroundColor: fundo,
      body: telas[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── BOTTOM NAV (6 itens) ──
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      backgroundColor: Colors.black,
      selectedItemColor: amarelo,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.domain_rounded),
          label: 'Obras',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sensors_rounded),
          label: 'Sensores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_rounded),
          label: 'Funcionários',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  // ──────────────── DASHBOARD ────────────────
  Widget _buildDashboard(String nome, dynamic obraAtual) {
    final alertas = context.watch<AlertaProvider>().alertas;
    final funcionarios = context.watch<FuncionarioProvider>().funcionarios;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu_rounded, color: Colors.white),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    if (alertas.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Olá, ${nome.toUpperCase()}!\n',
                    style: const TextStyle(
                      color: amarelo,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: 'Aqui está o resumo da sua obra.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card obra clicável
            GestureDetector(
              onTap: obraAtual != null
                  ? () => Navigator.pushNamed(
                      context,
                      AppRoutes.detalheObra,
                      arguments: obraAtual.id,
                    )
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: amarelo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Obra Atual',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            obraAtual != null
                                ? obraAtual.nome
                                : 'Nenhuma obra cadastrada',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (obraAtual != null)
                            Text(
                              obraAtual.endereco,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Stats rápidos
            Row(
              children: [
                Expanded(
                  child: _statQuick(
                    'Funcionários',
                    '${funcionarios.length}',
                    Icons.people_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statQuick(
                    'Alertas',
                    '${alertas.length}',
                    Icons.notifications_rounded,
                    cor: alertas.isNotEmpty ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Sensor temperatura
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sensor de Temperatura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: const Text(
                    'Ver mais',
                    style: TextStyle(color: amarelo, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: amarelo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.thermostat_rounded,
                      color: amarelo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temperatura',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        '28.6 °C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Normal',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Atividades Recentes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            alertas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Nenhuma atividade recente',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: alertas.take(3).map((a) {
                      final critico =
                          a.mensagem.contains('CRÍTICO') ||
                          a.mensagem.contains('🔥');
                      final hora =
                          '${a.data.hour.toString().padLeft(2, '0')}:${a.data.minute.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _atividadeItem(
                          icon: critico
                              ? Icons.local_fire_department_rounded
                              : Icons.thermostat_rounded,
                          iconBg: critico ? Colors.red.shade700 : Colors.orange,
                          titulo: a.mensagem,
                          descricao: 'Sensor de temperatura',
                          hora: hora,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statQuick(
    String label,
    String valor,
    IconData icon, {
    Color cor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: amarelo, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                valor,
                style: TextStyle(
                  color: cor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _atividadeItem({
    required IconData icon,
    required Color iconBg,
    required String titulo,
    required String descricao,
    required String hora,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  descricao,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            hora,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ──────────────── OBRAS ────────────────
  Widget _buildObrasTab() {
    final obras = context.watch<ObraProvider>().obras;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Obras',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addObra,
                  ).then((_) => context.read<ObraProvider>().carregarObras()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: amarelo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Nova obra',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          obras.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.domain_disabled_rounded,
                          color: Colors.white24,
                          size: 64,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Nenhuma obra cadastrada',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: obras.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final o = obras[i];
                      return GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(
                              context,
                              AppRoutes.detalheObra,
                              arguments: o.id,
                            ).then(
                              (_) =>
                                  context.read<ObraProvider>().carregarObras(),
                            ),
                        child: Container(
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
                                  color: amarelo.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  color: amarelo,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      o.endereco,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Resp.: ${o.responsavel}',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // ──────────────── SENSORES ────────────────
  Widget _buildSensoresTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor de Temperatura',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dados enviados via ESP32 + MQTT',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),

            const SizedBox(height: 16),

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temperatura Atual',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        '28.6 °C',
                        style: TextStyle(
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
                          const Text(
                            'Normal',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
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

            const SizedBox(height: 20),

            const Text(
              'Histórico - Últimas 24 horas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 160,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: CustomPaint(painter: _TempChartPainter()),
            ),

            const SizedBox(height: 20),

            const Text(
              'Estatísticas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _statCard('Mínima', '22.1 °C')),
                const SizedBox(width: 10),
                Expanded(child: _statCard('Máxima', '33.8 °C')),
                const SizedBox(width: 10),
                Expanded(child: _statCard('Média', '27.4 °C')),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.developer_board_rounded, color: amarelo, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESP32 via MQTT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Tópico: obra/temperatura • Broker: HiveMQ',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String valor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── ALERTAS ────────────────
  Widget _buildAlertasTab() {
    final provider = context.watch<AlertaProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Alertas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Botão Relatório
                GestureDetector(
                  onTap: () => _abrirRelatorio(provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: amarelo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: amarelo.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: amarelo, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Relatório',
                          style: TextStyle(
                            color: amarelo,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (provider.alertas.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmarLimparAlertas(provider),
                    child: const Text(
                      'Limpar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            provider.alertas.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.notifications_off_rounded,
                            color: Colors.white24,
                            size: 64,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhum alerta registrado',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                      itemCount: provider.alertas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final a = provider.alertas[i];
                        final critico =
                            a.mensagem.contains('CRÍTICO') ||
                            a.mensagem.contains('🔥');
                        final atencao =
                            a.mensagem.contains('⚠️') ||
                            a.mensagem.contains('ALTA') ||
                            a.mensagem.contains('ponto');
                        final cor = critico
                            ? Colors.red
                            : atencao
                            ? Colors.orange
                            : Colors.green;
                        final icon = a.mensagem.contains('ponto')
                            ? Icons.fingerprint_rounded
                            : critico
                            ? Icons.local_fire_department_rounded
                            : atencao
                            ? Icons.warning_rounded
                            : Icons.check_circle_rounded;

                        final hora =
                            '${a.data.hour.toString().padLeft(2, '0')}:${a.data.minute.toString().padLeft(2, '0')}';
                        final data =
                            '${a.data.day.toString().padLeft(2, '0')}/${a.data.month.toString().padLeft(2, '0')}';

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
                              Expanded(
                                child: Text(
                                  a.mensagem,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    hora,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    data,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _abrirRelatorio(AlertaProvider provider) {
    final alertas = provider.alertas;
    final total = alertas.length;
    final criticos = alertas
        .where(
          (a) => a.mensagem.contains('CRÍTICO') || a.mensagem.contains('🔥'),
        )
        .length;
    final atencao = alertas
        .where(
          (a) =>
              a.mensagem.contains('⚠️') ||
              a.mensagem.contains('ALTA') ||
              a.mensagem.contains('ponto'),
        )
        .length;
    final normais = total - criticos - atencao;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: amarelo.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: amarelo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Relatório de Alertas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: amarelo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total de alertas',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        '$total alerta${total != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Cards por tipo
            Row(
              children: [
                Expanded(
                  child: _cardRelatorio(
                    'Críticos',
                    criticos,
                    Icons.local_fire_department_rounded,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _cardRelatorio(
                    'Atenção',
                    atencao,
                    Icons.warning_rounded,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _cardRelatorio(
                    'Normais',
                    normais,
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Barra de proporção visual
            if (total > 0) ...[
              const Text(
                'Proporção',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    if (criticos > 0)
                      Expanded(
                        flex: criticos,
                        child: Container(height: 14, color: Colors.red),
                      ),
                    if (atencao > 0)
                      Expanded(
                        flex: atencao,
                        child: Container(height: 14, color: Colors.orange),
                      ),
                    if (normais > 0)
                      Expanded(
                        flex: normais,
                        child: Container(height: 14, color: Colors.green),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _legendaItem(Colors.red, 'Crítico'),
                  const SizedBox(width: 12),
                  _legendaItem(Colors.orange, 'Atenção'),
                  const SizedBox(width: 12),
                  _legendaItem(Colors.green, 'Normal'),
                ],
              ),
            ],

            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum alerta para gerar relatório.',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardRelatorio(
    String label,
    int quantidade,
    IconData icon,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: cor, size: 22),
          const SizedBox(height: 6),
          Text(
            '$quantidade',
            style: TextStyle(
              color: cor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _legendaItem(Color cor, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  void _confirmarLimparAlertas(AlertaProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        title: const Text(
          'Limpar alertas',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja apagar todos os alertas?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.limparAlertas();
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ──────────────── FUNCIONÁRIOS ────────────────
  Widget _buildFuncionariosTab() {
    final funcionarios = context.watch<FuncionarioProvider>().funcionarios;
    final obras = context.watch<ObraProvider>().obras;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Funcionários',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.funcionarios).then(
                        (_) => context
                            .read<FuncionarioProvider>()
                            .carregarFuncionarios(),
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: amarelo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          funcionarios.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.person_off_rounded,
                          color: Colors.white24,
                          size: 64,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum funcionário cadastrado',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: funcionarios.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final f = funcionarios[i];
                      final nomeObra = f.obraId != null && obras.isNotEmpty
                          ? obras
                                .firstWhere(
                                  (o) => o.id == f.obraId,
                                  orElse: () => obras.first,
                                )
                                .nome
                          : 'Sem obra';
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.cartaoPonto,
                          arguments: f.id,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: amarelo.withOpacity(0.2),
                                child: Text(
                                  f.nome[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: amarelo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${f.funcao} • $nomeObra',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: amarelo,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // ──────────────── PERFIL ────────────────
  Widget _buildPerfilTab(BuildContext context, String nome) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 44,
              backgroundColor: amarelo,
              child: Text(
                nome.isNotEmpty ? nome[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Engenheiro Responsável',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),

            const SizedBox(height: 30),

            _perfilItem(
              Icons.person_outline_rounded,
              'Meu Perfil',
              onTap: () => _abrirEditarPerfil(context),
            ),
            _perfilItem(
              Icons.notifications_none_rounded,
              'Notificações',
              onTap: () => _abrirNotificacoes(context),
            ),
            _perfilItem(
              Icons.info_outline_rounded,
              'Sobre o App',
              onTap: () => _abrirSobre(context),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (r) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirEditarPerfil(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nomeCtrl = TextEditingController(text: auth.nome ?? '');
    final telCtrl = TextEditingController(text: auth.telefone ?? '');
    final senhaCtrl = TextEditingController();
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _modalCampo(nomeCtrl, 'Nome completo', Icons.person_rounded),
              const SizedBox(height: 14),
              _modalCampo(
                telCtrl,
                'Telefone',
                Icons.phone_rounded,
                tipo: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _modalCampo(
                senhaCtrl,
                'Nova senha (opcional)',
                Icons.lock_rounded,
                obscure: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarelo,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: salvando
                      ? null
                      : () async {
                          setModal(() => salvando = true);
                          final ok = await context
                              .read<AuthProvider>()
                              .atualizarPerfil(
                                nome: nomeCtrl.text.trim(),
                                telefone: telCtrl.text.trim(),
                                novaSenha: senhaCtrl.text.isNotEmpty
                                    ? senhaCtrl.text.trim()
                                    : null,
                              );
                          setModal(() => salvando = false);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Perfil atualizado!' : 'Erro ao atualizar',
                              ),
                              backgroundColor: ok
                                  ? Colors.green
                                  : Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  child: salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SALVAR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirNotificacoes(BuildContext context) {
    final alertas = context.read<AlertaProvider>().alertas;
    final pontos = alertas
        .where((a) => a.mensagem.toLowerCase().contains('ponto'))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notificações de Ponto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            pontos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nenhuma batida de ponto registrada',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 300,
                    child: ListView.separated(
                      itemCount: pontos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final a = pontos[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fingerprint_rounded,
                                color: amarelo,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  a.mensagem,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${a.data.hour.toString().padLeft(2, '0')}:${a.data.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _abrirSobre(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: amarelo.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: amarelo,
                size: 40,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'ObraTech',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versão 1.0.0',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text(
              'O ObraTech é um sistema de gerenciamento inteligente para obras pequenas e médias. '
              'Permite cadastrar obras, gerenciar funcionários, monitorar temperatura em tempo real '
              'via ESP32 e acompanhar o ponto dos colaboradores com registro automático por RFID.\n\n'
              'Desenvolvido como projeto integrador do curso de Engenharia.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ana Clara • Kauana Cravelin • Samara',
              style: TextStyle(color: amarelo, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _perfilItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: amarelo),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _modalCampo(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType tipo = TextInputType.text,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: tipo,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: Icon(icon, color: amarelo, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

// ── GRÁFICO TEMPERATURA ──
class _TempChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFFFC107).withOpacity(0.35), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final pts = [
      0.45,
      0.35,
      0.50,
      0.68,
      0.75,
      0.62,
      0.48,
      0.42,
      0.52,
      0.58,
      0.68,
      0.70,
      0.65,
      0.60,
    ];
    final h = size.height - 16;
    final path = Path();
    final fill = Path();

    for (int i = 0; i < pts.length; i++) {
      final x = (i / (pts.length - 1)) * size.width;
      final y = h - pts[i] * h * 0.85;
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
    canvas.drawCircle(
      Offset(size.width, h - pts.last * h * 0.85),
      5,
      Paint()..color = const Color(0xFFFFC107),
    );
    final labels = ['10:00', '14:00', '18:00', '22:00', '06:00', '10:00'];
    for (int i = 0; i < labels.length; i++) {
      final x = (i / (labels.length - 1)) * size.width;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.white38, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 13));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
