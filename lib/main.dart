import 'package:flutter/material.dart';
import 'github_oauth_credentials.dart';
import 'src/github_login.dart';
import 'package:github/github.dart';
import 'package:window_to_front/window_to_front.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'GitHub Client'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return GithubLoginWidget(
      githubClientId: githubClientId,
      githubClientSecret: githubClientSecret,
      githubScopes: githubScopes,
      builder: (context, httpClient) {
        WindowToFront.activate();
        return FutureBuilder<List<PullRequest>>(
            future: _getPullRequests(httpClient.credentials.accessToken),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final pullRequests = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                ),
                body: Center(
                  child: ListView.builder(
                      itemCount: pullRequests.length,
                      itemBuilder: (context, index) {
                        final pullRequest = pullRequests.elementAt(index);
                        return ListTile(
                          title: Text(pullRequest.title ?? ''),
                        );
                      }),
                ),
              );
            });
      },
      /*githubClientId: githubClientId,
      githubClientSecret: githubClientSecret,
      githubScopes: githubScopes,*/
    );
  }
}

Future<CurrentUser> viewerDetail(accessToken) {
  final gitHub = GitHub(auth: Authentication.withToken(accessToken));
  return gitHub.users.getCurrentUser();
}

Future<List<PullRequest>> _getPullRequests(accessToken) {
  final gitHub = GitHub(auth: Authentication.withToken(accessToken));
  return gitHub.pullRequests
      .list(RepositorySlug('flutter', 'flutter'))
      .toList();
}
