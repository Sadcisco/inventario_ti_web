import 'package:flutter/material.dart';
import 'screens/equipos_generales_view.dart';
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
