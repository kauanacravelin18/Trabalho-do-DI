import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obra_provider.dart';
import '../providers/funcionario_provider.dart';

class DetalheObraScreen extends StatefulWidget {
  final String obraId;
  const DetalheObraScreen({super.key, required this.obraId});

  @override
  State<DetalheObraScreen> createState() => _DetalheObraScreenState();
}

class _DetalheObraScreenState extends State<DetalheObraScreen> {
  late TextEditingController _nomeCtrl;
  late TextEditingController _enderecoCtrl;
  String? _responsavelId;
  bool _editando = false;
  bool _salvando = false;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    final obra = context.read<ObraProvider>().obras.firstWhere((o) => o.id == widget.obraId);
    _nomeCtrl = TextEditingController(text: obra.nome);
    _enderecoCtrl = TextEditingController(text: obra.endereco);
    // Tenta encontrar o funcionário pelo nome atual do responsável
    final funcs = context.read<FuncionarioProvider>().funcionarios;
    final match = funcs.where((f) => f.nome == obra.responsavel);
    _responsavelId = match.isNotEmpty ? match.first.id : null;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _enderecoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final funcs = context.read<FuncionarioProvider>().funcionarios;
    final nomeResp = _responsavelId != null
        ? funcs.firstWhere((f) => f.id == _responsavelId).nome
        : '';

    await context.read<ObraProvider>().editarObra(
          widget.obraId,
          _nomeCtrl.text.trim(),
          _enderecoCtrl.text.trim(),
          nomeResp,
        );
    setState(() {
      _salvando = false;
      _editando = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Obra atualizada!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obra = context.watch<ObraProvider>().obras.firstWhere(
          (o) => o.id == widget.obraId,
          orElse: () => context.read<ObraProvider>().obras.first,
        );
    final funcionarios = context.watch<FuncionarioProvider>().funcionarios;
    final funcsDaObra =
        funcionarios.where((f) => f.obraId == widget.obraId).toList();

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalhes da Obra',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_editando ? Icons.close_rounded : Icons.edit_rounded,
                color: amarelo),
            onPressed: () => setState(() => _editando = !_editando),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card topo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: amarelo, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.apartment_rounded, color: Colors.black, size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(obra.nome,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(obra.endereco,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Campos editáveis
            _secao('Informações da Obra'),
            const SizedBox(height: 12),

            _campo('Nome da obra', _nomeCtrl, Icons.construction_rounded,
                ativo: _editando),
            const SizedBox(height: 12),
            _campo('Endereço', _enderecoCtrl, Icons.location_on_rounded,
                ativo: _editando),
            const SizedBox(height: 12),

            // Responsável — dropdown dos funcionários
            const Text('Responsável',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _editando ? amarelo.withOpacity(0.5) : Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _responsavelId,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF252525),
                  hint: Text(
                    obra.responsavel.isNotEmpty
                        ? obra.responsavel
                        : 'Selecione o responsável',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Nenhum',
                          style: TextStyle(color: Colors.white54)),
                    ),
                    ...funcionarios.map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Row(
                            children: [
                              const Icon(Icons.person_rounded,
                                  color: amarelo, size: 16),
                              const SizedBox(width: 8),
                              Text(f.nome,
                                  style:
                                      const TextStyle(color: Colors.white)),
                            ],
                          ),
                        )),
                  ],
                  onChanged: _editando
                      ? (v) => setState(() => _responsavelId = v)
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38),
                ),
              ),
            ),

            if (_editando) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarelo,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2.5))
                      : const Text('SALVAR ALTERAÇÕES',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Funcionários vinculados
            _secao('Funcionários nesta obra (${funcsDaObra.length})'),
            const SizedBox(height: 12),

            funcsDaObra.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.person_off_rounded,
                            color: Colors.white38, size: 20),
                        SizedBox(width: 10),
                        Text('Nenhum funcionário vinculado',
                            style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  )
                : Column(
                    children: funcsDaObra
                        .map((f) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.white10)),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        amarelo.withOpacity(0.2),
                                    child: Text(f.nome[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: amarelo,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(f.nome,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                        Text(f.funcao,
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${f.batidas.length} batida(s)',
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) => Text(
        titulo,
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      );

  Widget _campo(String label, TextEditingController ctrl, IconData icon,
      {bool ativo = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: ativo ? amarelo.withOpacity(0.5) : Colors.white10),
          ),
          child: TextField(
            controller: ctrl,
            enabled: ativo,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: amarelo, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}