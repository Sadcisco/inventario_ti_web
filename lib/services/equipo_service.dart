import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/equipo_model.dart';
import 'auth_service.dart';

class EquipoService {
  final Dio _dio = Dio();
  
  // Propiedad para rastrear el último equipo creado
  int? lastCreatedEquipoId;
  int? lastCreatedInventarioId;
  
  EquipoService() {
    // Agregar el interceptor JWT para todas las solicitudes
    _dio.interceptors.add(JwtInterceptor());
  }
  
  // URLs de los endpoints
  final String _inventarioUrl = '$apiUrl/inventario/';
  final String _equiposUrl = '$apiUrl/api/equipos/';

  // Obtener todos los equipos desde la API
  Future<List<EquipoModel>> obtenerEquipos() async {
    try {
      print('Haciendo petición a: $_inventarioUrl');
      final response = await _dio.get(_inventarioUrl);
      List data = response.data;
      return data.map((e) => EquipoModel.fromJson(e)).toList();
    } catch (e) {
      print("Error al obtener equipos: $e");
      return [];
    }
  }
  
  // Obtener un equipo específico por ID
  Future<EquipoModel?> obtenerEquipoPorId(int id) async {
    try {
      // Aseguramos que no haya doble barra en la URL
      final url = _inventarioUrl.endsWith('/') 
          ? '$_inventarioUrl$id' 
          : '$_inventarioUrl/$id';
      
      print('Haciendo petición a: $url');
      final response = await _dio.get(url);
      return EquipoModel.fromJson(response.data);
    } catch (e) {
      print("Error al obtener equipo: $e");
      if (e is DioException) {
        print("URL: ${e.requestOptions.path}");
        print("Código de estado: ${e.response?.statusCode}");
        print("Respuesta: ${e.response?.data}");
      }
      return null;
    }
  }
  
