import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_obra_screen.dart';
import '../screens/funcionarios_screen.dart';
import '../screens/cartao_ponto_screen.dart';
import '../screens/reset_senha_screen.dart';
import '../screens/register_screen.dart';
import '../screens/iot_screen.dart';
import '../screens/alertas_screen.dart';
import '../screens/detalhe_obra_screen.dart';

class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const addObra = '/add-obra';
  static const detalheObra = '/detalhe-obra';
  static const funcionarios = '/funcionarios';
  static const cartaoPonto = '/cartao-ponto';
  static const resetSenha = '/reset-senha';
  static const register = '/register';
  static const iot = '/iot';
  static const alertas = '/alertas';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(),
    addObra: (_) => const AddObraScreen(),
    funcionarios: (_) => const FuncionariosScreen(),
    resetSenha: (_) => const ResetSenhaScreen(),
    register: (_) => const RegisterScreen(),
    iot: (_) => const IotScreen(),
    alertas: (_) => const AlertasScreen(),
  };

  // Rotas com argumentos (não entram no mapa estático)
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case detalheObra:
        final obraId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => DetalheObraScreen(obraId: obraId));
      case cartaoPonto:
        final funcionarioId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => CartaoPontoScreen(funcionarioId: funcionarioId));
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}