class CelularModel {
  final int id;
  final String codigoInterno;
  final String marca;
  final String modelo;
  final String imei;
  final String numeroLinea;
  final String sistemaOperativo;
  final String capacidadAlmacenamiento;
  final String estado;
  final int idSucursal;
  final String? responsable;
  final String? observaciones;

  CelularModel({
    required this.id,
    required this.codigoInterno,
    required this.marca,
    required this.modelo,
    required this.imei,
    required this.numeroLinea,
    required this.sistemaOperativo,
    required this.capacidadAlmacenamiento,
    required this.estado,
    required this.idSucursal,
    this.responsable,
    this.observaciones,
  });

  factory CelularModel.fromJson(Map<String, dynamic> json) {
    return CelularModel(
      id: json['id_celular'] ?? 0,
      codigoInterno: json['codigo_interno'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      imei: json['imei'] ?? '',
      numeroLinea: json['numero_linea'] ?? '',
      sistemaOperativo: json['sistema_operativo'] ?? '',
      capacidadAlmacenamiento: json['capacidad_almacenamiento'] ?? '',
      estado: json['estado'] ?? '',
      idSucursal: json['id_sucursal'] ?? 0,
      responsable: json['responsable'],
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_celular': id,
      'codigo_interno': codigoInterno,
      'marca': marca,
      'modelo': modelo,
      'imei': imei,
      'numero_linea': numeroLinea,
      'sistema_operativo': sistemaOperativo,
      'capacidad_almacenamiento': capacidadAlmacenamiento,
      'estado': estado,
      'id_sucursal': idSucursal,
      'responsable': responsable,
      'observaciones': observaciones,
    };
  }
}
