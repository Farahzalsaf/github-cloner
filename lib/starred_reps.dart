import 'package:flutter/material.dart';
import './github_api_service.dart';
class StarredRepositoriesPage extends StatefulWidget {
  final String code;
  StarredRepositoriesPage({Key? key, required this.code});

  @override
  State<StarredRepositoriesPage> createState() =>
      _StarredRepositoriesPageState();
}

class _StarredRepositoriesPageState extends State<StarredRepositoriesPage> {
  final GithubApiService githubApiService = GithubApiService();
  late Future<List<dynamic>> _starredReposFuture;

  @override
  void initState() {
    super.initState();
    _starredReposFuture = githubApiService.getstarredrepos(widget.code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Repositories'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _starredReposFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error fetching starred repositories'));
          } else if (snapshot.hasData) {
            final starredRepositories = snapshot.data!;
            return ListView.builder(
              itemCount: starredRepositories.length,
              itemBuilder: (context, index) {
                final repository = starredRepositories[index];
                return ListTile(
                  title: Text(repository['name']),
                  subtitle: Text(repository['description'] ?? ''),
                  // Display other repository information as desired
                );
              },
            );
          } else {
            return const Center(child: Text('No starred repositories found'));
          }
        },
      ),
    );
  }
}