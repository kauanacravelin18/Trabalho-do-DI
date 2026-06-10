import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ResetSenhaScreen extends StatefulWidget {
  const ResetSenhaScreen({super.key});

  @override
  State<ResetSenhaScreen> createState() => _ResetSenhaScreenState();
}

class _ResetSenhaScreenState extends State<ResetSenhaScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _verSenha = false;
  bool _carregando = false;

  static const Color amarelo = Color(0xFFFFC107);
  static const Color fundo = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmar = _confirmarController.text.trim();

    if (email.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      _snack('Preencha todos os campos', Colors.red.shade700);
      return;
    }

    if (senha != confirmar) {
      _snack('As senhas não coincidem', Colors.red.shade700);
      return;
    }

    setState(() => _carregando = true);

    final ok = await context.read<AuthProvider>().resetSenha(email, senha);

    if (!mounted) return;
    setState(() => _carregando = false);

    if (ok) {
      _snack('Senha alterada com sucesso!', Colors.green);
      Navigator.pop(context);
    } else {
      _snack('E-mail não encontrado', Colors.red.shade700);
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recuperar senha',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: amarelo.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: amarelo,
                  size: 44,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Redefinir senha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Informe seu e-mail e a nova senha',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

            const SizedBox(height: 36),

            _label('E-mail cadastrado'),
            const SizedBox(height: 8),
            _campo(
              controller: _emailController,
              hint: 'seu@email.com',
              icon: Icons.email_rounded,
              tipo: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            _label('Nova senha'),
            const SizedBox(height: 8),
            _campoSenha(
              controller: _senhaController,
              hint: 'Digite sua nova senha',
              ver: _verSenha,
              onToggle: () => setState(() => _verSenha = !_verSenha),
            ),

            const SizedBox(height: 20),

            _label('Confirmar nova senha'),
            const SizedBox(height: 8),
            _campoSenha(
              controller: _confirmarController,
              hint: 'Repita a nova senha',
              ver: _verSenha,
              onToggle: () => setState(() => _verSenha = !_verSenha),
            ),

            const SizedBox(height: 40),

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
                onPressed: _carregando ? null : _confirmar,
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
                        'CONFIRMAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
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
    required bool ver,
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
        obscureText: !ver,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.lock_rounded, color: amarelo, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              ver ? Icons.visibility_off_rounded : Icons.visibility_rounded,
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
