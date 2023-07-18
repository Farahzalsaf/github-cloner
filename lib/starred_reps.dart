import 'package:flutter/material.dart';
import './github_api_service.dart';

class StarredRepositoriesPage extends StatelessWidget {
  final GithubApiService githubApiService = GithubApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Starred Repositories'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: githubApiService.fetchStarredRepositories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching starred repositories'));
          } else if (snapshot.hasData) {
            final starredRepositories = snapshot.data!;
            return ListView.builder(
              itemCount: starredRepositories.length,
              itemBuilder: (context, index) {
                // ignore: unused_local_variable
                final repository = starredRepositories[index];
                return ListTile(

                    // Display other repository information as desired
                    );
              },
            );
          } else {
            return Center(child: Text('No starred repositories found'));
          }
        },
      ),
    );
  }
}
