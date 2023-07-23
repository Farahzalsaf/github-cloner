import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;

  const ProfilePage({required this.accessToken, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await Dio().get(
        'https://api.github.com/user',
        options: Options(headers: {'Authorization': 'token ${widget.accessToken}'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = response.data;
        });
      } else {
        // Handle error case
        print('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Profile'),
      ),
      body: Center(
        child: _profileData.isEmpty
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_profileData['avatar_url'] ?? ''),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _profileData['name'] ?? 'No Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(_profileData['login'] ?? 'No Username'),
                  SizedBox(height: 8),
                  Text(_profileData['email'] ?? 'No Email'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle log out or navigate back to previous screen
                    },
                    child: Text('Log Out'),
                  ),
                ],
              ),
      ),
    );
  }
}
