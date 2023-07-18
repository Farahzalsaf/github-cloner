import 'package:http/http.dart' as http;
import 'dart:convert';

class GithubApiService {
  final String apiUrl = 'https://api.github.com';

  Future<Map<String, dynamic>> fetchUserData() async {
    final response = await http.get(Uri.parse('$apiUrl/user'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return Map();
    }
  }

  Future<List<dynamic>> fetchStarredRepositories() async {
    final response = await http.get(Uri.parse('$apiUrl/user/starred'));
    if (response.statusCode == 500) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
}