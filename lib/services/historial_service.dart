import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/historial_model.dart';

class HistorialService {
  final Dio _dio = Dio();

  // Obtener el historial de un equipo específico
  Future<List<HistorialModel>> obtenerHistorialEquipo(int idEquipo) async {
    try {
      print('Haciendo petición a: $apiUrl/historial/$idEquipo');
      final response = await _dio.get('$apiUrl/historial/$idEquipo');
      List data = response.data;
      return data.map((e) => HistorialModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener historial: $e");
      return [];
    }
  }

  // Agregar una nueva entrada al historial
  Future<bool> agregarHistorial(Map<String, dynamic> datos) async {
    try {
      print('Agregando historial en: $apiUrl/historial');
      await _dio.post('$apiUrl/historial', data: datos);
      return true;
    } catch (e) {
      print("Error al agregar historial: $e");
      return false;
    }
  }

  // Finalizar una asignación (establecer fecha de término)
  Future<bool> finalizarAsignacion(int idHistorial, Map<String, dynamic> datos) async {
    try {
      print('Finalizando asignación en: $apiUrl/historial/$idHistorial');
      await _dio.put('$apiUrl/historial/$idHistorial', data: datos);
      return true;
    } catch (e) {
      print("Error al finalizar asignación: $e");
      return false;
    }
  }
}
