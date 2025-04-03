// Archivo de constantes para la aplicación

import 'package:flutter/material.dart';

// Colores para estados de equipos
class AppColors {
  static const Color asignado = Colors.green;
  static const Color sinAsignar = Colors.orange;
  static const Color enReparacion = Colors.blue;
  static const Color deBaja = Colors.red;
  static const Color desconocido = Colors.grey;
}

// Textos para mensajes de error
class ErrorMessages {
  static const String errorCarga = 'Error al cargar los equipos. Intente nuevamente.';
  static const String sinDatos = 'No hay equipos registrados.';
  static const String sinResultados = 'No se encontraron equipos con ese criterio.';
}

// Configuración de la aplicación
class AppConfig {
  static const String appName = 'Inventario TI';
  static const String version = '1.0.0';
}
