/// Modelo para mapear los consumibles recibidos desde la API

class ConsumibleModel {
  final int id;
  final String tipo;
  final String marca;
  final String modelo;
  final int stockActual;
  final int stockMinimo;
  final Map<String, dynamic>? sucursal;

  ConsumibleModel({
    required this.id,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.stockActual,
    required this.stockMinimo,
    this.sucursal,
  });

  factory ConsumibleModel.fromJson(Map<String, dynamic> json) {
    return ConsumibleModel(
      id: json['id_consumible'],
      tipo: json['tipo'],
      marca: json['marca'],
      modelo: json['modelo'],
      stockActual: json['stock_actual'],
      stockMinimo: json['stock_minimo'],
      sucursal: json['sucursal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_consumible': id,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'id_sucursal_stock': sucursal?['id_sucursal'],
    };
  }
}
