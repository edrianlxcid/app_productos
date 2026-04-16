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

  static Future<List<dynamic>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  static Future<void> createProduct(
    String token,
    Map<String, String> fields,
    File? image,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    await request.send();
  }

  static Future<void> updateProduct(
    String token,
    String id,
    Map<String, String> fields,
    File? image,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/products/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    await request.send();
  }

  static Future<void> deleteProduct(String token, String id) async {
    await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
