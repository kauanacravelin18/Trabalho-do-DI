import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';

class AddObraScreen extends StatefulWidget {
  const AddObraScreen({super.key});

  @override
  State<AddObraScreen> createState() => _AddObraScreenState();
}

class _AddObraScreenState extends State<AddObraScreen> {
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _responsavelController = TextEditingController();
  bool _salvando = false;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final endereco = _enderecoController.text.trim();
    final responsavel = _responsavelController.text.trim();

    if (nome.isEmpty || endereco.isEmpty || responsavel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha todos os campos'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    await context.read<ObraProvider>().adicionarObra(
      nome,
      endereco,
      responsavel,
    );

    if (!mounted) return;
    setState(() => _salvando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Obra cadastrada com sucesso!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Obra',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Ícone topo
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: amarelo.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: amarelo,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Cadastre uma nova obra',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            const SizedBox(height: 30),

            // Campo nome
            _label('Nome da Obra'),
            const SizedBox(height: 8),
            _campo(
              controller: _nomeController,
              hint: 'Ex: Residencial Ville',
              icon: Icons.construction_rounded,
            ),

            const SizedBox(height: 20),

            // Campo endereço
            _label('Endereço'),
            const SizedBox(height: 8),
            _campo(
              controller: _enderecoController,
              hint: 'Ex: Rua das Flores, 123 – São Paulo, SP',
              icon: Icons.location_on_rounded,
            ),

            const SizedBox(height: 20),

            // Campo responsável
            _label('Responsável'),
            const SizedBox(height: 8),
            _campo(
              controller: _responsavelController,
              hint: 'Ex: Eng. Carlos Silva',
              icon: Icons.person_rounded,
            ),

            const SizedBox(height: 40),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amarelo,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'SALVAR OBRA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão cancelar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: Icon(icon, color: amarelo, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}
