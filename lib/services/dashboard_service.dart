import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DashboardService {
  final Dio _dio = Dio();

  /// Obtiene estadísticas generales para el dashboard
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      print('Haciendo petición a: $apiUrl/dashboard/estadisticas');
      final response = await _dio.get('$apiUrl/dashboard/estadisticas');
      return response.data;
    } catch (e) {
      print("Error al obtener estadísticas: $e");
      // Devolver datos de ejemplo para desarrollo
      return _generarDatosEjemplo();
    }
  }

  /// Obtiene los equipos con mantenimientos recientes
  Future<List<dynamic>> obtenerMantenimientosRecientes() async {
    try {
      print('Haciendo petición a: $apiUrl/dashboard/mantenimientos-recientes');
      final response = await _dio.get('$apiUrl/dashboard/mantenimientos-recientes');
      return response.data;
    } catch (e) {
      print("Error al obtener mantenimientos recientes: $e");
      // Devolver datos de ejemplo para desarrollo
      return _generarMantenimientosEjemplo();
    }
  }

  /// Obtiene los consumibles con stock bajo
  Future<List<dynamic>> obtenerConsumiblesStockBajo() async {
    try {
      print('Haciendo petición a: $apiUrl/dashboard/consumibles-stock-bajo');
      final response = await _dio.get('$apiUrl/dashboard/consumibles-stock-bajo');
      return response.data;
    } catch (e) {
      print("Error al obtener consumibles con stock bajo: $e");
      // Devolver datos de ejemplo para desarrollo
      return _generarConsumiblesStockBajoEjemplo();
    }
  }

  /// Obtiene los equipos por estado
  Future<Map<String, dynamic>> obtenerEquiposPorEstado() async {
    try {
      print('Haciendo petición a: $apiUrl/dashboard/equipos-por-estado');
      final response = await _dio.get('$apiUrl/dashboard/equipos-por-estado');
      return response.data;
    } catch (e) {
      print("Error al obtener equipos por estado: $e");
      // Devolver datos de ejemplo para desarrollo
      return _generarEquiposPorEstadoEjemplo();
    }
  }

  /// Obtiene los equipos por tipo
  Future<Map<String, dynamic>> obtenerEquiposPorTipo() async {
    try {
      print('Haciendo petición a: $apiUrl/dashboard/equipos-por-tipo');
      final response = await _dio.get('$apiUrl/dashboard/equipos-por-tipo');
      return response.data;
    } catch (e) {
      print("Error al obtener equipos por tipo: $e");
      // Devolver datos de ejemplo para desarrollo
      return _generarEquiposPorTipoEjemplo();
    }
  }

  // Métodos para generar datos de ejemplo (para desarrollo)
  
  Map<String, dynamic> _generarDatosEjemplo() {
    return {
      'total_equipos': 120,
      'equipos_activos': 95,
      'equipos_mantenimiento': 15,
      'equipos_baja': 10,
      'total_consumibles': 45,
      'consumibles_stock_bajo': 8,
      'mantenimientos_mes': 12,
    };
  }

  List<dynamic> _generarMantenimientosEjemplo() {
    return [
      {
        'id_mantenimiento': 1,
        'fecha': '2025-03-28',
        'descripcion': 'Limpieza y actualización de software',
        'equipo': {
          'id_inventario': 101,
          'tipo': 'Laptop',
          'detalle': {
            'marca': 'Dell',
            'modelo': 'Latitude 7420',
          }
        }
      },
      {
        'id_mantenimiento': 2,
        'fecha': '2025-03-25',
        'descripcion': 'Reemplazo de batería',
        'equipo': {
          'id_inventario': 102,
          'tipo': 'Laptop',
          'detalle': {
            'marca': 'HP',
            'modelo': 'EliteBook 840',
          }
        }
      },
      {
        'id_mantenimiento': 3,
        'fecha': '2025-03-22',
        'descripcion': 'Actualización de firmware',
        'equipo': {
          'id_inventario': 103,
          'tipo': 'Impresora',
          'detalle': {
            'marca': 'Epson',
            'modelo': 'EcoTank L3250',
          }
        }
      },
    ];
  }

  List<dynamic> _generarConsumiblesStockBajoEjemplo() {
    return [
      {
        'id_consumible': 1,
        'tipo': 'Toner',
        'marca': 'HP',
        'modelo': '26A',
        'stock_actual': 2,
        'stock_minimo': 5,
      },
      {
        'id_consumible': 2,
        'tipo': 'Toner',
        'marca': 'Brother',
        'modelo': 'TN-760',
        'stock_actual': 1,
        'stock_minimo': 3,
      },
      {
        'id_consumible': 3,
        'tipo': 'Cartucho',
        'marca': 'Epson',
        'modelo': '664 Negro',
        'stock_actual': 3,
        'stock_minimo': 4,
      },
    ];
  }

  Map<String, dynamic> _generarEquiposPorEstadoEjemplo() {
    return {
      'Activo': 95,
      'Mantenimiento': 15,
      'Baja': 10,
    };
  }

  Map<String, dynamic> _generarEquiposPorTipoEjemplo() {
    return {
      'Laptop': 45,
      'Desktop': 30,
      'Impresora': 20,
      'Celular': 15,
      'Tablet': 10,
    };
  }
}