  // Crear un nuevo equipo (primero crea el equipo y luego lo agrega al inventario)
  Future<bool> crearEquipo(Map<String, dynamic> datos) async {
    try {
      // Extraer los detalles para enviarlos correctamente a la API
      final detalle = datos['detalle'] as Map<String, dynamic>;
      
      // Generar un código interno único basado en la fecha y hora actual
      // para evitar duplicados
      String codigoInterno = 'EQ-${DateTime.now().millisecondsSinceEpoch}';
      
      // Paso 1: Crear el equipo
      print('Creando equipo en: $_equiposUrl');
      final equipoData = {
        'codigo_interno': codigoInterno,
        'tipo_equipo': datos['tipo_equipo'] ?? 'Computacional',
        'marca': detalle['marca'] ?? 'Sin especificar',
        'modelo': detalle['modelo'] ?? 'Sin especificar',
        'serial_number': detalle['serial_number'] ?? 'Sin especificar',
        'fecha_revision': DateTime.now().toIso8601String().split('T')[0],
        'entregado_por': 'Sistema',
        'comentarios': datos['observaciones'] ?? ''
      };
      
      // Agregar campos específicos según el tipo de equipo
      if (datos['tipo_equipo'] == 'Computacional') {
        equipoData['procesador'] = detalle['procesador'] ?? 'Sin especificar';
        equipoData['ram'] = detalle['ram'] ?? 'Sin especificar';
        // Asegurarnos de que disco_duro siempre tenga un valor
        equipoData['disco_duro'] = detalle['disco_duro'] ?? detalle['almacenamiento'] ?? 'Sin especificar';
        equipoData['sistema_operativo'] = detalle['sistema_operativo'] ?? 'Sin especificar';
        equipoData['office'] = detalle['office'] ?? 'No';
        equipoData['antivirus'] = detalle['antivirus'] ?? 'No';
        equipoData['drive'] = detalle['drive'] ?? 'No';
        equipoData['nombre_equipo'] = detalle['nombre_equipo'] ?? 'PC-NUEVO';
      } else if (datos['tipo_equipo'] == 'Celular') {
        equipoData['imei'] = detalle['imei'] ?? 'Sin especificar';
        equipoData['numero_linea'] = detalle['numero'] ?? detalle['numero_linea'] ?? 'Sin especificar';
        equipoData['sistema_operativo'] = detalle['sistema_operativo'] ?? 'Sin especificar';
      } else if (datos['tipo_equipo'] == 'Impresora') {
        equipoData['tipo_conexion'] = detalle['conectividad'] ?? detalle['tipo_conexion'] ?? 'Sin especificar';
        equipoData['ip_asignada'] = detalle['ip_asignada'] ?? 'Sin asignar';
      }
      
      print('Datos enviados a la API: $equipoData');
      
      // Usamos un try-catch específico para la creación del equipo
      Response<dynamic> equipoResponse;
      try {
        equipoResponse = await _dio.post(_equiposUrl, data: equipoData);
      } catch (equipoError) {
        print("Error al crear equipo: $equipoError");
        if (equipoError is DioException && equipoError.response?.statusCode == 400) {
          // Si el error es por código duplicado, intentamos con otro código
          print("Posible código duplicado, intentando con otro código");
          equipoData['codigo_interno'] = 'EQ-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().second}';
          equipoResponse = await _dio.post(_equiposUrl, data: equipoData);
        } else {
          // Si es otro tipo de error, lo propagamos
          rethrow;
        }
      }
      
      // Verificamos que tengamos una respuesta válida
      if (equipoResponse.data == null || !equipoResponse.data.containsKey('id_equipo')) {
        print("Respuesta inválida al crear equipo: ${equipoResponse.data}");
        lastCreatedEquipoId = null;
        return false;
      }
      
      int idEquipo = equipoResponse.data['id_equipo'];
      // Guardamos el ID del equipo creado
      lastCreatedEquipoId = idEquipo;
      
      // Paso 2: Agregar el equipo al inventario
      print('Agregando equipo al inventario en: $_inventarioUrl');
      final inventarioData = {
        'id_equipo': idEquipo,
        'estado': datos['estado'] ?? 'SinAsignar',
        'observaciones': datos['observaciones'] ?? ''
      };
      
      // Agregar campos opcionales si están presentes
      if (datos['id_usuario_responsable'] != null) {
        inventarioData['id_usuario_responsable'] = datos['id_usuario_responsable'];
      }
      if (datos['id_area_responsable'] != null) {
        inventarioData['id_area_responsable'] = datos['id_area_responsable'];
      }
      if (datos['id_sucursal_ubicacion'] != null) {
        inventarioData['id_sucursal_ubicacion'] = datos['id_sucursal_ubicacion'];
      }
      
      print('Datos de inventario enviados a la API: $inventarioData');
      
      // Usamos un try-catch específico para la creación del inventario
      try {
        final inventarioResponse = await _dio.post(_inventarioUrl, data: inventarioData);
        // Guardamos el ID del inventario creado si está disponible
        if (inventarioResponse.data != null && inventarioResponse.data.containsKey('id_inventario')) {
          lastCreatedInventarioId = inventarioResponse.data['id_inventario'];
        }
      } catch (inventarioError) {
        print("Error al agregar equipo al inventario: $inventarioError");
        
        // Verificar si el error es porque el equipo ya está en el inventario
        if (inventarioError is DioException && 
            inventarioError.response?.statusCode == 400 &&
            inventarioError.response?.data != null &&
            inventarioError.response!.data.containsKey('error') &&
            inventarioError.response!.data['error'].toString().contains('ya está registrado')) {
          
          // Si el equipo ya está registrado y tenemos su ID de inventario, lo consideramos un éxito
          if (inventarioError.response!.data.containsKey('id_inventario')) {
            lastCreatedInventarioId = inventarioError.response!.data['id_inventario'];
            print("Equipo ya registrado en inventario con ID: $lastCreatedInventarioId");
            return true; // Consideramos esto como un éxito para la UI
          }
        }
        
        // Si falla la creación del inventario, deberíamos eliminar el equipo creado
        // para evitar equipos huérfanos, pero esto requeriría implementar un endpoint
        // de eliminación de equipos en la API
        return false;
      }
      
      return true;
    } catch (e) {
      if (e is DioException) {
        print("Error al crear equipo: ${e.message}");
        print("URL: ${e.requestOptions.path}");
        print("Método: ${e.requestOptions.method}");
        print("Datos enviados: ${e.requestOptions.data}");
        if (e.response != null) {
          print("Código de estado: ${e.response?.statusCode}");
          print("Respuesta: ${e.response?.data}");
        }
      } else {
        print("Error al crear equipo: $e");
      }
      return false;
    }
  }
  
