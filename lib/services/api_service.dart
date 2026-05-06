import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://twut-backend.vercel.app";

  static Future<dynamic> get(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    try {
      final uri = Uri.parse("$baseUrl$endpoint")
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "GET error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}