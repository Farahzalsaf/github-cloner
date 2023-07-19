import 'package:flutter/material.dart';
import './Oauth_service.dart';
import './profile_page.dart';

class LoginPage extends StatelessWidget {
  final OAuthService oauthService = OAuthService();

  LoginPage({super.key});
  Future<void> _login(BuildContext context) async {
    try {
      await oauthService.launchUrl();
      //final accessToken = await oauthService.getAccessToken(); -> still choosing between them 
      final accessToken = await oauthService.handleAuthorizationFlow();
      if (accessToken != null) {
        await oauthService.saveAccessToken(accessToken);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
      print('login error: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
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
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Login with GitHub'),
          onPressed: () => _login(context),
        ),
      ),
    );
  }
}