  // Actualizar un equipo existente (actualiza tanto el equipo como su entrada en inventario)
  Future<bool> actualizarEquipo(int idInventario, Map<String, dynamic> datos) async {
    try {
      print('\n======= INICIO ACTUALIZACIÓN DE EQUIPO =======');
      print('Actualizando equipo con ID de inventario: $idInventario');
      print('Datos completos a enviar: $datos');
      
      // Construir URL para el inventario sin doble barra
      final inventarioUrl = _inventarioUrl.endsWith('/') 
          ? '${_inventarioUrl}$idInventario' 
          : '$_inventarioUrl/$idInventario';
      
      print('\n[1] OBTENIENDO DATOS ACTUALES DEL EQUIPO');
      print('URL del inventario: $inventarioUrl');
      
      // Primero obtenemos los datos actuales del equipo en inventario
      final inventarioResponse = await _dio.get(
        inventarioUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      if (inventarioResponse.statusCode != 200) {
        print('Error al obtener datos del inventario: ${inventarioResponse.statusCode}');
        return false;
      }
      
      print('Respuesta del inventario: ${inventarioResponse.data}');
      int idEquipo = inventarioResponse.data['equipo']['id_equipo'];
      
      // Construir URL para el equipo sin doble barra
      final equipoUrl = _equiposUrl.endsWith('/') 
          ? '${_equiposUrl}$idEquipo' 
          : '$_equiposUrl/$idEquipo';
      
      print('\n[2] PREPARANDO DATOS DEL EQUIPO');
      print('URL del equipo: $equipoUrl');
      print('Tipo de equipo recibido: ${datos['tipo_equipo']}');
      print('Tipo de equipo en el inventario: ${inventarioResponse.data['equipo']['tipo_equipo']}');
      
      // FORZAR el tipo de equipo a ser el mismo que el existente en el inventario
      // Esto asegura que no intentemos cambiar el tipo de equipo durante la actualización
      String tipoEquipo = inventarioResponse.data['equipo']['tipo_equipo'];
      print('[INFO] Forzando tipo de equipo al valor existente en el inventario: "$tipoEquipo"');
      
      // Verificar que el tipo sea válido
      if (tipoEquipo != 'Computacional' && tipoEquipo != 'Celular' && tipoEquipo != 'Impresora') {
        print('[ADVERTENCIA] Tipo de equipo en el inventario no es válido: "$tipoEquipo". Usando Computacional como valor por defecto.');
        tipoEquipo = 'Computacional';
      }
      
      // Crear una copia de los datos para no modificar el original
      final Map<String, dynamic> equipoData = {};
      
      // Agregar campos obligatorios
      equipoData['tipo_equipo'] = tipoEquipo;
      
      // Agregar código interno si está presente o usar el existente
      equipoData['codigo_interno'] = datos['codigo_interno'] ?? 
                                    inventarioResponse.data['equipo']['codigo_interno'];
      
      // Agregar otros campos si están presentes en los datos
      if (datos.containsKey('marca') && datos['marca'] != null) {
        equipoData['marca'] = datos['marca'];
      }
      if (datos.containsKey('modelo') && datos['modelo'] != null) {
        equipoData['modelo'] = datos['modelo'];
      }
      if (datos.containsKey('serial_number') && datos['serial_number'] != null) {
        equipoData['serial_number'] = datos['serial_number'];
      }
      
      // Agregar campos específicos según el tipo de equipo
      if (tipoEquipo == 'Computacional') {
        if (datos.containsKey('procesador') && datos['procesador'] != null) {
          equipoData['procesador'] = datos['procesador'];
        }
        if (datos.containsKey('ram') && datos['ram'] != null) {
          equipoData['ram'] = datos['ram'];
        }
        if (datos.containsKey('disco_duro') && datos['disco_duro'] != null) {
          equipoData['disco_duro'] = datos['disco_duro'];
        }
        if (datos.containsKey('sistema_operativo') && datos['sistema_operativo'] != null) {
          equipoData['sistema_operativo'] = datos['sistema_operativo'];
        }
        if (datos.containsKey('nombre_equipo') && datos['nombre_equipo'] != null) {
          equipoData['nombre_equipo'] = datos['nombre_equipo'];
        }
      } else if (tipoEquipo == 'Celular') {
        if (datos.containsKey('imei') && datos['imei'] != null) {
          equipoData['imei'] = datos['imei'];
        }
        if (datos.containsKey('numero_linea') && datos['numero_linea'] != null) {
          equipoData['numero_linea'] = datos['numero_linea'];
        }
      } else if (tipoEquipo == 'Impresora') {
        if (datos.containsKey('tipo_conexion') && datos['tipo_conexion'] != null) {
          equipoData['tipo_conexion'] = datos['tipo_conexion'];
        }
      }
      
      print('\n[3] ENVIANDO ACTUALIZACIÓN DEL EQUIPO');
      print('Datos a enviar al equipo: $equipoData');
      
      // Actualizar el equipo
      final equipoResponse = await _dio.put(
        equipoUrl, 
        data: equipoData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      print('Respuesta de actualización del equipo:');
      print('Código: ${equipoResponse.statusCode}');
      print('Datos: ${equipoResponse.data}');
      
      if (equipoResponse.statusCode != 200) {
        print('Error al actualizar equipo: ${equipoResponse.statusCode} - ${equipoResponse.data}');
        return false;
      }
      
      print('\n[4] PREPARANDO DATOS DEL INVENTARIO');
      
      // Preparar datos para la actualización del inventario
      final Map<String, dynamic> inventarioData = {};
      
      // Agregar estado si está presente
      if (datos.containsKey('estado') && datos['estado'] != null) {
        inventarioData['estado'] = datos['estado'];
      }
      
      // Agregar campos opcionales si están presentes
      if (datos.containsKey('observaciones') && datos['observaciones'] != null) {
        inventarioData['observaciones'] = datos['observaciones'];
      }
      if (datos.containsKey('id_usuario_responsable') && datos['id_usuario_responsable'] != null) {
        inventarioData['id_usuario_responsable'] = datos['id_usuario_responsable'];
      }
      if (datos.containsKey('id_area_responsable') && datos['id_area_responsable'] != null) {
        inventarioData['id_area_responsable'] = datos['id_area_responsable'];
      }
      if (datos.containsKey('id_sucursal_ubicacion') && datos['id_sucursal_ubicacion'] != null) {
        inventarioData['id_sucursal_ubicacion'] = datos['id_sucursal_ubicacion'];
      }
      
      // Solo actualizar el inventario si hay datos para actualizar
      if (inventarioData.isNotEmpty) {
        print('\n[5] ENVIANDO ACTUALIZACIÓN DEL INVENTARIO');
        print('Datos a enviar al inventario: $inventarioData');
        
        // Actualizar el inventario
        final inventarioUpdateResponse = await _dio.put(
          inventarioUrl, 
          data: inventarioData,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        
        print('Respuesta de actualización del inventario:');
        print('Código: ${inventarioUpdateResponse.statusCode}');
        print('Datos: ${inventarioUpdateResponse.data}');
        
        if (inventarioUpdateResponse.statusCode != 200) {
          print('Error al actualizar inventario: ${inventarioUpdateResponse.statusCode} - ${inventarioUpdateResponse.data}');
          return false;
        }
      } else {
        print('No hay datos para actualizar en el inventario');
      }
      
      print('\n======= FIN ACTUALIZACIÓN DE EQUIPO (EXITOSA) =======');
      return true;
    } catch (e) {
      print('\n======= ERROR EN ACTUALIZACIÓN DE EQUIPO =======');
      print('Error: $e');
      if (e is DioException) {
        print('Tipo de error: ${e.type}');
        print('Mensaje: ${e.message}');
        print('URL: ${e.requestOptions.uri}');
        print('Método: ${e.requestOptions.method}');
        print('Headers: ${e.requestOptions.headers}');
        print('Datos enviados: ${e.requestOptions.data}');
        if (e.response != null) {
          print('Código de respuesta: ${e.response!.statusCode}');
          print('Respuesta: ${e.response!.data}');
        }
      }
      print('======= FIN ERROR =======\n');
      return false;
    }
  }
  
  // Eliminar un equipo del inventario (no elimina el equipo de la tabla equipos)
  Future<bool> eliminarEquipo(int idInventario) async {
    try {
      // Aseguramos que no haya doble barra en la URL
      final url = _inventarioUrl.endsWith('/') 
          ? '$_inventarioUrl$idInventario' 
          : '$_inventarioUrl/$idInventario';
      
      print('Eliminando equipo del inventario en: $url');
      await _dio.delete(url);
      return true;
    } catch (e) {
      print("Error al eliminar equipo del inventario: $e");
      return false;
    }
  }
  
  // Cambiar el estado de un equipo
  Future<bool> cambiarEstadoEquipo(int idInventario, String nuevoEstado) async {
    try {
      // Aseguramos que no haya doble barra en la URL
      final baseUrl = _inventarioUrl.endsWith('/') 
          ? '$_inventarioUrl$idInventario' 
          : '$_inventarioUrl/$idInventario';
      final url = '$baseUrl/estado';
      
      print('Cambiando estado del equipo en: $url');
      await _dio.put(url, data: {
        'estado': nuevoEstado
      });
      return true;
    } catch (e) {
      print("Error al cambiar estado del equipo: $e");
      if (e is DioException) {
        print("URL: ${e.requestOptions.path}");
        print("Código de estado: ${e.response?.statusCode}");
        print("Respuesta: ${e.response?.data}");
      }
      return false;
    }
  }
}
