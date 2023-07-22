import 'dart:convert';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
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

  Future<String?> getAccessToken(String code) async {
    try {
      const tokenUrl = 'https://github.com/login/oauth/access_token';
      Dio dio = Dio();
      dio.interceptors.add(PrettyDioLogger());
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      final body = {
        'client_id': "62c3f7e3b4797d7ff0ed",
        'client_secret': "fdb5b7b94552992b6c8fcdde502f6029e9df5403",
        'code': code,
      };

      final response = await dio.get(
        tokenUrl,
        options: Options(
          headers: headers,
        ),
        data: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        if (data['access_token'] != null) {
          return data['access_token'];
        } else {
          throw Exception('Access token not found in the response');
        }
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GithubAuthButton(
              onPressed: () async {
                await _showAuthDialog(_url);
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

Future<String?> getAccessToken(String code) async {
  try {
    const tokenUrl = 'https://github.com/login/oauth/access_token';
    Dio dio = Dio();
    dio.interceptors.add(PrettyDioLogger());
    final headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer token'
    };

    final body = {
      'client_id': "62c3f7e3b4797d7ff0ed",
      'client_secret': "fdb5b7b94552992b6c8fcdde502f6029e9df5403",
      'code': code,
    };

    final response = await dio.get(
      tokenUrl,
      options: Options(
        headers: headers,
      ),
      data: body,
    );

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.data);
      final data = response.data;
      String res = '';
      if (data != null) {
        res = data.replaceAll('access_token=', '');
        res = res.replaceAll('&scope=read%3Auser&token_type=bearer', '');
        print(data);
        return await res;
      } else {
        throw Exception('Access token not found in the response');
      }
    } else {
      throw Exception('Failed to get access token: ${response.statusCode}');
    }
  } catch (e) {
    print(e);
  }
}

class _LoggedInState extends State<LoggedIn> {
  String token = '';

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
            ElevatedButton(
                onPressed: () async {
                  final accessToken = await getAccessToken(widget.code);
                  print('$accessToken heeeeeeeeeere');
                  setState(() {
                    token = accessToken.toString();
                  });
                  print(token);
                },
                child: Text('Click for codes')),
            Text(
              'You are logged in and here is your token code ${token.toString()} and your authorization code ${widget.code} !',
            ),
          ],
        ),
      ),
    );
  }
}
