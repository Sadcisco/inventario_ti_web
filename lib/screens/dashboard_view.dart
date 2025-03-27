import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<dynamic> inventario = [];
  Map<String, dynamic>? equipoSeleccionado;
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
      print("Error al cargar inventario: $e");
      setState(() {
        cargando = false;
      });
    }
  }

  void mostrarFormularioNuevoEquipo() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController codigoCtrl = TextEditingController();
    final TextEditingController marcaCtrl = TextEditingController();
    final TextEditingController modeloCtrl = TextEditingController();
    final TextEditingController procesadorCtrl = TextEditingController();
    final TextEditingController ramCtrl = TextEditingController();
    final TextEditingController sistemaCtrl = TextEditingController();
    final TextEditingController estadoCtrl = TextEditingController(text: "SinAsignar");
    final TextEditingController usuarioCtrl = TextEditingController();
    final TextEditingController areaCtrl = TextEditingController();
    final TextEditingController sucursalCtrl = TextEditingController();
    final TextEditingController obsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("Nuevo Equipo Computacional"),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(controller: codigoCtrl, decoration: const InputDecoration(labelText: 'Código interno')),
                TextFormField(controller: marcaCtrl, decoration: const InputDecoration(labelText: 'Marca')),
                TextFormField(controller: modeloCtrl, decoration: const InputDecoration(labelText: 'Modelo')),
                TextFormField(controller: procesadorCtrl, decoration: const InputDecoration(labelText: 'Procesador')),
                TextFormField(controller: ramCtrl, decoration: const InputDecoration(labelText: 'RAM')),
                TextFormField(controller: sistemaCtrl, decoration: const InputDecoration(labelText: 'Sistema Operativo')),
                TextFormField(controller: estadoCtrl, decoration: const InputDecoration(labelText: 'Estado')),
                TextFormField(controller: usuarioCtrl, decoration: const InputDecoration(labelText: 'ID Usuario Responsable')),
                TextFormField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'ID Área Responsable')),
                TextFormField(controller: sucursalCtrl, decoration: const InputDecoration(labelText: 'ID Sucursal')),
                TextFormField(controller: obsCtrl, decoration: const InputDecoration(labelText: 'Observaciones')),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Guardar"),
              onPressed: () async {
                final body = {
                  "tipo": "Computacional",
                  "estado": estadoCtrl.text,
                  "id_usuario_responsable": int.tryParse(usuarioCtrl.text),
                  "id_area_responsable": int.tryParse(areaCtrl.text),
                  "id_sucursal_ubicacion": int.tryParse(sucursalCtrl.text),
                  "observaciones": obsCtrl.text,
                  "equipo": {
                    "codigo_interno": codigoCtrl.text,
                    "marca": marcaCtrl.text,
                    "modelo": modeloCtrl.text,
                    "procesador": procesadorCtrl.text,
                    "ram": ramCtrl.text,
                    "sistema_operativo": sistemaCtrl.text,
                    "disco_duro": "",
                    "office": "",
                    "antivirus": "",
                    "drive": "",
                    "nombre_equipo": "",
                    "serial_number": "",
                    "fecha_revision": "2024-01-01",
                    "entregado_por": "",
                    "comentarios": ""
                  }
                };

                try {
                  final url = Uri.parse("http://127.0.0.1:5000/inventario");
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(body),
                  );

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop();
                    cargarInventario();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Equipo registrado correctamente")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${response.body}")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB6F7A5),
        title: const Text('Inventario TI'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: mostrarFormularioNuevoEquipo),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: const Color(0xFFE8FDE5),
                    child: ListView.builder(
                      itemCount: inventario.length,
                      itemBuilder: (context, index) {
                        final item = inventario[index];
                        return ListTile(
                          selected: equipoSeleccionado?['id'] == item['id'],
                          selectedTileColor: const Color(0xFFD0F5C3),
                          title: Text("Equipo #${item['id']} - Estado: ${item['estado']}"),
                          subtitle: Text("Tipo: ${item['detalle']['tipo'] ?? 'N/A'}"),
                          onTap: () {
                            setState(() {
                              equipoSeleccionado = item;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: equipoSeleccionado == null
                        ? const Center(
                            child: Text('Selecciona un equipo del listado'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detalle del Equipo #${equipoSeleccionado!['id']}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 20),
                              Text("Tipo: ${equipoSeleccionado!['detalle']['tipo'] ?? 'N/A'}"),
                              Text("Estado: ${equipoSeleccionado!['estado']}"),
                              Text("Responsable ID: ${equipoSeleccionado!['responsable_id'] ?? 'N/A'}"),
                              Text("Área ID: ${equipoSeleccionado!['area_id'] ?? 'N/A'}"),
                              Text("Sucursal ID: ${equipoSeleccionado!['sucursal_id'] ?? 'N/A'}"),
                              Text("Observaciones: ${equipoSeleccionado!['observaciones'] ?? ''}"),
                              Text("Fecha ingreso: ${equipoSeleccionado!['fecha_ingreso'] ?? ''}"),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
