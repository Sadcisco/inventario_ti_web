/// Modelo para mapear las salidas de consumibles recibidas desde la API

class DetalleSalidaModel {
  final int idDetalle;
  final int cantidad;
  final Map<String, dynamic> consumible;

  DetalleSalidaModel({
    required this.idDetalle,
    required this.cantidad,
    required this.consumible,
  });

  factory DetalleSalidaModel.fromJson(Map<String, dynamic> json) {
    return DetalleSalidaModel(
      idDetalle: json['id_detalle'],
      cantidad: json['cantidad'],
      consumible: json['consumible'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_detalle': idDetalle,
      'cantidad': cantidad,
      'id_consumible': consumible['id_consumible'],
    };
  }
}

class SalidaConsumibleModel {
  final int idSalida;
  final String fechaSalida;
  final Map<String, dynamic> sucursalDestino;
  final String? observaciones;
  final List<DetalleSalidaModel> detalles;

  SalidaConsumibleModel({
    required this.idSalida,
    required this.fechaSalida,
    required this.sucursalDestino,
    this.observaciones,
    required this.detalles,
  });

  factory SalidaConsumibleModel.fromJson(Map<String, dynamic> json) {
    List<DetalleSalidaModel> detallesList = [];
    if (json['detalles'] != null) {
      detallesList = List<DetalleSalidaModel>.from(
        (json['detalles'] as List).map((x) => DetalleSalidaModel.fromJson(x))
      );
    }

    return SalidaConsumibleModel(
      idSalida: json['id_salida'],
      fechaSalida: json['fecha_salida'],
      sucursalDestino: json['sucursal_destino'] ?? {},
      observaciones: json['observaciones'],
      detalles: detallesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_salida': idSalida,
      'fecha_salida': fechaSalida,
      'id_sucursal_destino': sucursalDestino['id_sucursal'],
      'observaciones': observaciones,
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }
}
