import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/equipo_service.dart';
import '../models/equipo_model.dart';
import '../widgets/drawer_menu.dart';

class EquiposGeneralesPage extends StatefulWidget {
  const EquiposGeneralesPage({super.key});

  @override
  State<EquiposGeneralesPage> createState() => _EquiposGeneralesPageState();
}

class _EquiposGeneralesPageState extends State<EquiposGeneralesPage> {
  List<EquipoModel> equipos = [];
  List<EquipoModel> equiposFiltrados = [];
  EquipoModel? equipoSeleccionado;
  bool cargando = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarEquipos();
  }

  Future<void> cargarEquipos() async {
    setState(() => cargando = true);
    equipos = await EquipoService().obtenerEquipos();
    equiposFiltrados = equipos;
    setState(() => cargando = false);
  }

  void filtrarEquipos(String texto) {
    setState(() {
      equiposFiltrados = equipos
          .where((e) => (e.detalle['nombre_equipo'] ?? '')
              .toString()
              .toLowerCase()
              .contains(texto.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text("Equipos Generales"),
        actions: [
          SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: filtrarEquipos,
                decoration: InputDecoration(
                  hintText: "Buscar...",
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.all(0),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí va la acción para agregar nuevo equipo
        },
        label: const Text("Agregar equipo"),
        icon: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Panel izquierdo: Lista de equipos
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: equiposFiltrados.length,
                    itemBuilder: (context, index) {
                      final eq = equiposFiltrados[index];
                      return ListTile(
                        leading: Icon(
                          eq.tipo == 'Computacional'
                              ? LucideIcons.monitor
                              : eq.tipo == 'Celular'
                                  ? LucideIcons.smartphone
                                  : LucideIcons.printer,
                        ),
                        title: Text(eq.detalle['nombre_equipo'] ?? 'Equipo sin nombre'),
                        subtitle: Text("Tipo: ${eq.tipo}"),
                        trailing: Text("Estado: ${eq.estado}"),
                        selected: equipoSeleccionado == eq,
                        onTap: () {
                          setState(() => equipoSeleccionado = eq);
                        },
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1),
                // Panel derecho: Detalle del equipo seleccionado
                Expanded(
                  flex: 3,
                  child: equipoSeleccionado == null
                      ? const Center(child: Text("Selecciona un equipo para ver el detalle"))
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                equipoSeleccionado!.detalle['nombre_equipo'] ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              ...equipoSeleccionado!.detalle.entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text("${e.key.toUpperCase()}: ${e.value}"),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                    label: const Text("Editar"),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    icon: const Icon(Icons.delete),
                                    label: const Text("Eliminar"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
