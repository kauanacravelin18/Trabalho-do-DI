import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/obra_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final nome = context.watch<AuthProvider>().nome ?? 'Usuário';
    final obras = context.watch<ObraProvider>().obras;
    final obraAtual = obras.isNotEmpty ? obras.first : null;

    final List<Widget> telas = [
      _buildDashboard(nome, obraAtual),
      _buildObrasTab(context),
      _buildSensoresTab(),
      _buildAlertasTab(),
      _buildPerfilTab(context, nome),
    ];

    return Scaffold(
      backgroundColor: fundo,
      body: telas[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────── BOTTOM NAV ───────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      backgroundColor: Colors.black,
      selectedItemColor: amarelo,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 11,
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
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  // ─────────────────── DASHBOARD ───────────────────
  Widget _buildDashboard(String nome, dynamic obraAtual) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            // Saudação
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

            // Card obra atual
            _buildObraAtualCard(obraAtual),

            const SizedBox(height: 22),

            // Título sensores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resumo dos Sensores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(color: amarelo, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Grid 4 sensores
            Row(
              children: [
                Expanded(
                  child: _sensorCard(
                    'Temperatura',
                    '28.6 °C',
                    Icons.thermostat_rounded,
                    'Normal',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _sensorCard(
                    'Umidade',
                    '65 %',
                    Icons.water_drop_rounded,
                    'Normal',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _sensorCard(
                    'Vibração',
                    '2.3 mm/s',
                    Icons.vibration_rounded,
                    'Atenção',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _sensorCard(
                    'Poeira',
                    '35 µg/m³',
                    Icons.cloud_rounded,
                    'Normal',
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Atividades recentes
            const Text(
              'Atividades Recentes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _atividadeItem(
              icon: Icons.build_rounded,
              iconBg: Colors.orange.shade800,
              titulo: 'Sensor de vibração',
              descricao: 'Atenção: vibração acima do normal',
              hora: '09:45',
            ),
            const SizedBox(height: 8),
            _atividadeItem(
              icon: Icons.water_drop_rounded,
              iconBg: amarelo,
              titulo: 'Sensor de umidade',
              descricao: 'Leitura dentro da normalidade',
              hora: '09:30',
            ),
            const SizedBox(height: 8),
            _atividadeItem(
              icon: Icons.thermostat_rounded,
              iconBg: Colors.red.shade700,
              titulo: 'Sensor de temperatura',
              descricao: 'Leitura dentro da normalidade',
              hora: '09:15',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildObraAtualCard(dynamic obraAtual) {
    return Container(
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
                  style: TextStyle(color: Colors.black54, fontSize: 12),
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
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _sensorCard(
    String nome,
    String valor,
    IconData icon,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: amarelo, size: 22),
          const SizedBox(height: 6),
          Text(
            nome,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
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

  // ─────────────────── OBRAS ───────────────────
  Widget _buildObrasTab(BuildContext context) {
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
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.addObra).then((_) {
                        context.read<ObraProvider>().carregarObras();
                      }),
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
                      children: [
                        const Icon(
                          Icons.domain_disabled_rounded,
                          color: Colors.white24,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        const Text(
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
                    itemBuilder: (context, i) => _obraCard(context, obras[i]),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _obraCard(BuildContext context, dynamic obra) {
    return Container(
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
                  obra.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  obra.endereco,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Resp.: ${obra.responsavel}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: card,
                  title: const Text(
                    'Excluir obra',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'Deseja excluir "${obra.nome}"?',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmar == true) {
                context.read<ObraProvider>().removerObra(obra.id);
              }
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────── SENSORES ───────────────────
  Widget _buildSensoresTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sensores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.tune_rounded, color: Colors.white54),
              ],
            ),

            const SizedBox(height: 16),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _sensorTab('Temperatura', true),
                  _sensorTab('Umidade', false),
                  _sensorTab('Vibração', false),
                  _sensorTab('Poeira', false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status atual
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
                    size: 40,
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
                          fontSize: 28,
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

            // Gráfico
            Container(
              height: 160,
              width: double.infinity,
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

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amarelo,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.download_rounded),
                label: const Text(
                  'Exportar Relatório',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorTab(String label, bool ativo) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ativo ? amarelo : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ativo ? amarelo : Colors.white54,
          fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
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

  // ─────────────────── ALERTAS ───────────────────
  Widget _buildAlertasTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alertas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _alertaItem(
                    cor: Colors.orange,
                    icon: Icons.vibration_rounded,
                    titulo: 'Vibração acima do normal',
                    descricao:
                        'Sensor registrou 2.3 mm/s na Obra Residencial Ville',
                    hora: '09:45',
                  ),
                  const SizedBox(height: 10),
                  _alertaItem(
                    cor: Colors.green,
                    icon: Icons.check_circle_rounded,
                    titulo: 'Umidade normalizada',
                    descricao: 'Sensor retornou ao intervalo normal: 65%',
                    hora: '09:30',
                  ),
                  const SizedBox(height: 10),
                  _alertaItem(
                    cor: Colors.green,
                    icon: Icons.thermostat_rounded,
                    titulo: 'Temperatura estável',
                    descricao: 'Temperatura em 28.6 °C — dentro do esperado',
                    hora: '09:15',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertaItem({
    required Color cor,
    required IconData icon,
    required String titulo,
    required String descricao,
    required String hora,
  }) {
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
              color: cor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cor, size: 20),
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
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            hora,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─────────────────── PERFIL ───────────────────
  Widget _buildPerfilTab(BuildContext context, String nome) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
            _perfilItem(Icons.person_outline_rounded, 'Meu Perfil'),
            _perfilItem(Icons.notifications_none_rounded, 'Notificações'),
            _perfilItem(Icons.help_outline_rounded, 'Ajuda'),
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

  Widget _perfilItem(IconData icon, String label) {
    return Container(
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
    );
  }
}

// ─────────────────── GRÁFICO ───────────────────
class _TempChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFC107).withOpacity(0.35),
          const Color(0xFFFFC107).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final points = [
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
    final h = size.height - 16; // espaço para labels

    final path = Path();
    final fill = Path();

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = h - points[i] * h * 0.85;
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

    // Ponto final
    final lx = size.width;
    final ly = h - points.last * h * 0.85;
    canvas.drawCircle(
      Offset(lx, ly),
      5,
      Paint()..color = const Color(0xFFFFC107),
    );

    // Labels eixo X
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
