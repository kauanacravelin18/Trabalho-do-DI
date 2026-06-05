import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nome = context.watch<AuthProvider>().nome ?? 'Usuário';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'OBRA TECH',
          style: TextStyle(
            color: Color(0xFFFFC107),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Olá, $nome 👷',
                style: const TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Monitoramento inteligente da sua obra',
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBRA ATIVA', style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 5),
                  Text(
                    'Residencial Ville',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Rua das Flores, 123',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(child: _card('Temperatura', '28°C', Icons.thermostat)),
                const SizedBox(width: 10),
                Expanded(child: _card('Umidade', '65%', Icons.water_drop)),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _card('Vibração', '2.3', Icons.vibration)),
                const SizedBox(width: 10),
                Expanded(child: _card('Status', 'OK', Icons.check_circle)),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                icon: const Icon(Icons.analytics),
                label: const Text(
                  'VISUALIZAR RELATÓRIOS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card(String titulo, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFC107), size: 30),
          const SizedBox(height: 10),
          Text(titulo, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
