import 'dart:convert';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Uri _url = Uri.parse(
      'https://github.com/login/oauth/authorize?client_id=62c3f7e3b4797d7ff0ed&redirect_uri=http://localhost:3000/callback&scope=read:user');

  Future<String?> _showAuthDialog(Uri authUrl) {
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
                  Future<void> _handleCode(String code) async {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoggedIn(code: code),
                      ),
                    );
                  }

                  await _handleCode(code);
                }
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GithubAuthButton(
              onPressed: () {
                _showAuthDialog(_url);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoggedIn extends StatefulWidget {
  final String code;
  const LoggedIn({super.key, required this.code});

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are logged in and here is your code ${widget.code}!',
            ),
          ],
        ),
      ),
    );
  }

  final storage = FlutterSecureStorage();

Future<void> getAccessToken(String clientId, String clientSecret, String code) async {
  final tokenUrl = 'https://github.com/login/oauth/access_token';

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final body = jsonEncode({
    'client_id': '62c3f7e3b4797d7ff0ed',
    'client_secret': 'fdb5b7b94552992b6c8fcdde502f6029e9df5403',
    'code': '439c7ee38f7db5f1e6fa',
  });

  
  final response = await http.post(
    Uri.parse(tokenUrl),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['access_token'] != null) {
      await storage.write(key: "token", value: data['access_token']);
    } else {
      throw Exception('Access token not found in the response');
    }
  } else {
    throw Exception('Failed to get access token: ${response.statusCode}');
  }
}
}
