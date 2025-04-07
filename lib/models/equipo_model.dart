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

  Map<String, dynamic> toJson() {
    return {
      'id_inventario': id,
      'id_equipo': id,
      'estado': 'Activo',
      'id_usuario_responsable': id,
      'id_area_responsable': id,
      'id_sucursal_ubicacion': id,
      'fecha_ingreso': DateTime.now().toIso8601String(),
      'observaciones': 'Sin observaciones',
    };
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
  final int id; // id_inventario
  final Map<String, dynamic> equipo; // datos del equipo
  final String estado;
  final Map<String, dynamic>? responsable;
  final Map<String, dynamic>? area;
  final Map<String, dynamic>? sucursal;
  final DateTime? fechaIngreso;
  final String? observaciones;

  EquipoModel({
    required this.id,
    required this.equipo,
    required this.estado,
    this.responsable,
    this.area,
    this.sucursal,
    this.fechaIngreso,
    this.observaciones,
  });

  // Getters para facilitar el acceso a los datos del equipo
  String get tipo => equipo['tipo_equipo'] ?? 'No especificado';
  String get marca => equipo['marca'] ?? 'No especificada';
  String get modelo => equipo['modelo'] ?? 'No especificado';
  String get nombreEquipo => equipo['nombre_equipo'] ?? 'No especificado';
  String get serialNumber => equipo['serial_number'] ?? 'No especificado';
  String get codigoInterno => equipo['codigo_interno'] ?? 'No especificado';
  
  // Getter para acceder a los detalles del equipo (para compatibilidad con código existente)
  Map<String, dynamic> get detalle => equipo;
  
  // Getters para acceder a los datos del responsable, área y sucursal
  ResponsableModel? get usuarioResponsable => responsable != null ? ResponsableModel.fromJson(responsable) : null;
  AreaModel? get areaResponsable => area != null ? AreaModel.fromJson(area) : null;
  SucursalModel? get sucursalUbicacion => sucursal != null ? SucursalModel.fromJson(sucursal) : null;

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    return EquipoModel(
      id: json['id_inventario'],
      equipo: json['equipo'] ?? {},
      estado: json['estado'],
      responsable: json['responsable'],
      area: json['area'],
      sucursal: json['sucursal'],
      fechaIngreso: json['fecha_ingreso'] != null ? DateTime.parse(json['fecha_ingreso']) : null,
      observaciones: json['observaciones'],
    );
  }
}
