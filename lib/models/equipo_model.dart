// Modelo para mapear un equipo recibido desde la API

class ResponsableModel {
  final int? id;
  final String? nombre;
  final String? rut;
  final String? cargo;

  ResponsableModel({this.id, this.nombre, this.rut, this.cargo});

  factory ResponsableModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ResponsableModel();
    return ResponsableModel(
      id: json['id'],
      nombre: json['nombre'],
      rut: json['rut'],
      cargo: json['cargo'],
    );
  }
}

class AreaModel {
  final int? id;
  final String? nombre;

  AreaModel({this.id, this.nombre});

  factory AreaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AreaModel();
    return AreaModel(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}

class SucursalModel {
  final int? id;
  final String? nombre;
  final String? direccion;

  SucursalModel({this.id, this.nombre, this.direccion});

  factory SucursalModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SucursalModel();
    return SucursalModel(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
    );
  }
}

class EquipoModel {
  final int id;
  final String estado;
  final String tipo;
  final Map detalle;
  final DateTime? fechaIngreso;
  final String? observaciones;
  final ResponsableModel? usuarioResponsable;
  final AreaModel? areaResponsable;
  final SucursalModel? sucursal;

  EquipoModel({
    required this.id,
    required this.estado,
    required this.tipo,
    required this.detalle,
    this.fechaIngreso,
    this.observaciones,
    this.usuarioResponsable,
    this.areaResponsable,
    this.sucursal,
  });

  factory EquipoModel.fromJson(Map json) {
    return EquipoModel(
      id: json['id'],
      estado: json['estado'] ?? 'SinAsignar',
      tipo: json['detalle']['tipo'] ?? '',
      detalle: json['detalle'] ?? {},
      fechaIngreso: json['fecha_ingreso'] != null ? DateTime.parse(json['fecha_ingreso']) : null,
      observaciones: json['observaciones'],
      usuarioResponsable: ResponsableModel.fromJson(json['detalle']['usuario_responsable']),
      areaResponsable: AreaModel.fromJson(json['detalle']['area_responsable']),
      sucursal: SucursalModel.fromJson(json['detalle']['sucursal']),
    );
  }
}
