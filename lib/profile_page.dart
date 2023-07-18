import 'package:flutter/material.dart';
import './github_api_service.dart';

class ProfilePage extends StatelessWidget {
  final GithubApiService githubApiService = GithubApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: githubApiService.fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching user data'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            return Column(
              children: [
                Text('Name: ${userData['name']}'),
                // Display other user information as desired
              ],
            );
          } else {
            return Center(child: Text('No user data found'));
          }
        },
      ),
    );
  }
}
