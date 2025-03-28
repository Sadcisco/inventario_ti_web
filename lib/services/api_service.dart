import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000"; // Cambia por tu IP si lo corres en otro PC

  // Equipos (general)
  static Future<List<dynamic>> obtenerInventario() async {
    final response = await http.get(Uri.parse('$baseUrl/inventario'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar inventario");
    }
  }

  // Movimientos por equipo
  static Future<List<dynamic>> obtenerMovimientos(int idInventario) async {
    final response = await http.get(Uri.parse('$baseUrl/movimientos?id_inventario=$idInventario'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al cargar movimientos");
    }
  }

  // Consumibles (simulación por ahora, se pueden agregar endpoints reales)
  static Future<List<Map<String, dynamic>>> obtenerConsumiblesFake() async {
    return [
      {"nombre": "Toner HP 12A", "stock": 4, "stock_minimo": 2},
      {"nombre": "Tambor Samsung MLT-D111", "stock": 2, "stock_minimo": 1},
    ];
  }

  static Future<List<Map<String, dynamic>>> obtenerMovimientosConsumiblesFake() async {
    return [
      {"item": "Toner HP 12A", "sucursal": "Maitén", "fecha": "24/03/2025"},
      {"item": "Tambor MLT-D111", "sucursal": "Hospital", "fecha": "18/03/2025"},
    ];
  }
    // Agregar equipo computacional
  static Future<Map<String, dynamic>?> agregarEquipoComputacional(Map<String, dynamic> data) async {
    final payload = {
      "tipo": "Computacional",
      "equipo": data,
      "estado": "SinAsignar",
      "id_usuario_responsable": 1, // Puedes cambiar estos valores luego
      "id_area_responsable": 1,
      "id_sucursal_ubicacion": 1,
      "observaciones": "Agregado desde Flutter"
    };

    final response = await http.post(
      Uri.parse("$baseUrl/inventario"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      print("Error: ${response.body}");
      return null;
    }
  }

}
