import 'package:flutter/material.dart';
import './Oauth_service.dart';
import './profile_page.dart';

class LoginPage extends StatelessWidget {
  final OAuthService oauthService = OAuthService();
  Future<void> _login(BuildContext context) async {
    try {
      await oauthService.launchUrl();
      final accessToken = await oauthService.getAccessToken();
      if (accessToken != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
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
