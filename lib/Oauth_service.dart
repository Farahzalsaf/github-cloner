import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
class OAuthService {
  final String clientId = '62c3f7e3b4797d7ff0ed';
  final String clientSecret = '320bbf27ff4f7c021405dc7cc671edad90c8dae4';
  final String authorizationUrl = 'https://github.com/login/oauth/authorize';
  final String tokenUrl = 'https://github.com/login/oauth/access_token';
  final String redirectUrl = 'http://localhost:3000/callback';
  final scopes = ['read:user', 'repo'];
  final Uri _url = Uri.parse(
      'https://github.com/login/oauth/authorize?client_id=62c3f7e3b4797d7ff0ed&redirect_uri=http://localhost:3000/callback&scope=read:user');

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


}






