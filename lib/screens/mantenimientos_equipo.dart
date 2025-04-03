import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/equipo_model.dart';
import '../models/mantenimiento_model.dart';
import '../services/mantenimiento_service.dart';
import '../utils/constants.dart';
import '../widgets/error_message.dart';

/// Pantalla para visualizar y gestionar los mantenimientos de un equipo
class MantenimientosEquipoPage extends StatefulWidget {
  final EquipoModel equipo;
  
  const MantenimientosEquipoPage({super.key, required this.equipo});

  @override
  State<MantenimientosEquipoPage> createState() => _MantenimientosEquipoPageState();
}

class _MantenimientosEquipoPageState extends State<MantenimientosEquipoPage> {
  final MantenimientoService _mantenimientoService = MantenimientoService();
  
  // Estado
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<MantenimientoModel> _mantenimientos = [];
  
  @override
  void initState() {
    super.initState();
    _cargarMantenimientos();
  }
  
  /// Carga los mantenimientos del equipo desde el servicio
  Future<void> _cargarMantenimientos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final mantenimientosResponse = await _mantenimientoService.obtenerMantenimientosEquipo(widget.equipo.id);
      setState(() {
        _mantenimientos = mantenimientosResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = ErrorMessages.errorCarga;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mantenimientos de ${widget.equipo.detalle['nombre_equipo'] ?? '#${widget.equipo.id}'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarMantenimientos,
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioMantenimiento(context),
        tooltip: 'Registrar Mantenimiento',
        child: const Icon(LucideIcons.wrench),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_hasError) {
      return Center(
        child: ErrorMessage(
          message: _errorMessage,
          onRetry: _cargarMantenimientos,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del equipo
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Equipo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Tipo', widget.equipo.tipo),
                  _buildInfoRow('Estado', widget.equipo.estado),
                  _buildInfoRow('Marca', widget.equipo.detalle['marca'] ?? 'No especificada'),
                  _buildInfoRow('Modelo', widget.equipo.detalle['modelo'] ?? 'No especificado'),
                  _buildInfoRow('Serial', widget.equipo.detalle['serial_number'] ?? 'No especificado'),
                ],
              ),
            ),
          ),
        ),
        
        // Título de mantenimientos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Historial de Mantenimientos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        
        // Lista de mantenimientos
        Expanded(
          child: _mantenimientos.isEmpty
              ? const Center(child: Text('No hay registros de mantenimientos para este equipo'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _mantenimientos.length,
                  itemBuilder: (context, index) {
                    final mantenimiento = _mantenimientos[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: const Icon(LucideIcons.wrench),
                        title: Text(mantenimiento.descripcion),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: ${_formatDate(mantenimiento.fecha)}'),
                            Text('Realizado por: ${mantenimiento.realizadoPor}'),
                            if (mantenimiento.observaciones != null && mantenimiento.observaciones!.isNotEmpty)
                              Text('Observaciones: ${mantenimiento.observaciones}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(LucideIcons.trash, color: Colors.red),
                          tooltip: 'Eliminar mantenimiento',
                          onPressed: () => _mostrarDialogoEliminarMantenimiento(mantenimiento),
                        ),
                        onTap: () => _mostrarDetallesMantenimiento(mantenimiento),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  /// Formatea una fecha para mostrarla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  /// Muestra un diálogo con los detalles del mantenimiento
  void _mostrarDetallesMantenimiento(MantenimientoModel mantenimiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Mantenimiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Fecha', _formatDate(mantenimiento.fecha)),
            _buildInfoRow('Descripción', mantenimiento.descripcion),
            _buildInfoRow('Realizado por', mantenimiento.realizadoPor),
            if (mantenimiento.observaciones != null)
              _buildInfoRow('Observaciones', mantenimiento.observaciones!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarFormularioMantenimiento(context, mantenimiento: mantenimiento);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
  
  /// Muestra un diálogo para eliminar un mantenimiento
  Future<void> _mostrarDialogoEliminarMantenimiento(MantenimientoModel mantenimiento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro que desea eliminar este registro de mantenimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirmar != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final resultado = await _mantenimientoService.eliminarMantenimiento(mantenimiento.id);
      
      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mantenimiento eliminado con éxito')),
        );
        _cargarMantenimientos();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al eliminar el mantenimiento';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
    }
  }
  
  /// Muestra un formulario para crear o editar un mantenimiento
  Future<void> _mostrarFormularioMantenimiento(
    BuildContext context, {
    MantenimientoModel? mantenimiento,
  }) async {
    final descripcionController = TextEditingController(text: mantenimiento?.descripcion ?? '');
    final realizadoPorController = TextEditingController(text: mantenimiento?.realizadoPor ?? '');
    final observacionesController = TextEditingController(text: mantenimiento?.observaciones ?? '');
    
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mantenimiento == null ? 'Registrar Mantenimiento' : 'Editar Mantenimiento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: realizadoPorController,
                decoration: const InputDecoration(
                  labelText: 'Realizado por',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validar campos
              if (descripcionController.text.isEmpty || realizadoPorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete los campos obligatorios')),
                );
                return;
              }
              
              // Preparar datos
              final datos = {
                'id_inventario': widget.equipo.id,
                'descripcion': descripcionController.text,
                'realizado_por': realizadoPorController.text,
                'observaciones': observacionesController.text,
                'fecha': DateTime.now().toIso8601String(),
              };
              
              bool resultado;
              if (mantenimiento == null) {
                // Crear nuevo
                resultado = await _mantenimientoService.crearMantenimiento(datos);
              } else {
                // Actualizar existente
                resultado = await _mantenimientoService.actualizarMantenimiento(
                  mantenimiento.id, 
                  datos,
                );
              }
              
              if (resultado) {
                Navigator.pop(context, true);
                _cargarMantenimientos();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      mantenimiento == null
                          ? 'Error al registrar mantenimiento'
                          : 'Error al actualizar mantenimiento',
                    ),
                  ),
                );
              }
            },
            child: Text(mantenimiento == null ? 'Registrar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }
  
  /// Construye una fila de información con etiqueta y valor
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
