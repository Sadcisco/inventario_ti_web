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
    
    // Inicializamos los controladores para cada tipo de equipo
    _inicializarControladores();
    
    // Si estamos editando, cargamos los datos del equipo
    if (widget.equipo != null) {
      print('Cargando datos del equipo para edición: ${widget.equipo!.id}');
      print('Tipo de equipo: ${widget.equipo!.tipo}');
      print('Estado: ${widget.equipo!.estado}');
      print('Observaciones: ${widget.equipo!.observaciones}');
      print('Detalles: ${widget.equipo!.detalle}');
      
      // Establecer el tipo de equipo
      _tipoEquipo = widget.equipo!.tipo;
      
      // Establecer estado y observaciones
      _estadoController.text = widget.equipo!.estado;
      _observacionesController.text = widget.equipo!.observaciones ?? '';
      
      // Cargamos los detalles específicos según el tipo
      _cargarDetallesEspecificos();
    }
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
    _detallesControllers['disco_duro'] = TextEditingController(); 
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
    if (widget.equipo == null) {
      print('No hay equipo para cargar detalles');
      return;
    }
    
    print('Cargando detalles específicos del equipo ID: ${widget.equipo!.id}');
    print('Detalles completos: ${widget.equipo!.detalle}');
    
    // Verificar que los controladores estén inicializados
    if (_detallesControllers.isEmpty) {
      print('ERROR: Los controladores no están inicializados');
      _inicializarControladores();
    }
    
    // Cargar todos los campos del detalle en los controladores correspondientes
    widget.equipo!.detalle.forEach((key, value) {
      if (_detallesControllers.containsKey(key)) {
        print('Cargando campo $key con valor: $value');
        _detallesControllers[key]!.text = value?.toString() ?? '';
      } else {
        print('No existe controlador para el campo: $key');
      }
    });
    
    // Manejar caso especial: disco_duro/almacenamiento
    if (_detallesControllers.containsKey('disco_duro')) {
      if (widget.equipo!.detalle.containsKey('disco_duro')) {
        print('Cargando disco_duro: ${widget.equipo!.detalle['disco_duro']}');
        _detallesControllers['disco_duro']!.text = widget.equipo!.detalle['disco_duro']?.toString() ?? '';
      } else if (widget.equipo!.detalle.containsKey('almacenamiento')) {
        print('Cargando almacenamiento como disco_duro: ${widget.equipo!.detalle['almacenamiento']}');
        _detallesControllers['disco_duro']!.text = widget.equipo!.detalle['almacenamiento']?.toString() ?? '';
      }
    }
    
    // Manejar caso especial: numero_linea/numero
    if (_detallesControllers.containsKey('numero')) {
      if (widget.equipo!.detalle.containsKey('numero_linea')) {
        print('Cargando numero_linea como numero: ${widget.equipo!.detalle['numero_linea']}');
        _detallesControllers['numero']!.text = widget.equipo!.detalle['numero_linea']?.toString() ?? '';
      }
    }
    
    // Imprimir los valores cargados para depuración
    print('\n--- VALORES CARGADOS EN CONTROLADORES ---');
    _detallesControllers.forEach((key, controller) {
      print('Campo $key: "${controller.text}"');
    });
    print('--- FIN DE VALORES CARGADOS ---\n');
  }
  
  // Prepara los datos para enviar al servidor
  Map<String, dynamic> _prepararDatos() {
    // FORZAR el tipo de equipo a uno de los valores válidos
    String tipoEquipoNormalizado;
    
    // Asignar directamente uno de los valores válidos basado en el tipo seleccionado
    if (_tipoEquipo.toLowerCase().contains('compu')) {
      tipoEquipoNormalizado = 'Computacional';
    } else if (_tipoEquipo.toLowerCase().contains('cel')) {
      tipoEquipoNormalizado = 'Celular';
    } else if (_tipoEquipo.toLowerCase().contains('impre')) {
      tipoEquipoNormalizado = 'Impresora';
    } else {
      // Si no podemos determinar, usar Computacional como valor por defecto
      tipoEquipoNormalizado = 'Computacional';
    }
    
    print('[DEBUG] Tipo de equipo original: $_tipoEquipo');
    print('[DEBUG] Tipo de equipo normalizado a: $tipoEquipoNormalizado');
    
    // Si estamos editando, usar el tipo del equipo existente
    if (widget.equipo != null) {
      String tipoOriginal = widget.equipo!.tipo;
      if (tipoOriginal == 'Computacional' || tipoOriginal == 'Celular' || tipoOriginal == 'Impresora') {
        tipoEquipoNormalizado = tipoOriginal;
        print('[DEBUG] Usando tipo de equipo existente: $tipoEquipoNormalizado');
      }
    }
    
    // Datos básicos
    final datos = <String, dynamic>{
      'estado': _estadoController.text,
      'tipo_equipo': tipoEquipoNormalizado,
      'observaciones': _observacionesController.text,
    };
    
    // Agregar campos comunes a todos los tipos
    datos['marca'] = _detallesControllers['marca']!.text;
    datos['modelo'] = _detallesControllers['modelo']!.text;
    datos['serial_number'] = _detallesControllers['serial_number']!.text;
    
    // Agregar campos específicos según el tipo de equipo
    if (tipoEquipoNormalizado == 'Computacional') {
      datos['nombre_equipo'] = _detallesControllers['nombre_equipo']!.text;
      datos['procesador'] = _detallesControllers['procesador']!.text;
      datos['ram'] = _detallesControllers['ram']!.text;
      datos['disco_duro'] = _detallesControllers['disco_duro']!.text;
      datos['sistema_operativo'] = _detallesControllers['sistema_operativo']!.text;
      // Agregar campos opcionales si existen los controladores
      if (_detallesControllers.containsKey('office')) {
        datos['office'] = _detallesControllers['office']!.text;
      }
      if (_detallesControllers.containsKey('antivirus')) {
        datos['antivirus'] = _detallesControllers['antivirus']!.text;
      }
      if (_detallesControllers.containsKey('drive')) {
        datos['drive'] = _detallesControllers['drive']!.text;
      }
    } else if (tipoEquipoNormalizado == 'Celular') {
      datos['imei'] = _detallesControllers['imei']!.text;
      // Asegurarse de usar el nombre correcto del campo
      if (_detallesControllers.containsKey('numero_linea')) {
        datos['numero_linea'] = _detallesControllers['numero_linea']!.text;
      } else if (_detallesControllers.containsKey('numero')) {
        datos['numero_linea'] = _detallesControllers['numero']!.text;
      }
      // Agregar sistema operativo si existe
      if (_detallesControllers.containsKey('sistema_operativo')) {
        datos['sistema_operativo'] = _detallesControllers['sistema_operativo']!.text;
      }
    } else if (tipoEquipoNormalizado == 'Impresora') {
      // Asegurarse de usar el nombre correcto del campo
      if (_detallesControllers.containsKey('tipo_conexion')) {
        datos['tipo_conexion'] = _detallesControllers['tipo_conexion']!.text;
      } else if (_detallesControllers.containsKey('conectividad')) {
        datos['tipo_conexion'] = _detallesControllers['conectividad']!.text;
      }
      // Agregar IP asignada si existe
      if (_detallesControllers.containsKey('ip_asignada')) {
        datos['ip_asignada'] = _detallesControllers['ip_asignada']!.text;
      }
    }
    
    // Agregar código interno si existe
    if (widget.equipo != null && widget.equipo!.codigoInterno.isNotEmpty) {
      datos['codigo_interno'] = widget.equipo!.codigoInterno;
    }
    
    // Si estamos editando, agregamos los datos del equipo existente
    if (widget.equipo != null) {
      // Agregamos información de usuario responsable si está disponible
      if (widget.equipo!.usuarioResponsable?.id != null) {
        datos['id_usuario_responsable'] = widget.equipo!.usuarioResponsable!.id!;
      }
      
      // Agregamos información de área responsable si está disponible
      if (widget.equipo!.areaResponsable?.id != null) {
        datos['id_area_responsable'] = widget.equipo!.areaResponsable!.id!;
      }
      
      // Agregamos información de sucursal si está disponible
      if (widget.equipo!.sucursalUbicacion?.id != null) {
        datos['id_sucursal_ubicacion'] = widget.equipo!.sucursalUbicacion!.id!;
      }
    }
    
    // Imprimir los datos para depuración
    print('Datos preparados para enviar: $datos');
    
    return datos;
  }
  
  // Guarda el equipo (crea o actualiza)
  Future<void> _guardarEquipo() async {
    // Evitar múltiples envíos
    if (_isLoading) return;
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final datos = _prepararDatos();
      
      // Depuración detallada
      print('\n==== DATOS PARA GUARDAR EQUIPO ====');
      print('Tipo de operación: ${widget.equipo != null ? "ACTUALIZACIÓN" : "CREACIÓN"}');
      if (widget.equipo != null) {
        print('ID de inventario: ${widget.equipo!.id}');
        print('Tipo de equipo actual: ${widget.equipo!.tipo}');
      }
      print('Tipo de equipo enviado: ${datos["tipo_equipo"]}');
      print('Estado: ${datos["estado"]}');
      print('Datos completos: $datos');
      print('==============================\n');
      
      bool resultado;
      
      if (widget.equipo != null) {
        // Actualizar equipo existente
        resultado = await _equipoService.actualizarEquipo(widget.equipo!.id, datos);
      } else {
        // Crear nuevo equipo
        resultado = await _equipoService.crearEquipo(datos);
      }
      
      if (resultado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.equipo != null ? 'Equipo actualizado correctamente' : 'Equipo agregado correctamente')),
          );
          Navigator.of(context).pop(true); // Volver a la pantalla anterior con resultado exitoso
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar el equipo')),
          );
        }
      }
    } catch (e) {
      print('Error al guardar equipo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      
      // Intentamos cerrar la pantalla de todos modos si el equipo se creó parcialmente
      if (_equipoService.lastCreatedEquipoId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El equipo se creó pero hubo un error al actualizar la interfaz')),
          );
          Navigator.pop(context, true);
        }
        return;
      }
    } finally {
      // Si llegamos aquí y no hemos cerrado la pantalla, actualizamos el estado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarEquipo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(widget.equipo == null ? 'Crear' : 'Actualizar'),
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
            controller: _detallesControllers['disco_duro'],
            decoration: const InputDecoration(
              labelText: 'Disco Duro',
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
