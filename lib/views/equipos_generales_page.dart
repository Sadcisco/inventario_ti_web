import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class EquiposGeneralesPage extends StatefulWidget {
  const EquiposGeneralesPage({super.key});

  @override
  State<EquiposGeneralesPage> createState() => _EquiposGeneralesPageState();
}

class _EquiposGeneralesPageState extends State<EquiposGeneralesPage> {
  List equipos = [];
  Map? equipoSeleccionado;
  final Dio _dio = Dio();
  bool isLoading = true;
  String? errorMessage;
  
  // Método para construir secciones de información
  Widget _buildInfoSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.keys.first.isNotEmpty)
                SizedBox(
                  width: 100,
                  child: Text(
                    "${item.keys.first}:", 
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              Expanded(
                child: Text(
                  "${item.values.first}",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        )),
        const Divider(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Configurar interceptor para JWT
    _dio.interceptors.add(JwtInterceptor());
    cargarEquipos();
  }

  Future<void> cargarEquipos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      // Usar la URL de la configuración correcta
      final response = await _dio.get('$apiUrl/inventario/');
      
      setState(() {
        equipos = response.data;
        isLoading = false;
        print('Equipos cargados: ${equipos.length}');
        if (equipos.isNotEmpty) equipoSeleccionado = equipos.first;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al cargar equipos: ${e.toString()}';
      });
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: cargarEquipos,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ))
                    : equipos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No hay equipos registrados.'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: cargarEquipos,
                                  child: const Text('Actualizar'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: cargarEquipos,
                            child: ListView(
                              children: equipos.map((e) {
                                final equipo = e['equipo'] ?? {};
                                final tipo = equipo['tipo_equipo'] ?? 'Desconocido';
                                final nombre = equipo['nombre_equipo'] ?? equipo['codigo_interno'] ?? 'Equipo sin nombre';
                                final icono = tipo.toString().contains('Computacional')
                                    ? LucideIcons.monitor
                                    : tipo.toString().contains('Celular')
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
                            Text(
                                equipoSeleccionado!['equipo']['nombre_equipo'] ?? 
                                equipoSeleccionado!['equipo']['codigo_interno'] ?? 
                                'Equipo',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoSection('Información General', [
                                      {'Código': equipoSeleccionado!['equipo']['codigo_interno'] ?? 'N/A'},
                                      {'Tipo': equipoSeleccionado!['equipo']['tipo_equipo'] ?? 'N/A'},
                                      {'Estado': equipoSeleccionado!['estado'] ?? 'N/A'},
                                      {'Marca': equipoSeleccionado!['equipo']['marca'] ?? 'N/A'},
                                      {'Modelo': equipoSeleccionado!['equipo']['modelo'] ?? 'N/A'},
                                      {'Serial': equipoSeleccionado!['equipo']['serial_number'] ?? 'N/A'},
                                    ]),
                                    if (equipoSeleccionado!['equipo']['procesador'] != null)
                                      _buildInfoSection('Especificaciones Técnicas', [
                                        {'Procesador': equipoSeleccionado!['equipo']['procesador'] ?? 'N/A'},
                                        {'RAM': equipoSeleccionado!['equipo']['ram'] ?? 'N/A'},
                                        {'Disco': equipoSeleccionado!['equipo']['disco_duro'] ?? 'N/A'},
                                        {'S.O.': equipoSeleccionado!['equipo']['sistema_operativo'] ?? 'N/A'},
                                      ]),
                                    if (equipoSeleccionado!['responsable'] != null)
                                      _buildInfoSection('Responsable', [
                                        {'Nombre': equipoSeleccionado!['responsable']['nombre'] ?? 'N/A'},
                                        {'Cargo': equipoSeleccionado!['responsable']['cargo'] ?? 'N/A'},
                                      ]),
                                    if (equipoSeleccionado!['sucursal'] != null)
                                      _buildInfoSection('Ubicación', [
                                        {'Sucursal': equipoSeleccionado!['sucursal']['nombre'] ?? 'N/A'},
                                        {'Dirección': equipoSeleccionado!['sucursal']['direccion'] ?? 'N/A'},
                                      ]),
                                    _buildInfoSection('Observaciones', [
                                      {'': equipoSeleccionado!['observaciones'] ?? 'Sin observaciones'},
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
