import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_player/utils/device_id_util.dart';

class ApiService {
  static const String baseUrl = "https://twut-backend.vercel.app/api";
  static const String xApiKey = "tugas_cak_nanang";

  static Future<dynamic> get(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    try {
      final uri = Uri.parse("$baseUrl$endpoint")
          .replace(queryParameters: queryParams);

      final deviceId = await DeviceIdUtil.getDeviceId();

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "x-api-key" : xApiKey,
          "x-device-id": deviceId
        },
      );

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