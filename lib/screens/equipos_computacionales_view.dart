import 'package:flutter/material.dart';

class EquiposComputacionalesView extends StatelessWidget {
  const EquiposComputacionalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Equipos Computacionales")),
      body: const Center(child: Text("Aquí irá el listado de equipos computacionales")),
    );
  }
}
