import 'package:flutter/material.dart';
import 'views/equipos_generales_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const InventarioTIApp());
}

class InventarioTIApp extends StatelessWidget {
  const InventarioTIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario TI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const EquiposGeneralesPage(),
    );
  }
}
