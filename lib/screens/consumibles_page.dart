import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/consumible_model.dart';
import '../services/consumible_service.dart';
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/error_message.dart';

/// Pantalla para visualizar y gestionar consumibles
class ConsumiblesPage extends StatefulWidget {
  const ConsumiblesPage({super.key});

  @override
  State<ConsumiblesPage> createState() => _ConsumiblesPageState();
}

class _ConsumiblesPageState extends State<ConsumiblesPage> {
  // Estado
  final List<ConsumibleModel> _consumibles = [];
  List<ConsumibleModel> _consumiblesFiltrados = [];
  ConsumibleModel? _consumibleSeleccionado;
  
  // UI
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final ConsumibleService _consumibleService = ConsumibleService();

  @override
  void initState() {
    super.initState();
    _cargarConsumibles();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los consumibles desde el servicio
  Future<void> _cargarConsumibles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final consumiblesResponse = await _consumibleService.obtenerConsumibles();
      setState(() {
        _consumibles.clear();
        _consumibles.addAll(consumiblesResponse);
        _consumiblesFiltrados = List.from(_consumibles);
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

  /// Filtra los consumibles según el texto ingresado
  void _filtrarConsumibles(String texto) {
    if (texto.isEmpty) {
      setState(() => _consumiblesFiltrados = List.from(_consumibles));
      return;
    }
    
    final textoBusqueda = texto.toLowerCase().trim();
    setState(() {
      _consumiblesFiltrados = _consumibles.where((consumible) {
        // Buscar en varios campos
        final tipo = consumible.tipo.toLowerCase();
        final marca = consumible.marca.toLowerCase();
        final modelo = consumible.modelo.toLowerCase();
        final sucursal = consumible.sucursal?['nombre']?.toString().toLowerCase() ?? '';
        
        return tipo.contains(textoBusqueda) ||
               marca.contains(textoBusqueda) ||
               modelo.contains(textoBusqueda) ||
               sucursal.contains(textoBusqueda);
      }).toList();
    });
  }
  
  /// Selecciona un consumible para mostrar sus detalles
  void _seleccionarConsumible(ConsumibleModel consumible) {
    setState(() => _consumibleSeleccionado = consumible);
  }
  
  /// Abre el diálogo para agregar un nuevo consumible
  Future<void> _agregarConsumible(BuildContext context) async {
    final result = await _mostrarFormularioConsumible(context);
    
    if (result == true) {
      _cargarConsumibles(); // Recargamos la lista si se creó un consumible
    }
  }
  
  /// Abre el diálogo para editar un consumible existente
  Future<void> _editarConsumible(BuildContext context) async {
    if (_consumibleSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un consumible para editar')),
      );
      return;
    }
    
    final result = await _mostrarFormularioConsumible(
      context, 
      consumible: _consumibleSeleccionado,
    );
    
    if (result == true) {
      _cargarConsumibles(); // Recargamos la lista si se editó un consumible
    }
  }
  
  /// Muestra un diálogo de confirmación y elimina el consumible seleccionado
  Future<void> _eliminarConsumible(BuildContext context) async {
    if (_consumibleSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un consumible para eliminar')),
      );
      return;
    }
    
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro que desea eliminar el consumible ${_consumibleSeleccionado!.marca} ${_consumibleSeleccionado!.modelo}?'),
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
    
    // Mostrar indicador de carga
    setState(() => _isLoading = true);
    
    try {
      final resultado = await _consumibleService.eliminarConsumible(_consumibleSeleccionado!.id);
      
      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consumible eliminado con éxito')),
        );
        
        setState(() {
          _consumibleSeleccionado = null;
          _cargarConsumibles();
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al eliminar el consumible';
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
  
  /// Abre un diálogo para registrar una salida de stock
  Future<void> _registrarSalida(BuildContext context) async {
    if (_consumibleSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un consumible para registrar salida')),
      );
      return;
    }
    
    final cantidadController = TextEditingController();
    final observacionesController = TextEditingController();
    
    // Mostrar diálogo para ingresar la cantidad
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Salida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Consumible: ${_consumibleSeleccionado!.marca} ${_consumibleSeleccionado!.modelo}'),
            Text('Stock actual: ${_consumibleSeleccionado!.stockActual}'),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    
    if (result != true) return;
    
    // Validar cantidad
    final cantidad = int.tryParse(cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una cantidad válida')),
      );
      return;
    }
    
    if (cantidad > _consumibleSeleccionado!.stockActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad no puede ser mayor al stock actual')),
      );
      return;
    }
    
    // Mostrar indicador de carga
    setState(() => _isLoading = true);
    
    try {
      // Registrar la salida
      final nuevoStock = _consumibleSeleccionado!.stockActual - cantidad;
      final resultado = await _consumibleService.actualizarStock(
        _consumibleSeleccionado!.id, 
        nuevoStock,
      );
      
      if (resultado) {
        // Registrar en el historial de salidas (esto sería implementado en el backend)
        final datosSalida = {
          'id_consumible': _consumibleSeleccionado!.id,
          'cantidad': cantidad,
          'observaciones': observacionesController.text,
          'fecha': DateTime.now().toIso8601String(),
        };
        
        await _consumibleService.registrarSalida(datosSalida);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salida registrada con éxito')),
        );
        
        _cargarConsumibles();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al registrar la salida';
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
  
  /// Muestra un formulario para crear o editar un consumible
  Future<bool?> _mostrarFormularioConsumible(
    BuildContext context, {
    ConsumibleModel? consumible,
  }) async {
    final tipoController = TextEditingController(text: consumible?.tipo ?? 'Toner');
    final marcaController = TextEditingController(text: consumible?.marca ?? '');
    final modeloController = TextEditingController(text: consumible?.modelo ?? '');
    final stockActualController = TextEditingController(
      text: consumible?.stockActual.toString() ?? '0',
    );
    final stockMinimoController = TextEditingController(
      text: consumible?.stockMinimo.toString() ?? '0',
    );
    
    String tipoSeleccionado = consumible?.tipo ?? 'Toner';
    
    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(consumible == null ? 'Nuevo Consumible' : 'Editar Consumible'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tipo de consumible
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Toner', child: Text('Toner')),
                    DropdownMenuItem(value: 'Tambor', child: Text('Tambor')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => tipoSeleccionado = value);
                      tipoController.text = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Marca
                TextField(
                  controller: marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Modelo
                TextField(
                  controller: modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stock actual
                TextField(
                  controller: stockActualController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Actual',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Stock mínimo
                TextField(
                  controller: stockMinimoController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Mínimo',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                if (marcaController.text.isEmpty || modeloController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete los campos obligatorios')),
                  );
                  return;
                }
                
                final stockActual = int.tryParse(stockActualController.text) ?? 0;
                final stockMinimo = int.tryParse(stockMinimoController.text) ?? 0;
                
                // Preparar datos
                final datos = {
                  'tipo': tipoSeleccionado,
                  'marca': marcaController.text,
                  'modelo': modeloController.text,
                  'stock_actual': stockActual,
                  'stock_minimo': stockMinimo,
                  // En una implementación real, aquí se seleccionaría la sucursal
                  'id_sucursal_stock': 1,
                };
                
                bool resultado;
                if (consumible == null) {
                  // Crear nuevo
                  resultado = await _consumibleService.crearConsumible(datos);
                } else {
                  // Actualizar existente
                  resultado = await _consumibleService.actualizarConsumible(
                    consumible.id, 
                    datos,
                  );
                }
                
                if (resultado) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        consumible == null
                            ? 'Error al crear consumible'
                            : 'Error al actualizar consumible',
                      ),
                    ),
                  );
                }
              },
              child: Text(consumible == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Consumibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarConsumibles,
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarConsumible(context),
        tooltip: 'Agregar Consumible',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_hasError) {
      return Center(
        child: ErrorMessage(
          message: _errorMessage,
          onRetry: _cargarConsumibles,
        ),
      );
    }
    
