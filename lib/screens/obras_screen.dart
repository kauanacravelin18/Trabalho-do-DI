import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/obra_provider.dart';
import '../routes/app_routes.dart';

class ObrasScreen extends StatelessWidget {
  const ObrasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObraProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Obras')),
      body: ListView.builder(
        itemCount: provider.obras.length,
        itemBuilder: (context, index) {
          final obra = provider.obras[index];

          return Card(
            child: ListTile(
              title: Text(obra.nome),
              subtitle: Text(obra.endereco),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  provider.removerObra(obra.id);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addObra);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}