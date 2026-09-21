import 'package:flutter/material.dart';
import 'telas/tela_principal.dart';

void main() {
  runApp(const AplicativoNutriBusca());
}

class AplicativoNutriBusca extends StatelessWidget {
  const AplicativoNutriBusca({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData temaAplicativo = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        primary: Colors.green.shade700,
        secondary: Colors.amber.shade700,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'NutriBusca - Open Food Facts',
      debugShowCheckedModeBanner: false,
      theme: temaAplicativo,
      home: const TelaPrincipal(),
    );
  }
}
