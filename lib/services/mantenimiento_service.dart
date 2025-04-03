import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/mantenimiento_model.dart';

class MantenimientoService {
  final Dio _dio = Dio();

  // Obtener todos los mantenimientos
  Future<List<MantenimientoModel>> obtenerMantenimientos() async {
    try {
      print('Haciendo petición a: $apiUrl/mantenimientos');
      final response = await _dio.get('$apiUrl/mantenimientos');
      List data = response.data;
      return data.map((e) => MantenimientoModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener mantenimientos: $e");
      return [];
    }
  }

  // Obtener mantenimientos de un equipo específico
  Future<List<MantenimientoModel>> obtenerMantenimientosEquipo(int idEquipo) async {
    try {
      print('Haciendo petición a: $apiUrl/equipos/$idEquipo/mantenimientos');
      final response = await _dio.get('$apiUrl/equipos/$idEquipo/mantenimientos');
      List data = response.data;
      return data.map((e) => MantenimientoModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener mantenimientos del equipo: $e");
      return [];
    }
  }

  // Obtener un mantenimiento específico
  Future<MantenimientoModel?> obtenerMantenimiento(int id) async {
    try {
      print('Haciendo petición a: $apiUrl/mantenimientos/$id');
      final response = await _dio.get('$apiUrl/mantenimientos/$id');
      return MantenimientoModel.fromJson(response.data);
    } catch (e) {
      print("Error al obtener mantenimiento: $e");
      return null;
    }
  }

  // Crear un nuevo mantenimiento
  Future<bool> crearMantenimiento(Map<String, dynamic> datos) async {
    try {
      print('Creando mantenimiento en: $apiUrl/mantenimientos');
      await _dio.post('$apiUrl/mantenimientos', data: datos);
      return true;
    } catch (e) {
      print("Error al crear mantenimiento: $e");
      return false;
    }
  }

  // Actualizar un mantenimiento existente
  Future<bool> actualizarMantenimiento(int id, Map<String, dynamic> datos) async {
    try {
      print('Actualizando mantenimiento en: $apiUrl/mantenimientos/$id');
      await _dio.put('$apiUrl/mantenimientos/$id', data: datos);
      return true;
    } catch (e) {
      print("Error al actualizar mantenimiento: $e");
      return false;
    }
  }

  // Eliminar un mantenimiento
  Future<bool> eliminarMantenimiento(int id) async {
    try {
      print('Eliminando mantenimiento en: $apiUrl/mantenimientos/$id');
      await _dio.delete('$apiUrl/mantenimientos/$id');
      return true;
    } catch (e) {
      print("Error al eliminar mantenimiento: $e");
      return false;
    }
  }
}
