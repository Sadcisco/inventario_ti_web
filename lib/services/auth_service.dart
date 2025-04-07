import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // URLs de los endpoints
  final String _authUrl = '$apiUrl/api/auth';

  // Iniciar sesión
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post('$_authUrl/login', data: {
        'username': username,
        'password': password,
      });
      
      // Guardar tokens
      await _storage.write(key: 'access_token', value: response.data['access_token']);
      await _storage.write(key: 'refresh_token', value: response.data['refresh_token']);
      
      return response.data;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // Obtener token de acceso
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Obtener token de actualización
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }
  
  // Simular autenticación para modo desarrollo
  Future<bool> setDevelopmentToken() async {
    try {
      // Token JWT simulado para desarrollo (no es un token real válido)
      const String devToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwibmFtZSI6IkRldmVsb3BlciIsImlhdCI6MTUxNjIzOTAyMn0.ye3DGiiRmVBL4t3kO0WYhD21HQjDdmqVU5xTMnFoWxs';
      
      // Guardar token simulado
      await _storage.write(key: 'access_token', value: devToken);
      await _storage.write(key: 'refresh_token', value: devToken);
      
      return true;
    } catch (e) {
      print("Error al establecer token de desarrollo: $e");
      return false;
    }
  }

  // Actualizar token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post('$_authUrl/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      await _storage.write(key: 'access_token', value: response.data['access_token']);
      return true;
    } catch (e) {
      print("Error al actualizar token: $e");
      return false;
    }
  }
}

// Interceptor para añadir el token JWT a todas las solicitudes
class JwtInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Asegurar que los headers de CORS estén configurados correctamente
    options.headers['Accept'] = 'application/json, text/plain, */*';
    options.headers['Content-Type'] = 'application/json';
    
    // Imprimir información de depuración
    print('Enviando solicitud a: ${options.uri}');
    print('Método: ${options.method}');
    print('Headers: ${options.headers}');
    
    return super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('Respuesta recibida de: ${response.requestOptions.uri}');
    print('Código de estado: ${response.statusCode}');
    print('Datos: ${response.data}');
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('Error en solicitud a: ${err.requestOptions.uri}');
    print('Tipo de error: ${err.type}');
    print('Mensaje de error: ${err.message}');
    if (err.response != null) {
      print('Código de estado: ${err.response?.statusCode}');
      print('Datos de error: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
