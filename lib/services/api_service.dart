import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.100.123:3000/api';

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl'))
          .timeout(const Duration(seconds: 10));
      print('Test status: ${response.statusCode}');
      print('Test body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Test error: $e');
      return {'error': '$e'};
    }
  }

  static String? currentUser;

  static void setCurrentUser(String user) {
    currentUser = user;
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final testResp = await http
          .get(Uri.parse('$baseUrl'))
          .timeout(const Duration(seconds: 5));
      print('Test connection: ${testResp.statusCode} - ${testResp.body}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'usuario': username, 'contraseña': password}),
          )
          .timeout(const Duration(seconds: 10));

      print('Login status: ${response.statusCode}');
      print('Login body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'message': 'Error ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': username, 'contraseña': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getPublicaciones(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publicaciones'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  static Future<void> createPublicacion(
    String token,
    Map<String, String> fields,
  ) async {
    try {
      print('Creating publicacion at: $baseUrl/publicaciones');
      print('Fields: $fields');

      final response = await http.post(
        Uri.parse('$baseUrl/publicaciones'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(fields),
      );

      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode >= 400) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Create publicacion error: $e');
      rethrow;
    }
  }

  static Future<void> updatePublicacion(
    String token,
    String id,
    Map<String, String> fields,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/publicaciones/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(fields),
    );

    if (response.statusCode >= 400) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  static Future<void> deletePublicacion(String token, String id) async {
    await http.delete(
      Uri.parse('$baseUrl/publicaciones/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<void> addComentario(
    String token,
    String publicacionId,
    Map<String, String> fields,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/publicaciones/$publicacionId/comentarios'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    await request.send();
  }
}
