import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/celular_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class CelularesPage extends StatefulWidget {
  const CelularesPage({Key? key}) : super(key: key);

  @override
  State<CelularesPage> createState() => _CelularesPageState();
}

class _CelularesPageState extends State<CelularesPage> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<CelularModel> _celulares = [];
  CelularModel? _selectedCelular;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCelulares();
  }

  Future<void> _loadCelulares() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // TODO: Implementar autenticación JWT
      final response = await _dio.get('$apiUrl/api/celulares');
      
      final List data = response.data;
      setState(() {
        _celulares = data.map((e) => CelularModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        print("Error cargando celulares: $e");
      });
    }
  }

  void _selectCelular(CelularModel celular) {
    setState(() {
      _selectedCelular = celular;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Celulares'),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Cargando celulares...')
          : _hasError
              ? ErrorMessage(
                  message: 'Error al cargar celulares: $_errorMessage',
                  onRetry: _loadCelulares,
                )
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar formulario para agregar celular
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        // Panel izquierdo - Listado de celulares
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar celular',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // TODO: Implementar búsqueda
                    },
                  ),
                ),
                Expanded(
                  child: _celulares.isEmpty
                      ? const Center(child: Text('No hay celulares registrados'))
                      : ListView.builder(
                          itemCount: _celulares.length,
                          itemBuilder: (context, index) {
                            final celular = _celulares[index];
                            return ListTile(
                              title: Text('${celular.marca} ${celular.modelo}'),
                              subtitle: Text('IMEI: ${celular.imei}'),
                              selected: _selectedCelular?.id == celular.id,
                              onTap: () => _selectCelular(celular),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        
        // Panel derecho - Detalles del celular seleccionado
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: _selectedCelular == null
                ? const Center(child: Text('Selecciona un celular para ver sus detalles'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedCelular!.marca} ${_selectedCelular!.modelo}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Código Interno:', _selectedCelular!.codigoInterno),
                        _buildDetailRow('IMEI:', _selectedCelular!.imei),
                        _buildDetailRow('Número de Línea:', _selectedCelular!.numeroLinea),
                        _buildDetailRow('Sistema Operativo:', _selectedCelular!.sistemaOperativo),
                        _buildDetailRow('Almacenamiento:', _selectedCelular!.capacidadAlmacenamiento),
                        _buildDetailRow('Estado:', _selectedCelular!.estado),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                              onPressed: () {
                                // TODO: Implementar edición
                              },
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Eliminar'),
                              onPressed: () {
                                // TODO: Implementar eliminación
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}