// Modelo para mapear el historial de un equipo recibido desde la API

class HistorialModel {
  final int id;
  final int idInventario;
  final int idUsuario;
  final String nombreUsuario;
  final DateTime fechaAsignacion;
  final DateTime? fechaTermino;
  final String? observaciones;

  HistorialModel({
    required this.id,
    required this.idInventario,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.fechaAsignacion,
    this.fechaTermino,
    this.observaciones,
  });

  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    return HistorialModel(
      id: json['id_historial'],
      idInventario: json['id_inventario'],
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'] ?? 'Sin nombre',
      fechaAsignacion: DateTime.parse(json['fecha_asignacion']),
      fechaTermino: json['fecha_termino'] != null ? DateTime.parse(json['fecha_termino']) : null,
      observaciones: json['observaciones'],
    );
  }
}
