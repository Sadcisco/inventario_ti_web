import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/equipo_model.dart';
import '../models/historial_model.dart';
import '../services/historial_service.dart';
import '../utils/constants.dart';
import '../widgets/error_message.dart';

/// Pantalla para visualizar el historial de un equipo
class HistorialEquipoPage extends StatefulWidget {
  final EquipoModel equipo;
  
  const HistorialEquipoPage({super.key, required this.equipo});

  @override
  State<HistorialEquipoPage> createState() => _HistorialEquipoPageState();
}

class _HistorialEquipoPageState extends State<HistorialEquipoPage> {
  final HistorialService _historialService = HistorialService();
  
  // Estado
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<HistorialModel> _historial = [];
  
  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }
  
  /// Carga el historial del equipo desde el servicio
  Future<void> _cargarHistorial() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final historialResponse = await _historialService.obtenerHistorialEquipo(widget.equipo.id);
      setState(() {
        _historial = historialResponse;
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
        title: Text('Historial de Equipo ${widget.equipo.detalle['nombre_equipo'] ?? '#${widget.equipo.id}'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarHistorial,
          ),
        ],
      ),
      body: _buildContent(),
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
          onRetry: _cargarHistorial,
        ),
      );
    }
    
    if (_historial.isEmpty) {
      return const Center(
        child: Text('No hay registros de historial para este equipo'),
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
        
        // Título de historial
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Historial de Asignaciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        
        // Lista de historial
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _historial.length,
            itemBuilder: (context, index) {
              final item = _historial[index];
              final isActive = item.fechaTermino == null;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                color: isActive ? Colors.green[50] : null,
                child: ListTile(
                  leading: Icon(
                    isActive ? LucideIcons.userCheck : LucideIcons.user,
                    color: isActive ? Colors.green : null,
                  ),
                  title: Text(item.nombreUsuario),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asignado: ${_formatDate(item.fechaAsignacion)}'),
                      if (item.fechaTermino != null)
                        Text('Finalizado: ${_formatDate(item.fechaTermino!)}'),
                      if (item.observaciones != null && item.observaciones!.isNotEmpty)
                        Text('Nota: ${item.observaciones}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: isActive
                      ? IconButton(
                          icon: const Icon(LucideIcons.userMinus, color: Colors.red),
                          tooltip: 'Finalizar asignación',
                          onPressed: () => _mostrarDialogoFinalizarAsignacion(item),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        
        // Botón para agregar nueva asignación
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.userPlus),
              label: const Text('Nueva Asignación'),
              onPressed: _mostrarDialogoNuevaAsignacion,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Formatea una fecha para mostrarla
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Muestra un diálogo para finalizar una asignación
  Future<void> _mostrarDialogoFinalizarAsignacion(HistorialModel historial) async {
    final observacionesController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Asignación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Desea finalizar la asignación de ${historial.nombreUsuario}?'),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    
    if (result != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final datos = {
        'fecha_termino': DateTime.now().toIso8601String(),
        'observaciones': observacionesController.text,
      };
      
      final resultado = await _historialService.finalizarAsignacion(historial.id, datos);
      
      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asignación finalizada con éxito')),
        );
        _cargarHistorial();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al finalizar la asignación';
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
  
  /// Muestra un diálogo para crear una nueva asignación
  Future<void> _mostrarDialogoNuevaAsignacion() async {
    // TODO: Implementar selección de usuario desde una lista
    final nombreController = TextEditingController();
    final observacionesController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Asignación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Usuario',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
    
    if (result != true) return;
    
    if (nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe ingresar el nombre del usuario')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // En una implementación real, aquí se seleccionaría un usuario existente
      // Por ahora, simulamos con un ID fijo
      final datos = {
        'id_inventario': widget.equipo.id,
        'id_usuario': 1, // Este debería ser el ID real del usuario seleccionado
        'nombre_usuario': nombreController.text,
        'fecha_asignacion': DateTime.now().toIso8601String(),
        'observaciones': observacionesController.text,
      };
      
      final resultado = await _historialService.agregarHistorial(datos);
      
      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo asignado con éxito')),
        );
        _cargarHistorial();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al asignar el equipo';
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
