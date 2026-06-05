import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/obra_provider.dart';

class FuncionariosScreen extends StatelessWidget {
  const FuncionariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final obras = context.watch<ObraProvider>().obras;

    return Scaffold(
      appBar: AppBar(title: const Text('Funcionários')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          items: obras
              .map((o) => DropdownMenuItem(
                    value: o.id,
                    child: Text(o.nome),
                  ))
              .toList(),
          onChanged: (value) {},
          decoration: const InputDecoration(
            labelText: 'Selecione a Obra',
          ),
        ),
      ),
    );
  }
}