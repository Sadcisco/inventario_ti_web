import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/equipo_model.dart';

class EquipoService {
  final Dio _dio = Dio();

  // Obtener todos los equipos desde la API
  Future<List<EquipoModel>> obtenerEquipos() async {
    try {
      print('Haciendo petición a: $apiUrl/inventario');
      final response = await _dio.get('$apiUrl/inventario');
      List data = response.data;
      return data.map((e) => EquipoModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener equipos: $e");
      return [];
    }
  }
  
  // Crear un nuevo equipo
  Future<bool> crearEquipo(Map<String, dynamic> datos) async {
    try {
      print('Creando equipo en: $apiUrl/inventario');
      await _dio.post('$apiUrl/inventario', data: datos);
      return true;
    } catch (e) {
      print("Error al crear equipo: $e");
      return false;
    }
  }
  
  // Actualizar un equipo existente
  Future<bool> actualizarEquipo(int id, Map<String, dynamic> datos) async {
    try {
      print('Actualizando equipo en: $apiUrl/inventario/$id');
      await _dio.put('$apiUrl/inventario/$id', data: datos);
      return true;
    } catch (e) {
      print("Error al actualizar equipo: $e");
      return false;
    }
  }
  
  // Eliminar un equipo
  Future<bool> eliminarEquipo(int id) async {
    try {
      print('Eliminando equipo en: $apiUrl/inventario/$id');
      await _dio.delete('$apiUrl/inventario/$id');
      return true;
    } catch (e) {
      print("Error al eliminar equipo: $e");
      return false;
    }
  }
}
