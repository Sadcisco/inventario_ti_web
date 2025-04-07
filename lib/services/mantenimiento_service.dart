import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/mantenimiento_model.dart';

class MantenimientoService {
  final Dio _dio = Dio();
  
  // URLs de los endpoints
  final String _mantenimientosUrl = '$apiUrl/mantenimientos';

  // Obtener todos los mantenimientos
  Future<List<MantenimientoModel>> obtenerMantenimientos() async {
    try {
      print('Haciendo petición a: $_mantenimientosUrl');
      final response = await _dio.get(_mantenimientosUrl);
      List data = response.data;
      return data.map((e) => MantenimientoModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener mantenimientos: $e");
      return [];
    }
  }

  // Obtener mantenimientos de un equipo específico (ahora por id_inventario)
  Future<List<MantenimientoModel>> obtenerMantenimientosEquipo(int idInventario) async {
    try {
      print('Haciendo petición a: $apiUrl/inventario/$idInventario/mantenimientos');
      final response = await _dio.get('$apiUrl/inventario/$idInventario/mantenimientos');
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
      print('Haciendo petición a: $_mantenimientosUrl/$id');
      final response = await _dio.get('$_mantenimientosUrl/$id');
      return MantenimientoModel.fromJson(response.data);
    } catch (e) {
      print("Error al obtener mantenimiento: $e");
      return null;
    }
  }

  // Crear un nuevo mantenimiento
  Future<bool> crearMantenimiento(Map<String, dynamic> datos) async {
    try {
      print('Creando mantenimiento en: $_mantenimientosUrl');
      await _dio.post(_mantenimientosUrl, data: {
        'id_inventario': datos['id_inventario'],
        'fecha': datos['fecha'],
        'descripcion': datos['descripcion'],
        'realizado_por': datos['realizado_por'],
        'observaciones': datos['observaciones']
      });
      return true;
    } catch (e) {
      print("Error al crear mantenimiento: $e");
      return false;
    }
  }

  // Actualizar un mantenimiento existente
  Future<bool> actualizarMantenimiento(int id, Map<String, dynamic> datos) async {
    try {
      print('Actualizando mantenimiento en: $_mantenimientosUrl/$id');
      await _dio.put('$_mantenimientosUrl/$id', data: {
        'id_inventario': datos['id_inventario'],
        'fecha': datos['fecha'],
        'descripcion': datos['descripcion'],
        'realizado_por': datos['realizado_por'],
        'observaciones': datos['observaciones']
      });
      return true;
    } catch (e) {
      print("Error al actualizar mantenimiento: $e");
      return false;
    }
  }

  // Eliminar un mantenimiento
  Future<bool> eliminarMantenimiento(int id) async {
    try {
      print('Eliminando mantenimiento en: $_mantenimientosUrl/$id');
      await _dio.delete('$_mantenimientosUrl/$id');
      return true;
    } catch (e) {
      print("Error al eliminar mantenimiento: $e");
      return false;
    }
  }
}
