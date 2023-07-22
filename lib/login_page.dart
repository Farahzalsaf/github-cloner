import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import './Oauth_service.dart';
import './profile_page.dart';
import 'package:http/http.dart';

class LoginPage extends StatelessWidget {
  final OAuthService oauthService = OAuthService();

  Future<void> _login(BuildContext context) async {
    try {
      await oauthService.launchUrl();
      // Do not navigate to the profile page immediately.
      // The app will be redirected back to the custom URI scheme after GitHub login.
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Login with GitHub'),
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (context) => Dialog(
                child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: Uri.https('github.com', '/login/oauth/authorize', {
                        'client_id': '62c3f7e3b4797d7ff0ed',
                        'redirect_uri': 'http://localhost:3000/callback',
                        'scope': 'read:user',
                      }),
                    ),
                    onLoadStart: (controller, url) {
                      // This is called when a page starts loading.
                      // You can show a loading indicator here if needed.
                    },
                    onLoadStop: (controller, url) async {
                      // This is called when a page finishes loading.
                      // Check if the URL starts with the callback URL to extract the code.
                      if (url != null &&
                          url
                              .toString()
                              .startsWith('http://localhost:3000/callback')) {
                        final code =
                            Uri.parse(url.toString()).queryParameters['code'];
                        if (code != null) {
                          Navigator.of(context).pop(code);
                        }
                      }
                    }),
              ),
            );
          },
        ),
      ),
    );
  }
}