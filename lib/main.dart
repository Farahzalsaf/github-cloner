import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import './login_page.dart';
import './profile_page.dart';
import './oauth_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Login',
      home: LoginPage(),
      routes: {
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  final OAuthService oauthService = OAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Get the access token from the OAuthService
            final accessToken = await oauthService.getAccessToken();
            if (accessToken != null) {
              // Make authenticated API requests or perform other tasks with the access token
              // Navigate back to the login page
              Navigator.pop(context);
            } else {
              // Access token is null, handle the error or show login page again
              Navigator.pop(context);
            }
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final OAuthService oauthService = OAuthService();

  Future<void> _login(BuildContext context) async {
    try {
      await oauthService.launchUrl();
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
          onPressed: () => _login(context),
        ),
      ),
    );
  }
}

