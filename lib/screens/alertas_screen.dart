import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alerta_provider.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AlertaProvider>().carregarAlertas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertaProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Histórico de Alertas'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              provider.limparAlertas();
            },
          ),
        ],
      ),
      body: provider.alertas.isEmpty
          ? const Center(
              child: Text(
                'Nenhum alerta',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: provider.alertas.length,
              itemBuilder: (context, index) {
                final alerta = provider.alertas[index];

                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          alerta.mensagem,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      Text(
                        "${alerta.data.hour}:${alerta.data.minute}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
