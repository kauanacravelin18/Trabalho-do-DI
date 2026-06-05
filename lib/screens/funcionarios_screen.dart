import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/funcionario_provider.dart';
import '../providers/obra_provider.dart';

class FuncionariosScreen extends StatefulWidget {
  const FuncionariosScreen({super.key});

  @override
  State<FuncionariosScreen> createState() => _FuncionariosScreenState();
}

class _FuncionariosScreenState extends State<FuncionariosScreen> {
  final _nomeController = TextEditingController();
  final _funcaoController = TextEditingController();
  String? _obraSelecionada;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  void _abrirModal() {
    final obras = context.read<ObraProvider>().obras;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Novo Funcionário',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _campoModal(
                    _nomeController,
                    'Nome completo',
                    Icons.person_rounded,
                  ),
                  const SizedBox(height: 14),
                  _campoModal(
                    _funcaoController,
                    'Função (ex: Pedreiro)',
                    Icons.work_rounded,
                  ),
                  const SizedBox(height: 14),

                  // Dropdown obras
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _obraSelecionada,
                        isExpanded: true,
                        dropdownColor: card,
                        hint: const Text(
                          'Vincular à obra (opcional)',
                          style: TextStyle(color: Colors.white30),
                        ),
                        items: obras
                            .map(
                              (o) => DropdownMenuItem(
                                value: o.id,
                                child: Text(
                                  o.nome,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setModal(() => _obraSelecionada = v),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white38,
                        ),
                      ),
                    ),
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
                      onPressed: () {
                        final nome = _nomeController.text.trim();
                        final funcao = _funcaoController.text.trim();

                        if (nome.isEmpty || funcao.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preencha nome e função'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        context
                            .read<FuncionarioProvider>()
                            .adicionarFuncionario(
                              nome,
                              funcao,
                              _obraSelecionada,
                            );
                        _nomeController.clear();
                        _funcaoController.clear();
                        setState(() => _obraSelecionada = null);
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'ADICIONAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _campoModal(TextEditingController c, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: c,
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

  @override
  Widget build(BuildContext context) {
    final funcionarios = context.watch<FuncionarioProvider>().funcionarios;
    final obras = context.watch<ObraProvider>().obras;

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Funcionários',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: amarelo,
        onPressed: _abrirModal,
        child: const Icon(Icons.person_add_rounded, color: Colors.black),
      ),
      body: Column(
        children: [
          // Resumo
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: amarelo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_rounded, color: Colors.black, size: 32),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total de funcionários',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    Text(
                      '${funcionarios.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista
          funcionarios.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_rounded,
                          color: Colors.white24,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhum funcionário cadastrado',
                          style: TextStyle(color: Colors.white38),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Toque no + para adicionar',
                          style: TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: funcionarios.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final f = funcionarios[i];
                      final obraNome = obras.firstWhere(
                        (o) => o.id == f.obraId,
                        orElse: () =>
                            obras.isNotEmpty ? obras.first : obras.first,
                      );

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: amarelo.withOpacity(0.2),
                              child: Text(
                                f.nome[0].toUpperCase(),
                                style: const TextStyle(
                                  color: amarelo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    f.funcao,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (f.obraId != null)
                                    Text(
                                      '📍 ${obraNome.nome}',
                                      style: const TextStyle(
                                        color: amarelo,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => context
                                  .read<FuncionarioProvider>()
                                  .removerFuncionario(f.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
