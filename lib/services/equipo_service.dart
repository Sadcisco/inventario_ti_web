import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/equipo_model.dart';

class EquipoService {
  final Dio _dio = Dio();

  // Obtener todos los equipos desde la API
  Future<List<EquipoModel>> obtenerEquipos() async {
    try {
      final response = await _dio.get('$apiUrl/inventario');
      List data = response.data;
      return data.map((e) => EquipoModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener equipos: $e");
      return [];
    }
  }
}
