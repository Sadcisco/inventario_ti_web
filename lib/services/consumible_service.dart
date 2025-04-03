import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/consumible_model.dart';

class ConsumibleService {
  final Dio _dio = Dio();

  // Obtener todos los consumibles
  Future<List<ConsumibleModel>> obtenerConsumibles() async {
    try {
      print('Haciendo petición a: $apiUrl/consumibles');
      final response = await _dio.get('$apiUrl/consumibles');
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
      print('Haciendo petición a: $apiUrl/consumibles/$id');
      final response = await _dio.get('$apiUrl/consumibles/$id');
      return ConsumibleModel.fromJson(response.data);
    } catch (e) {
      print("Error al obtener consumible: $e");
      return null;
    }
  }

  // Crear un nuevo consumible
  Future<bool> crearConsumible(Map<String, dynamic> datos) async {
    try {
      print('Creando consumible en: $apiUrl/consumibles');
      await _dio.post('$apiUrl/consumibles', data: datos);
      return true;
    } catch (e) {
      print("Error al crear consumible: $e");
      return false;
    }
  }

  // Actualizar un consumible existente
  Future<bool> actualizarConsumible(int id, Map<String, dynamic> datos) async {
    try {
      print('Actualizando consumible en: $apiUrl/consumibles/$id');
      await _dio.put('$apiUrl/consumibles/$id', data: datos);
      return true;
    } catch (e) {
      print("Error al actualizar consumible: $e");
      return false;
    }
  }

  // Eliminar un consumible
  Future<bool> eliminarConsumible(int id) async {
    try {
      print('Eliminando consumible en: $apiUrl/consumibles/$id');
      await _dio.delete('$apiUrl/consumibles/$id');
      return true;
    } catch (e) {
      print("Error al eliminar consumible: $e");
      return false;
    }
  }

  // Actualizar el stock de un consumible
  Future<bool> actualizarStock(int id, int nuevoStock) async {
    try {
      print('Actualizando stock en: $apiUrl/consumibles/$id/stock');
      await _dio.put('$apiUrl/consumibles/$id/stock', data: {'stock_actual': nuevoStock});
      return true;
    } catch (e) {
      print("Error al actualizar stock: $e");
      return false;
    }
  }

  // Registrar una salida de consumible
  Future<bool> registrarSalida(Map<String, dynamic> datos) async {
    try {
      print('Registrando salida en: $apiUrl/salidas-consumibles');
      await _dio.post('$apiUrl/salidas-consumibles', data: datos);
      return true;
    } catch (e) {
      print("Error al registrar salida: $e");
      return false;
    }
  }
}
