import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFFFFFFF, {
          50: Color(0xFFFFFFFF),
          100: Color(0xFFFFFFFF),
          200: Color(0xFFFFFFFF),
          300: Color(0xFFFFFFFF),
          400: Color(0xFFFFFFFF),
          500: Color(0xFFFFFFFF),
          600: Color(0xFFFFFFFF),
          700: Color(0xFFFFFFFF),
          800: Color(0xFFFFFFFF),
          900: Color(0xFFFFFFFF),
        }),
      ),
      home: const MyHomePage(title: 'Github cloner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
                  _handleCode(code);
                }
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleCode(String code) async {
    try {
      final accessToken = await _getAccessToken(code);
      if (accessToken != null && accessToken.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileWidget(
              code: code,
              accessToken: accessToken,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error handling code: $e');
    }
  }

  Future<String?> _getAccessToken(String code) async {
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
        final data = response.data;
        String res = '';
        if (data != null) {
          res = data.replaceAll('access_token=', '');
          res = res.replaceAll('&scope=read%3Auser&token_type=bearer', '');
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


/**
 * after the comment, the UI of the app starts 
 */

class UserRepoCard extends StatelessWidget {
  final String repoName;
  final String repoDescription;
  final VoidCallback onTap;

  const UserRepoCard({
    required this.repoName,
    required this.repoDescription,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(repoName),
        subtitle: Text(repoDescription),
        onTap: onTap,
      ),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  final String code;
  final String accessToken;

  const ProfileWidget({required this.code, required this.accessToken, Key? key})
      : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  Map<String, dynamic> _profileData = {};
  List<dynamic> _userRepos = [];


  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserRepos(); // Fetch user repositories during initialization

  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await Dio().get(
        'https://api.github.com/user',
        options:
            Options(headers: {'Authorization': 'token ${widget.accessToken}'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = response.data;
        });
      } else {
        print('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

Future<void> _fetchUserRepos() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.github.com/user/repos'), // Use the correct URL to fetch user repositories
      headers: {'Authorization': 'token ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _userRepos = json.decode(response.body);
        print('User Repositories: $_userRepos');
      });
    } else {
      print('Failed to fetch user repositories: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  Future<Map<String, dynamic>> _fetchFollowersFollowing() async {
    try {
      final followersResponse = await Dio().get(
        'https://api.github.com/user/followers',
        options:
            Options(headers: {'Authorization': 'token ${widget.accessToken}'}),
      );

      final followingResponse = await Dio().get(
        'https://api.github.com/user/following',
        options:
            Options(headers: {'Authorization': 'token ${widget.accessToken}'}),
      );

      if (followersResponse.statusCode == 200 &&
          followingResponse.statusCode == 200) {
        final followersData = followersResponse.data;
        final followingData = followingResponse.data;
        return {
          'followers': followersData.length,
          'following': followingData.length,
        };
      } else {
        throw Exception('Failed to fetch followers and following data');
      }
    } catch (e) {
      print('Error fetching followers and following: $e');
      throw Exception('Failed to fetch followers and following data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GitHub Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white, // Set the background color to white
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: _profileData.isEmpty
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          )
                        ]
                        
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              _profileData['avatar_url'] ?? '',
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            _profileData['name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _profileData['login'] ?? 'No Username',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _fetchFollowersFollowing(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error fetching followers and following');
                              } else {
                                final followers = snapshot.data?['followers'] ?? 0;
                                final following = snapshot.data?['following'] ?? 0;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '$followers',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          '$following',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _StarredReposPage(
                              accessToken: widget.accessToken,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200], // Set the background color to light grey
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'View Starred Repos',
                        style: TextStyle(color: Colors.black), // Set the text color to black
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    ContributionsWidget(
                      username: _profileData['login'] ?? '',
                      widgetSize: 'medium',
                      theme: 'green',
                      weeks: 30,
                    ),
                    SizedBox(height: 20),
                    // User Repositories Section
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'User Repositories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (_userRepos.isNotEmpty)
                            Column(
                              children: [
                                for (var repo in _userRepos.sublist(0, 5))
                                  UserRepoCard(
                                    repoName: repo['name'] ?? '',
                                    repoDescription: repo['description'] ?? 'No description',
                                    onTap: () {
                                      final repoUrl = repo['html_url'];
                                      if (repoUrl != null && repoUrl.isNotEmpty) {
                                        launch(repoUrl);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          if (_userRepos.isEmpty)
                            Text('No repositories found.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
      ),
    );
  }
}



class ContributionsWidget extends StatefulWidget {
  final String? username; // Make username nullable
  final String widgetSize;
  final String theme;
  final int weeks;

  const ContributionsWidget({
    required this.username,
    required this.widgetSize,
    required this.theme,
    required this.weeks,
    Key? key,
  }) : super(key: key);

  @override
  _ContributionsWidgetState createState() => _ContributionsWidgetState();
}

class _ContributionsWidgetState extends State<ContributionsWidget> {
  late String _url;

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      _url =
          'https://contribution.catsjuice.com/_/${widget.username}?format=png&weeks=${widget.weeks}&theme=${widget.theme}&widget_size=${widget.widgetSize}';
    } else {
      _url = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Set the container color to white
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Contributions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          if (_url.isNotEmpty)
            Image.network(_url)
          else
            Text('No contributions data available.'),
        ],
      ),
    );
  }
}

class _StarredReposPage extends StatefulWidget {
  final String accessToken;

  const _StarredReposPage({required this.accessToken});

  @override
  State<_StarredReposPage> createState() => _StarredReposPageState();
}

class _StarredReposPageState extends State<_StarredReposPage> {
  List<dynamic> _starredRepos = [];

  @override
  void initState() {
    super.initState();
    _fetchStarredRepos();
  }

  Future<void> _fetchStarredRepos() async {
    try {
      final response = await Dio().get(
        'https://api.github.com/user/starred',
        options: Options(headers: {'Authorization': 'token ${widget.accessToken}'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _starredRepos = response.data;
        });
      } else {
        print('Failed to fetch starred repos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Starred Repositories',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[300],
        child: ListView.builder(
          itemCount: _starredRepos.length > 14 ? 14 : _starredRepos.length, // Show up to 5 repositories
          itemBuilder: (context, index) {
            final repo = _starredRepos[index];
            return UserRepoCard(
              repoName: repo['name'] ?? '',
              repoDescription: repo['description'] ?? 'No description',
              onTap: () {
                final repoUrl = repo['html_url'];
                if (repoUrl != null && repoUrl.isNotEmpty) {
                  launch(repoUrl); // Use the launch method to open the URL
                }
              },
            );
          },
        ),
      ),
    );
  }
}


