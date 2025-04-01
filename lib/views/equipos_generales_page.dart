import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EquiposGeneralesPage extends StatefulWidget {
  const EquiposGeneralesPage({super.key});

  @override
  State<EquiposGeneralesPage> createState() => _EquiposGeneralesPageState();
}

class _EquiposGeneralesPageState extends State<EquiposGeneralesPage> {
  List equipos = [];
  Map? equipoSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarEquipos();
  }

  Future<void> cargarEquipos() async {
    try {
      final response = await Dio().get('http://127.0.0.1:5000/inventario');
      setState(() {
        equipos = response.data;
        if (equipos.isNotEmpty) equipoSeleccionado = equipos.first;
      });
    } catch (e) {
      print('Error al cargar equipos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              color: Colors.green[800],
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Text('Inventario TI', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(leading: Icon(LucideIcons.monitor), title: Text('Equipos Generales')),
                  ListTile(leading: Icon(LucideIcons.monitorSmartphone), title: Text('Computacionales')),
                  ListTile(leading: Icon(LucideIcons.smartphone), title: Text('Celulares')),
                  ListTile(leading: Icon(LucideIcons.printer), title: Text('Impresoras')),
                  ListTile(leading: Icon(LucideIcons.history), title: Text('Historial')),
                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('Equipos Generales'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              children: equipos.map((e) {
                final tipo = e['detalle']['tipo'];
                final nombre = e['detalle']['nombre_equipo'] ?? 'Equipo sin nombre';
                final icono = tipo == 'Computacional'
                    ? LucideIcons.monitor
                    : tipo == 'Celular'
                        ? LucideIcons.smartphone
                        : LucideIcons.printer;
                return ListTile(
                  leading: Icon(icono),
                  title: Text(nombre),
                  subtitle: Text("Tipo: $tipo"),
                  trailing: Text("Estado: ${e['estado'] ?? 'SinAsignar'}"),
                  selected: equipoSeleccionado == e,
                  onTap: () => setState(() => equipoSeleccionado = e),
                );
              }).toList(),
            ),
          ),
          Expanded(
            flex: 3,
            child: equipoSeleccionado == null
                ? const Center(child: Text('Selecciona un equipo'))
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(equipoSeleccionado!['detalle']['nombre_equipo'] ?? '',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ...equipoSeleccionado!['detalle'].entries.map((e) => Text("${e.key.toUpperCase()}: ${e.value}")),
                            const Spacer(),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Eliminar'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Agregar equipo'),
      ),
    );
  }
}
