import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/equipo_model.dart';
import '../services/equipo_service.dart';
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/error_message.dart';

/// Pantalla para visualizar y gestionar equipos
class EquiposGeneralesPage extends StatefulWidget {
  const EquiposGeneralesPage({super.key});

  @override
  State<EquiposGeneralesPage> createState() => _EquiposGeneralesPageState();
}

class _EquiposGeneralesPageState extends State<EquiposGeneralesPage> {
  // Estado
  final List<EquipoModel> _equipos = [];
  List<EquipoModel> _equiposFiltrados = [];
  EquipoModel? _equipoSeleccionado;
  
  // UI
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final EquipoService _equipoService = EquipoService();

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los equipos desde el servicio
  Future<void> _cargarEquipos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final equiposResponse = await _equipoService.obtenerEquipos();
      setState(() {
        _equipos.clear();
        _equipos.addAll(equiposResponse);
        _equiposFiltrados = List.from(_equipos);
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

  /// Filtra los equipos según el texto ingresado
  void _filtrarEquipos(String texto) {
    if (texto.isEmpty) {
      setState(() => _equiposFiltrados = List.from(_equipos));
      return;
    }
    
    final textoBusqueda = texto.toLowerCase().trim();
    setState(() {
      _equiposFiltrados = _equipos.where((equipo) {
        // Buscar en varios campos
        final nombreEquipo = equipo.detalle['nombre_equipo']?.toString().toLowerCase() ?? '';
        final marca = equipo.detalle['marca']?.toString().toLowerCase() ?? '';
        final modelo = equipo.detalle['modelo']?.toString().toLowerCase() ?? '';
        final serial = equipo.detalle['serial_number']?.toString().toLowerCase() ?? '';
        final usuario = equipo.usuarioResponsable?.nombre?.toLowerCase() ?? '';
        
        return nombreEquipo.contains(textoBusqueda) ||
               marca.contains(textoBusqueda) ||
               modelo.contains(textoBusqueda) ||
               serial.contains(textoBusqueda) ||
               usuario.contains(textoBusqueda);
      }).toList();
    });
  }

  /// Obtiene el color según el estado del equipo
  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'asignado':
        return AppColors.asignado;
      case 'sinasignar':
        return AppColors.sinAsignar;
      case 'enreparacion':
        return AppColors.enReparacion;
      case 'debaja':
        return AppColors.deBaja;
      default:
        return AppColors.desconocido;
    }
  }
  
