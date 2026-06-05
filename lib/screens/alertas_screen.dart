import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alerta_provider.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  // Removidas as constantes locais — usando valores diretos
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AlertaProvider>().carregarAlertas());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertaProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico de Alertas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (provider.alertas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: () => _confirmarLimpeza(context, provider),
            ),
        ],
      ),
      body: provider.alertas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.alertas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final alerta = provider.alertas[i];
                final critico =
                    alerta.mensagem.contains('CRÍTICO') ||
                    alerta.mensagem.contains('🔥');
                final atencao =
                    alerta.mensagem.contains('ALTA') ||
                    alerta.mensagem.contains('⚠️');
                final cor = critico
                    ? Colors.red
                    : atencao
                    ? Colors.orange
                    : Colors.green;
                final icon = critico
                    ? Icons.local_fire_department_rounded
                    : atencao
                    ? Icons.warning_rounded
                    : Icons.check_circle_rounded;

                final hora =
                    '${alerta.data.hour.toString().padLeft(2, '0')}:${alerta.data.minute.toString().padLeft(2, '0')}';
                final data =
                    '${alerta.data.day.toString().padLeft(2, '0')}/${alerta.data.month.toString().padLeft(2, '0')}';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
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
                          alerta.mensagem,
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
    );
  }

  // Método separado para evitar uso de BuildContext across async gaps
  void _confirmarLimpeza(BuildContext context, AlertaProvider provider) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((confirmar) {
      if (confirmar == true) provider.limparAlertas();
    });
  }
}
