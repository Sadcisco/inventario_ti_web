// Modelo para mapear un equipo recibido desde la API

class EquipoModel {
  final int id;
  final String estado;
  final String tipo;
  final Map detalle;

  EquipoModel({
    required this.id,
    required this.estado,
    required this.tipo,
    required this.detalle,
  });

  factory EquipoModel.fromJson(Map json) {
    return EquipoModel(
      id: json['id'],
      estado: json['estado'] ?? 'SinAsignar',
      tipo: json['detalle']['tipo'] ?? '',
      detalle: json['detalle'],
    );
  }
}
