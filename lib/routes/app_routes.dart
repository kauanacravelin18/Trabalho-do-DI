import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/obras_screen.dart';
import '../screens/add_obra_screen.dart';
import '../screens/funcionarios_screen.dart';
import '../screens/reset_senha_screen.dart';
import '../screens/register_screen.dart';
import '../screens/iot_screen.dart';
import '../screens/alertas_screen.dart';

class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const obras = '/obras';
  static const addObra = '/add-obra';
  static const funcionarios = '/funcionarios';
  static const resetSenha = '/reset-senha';
  static const register = '/register';
  static const iot = '/iot';
  static const alertas = '/alertas';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    obras: (context) => const ObrasScreen(),
    addObra: (context) => const AddObraScreen(),
    funcionarios: (context) => const FuncionariosScreen(),
    resetSenha: (context) => const ResetSenhaScreen(),
    register: (context) => const RegisterScreen(),
    iot: (context) => const IotScreen(),
    alertas: (context) => const AlertasScreen(),
  };
}
