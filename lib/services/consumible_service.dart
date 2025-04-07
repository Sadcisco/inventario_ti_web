import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/consumible_model.dart';

class ConsumibleService {
  final Dio _dio = Dio();
  
  // URLs de los endpoints
  final String _consumiblesUrl = '$apiUrl/consumibles';
  final String _salidasUrl = '$apiUrl/salidas-consumibles';

  // Obtener todos los consumibles
  Future<List<ConsumibleModel>> obtenerConsumibles() async {
    try {
      print('Haciendo petición a: $_consumiblesUrl');
      final response = await _dio.get(_consumiblesUrl);
      List data = response.data;
      return data.map((e) => ConsumibleModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener consumibles: $e");
      return [];
    }
  }

  // Obtener un consumible específico
  Future<ConsumibleModel?> obtenerConsumible(int id) async {
    try {
      print('Haciendo petición a: $_consumiblesUrl/$id');
      final response = await _dio.get('$_consumiblesUrl/$id');
      return ConsumibleModel.fromJson(response.data);
    } catch (e) {
      print("Error al obtener consumible: $e");
      return null;
    }
  }

  // Crear un nuevo consumible
  Future<bool> crearConsumible(Map<String, dynamic> datos) async {
    try {
      print('Creando consumible en: $_consumiblesUrl');
      await _dio.post(_consumiblesUrl, data: {
        'tipo': datos['tipo'],
        'marca': datos['marca'],
        'modelo': datos['modelo'],
        'stock_actual': datos['stock_actual'],
        'stock_minimo': datos['stock_minimo'],
        'id_sucursal': datos['id_sucursal']
      });
      return true;
    } catch (e) {
      print("Error al crear consumible: $e");
      return false;
    }
  }

  // Actualizar un consumible existente
  Future<bool> actualizarConsumible(int id, Map<String, dynamic> datos) async {
    try {
      print('Actualizando consumible en: $_consumiblesUrl/$id');
      await _dio.put('$_consumiblesUrl/$id', data: {
        'tipo': datos['tipo'],
        'marca': datos['marca'],
        'modelo': datos['modelo'],
        'stock_actual': datos['stock_actual'],
        'stock_minimo': datos['stock_minimo'],
        'id_sucursal': datos['id_sucursal']
      });
      return true;
    } catch (e) {
      print("Error al actualizar consumible: $e");
      return false;
    }
  }

  // Eliminar un consumible
  Future<bool> eliminarConsumible(int id) async {
    try {
      print('Eliminando consumible en: $_consumiblesUrl/$id');
      await _dio.delete('$_consumiblesUrl/$id');
      return true;
    } catch (e) {
      print("Error al eliminar consumible: $e");
      return false;
    }
  }

  // Actualizar el stock de un consumible
  Future<bool> actualizarStock(int id, int nuevoStock) async {
    try {
      print('Actualizando stock en: $_consumiblesUrl/$id/stock');
      await _dio.put('$_consumiblesUrl/$id/stock', data: {'stock_actual': nuevoStock});
      return true;
    } catch (e) {
      print("Error al actualizar stock: $e");
      return false;
    }
  }

  // Registrar una salida de consumible
  Future<bool> registrarSalida(Map<String, dynamic> datos) async {
    try {
      print('Registrando salida en: $_salidasUrl');
      
      // Preparar los detalles de consumibles para la salida
      List<Map<String, dynamic>> detalles = [];
      if (datos['detalles'] != null && datos['detalles'] is List) {
        detalles = List<Map<String, dynamic>>.from(datos['detalles']);
      } else if (datos['id_consumible'] != null && datos['cantidad'] != null) {
        // Compatibilidad con el formato anterior
        detalles = [{
          'id_consumible': datos['id_consumible'],
          'cantidad': datos['cantidad']
        }];
      }
      
      await _dio.post(_salidasUrl, data: {
        'id_sucursal_destino': datos['id_sucursal_destino'],
        'fecha_salida': datos['fecha_salida'] ?? DateTime.now().toString().substring(0, 10),
        'observaciones': datos['observaciones'],
        'detalles': detalles
      });
      return true;
    } catch (e) {
      print("Error al registrar salida: $e");
      return false;
    }
  }
}