  /// Selecciona un equipo para mostrar sus detalles
  void _seleccionarEquipo(EquipoModel equipo) {
    setState(() => _equipoSeleccionado = equipo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEquipos,
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar equipo',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filtrarEquipos,
            ),
          ),
          // Contenido principal
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? ErrorMessage(
                        message: _errorMessage,
                        onRetry: _cargarEquipos,
                      )
                    : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido principal (lista y detalles)
  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista de equipos
        Expanded(
          flex: 1,
          child: _equiposFiltrados.isEmpty
              ? Center(child: Text(ErrorMessages.sinDatos))
              : _buildEquiposList(),
        ),
        // Detalles del equipo
        if (_equipoSeleccionado != null)
          Expanded(
            flex: 2,
            child: _buildEquipoDetails(),
          ),
      ],
    );
  }

  /// Construye la lista de equipos
  Widget _buildEquiposList() {
    return ListView.builder(
      itemCount: _equiposFiltrados.length,
      itemBuilder: (context, index) {
        final equipo = _equiposFiltrados[index];
        final isSelected = _equipoSeleccionado?.id == equipo.id;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(equipo.estado),
              child: Icon(
                equipo.tipo == 'Computacional'
                    ? LucideIcons.laptop
                    : equipo.tipo == 'Celular'
                        ? LucideIcons.smartphone
                        : LucideIcons.printer,
                color: Colors.white,
              ),
            ),
            title: Text(equipo.detalle['nombre_equipo'] ?? 'Sin nombre'),
            subtitle: Text(equipo.tipo),
            trailing: Text(equipo.estado),
            onTap: () => _seleccionarEquipo(equipo),
          ),
        );
      },
    );
  }

  /// Construye el panel de detalles del equipo
  Widget _buildEquipoDetails() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _equipoSeleccionado!.detalle['nombre_equipo'] ?? 'Sin nombre',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Chip(
                  label: Text(_equipoSeleccionado!.estado),
                  backgroundColor: _getStatusColor(_equipoSeleccionado!.estado),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Información general
            _buildSectionTitle(context, 'Información General'),
            _buildInfoRow('Tipo', _equipoSeleccionado!.tipo),
            _buildInfoRow('Marca', _equipoSeleccionado!.detalle['marca'] ?? 'No especificado'),
            _buildInfoRow('Modelo', _equipoSeleccionado!.detalle['modelo'] ?? 'No especificado'),
            _buildInfoRow('Serial', _equipoSeleccionado!.detalle['serial_number'] ?? 'No especificado'),
            const SizedBox(height: 16),
            
            // Información del usuario responsable
            if (_equipoSeleccionado!.usuarioResponsable != null) ...[
              _buildSectionTitle(context, 'Usuario Responsable'),
              _buildInfoRow('Nombre', _equipoSeleccionado!.usuarioResponsable?.nombre ?? 'No asignado'),
              _buildInfoRow('Cargo', _equipoSeleccionado!.usuarioResponsable?.cargo ?? 'No disponible'),
              _buildInfoRow('RUT', _equipoSeleccionado!.usuarioResponsable?.rut ?? 'No disponible'),
              const SizedBox(height: 16),
            ],
            
            // Información del área responsable
            if (_equipoSeleccionado!.areaResponsable != null) ...[
              _buildSectionTitle(context, 'Área Responsable'),
              _buildInfoRow('Nombre', _equipoSeleccionado!.areaResponsable?.nombre ?? 'No asignada'),
              const SizedBox(height: 16),
            ],
            
            // Información de la sucursal
            if (_equipoSeleccionado!.sucursalUbicacion != null) ...[
              _buildSectionTitle(context, 'Sucursal'),
              _buildInfoRow('Nombre', _equipoSeleccionado!.sucursalUbicacion?.nombre ?? 'No asignada'),
              _buildInfoRow('Dirección', _equipoSeleccionado!.sucursalUbicacion?.direccion ?? 'No disponible'),
              const SizedBox(height: 16),
            ],
            
            // Detalles específicos según el tipo de equipo
            _buildSectionTitle(context, 'Detalles Específicos'),
            _buildEquipoTypeDetails(),
            
            const SizedBox(height: 16),
            
            // Acciones
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementar edición
                  },
                  icon: const Icon(LucideIcons.edit),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementar historial
                  },
                  icon: const Icon(LucideIcons.history),
                  label: const Text('Historial'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye los detalles específicos según el tipo de equipo
  Widget _buildEquipoTypeDetails() {
    if (_equipoSeleccionado!.tipo == 'Computacional') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Procesador', _equipoSeleccionado!.detalle['procesador'] ?? 'No especificado'),
          _buildInfoRow('RAM', _equipoSeleccionado!.detalle['ram'] ?? 'No especificado'),
          _buildInfoRow('Almacenamiento', _equipoSeleccionado!.detalle['almacenamiento'] ?? 'No especificado'),
          _buildInfoRow('Sistema Operativo', _equipoSeleccionado!.detalle['sistema_operativo'] ?? 'No especificado'),
        ],
      );
    } else if (_equipoSeleccionado!.tipo == 'Celular') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('IMEI', _equipoSeleccionado!.detalle['imei'] ?? 'No especificado'),
          _buildInfoRow('Número', _equipoSeleccionado!.detalle['numero'] ?? 'No especificado'),
          _buildInfoRow('Plan', _equipoSeleccionado!.detalle['plan'] ?? 'No especificado'),
        ],
      );
    } else if (_equipoSeleccionado!.tipo == 'Impresora') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Tipo', _equipoSeleccionado!.detalle['tipo_impresora'] ?? 'No especificado'),
          _buildInfoRow('Conectividad', _equipoSeleccionado!.detalle['conectividad'] ?? 'No especificado'),
          _buildInfoRow('Tóner/Cartucho', _equipoSeleccionado!.detalle['toner_cartucho'] ?? 'No especificado'),
        ],
      );
    } else {
      return const Text('No hay detalles específicos para este tipo de equipo');
    }
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
