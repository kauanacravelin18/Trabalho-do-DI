import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/obra_provider.dart';
import '../routes/app_routes.dart';

class ObrasScreen extends StatelessWidget {
  const ObrasScreen({super.key});

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  Future<void> _confirmarApagar(
    BuildContext context,
    String obraId,
    String nomeObra,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Apagar obra',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Deseja apagar a obra "$nomeObra"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      context.read<ObraProvider>().removerObra(obraId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObraProvider>();
    final obrasAtivas = provider.obras.where((o) => !o.concluida).toList();
    final obrasConcluidas = provider.obras.where((o) => o.concluida).toList();

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Obras',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: provider.obras.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma obra cadastrada',
                style: TextStyle(color: Colors.white38),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (obrasAtivas.isNotEmpty) ...[
                  _secao('Em andamento (${obrasAtivas.length})'),
                  const SizedBox(height: 10),
                  ...obrasAtivas.map((obra) => _cardObra(context, obra)),
                  const SizedBox(height: 20),
                ],
                if (obrasConcluidas.isNotEmpty) ...[
                  _secao('Concluídas (${obrasConcluidas.length})'),
                  const SizedBox(height: 10),
                  ...obrasConcluidas.map((obra) => _cardObra(context, obra)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: amarelo,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addObra),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _secao(String titulo) => Text(
    titulo,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _cardObra(BuildContext context, obra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: obra.concluida
              ? Colors.green.withOpacity(0.4)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: obra.concluida
              ? Colors.green.withOpacity(0.2)
              : amarelo.withOpacity(0.15),
          child: Icon(
            obra.concluida
                ? Icons.check_circle_rounded
                : Icons.apartment_rounded,
            color: obra.concluida ? Colors.green : amarelo,
            size: 20,
          ),
        ),
        title: Text(
          obra.nome,
          style: TextStyle(
            color: obra.concluida ? Colors.white38 : Colors.white,
            fontWeight: FontWeight.w600,
            decoration: obra.concluida ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white38,
          ),
        ),
        subtitle: Text(
          obra.endereco,
          style: TextStyle(
            color: obra.concluida ? Colors.white24 : Colors.white54,
            fontSize: 12,
          ),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.detalheObra,
          arguments: obra.id,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão concluir / reabrir
            IconButton(
              tooltip: obra.concluida
                  ? 'Reabrir obra'
                  : 'Marcar como concluída',
              icon: Icon(
                obra.concluida
                    ? Icons.restart_alt_rounded
                    : Icons.check_circle_outline_rounded,
                color: obra.concluida ? Colors.white38 : Colors.green,
              ),
              onPressed: () =>
                  context.read<ObraProvider>().concluirObra(obra.id),
            ),
            // Botão apagar
            IconButton(
              tooltip: 'Apagar obra',
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () => _confirmarApagar(context, obra.id, obra.nome),
            ),
          ],
        ),
      ),
    );
  }
}
