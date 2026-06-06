import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/funcionario_provider.dart';
import '../providers/obra_provider.dart';
import '../models/funcionario.dart';
import '../routes/app_routes.dart';

class FuncionariosScreen extends StatefulWidget {
  const FuncionariosScreen({super.key});

  @override
  State<FuncionariosScreen> createState() => _FuncionariosScreenState();
}

class _FuncionariosScreenState extends State<FuncionariosScreen> {
  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuncionarioProvider>().carregarFuncionarios();
      context.read<ObraProvider>().carregarObras();
    });
  }

  void _abrirModal({Funcionario? editando}) {
    final obras = context.read<ObraProvider>().obras;
    final nomeCtrl = TextEditingController(text: editando?.nome ?? '');
    final telCtrl = TextEditingController(text: editando?.telefone ?? '');
    final cpfCtrl = TextEditingController(text: editando?.cpf ?? '');
    final emailCtrl = TextEditingController(text: editando?.email ?? '');
    final funcaoCtrl = TextEditingController(text: editando?.funcao ?? '');
    String? obraSelecionada = editando?.obraId;
    String? erroNome, erroTel, erroCpf, erroEmail, erroFuncao;
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editando == null ? 'Novo Funcionário' : 'Editar Funcionário',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _lbl('Nome completo'),
                const SizedBox(height: 6),
                _campo(nomeCtrl, 'Ex: João da Silva', Icons.person_rounded,
                    erro: erroNome,
                    onChange: (_) => setModal(() => erroNome = null)),

                const SizedBox(height: 14),
                _lbl('Telefone'),
                const SizedBox(height: 6),
                _campo(telCtrl, '(00) 00000-0000', Icons.phone_rounded,
                    tipo: TextInputType.phone,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _TelFormatter()
                    ],
                    erro: erroTel,
                    onChange: (_) => setModal(() => erroTel = null)),

                const SizedBox(height: 14),
                _lbl('CPF'),
                const SizedBox(height: 6),
                _campo(cpfCtrl, '000.000.000-00', Icons.badge_rounded,
                    tipo: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CpfFormatter()
                    ],
                    erro: erroCpf,
                    onChange: (_) => setModal(() => erroCpf = null)),

                const SizedBox(height: 14),
                _lbl('E-mail'),
                const SizedBox(height: 6),
                _campo(emailCtrl, 'funcionario@email.com', Icons.email_rounded,
                    tipo: TextInputType.emailAddress,
                    erro: erroEmail,
                    onChange: (_) => setModal(() => erroEmail = null)),

                const SizedBox(height: 14),
                _lbl('Função / Profissão'),
                const SizedBox(height: 6),
                _campo(funcaoCtrl, 'Ex: Pedreiro, Eletricista...', Icons.work_rounded,
                    erro: erroFuncao,
                    onChange: (_) => setModal(() => erroFuncao = null)),

                const SizedBox(height: 14),
                _lbl('Obra vinculada'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: obraSelecionada,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF252525),
                      hint: const Text('Selecione a obra',
                          style: TextStyle(color: Colors.white30)),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Nenhuma',
                              style: TextStyle(color: Colors.white54)),
                        ),
                        ...obras.map((o) => DropdownMenuItem(
                              value: o.id,
                              child: Row(children: [
                                const Icon(Icons.apartment_rounded,
                                    color: amarelo, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(o.nome,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        overflow: TextOverflow.ellipsis)),
                              ]),
                            )),
                      ],
                      onChanged: (v) => setModal(() => obraSelecionada = v),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white38),
                    ),
                  ),
                ),

                const SizedBox(height: 28),
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
                    onPressed: salvando
                        ? null
                        : () async {
                            bool temErro = false;
                            if (nomeCtrl.text.trim().isEmpty) {
                              setModal(() => erroNome = 'Informe o nome');
                              temErro = true;
                            }
                            if (telCtrl.text.trim().length < 14) {
                              setModal(() => erroTel = 'Telefone incompleto');
                              temErro = true;
                            }
                            if (cpfCtrl.text.trim().length < 14) {
                              setModal(() => erroCpf = 'CPF incompleto');
                              temErro = true;
                            }
                            if (!emailCtrl.text.contains('@')) {
                              setModal(() => erroEmail = 'E-mail inválido');
                              temErro = true;
                            }
                            if (funcaoCtrl.text.trim().isEmpty) {
                              setModal(() => erroFuncao = 'Informe a função');
                              temErro = true;
                            }
                            if (temErro) return;

                            setModal(() => salvando = true);
                            final provider =
                                context.read<FuncionarioProvider>();
                            String? erro;

                            if (editando == null) {
                              erro = await provider.adicionarFuncionario(
                                nome: nomeCtrl.text.trim(),
                                telefone: telCtrl.text.trim(),
                                cpf: cpfCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                funcao: funcaoCtrl.text.trim(),
                                obraId: obraSelecionada,
                              );
                            } else {
                              erro = await provider.editarFuncionario(
                                id: editando.id,
                                nome: nomeCtrl.text.trim(),
                                telefone: telCtrl.text.trim(),
                                cpf: cpfCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                funcao: funcaoCtrl.text.trim(),
                                obraId: obraSelecionada,
                              );
                            }

                            setModal(() => salvando = false);
                            if (!ctx.mounted) return;

                            if (erro != null) {
                              if (erro.contains('CPF')) {
                                setModal(() => erroCpf = erro);
                              } else if (erro.contains('mail')) {
                                setModal(() => erroEmail = erro);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(erro),
                                      backgroundColor: Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating),
                                );
                              }
                            } else {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(editando == null
                                        ? 'Funcionário cadastrado!'
                                        : 'Cadastro atualizado!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating),
                              );
                            }
                          },
                    child: salvando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2.5))
                        : Text(
                            editando == null
                                ? 'CADASTRAR FUNCIONÁRIO'
                                : 'SALVAR ALTERAÇÕES',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(Funcionario f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        title: const Text('Remover funcionário',
            style: TextStyle(color: Colors.white)),
        content: Text('Deseja remover ${f.nome}?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<FuncionarioProvider>().removerFuncionario(f.id);
              },
              child:
                  const Text('Remover', style: TextStyle(color: Colors.red))),
        ],
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
        title: const Text('Funcionários',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: amarelo,
        onPressed: () => _abrirModal(),
        child: const Icon(Icons.person_add_rounded, color: Colors.black),
      ),
      body: Column(
        children: [
          // Resumo amarelo
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: amarelo, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.people_rounded,
                    color: Colors.black, size: 36),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total de funcionários',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                    Text('${funcionarios.length}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Obras ativas',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                    Text('${obras.length}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          funcionarios.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_off_rounded,
                            color: Colors.white24, size: 64),
                        SizedBox(height: 12),
                        Text('Nenhum funcionário cadastrado',
                            style: TextStyle(color: Colors.white38)),
                        SizedBox(height: 6),
                        Text('Toque no + para adicionar',
                            style: TextStyle(
                                color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: funcionarios.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final f = funcionarios[i];
                      final nomeObra = f.obraId != null && obras.isNotEmpty
                          ? obras
                              .firstWhere((o) => o.id == f.obraId,
                                  orElse: () => obras.first)
                              .nome
                          : null;
                      final ultima = f.batidas.isNotEmpty
                          ? f.batidas.last
                          : null;

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.cartaoPonto,
                          arguments: f.id,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        amarelo.withOpacity(0.2),
                                    child: Text(
                                      f.nome[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: amarelo,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                        Text(f.funcao,
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded,
                                        color: amarelo, size: 20),
                                    onPressed: () =>
                                        _abrirModal(editando: f),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 20),
                                    onPressed: () =>
                                        _confirmarExclusao(f),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  color: Colors.white10, height: 1),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _chip(Icons.phone_rounded, f.telefone),
                                  _chip(Icons.badge_rounded, f.cpf),
                                  _chip(Icons.email_rounded, f.email),
                                  if (nomeObra != null)
                                    _chip(Icons.apartment_rounded,
                                        nomeObra,
                                        cor: amarelo),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  color: Colors.white10, height: 1),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: ultima != null
                                        ? Colors.green
                                        : Colors.white38,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ultima != null
                                        ? 'Última batida: ${ultima.day.toString().padLeft(2, '0')}/${ultima.month.toString().padLeft(2, '0')} às ${ultima.hour.toString().padLeft(2, '0')}:${ultima.minute.toString().padLeft(2, '0')}'
                                        : 'Nenhuma batida registrada',
                                    style: TextStyle(
                                        color: ultima != null
                                            ? Colors.green
                                            : Colors.white38,
                                        fontSize: 12),
                                  ),
                                  const Spacer(),
                                  const Row(
                                    children: [
                                      Text('Ver ponto',
                                          style: TextStyle(
                                              color: amarelo,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600)),
                                      SizedBox(width: 2),
                                      Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: amarelo,
                                          size: 11),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color cor = Colors.white54}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cor, size: 13),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: cor, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600));

  Widget _campo(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    String? erro,
    TextInputType tipo = TextInputType.text,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    erro != null ? Colors.red.shade700 : Colors.white10),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: tipo,
            inputFormatters: formatters,
            onChanged: onChange,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: Icon(icon, color: amarelo, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 12),
            ),
          ),
        ),
        if (erro != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 13),
            const SizedBox(width: 4),
            Text(erro,
                style:
                    const TextStyle(color: Colors.red, fontSize: 12)),
          ]),
        ],
      ],
    );
  }
}

// ── FORMATADORES ──
class _CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue nv) {
    final d = nv.text.replaceAll(RegExp(r'[^0-9]'), '');
    final b = StringBuffer();
    for (int i = 0; i < d.length && i < 11; i++) {
      if (i == 3 || i == 6) b.write('.');
      if (i == 9) b.write('-');
      b.write(d[i]);
    }
    final f = b.toString();
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

class _TelFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue nv) {
    final d = nv.text.replaceAll(RegExp(r'[^0-9]'), '');
    final b = StringBuffer();
    for (int i = 0; i < d.length && i < 11; i++) {
      if (i == 0) b.write('(');
      if (i == 2) b.write(') ');
      if (i == 7) b.write('-');
      b.write(d[i]);
    }
    final f = b.toString();
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}