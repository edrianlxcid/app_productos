import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    print(response);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
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
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/publicaciones'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    await request.send();
  }

  static Future<void> updatePublicacion(
    String token,
    String id,
    Map<String, String> fields,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/publicaciones/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    await request.send();
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
