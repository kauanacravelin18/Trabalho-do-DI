import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _verSenha = false;
  bool _verConfirmar = false;
  bool _carregando = false;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmar = _confirmarController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      _snack('Preencha todos os campos', Colors.red.shade700);
      return;
    }

    if (senha != confirmar) {
      _snack('As senhas não coincidem', Colors.red.shade700);
      return;
    }

    setState(() => _carregando = true);

    final ok = await context.read<AuthProvider>().register(nome, email, senha);

    if (!mounted) return;
    setState(() => _carregando = false);

    if (ok) {
      _snack('Conta criada com sucesso!', Colors.green);
      Navigator.pop(context);
    } else {
      _snack('E-mail já cadastrado', Colors.red.shade700);
    }
  }

  void _snack(String msg, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Topo preto com logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
              color: Colors.black,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: amarelo.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: amarelo,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Criar conta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Preencha os dados abaixo',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Formulário
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  _label('Nome completo'),
                  const SizedBox(height: 8),
                  _campo(
                    controller: _nomeController,
                    hint: 'Seu nome',
                    icon: Icons.person_rounded,
                  ),

                  const SizedBox(height: 18),

                  _label('E-mail'),
                  const SizedBox(height: 8),
                  _campo(
                    controller: _emailController,
                    hint: 'seu@email.com',
                    icon: Icons.email_rounded,
                    tipo: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  _label('Senha'),
                  const SizedBox(height: 8),
                  _campoSenha(
                    controller: _senhaController,
                    hint: 'Digite sua senha',
                    verSenha: _verSenha,
                    onToggle: () => setState(() => _verSenha = !_verSenha),
                  ),

                  const SizedBox(height: 18),

                  _label('Confirmar senha'),
                  const SizedBox(height: 8),
                  _campoSenha(
                    controller: _confirmarController,
                    hint: 'Repita a senha',
                    verSenha: _verConfirmar,
                    onToggle: () =>
                        setState(() => _verConfirmar = !_verConfirmar),
                  ),

                  const SizedBox(height: 36),

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
                      onPressed: _carregando ? null : _cadastrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'CRIAR CONTA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já tem conta?',
                        style: TextStyle(color: Colors.white54),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: amarelo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String texto) => Text(
    texto,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
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

  Widget _campoSenha({
    required TextEditingController controller,
    required String hint,
    required bool verSenha,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: !verSenha,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.lock_rounded, color: amarelo, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              verSenha
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: Colors.white38,
            ),
            onPressed: onToggle,
          ),
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
