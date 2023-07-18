import 'package:oauth2/oauth2.dart' as oauth2;
class OAuthService {
  final String clientId = '62c3f7e3b4797d7ff0ed';
  final String clientSecret = 'd47954ef6463476d9ca8750b285eae7303e0c882';
  final String authorizationUrl = 'https://github.com/login/oauth/authorize';
  final String tokenUrl = 'https://github.com/login/oauth/access_token';
  final String redirectUrl = 'http://localhost:3000/callback';
  final scopes = ['read:user', 'repo'];

  Future<bool> authenticate() async {
    final grant = oauth2.AuthorizationCodeGrant(
      '8abc0cdfdd947d5a5f78',
      Uri.parse('https://github.com/login/oauth/authorize'),
      Uri.parse('https://github.com/login/oauth/access_token'),
      secret: 'd47954ef6463476d9ca8750b285eae7303e0c882',
    );
    // Redirect user to GitHub login page
    final authorizationUrl =
        await grant.getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes);
    // Handle the authorization flow
    final responseUrl = await handleAuthorizationFlow(authorizationUrl);

    // Exchange authorization code for access token
    responseUrl.queryParameters.addAll({
      "code":""
    });
    final client =
        await grant.handleAuthorizationResponse(responseUrl.queryParameters);
    print(client.credentials);
    // Store the access token for future API requests
    

    return true; // Return true if authentication was successful
  }

  Future<Uri> handleAuthorizationFlow(Uri authorizationUrl) {


    return Future.value(Uri.parse('http://localhost:3000/callback'));
  }
}




