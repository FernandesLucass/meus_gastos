import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const MeusGastosApp());
}

class MeusGastosApp extends StatelessWidget {
  const MeusGastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus Gastos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Aqui a mágica acontece!
      home: const MainNavigation(),
    );
  }
}
