import 'package:flutter/material.dart';

import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Força a leitura do banco de dados para criar o arquivo .db
  await DatabaseHelper.instance.database;

  runApp(const MeusGastosApp());
}

class MeusGastosApp extends StatelessWidget {
  const MeusGastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus Gastos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('Estrutura Base Pronta!'))),
    );
  }
}
