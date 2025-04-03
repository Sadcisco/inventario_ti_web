/// Modelo para mapear los mantenimientos recibidos desde la API

class MantenimientoModel {
  final int id;
  final int idInventario;
  final DateTime fecha;
  final String descripcion;
  final String realizadoPor;
  final String? observaciones;
  final Map<String, dynamic>? equipo;

  MantenimientoModel({
    required this.id,
    required this.idInventario,
    required this.fecha,
    required this.descripcion,
    required this.realizadoPor,
    this.observaciones,
    this.equipo,
  });

  factory MantenimientoModel.fromJson(Map<String, dynamic> json) {
    return MantenimientoModel(
      id: json['id_mantenimiento'],
      idInventario: json['id_inventario'],
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'] ?? '',
      realizadoPor: json['realizado_por'] ?? 'No especificado',
      observaciones: json['observaciones'],
      equipo: json['equipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mantenimiento': id,
      'id_inventario': idInventario,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'realizado_por': realizadoPor,
      'observaciones': observaciones,
    };
  }
}
