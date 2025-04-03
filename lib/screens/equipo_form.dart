import 'package:flutter/material.dart';

import '../models/equipo_model.dart';
import '../services/equipo_service.dart';

/// Pantalla para crear o editar un equipo
class EquipoForm extends StatefulWidget {
  final EquipoModel? equipo;
  
  const EquipoForm({super.key, this.equipo});

  @override
  State<EquipoForm> createState() => _EquipoFormState();
}

class _EquipoFormState extends State<EquipoForm> {
  final _formKey = GlobalKey<FormState>();
  final EquipoService _equipoService = EquipoService();
  
  // Controladores para campos comunes
  final _estadoController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  // Controladores para detalles específicos
  final Map<String, TextEditingController> _detallesControllers = {};
  
  // Estado del formulario
  String _tipoEquipo = 'Computacional';
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // Si estamos editando, cargamos los datos del equipo
    if (widget.equipo != null) {
      _tipoEquipo = widget.equipo!.tipo;
      _estadoController.text = widget.equipo!.estado;
      _observacionesController.text = widget.equipo!.observaciones ?? '';
      
      // Cargamos los detalles específicos según el tipo
      _cargarDetallesEspecificos();
    }
    
    // Inicializamos los controladores para cada tipo de equipo
    _inicializarControladores();
  }
  
  @override
  void dispose() {
    // Liberamos los controladores
    _estadoController.dispose();
    _observacionesController.dispose();
    
    for (var controller in _detallesControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }
  
  // Inicializa los controladores según el tipo de equipo
  void _inicializarControladores() {
    // Campos comunes para todos los tipos
    _detallesControllers['nombre_equipo'] = TextEditingController();
    _detallesControllers['marca'] = TextEditingController();
    _detallesControllers['modelo'] = TextEditingController();
    _detallesControllers['serial_number'] = TextEditingController();
    
    // Campos específicos para computacionales
    _detallesControllers['procesador'] = TextEditingController();
    _detallesControllers['ram'] = TextEditingController();
    _detallesControllers['almacenamiento'] = TextEditingController();
    _detallesControllers['sistema_operativo'] = TextEditingController();
    
    // Campos específicos para celulares
    _detallesControllers['imei'] = TextEditingController();
    _detallesControllers['numero'] = TextEditingController();
    _detallesControllers['plan'] = TextEditingController();
    
    // Campos específicos para impresoras
    _detallesControllers['tipo_impresora'] = TextEditingController();
    _detallesControllers['conectividad'] = TextEditingController();
    _detallesControllers['toner_cartucho'] = TextEditingController();
  }
  
  // Carga los detalles específicos del equipo en edición
  void _cargarDetallesEspecificos() {
    if (widget.equipo == null) return;
    
    widget.equipo!.detalle.forEach((key, value) {
      if (_detallesControllers.containsKey(key) && value != null) {
        _detallesControllers[key]!.text = value.toString();
      }
    });
  }
  
  // Prepara los datos para enviar al servidor
  Map<String, dynamic> _prepararDatos() {
    // Datos básicos
    final datos = {
      'estado': _estadoController.text,
      'tipo_equipo': _tipoEquipo,
      'observaciones': _observacionesController.text,
      'detalle': <String, dynamic>{},
    };
    
    // Agregamos los detalles comunes
    final detalle = datos['detalle'] as Map<String, dynamic>;
    detalle['nombre_equipo'] = _detallesControllers['nombre_equipo']!.text;
    detalle['marca'] = _detallesControllers['marca']!.text;
    detalle['modelo'] = _detallesControllers['modelo']!.text;
    detalle['serial_number'] = _detallesControllers['serial_number']!.text;
    
    // Agregamos detalles específicos según el tipo
    if (_tipoEquipo == 'Computacional') {
      detalle['procesador'] = _detallesControllers['procesador']!.text;
      detalle['ram'] = _detallesControllers['ram']!.text;
      detalle['almacenamiento'] = _detallesControllers['almacenamiento']!.text;
      detalle['sistema_operativo'] = _detallesControllers['sistema_operativo']!.text;
    } else if (_tipoEquipo == 'Celular') {
      detalle['imei'] = _detallesControllers['imei']!.text;
      detalle['numero'] = _detallesControllers['numero']!.text;
      detalle['plan'] = _detallesControllers['plan']!.text;
    } else if (_tipoEquipo == 'Impresora') {
      detalle['tipo_impresora'] = _detallesControllers['tipo_impresora']!.text;
      detalle['conectividad'] = _detallesControllers['conectividad']!.text;
      detalle['toner_cartucho'] = _detallesControllers['toner_cartucho']!.text;
    }
    
    return datos;
  }
  
  // Guarda el equipo (crea o actualiza)
  Future<void> _guardarEquipo() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final datos = _prepararDatos();
    bool resultado;
    
    try {
      if (widget.equipo == null) {
        // Crear nuevo equipo
        resultado = await _equipoService.crearEquipo(datos);
      } else {
        // Actualizar equipo existente
        resultado = await _equipoService.actualizarEquipo(widget.equipo!.id, datos);
      }
      
      if (resultado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.equipo == null ? 'Equipo creado con éxito' : 'Equipo actualizado con éxito')),
          );
          Navigator.pop(context, true); // Regresamos con resultado exitoso
        }
      } else {
        setState(() {
          _errorMessage = 'Error al guardar el equipo. Intente nuevamente.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipo == null ? 'Nuevo Equipo' : 'Editar Equipo'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje de error
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Tipo de equipo
                  Text(
                    'Tipo de Equipo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _tipoEquipo,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Computacional', child: Text('Computacional')),
                      DropdownMenuItem(value: 'Celular', child: Text('Celular')),
                      DropdownMenuItem(value: 'Impresora', child: Text('Impresora')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _tipoEquipo = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Estado
                  Text(
                    'Estado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _estadoController.text.isEmpty ? 'SinAsignar' : _estadoController.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SinAsignar', child: Text('Sin Asignar')),
                      DropdownMenuItem(value: 'Asignado', child: Text('Asignado')),
                      DropdownMenuItem(value: 'EnReparacion', child: Text('En Reparación')),
                      DropdownMenuItem(value: 'DeBaja', child: Text('De Baja')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estadoController.text = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Información general
                  Text(
                    'Información General',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detallesControllers['nombre_equipo'],
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Equipo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detallesControllers['marca'],
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la marca';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detallesControllers['modelo'],
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el modelo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detallesControllers['serial_number'],
                    decoration: const InputDecoration(
                      labelText: 'Número de Serie',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el número de serie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Detalles específicos según el tipo
                  Text(
                    'Detalles Específicos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTipoEspecificoFields(),
                  const SizedBox(height: 16),
                  
                  // Observaciones
                  Text(
                    'Observaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _observacionesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _guardarEquipo,
                        child: Text(widget.equipo == null ? 'Crear' : 'Actualizar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
  
  // Construye los campos específicos según el tipo de equipo
  Widget _buildTipoEspecificoFields() {
    if (_tipoEquipo == 'Computacional') {
      return Column(
        children: [
          TextFormField(
            controller: _detallesControllers['procesador'],
            decoration: const InputDecoration(
              labelText: 'Procesador',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['ram'],
            decoration: const InputDecoration(
              labelText: 'RAM',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['almacenamiento'],
            decoration: const InputDecoration(
              labelText: 'Almacenamiento',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['sistema_operativo'],
            decoration: const InputDecoration(
              labelText: 'Sistema Operativo',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else if (_tipoEquipo == 'Celular') {
      return Column(
        children: [
          TextFormField(
            controller: _detallesControllers['imei'],
            decoration: const InputDecoration(
              labelText: 'IMEI',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['numero'],
            decoration: const InputDecoration(
              labelText: 'Número',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['plan'],
            decoration: const InputDecoration(
              labelText: 'Plan',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else if (_tipoEquipo == 'Impresora') {
      return Column(
        children: [
          TextFormField(
            controller: _detallesControllers['tipo_impresora'],
            decoration: const InputDecoration(
              labelText: 'Tipo de Impresora',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['conectividad'],
            decoration: const InputDecoration(
              labelText: 'Conectividad',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detallesControllers['toner_cartucho'],
            decoration: const InputDecoration(
              labelText: 'Tóner/Cartucho',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else {
      return const Text('Tipo de equipo no soportado');
    }
  }
}
