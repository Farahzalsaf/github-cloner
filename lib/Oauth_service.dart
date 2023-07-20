import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthService {
  final String clientId = '62c3f7e3b4797d7ff0ed';
  final String clientSecret = '320bbf27ff4f7c021405dc7cc671edad90c8dae4';
  final String authorizationUrl =
      'http://localhost:3000/callback';
  final String tokenUrl = 'https://github.com/login/oauth/access_token';
  final String redirectUrl = 'http://localhost:3000/callback';
  final String tokenPath = 'https://github.com/login/oauth/access_token';
  final scopes = ['read:user', 'repo'];
  final Uri _url = Uri.parse(
      'https://github.com/login/oauth/authorize?client_id=62c3f7e3b4797d7ff0ed&redirect_uri=http://localhost:3000/callback&scope=read:user');
      
  late final BuildContext context;

  Future<void> launchUrl() async {
    if (!await canLaunch(_url.toString())) {
      print('Could not launch $_url');
      throw Exception('Could not launch $_url');
    }
    await launch(_url.toString());
  }

  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /*Future<void> makeAuthenticatedRequest(String accessToken) async {
    final client = http.Client();
    final headers = {'Authorization': 'Bearer $accessToken'};

    // Make authenticated API requests
    final response = await client.get(Uri.parse('https://api.github.com/user'),
        headers: headers);

    // Handle the response
    if (response.statusCode == 200) {
      // Successful response
      final responseBody = response.body;
      print('API response: $responseBody');
    } else {
      // Error response
      print('API request failed: ${response.statusCode}');
    }

    // Close the client
    client.close();
  }
  */
  Future<String?> showAuthDialog(Uri authUrl) {
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: authUrl),
          onProgressChanged: (controller, progress) async {
            if (progress == 100) {
              final url = await controller.getUrl();
              if (url!
                  .toString()
                  .startsWith('http://localhost:3000/callback')) {
                final code = Uri.parse(url.toString()).queryParameters['code'];
                if (code != null) {
                  Navigator.of(context).pop(code);
                }
              }
            }
          },
        ),
      ),
    );
  } 

}