    return Row(
      children: [
        // Lista de consumibles (1/3 del ancho)
        Expanded(
          flex: 1,
          child: _buildConsumiblesList(),
        ),
        
        // Detalles del consumible seleccionado (2/3 del ancho)
        Expanded(
          flex: 2,
          child: _buildConsumibleDetails(),
        ),
      ],
    );
  }
  
  /// Construye la lista de consumibles
  Widget _buildConsumiblesList() {
    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar consumible',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filtrarConsumibles,
          ),
        ),
        
        // Lista
        Expanded(
          child: _consumiblesFiltrados.isEmpty
              ? const Center(child: Text('No hay consumibles disponibles'))
              : ListView.builder(
                  itemCount: _consumiblesFiltrados.length,
                  itemBuilder: (context, index) {
                    final consumible = _consumiblesFiltrados[index];
                    final isSelected = _consumibleSeleccionado?.id == consumible.id;
                    
                    // Determinar si el stock está por debajo del mínimo
                    final bool stockBajo = consumible.stockActual <= consumible.stockMinimo;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: ListTile(
                        leading: Icon(
                          consumible.tipo == 'Toner' ? LucideIcons.printer : LucideIcons.box,
                          color: stockBajo ? Colors.red : null,
                        ),
                        title: Text('${consumible.marca} ${consumible.modelo}'),
                        subtitle: Text(
                          'Stock: ${consumible.stockActual} (Mín: ${consumible.stockMinimo})',
                          style: TextStyle(
                            color: stockBajo ? Colors.red : null,
                            fontWeight: stockBajo ? FontWeight.bold : null,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () => _seleccionarConsumible(consumible),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  /// Construye el panel de detalles del consumible
  Widget _buildConsumibleDetails() {
    if (_consumibleSeleccionado == null) {
      return const Center(
        child: Text('Seleccione un consumible para ver sus detalles'),
      );
    }
    
    // Determinar si el stock está por debajo del mínimo
    final bool stockBajo = _consumibleSeleccionado!.stockActual <= _consumibleSeleccionado!.stockMinimo;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            '${_consumibleSeleccionado!.marca} ${_consumibleSeleccionado!.modelo}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // Información general
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Información General'),
                  _buildInfoRow('Tipo', _consumibleSeleccionado!.tipo),
                  _buildInfoRow('Marca', _consumibleSeleccionado!.marca),
                  _buildInfoRow('Modelo', _consumibleSeleccionado!.modelo),
                  const SizedBox(height: 16),
                  
                  // Stock
                  _buildSectionTitle(context, 'Inventario'),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: stockBajo ? Colors.red.shade50 : Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Stock Actual',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _consumibleSeleccionado!.stockActual.toString(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: stockBajo ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Stock Mínimo',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _consumibleSeleccionado!.stockMinimo.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (stockBajo)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'El stock está por debajo del mínimo recomendado',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Ubicación
                  _buildSectionTitle(context, 'Ubicación'),
                  _buildInfoRow(
                    'Sucursal',
                    _consumibleSeleccionado!.sucursal?['nombre'] ?? 'No asignada',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Acciones
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _editarConsumible(context),
                        icon: const Icon(LucideIcons.edit),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _eliminarConsumible(context),
                        icon: const Icon(LucideIcons.trash),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        label: const Text('Eliminar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _registrarSalida(context),
                        icon: const Icon(LucideIcons.packageMinus),
                        label: const Text('Registrar Salida'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye un título de sección
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
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
            width: 120,
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
