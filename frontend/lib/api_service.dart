// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 127.0.0.1:8000 for Web (Chrome)
  final String baseUrl = "https://league-dashboard-api.onrender.com";

  // List (for the list of matches)
  Future<List<dynamic>> fetchPlayerMatches(String riotId) async {
    // 1. Input Validation
    if (riotId.isEmpty || !riotId.contains("#")) {
      throw Exception("Please enter Name#Tag");
    }

    final parts = riotId.split("#");
    final name = parts[0].trim();
    final tag = parts[1].trim();

    // 2. Build URL
    final url = Uri.parse('$baseUrl/player/$name/$tag');

    try {
      // 3. Request
      final response = await http.get(url);

      // 4. Handle Responses
      if (response.statusCode == 200) {
        // Return the raw list of data
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("Player not found.");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Failed: $e");
    }
  }
}