import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/obra_provider.dart';
import 'providers/funcionario_provider.dart';
import 'providers/alerta_provider.dart';
import 'routes/app_routes.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.database;

  runApp(const ObraTechApp());
}

class ObraTechApp extends StatelessWidget {
  const ObraTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// 🔥 AUTH (OBRIGATÓRIO PRO LOGIN FUNCIONAR)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// 🔥 OUTROS
        ChangeNotifierProvider(create: (_) => ObraProvider()),
        ChangeNotifierProvider(create: (_) => FuncionarioProvider()),
        ChangeNotifierProvider(create: (_) => AlertaProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
