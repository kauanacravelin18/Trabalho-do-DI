import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/obra_provider.dart';

class AddObraScreen extends StatefulWidget {
  const AddObraScreen({super.key});

  @override
  State<AddObraScreen> createState() => _AddObraScreenState();
}

class _AddObraScreenState extends State<AddObraScreen> {
  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final responsavelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final obraProvider = context.read<ObraProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Obra'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da Obra',
                prefixIcon: Icon(Icons.construction),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: enderecoController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: responsavelController,
              decoration: const InputDecoration(
                labelText: 'Responsável',
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                await obraProvider.adicionarObra(
                  nomeController.text,
                  enderecoController.text,
                  responsavelController.text,
                );

                Navigator.pop(context);
              },
              child: const Text('SALVAR OBRA'),
            ),
          ],
        ),
      ),
    );
  }
}