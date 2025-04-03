import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../services/dashboard_service.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/error_message.dart';
import 'consumibles_page.dart';
import 'equipos_generales_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  
  // Estado
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Datos para el dashboard
  Map<String, dynamic> _estadisticas = {};
  List<dynamic> _mantenimientosRecientes = [];
  List<dynamic> _consumiblesStockBajo = [];
  Map<String, dynamic> _equiposPorEstado = {};
  Map<String, dynamic> _equiposPorTipo = {};
  
  @override
  void initState() {
    super.initState();
    _cargarDatosDashboard();
  }
  
  /// Carga todos los datos necesarios para el dashboard
  Future<void> _cargarDatosDashboard() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Cargar datos en paralelo
      final estadisticasFuture = _dashboardService.obtenerEstadisticas();
      final mantenimientosFuture = _dashboardService.obtenerMantenimientosRecientes();
      final consumiblesFuture = _dashboardService.obtenerConsumiblesStockBajo();
      final equiposEstadoFuture = _dashboardService.obtenerEquiposPorEstado();
      final equiposTipoFuture = _dashboardService.obtenerEquiposPorTipo();
      
      // Esperar a que todas las peticiones terminen
      final resultados = await Future.wait([
        estadisticasFuture,
        mantenimientosFuture,
        consumiblesFuture,
        equiposEstadoFuture,
        equiposTipoFuture,
      ]);
      
      setState(() {
        _estadisticas = resultados[0] as Map<String, dynamic>;
        _mantenimientosRecientes = resultados[1] as List<dynamic>;
        _consumiblesStockBajo = resultados[2] as List<dynamic>;
        _equiposPorEstado = resultados[3] as Map<String, dynamic>;
        _equiposPorTipo = resultados[4] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al cargar datos del dashboard: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarDatosDashboard,
          ),
        ],
      ),
      drawer: const DrawerMenu(),
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
          onRetry: _cargarDatosDashboard,
        ),
      );
    }
    
    // Responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar si estamos en un dispositivo móvil o desktop
        final isMobile = constraints.maxWidth < 800;
        
        if (isMobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }
  
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          const SizedBox(height: 16),
          _buildEquiposPorEstadoChart(),
          const SizedBox(height: 16),
          _buildEquiposPorTipoChart(),
          const SizedBox(height: 16),
          _buildConsumiblesStockBajoSection(),
          const SizedBox(height: 16),
          _buildMantenimientosRecientesSection(),
        ],
      ),
    );
  }
  
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildEquiposPorEstadoChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildEquiposPorTipoChart()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildConsumiblesStockBajoSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildMantenimientosRecientesSection()),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Total Equipos',
          _estadisticas['total_equipos']?.toString() ?? '0',
          LucideIcons.monitor,
          Colors.blue,
        ),
        _buildStatCard(
          'Equipos Activos',
          _estadisticas['equipos_activos']?.toString() ?? '0',
          LucideIcons.checkCircle,
          Colors.green,
        ),
        _buildStatCard(
          'En Mantenimiento',
          _estadisticas['equipos_mantenimiento']?.toString() ?? '0',
          LucideIcons.wrench,
          Colors.orange,
        ),
        _buildStatCard(
          'Consumibles Bajos',
          _estadisticas['consumibles_stock_bajo']?.toString() ?? '0',
          LucideIcons.alertTriangle,
          Colors.red,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquiposPorEstadoChart() {
    final data = _equiposPorEstado;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipos por Estado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _crearSeccionesPieChart(data),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _crearLeyendasGrafico(data),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquiposPorTipoChart() {
    final data = _equiposPorTipo;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipos por Tipo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calcularMaximoBarras(data),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = data.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                keys[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value % 10 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _crearGruposBarras(data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConsumiblesStockBajoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Consumibles con Stock Bajo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsumiblesPage(),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _consumiblesStockBajo.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No hay consumibles con stock bajo'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _consumiblesStockBajo.length,
                    itemBuilder: (context, index) {
                      final consumible = _consumiblesStockBajo[index];
                      final stockActual = consumible['stock_actual'] ?? 0;
                      final stockMinimo = consumible['stock_minimo'] ?? 0;
                      final porcentaje = stockActual / stockMinimo;
                      
                      return ListTile(
                        leading: Icon(
                          consumible['tipo'] == 'Toner' ? LucideIcons.printer : LucideIcons.box,
                          color: Colors.red,
                        ),
                        title: Text('${consumible['marca']} ${consumible['modelo']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${consumible['tipo']}'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: porcentaje > 1 ? 1 : porcentaje,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                porcentaje < 0.5 ? Colors.red : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Stock: ${stockActual}/${stockMinimo}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMantenimientosRecientesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mantenimientos Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EquiposGeneralesPage(),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text('Ver equipos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _mantenimientosRecientes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No hay mantenimientos recientes'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mantenimientosRecientes.length,
                    itemBuilder: (context, index) {
                      final mantenimiento = _mantenimientosRecientes[index];
                      final equipo = mantenimiento['equipo'] ?? {};
                      final fecha = mantenimiento['fecha'] != null
                          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(mantenimiento['fecha']))
                          : 'Fecha no disponible';
                      
                      return ListTile(
                        leading: const Icon(LucideIcons.wrench, color: Colors.orange),
                        title: Text(mantenimiento['descripcion'] ?? 'Sin descripción'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: $fecha'),
                            Text(
                              '${equipo['tipo'] ?? 'Equipo'}: ${equipo['detalle']?['marca'] ?? ''} ${equipo['detalle']?['modelo'] ?? ''}',
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
  
  // Métodos auxiliares para los gráficos
  
  List<PieChartSectionData> _crearSeccionesPieChart(Map<String, dynamic> data) {
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.purple,
    ];
    
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    
    data.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value.toDouble(),
          title: '',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });
    
    return sections;
  }
  
  List<Widget> _crearLeyendasGrafico(Map<String, dynamic> data) {
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.purple,
    ];
    
    final List<Widget> legends = [];
    int colorIndex = 0;
    
    data.forEach((key, value) {
      legends.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: colors[colorIndex % colors.length],
            ),
            const SizedBox(width: 4),
            Text('$key: $value'),
          ],
        ),
      );
      colorIndex++;
    });
    
    return legends;
  }
  
  double _calcularMaximoBarras(Map<String, dynamic> data) {
    double max = 0;
    data.forEach((key, value) {
      if (value > max) {
        max = value.toDouble();
      }
    });
    return max * 1.2; // 20% más para espacio
  }
  
  List<BarChartGroupData> _crearGruposBarras(Map<String, dynamic> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    
    final List<BarChartGroupData> groups = [];
    int index = 0;
    
    data.forEach((key, value) {
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: colors[index % colors.length],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
    });
    
    return groups;
  }
}
