import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class InventarioService {
  final Dio _dio = Dio();
  
  InventarioService() {
    // Agregar el interceptor JWT para todas las solicitudes
    _dio.interceptors.add(JwtInterceptor());
  }
  
  // URLs de los endpoints
  final String _inventarioUrl = '$apiUrl/inventario/';

  // Obtener todos los registros de inventario
  Future<List<Map<String, dynamic>>> obtenerInventario() async {
    try {
      print('Haciendo petición a: $_inventarioUrl');
      final response = await _dio.get(_inventarioUrl);
      List data = response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error al obtener inventario: $e");
      return [];
    }
  }

  // Obtener un registro de inventario específico
  Future<Map<String, dynamic>?> obtenerRegistroInventario(int id) async {
    try {
      print('Haciendo petición a: $_inventarioUrl/$id');
      final response = await _dio.get('$_inventarioUrl/$id');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print("Error al obtener registro de inventario: $e");
      return null;
    }
  }

  // Crear un nuevo registro de inventario
  Future<bool> crearRegistroInventario(Map<String, dynamic> datos) async {
    try {
      print('Creando registro de inventario en: $_inventarioUrl');
      await _dio.post(_inventarioUrl, data: {
        'id_equipo': datos['id_equipo'],
        'estado': datos['estado'],
        'id_usuario_responsable': datos['id_usuario_responsable'],
        'id_area': datos['id_area'],
        'id_sucursal': datos['id_sucursal'],
        'observaciones': datos['observaciones'],
      });
      return true;
    } catch (e) {
      print("Error al crear registro de inventario: $e");
      return false;
    }
  }

  // Actualizar un registro de inventario existente
  Future<bool> actualizarRegistroInventario(int id, Map<String, dynamic> datos) async {
    try {
      print('Actualizando registro de inventario en: $_inventarioUrl/$id');
      await _dio.put('$_inventarioUrl/$id', data: {
        'id_equipo': datos['id_equipo'],
        'estado': datos['estado'],
        'id_usuario_responsable': datos['id_usuario_responsable'],
        'id_area': datos['id_area'],
        'id_sucursal': datos['id_sucursal'],
        'observaciones': datos['observaciones'],
      });
      return true;
    } catch (e) {
      print("Error al actualizar registro de inventario: $e");
      return false;
    }
  }

  // Eliminar un registro de inventario
  Future<bool> eliminarRegistroInventario(int id) async {
    try {
      print('Eliminando registro de inventario en: $_inventarioUrl/$id');
      await _dio.delete('$_inventarioUrl/$id');
      return true;
    } catch (e) {
      print("Error al eliminar registro de inventario: $e");
      return false;
    }
  }

  // Actualizar el estado de un equipo en inventario
  Future<bool> actualizarEstadoEquipo(int id, String nuevoEstado) async {
    try {
      print('Actualizando estado en: $_inventarioUrl/$id/estado');
      await _dio.put('$_inventarioUrl/$id/estado', data: {'estado': nuevoEstado});
      return true;
    } catch (e) {
      print("Error al actualizar estado: $e");
      return false;
    }
  }

  // Asignar equipo a un usuario
  Future<bool> asignarEquipo(int idInventario, int idUsuario, int? idArea, int? idSucursal) async {
    try {
      print('Asignando equipo en: $_inventarioUrl/$idInventario/asignar');
      await _dio.put('$_inventarioUrl/$idInventario/asignar', data: {
        'id_usuario_responsable': idUsuario,
        'id_area': idArea,
        'id_sucursal': idSucursal,
      });
      return true;
    } catch (e) {
      print("Error al asignar equipo: $e");
      return false;
    }
  }

  // Desasignar equipo
  Future<bool> desasignarEquipo(int idInventario) async {
    try {
      print('Desasignando equipo en: $_inventarioUrl/$idInventario/desasignar');
      await _dio.put('$_inventarioUrl/$idInventario/desasignar');
      return true;
    } catch (e) {
      print("Error al desasignar equipo: $e");
      return false;
    }
  }

  // Obtener equipos por usuario
  Future<List<Map<String, dynamic>>> obtenerEquiposPorUsuario(int idUsuario) async {
    try {
      print('Haciendo petición a: $_inventarioUrl/usuario/$idUsuario');
      final response = await _dio.get('$_inventarioUrl/usuario/$idUsuario');
      List data = response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error al obtener equipos por usuario: $e");
      return [];
    }
  }

  // Obtener equipos por área
  Future<List<Map<String, dynamic>>> obtenerEquiposPorArea(int idArea) async {
    try {
      print('Haciendo petición a: $_inventarioUrl/area/$idArea');
      final response = await _dio.get('$_inventarioUrl/area/$idArea');
      List data = response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error al obtener equipos por área: $e");
      return [];
    }
  }

  // Obtener equipos por sucursal
  Future<List<Map<String, dynamic>>> obtenerEquiposPorSucursal(int idSucursal) async {
    try {
      print('Haciendo petición a: $_inventarioUrl/sucursal/$idSucursal');
      final response = await _dio.get('$_inventarioUrl/sucursal/$idSucursal');
      List data = response.data;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error al obtener equipos por sucursal: $e");
      return [];
    }
  }
}
