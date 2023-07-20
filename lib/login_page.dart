import 'package:flutter/material.dart';
import './oauth_service.dart';
import './profile_page.dart';
import 'package:auth_buttons/auth_buttons.dart';

class LoginPage extends StatelessWidget {
  final OAuthService oauthService = OAuthService();

  Future<void> _login(BuildContext context) async {
    try {
      final isAuthenticated = await oauthService.authenticate();
      if (isAuthenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else {
        // Handle login failure
        _showErrorDialog(context, 'Login failed. Please try again.');
      }
    } catch (e) {
      print('Login error: $e');
      // Handle the error or show an error message
      _showErrorDialog(
          context, 'An error occurred during login. Please try again later.');
      print(e);
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

