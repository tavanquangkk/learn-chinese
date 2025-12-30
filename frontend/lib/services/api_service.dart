import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://localhost:8080/api';
  static const String baseUrl = '/api'; // use nginx to connect to backend

  Future<String> chat(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['answer'] ?? 'No answer.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error connecting to server: $e';
    }
  }

  Future<bool> toggleRemember(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/vocabulary/$id/remember'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error toggle remember: $e');
      return false;
    }
  }
}
