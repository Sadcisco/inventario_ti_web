import 'package:flutter/material.dart';


void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario TI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB6F7A5), // Verde manzana
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardView(),
    );
  }
}
