import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Ojo con la ruta: ../ porque está en otra carpeta

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> inventario = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarInventario();
  }

  void cargarInventario() async {
    try {
      final data = await ApiService.obtenerInventario();
      setState(() {
        inventario = data;
        cargando = false;
      });
    } catch (e) {
      print("Error al cargar: $e");
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario TI")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: inventario.length,
              itemBuilder: (context, index) {
                final item = inventario[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text("Equipo #${item["id"]} - Estado: ${item["estado"]}"),
                    subtitle: Text("Tipo: ${item["detalle"]["tipo"] ?? "N/A"}"),
                  ),
                );
              },
            ),
    );
  }
}
