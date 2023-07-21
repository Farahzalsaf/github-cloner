import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class GithubApiService extends StatelessWidget {
  Future<Map<String, dynamic>> getuserdata(String accessToken) async {
    try {
      final userResponse = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        return userData;
      } else {
        // Handle error response
        final errorMessage =
            'Failed to fetch user data: ${userResponse.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Handle exceptions
      throw Exception('Error occurred while fetching user data: $error');
    }
  }

  Future<List<dynamic>> getrepos(String accessToken) async {
    try {
      final userResponse = await http.get(
        Uri.parse('https://api.github.com/user/repos'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        return userData;
      } else {
        // Handle error response
        final errorMessage =
            'Failed to fetch user repositories: ${userResponse.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Handle exceptions
      throw Exception(
          'Error occurred while fetching user repositories: $error');
    }
  }

  Future<List<dynamic>> getstarredrepos(String accessToken) async {
    try {
      final userResponse = await http.get(
        Uri.parse('https://api.github.com/user/starred'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        return userData;
      } else {
        // Handle error response
        final errorMessage =
            'Failed to fetch starred repositories: ${userResponse.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (error) {
      // Handle exceptions
      throw Exception(
          'Error occurred while fetching starred repositories: $error');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
