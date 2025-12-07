import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_links/app_links.dart';
import 'package:sori/services/global_storage.dart';
import 'pages/workspace/id/page.dart';
import 'pages/login/page.dart';
import 'pages/splash/page.dart';
import 'pages/workspace/page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/workspace',
        builder: (context, state) => const WorkspaceListPage(),
      ),
      GoRoute(
        path: '/workspace/:workspaceId/home',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          return HomePage(workspaceId: workspaceId);
        },
      ),
    ],
  );

  MyApp({super.key}) {
    _initDeepLinks();
  }

  void _initDeepLinks() {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'sori' && uri.host == 'login-callback') {
        debugPrint('deeplink: $uri');

        // sori://login-callback?accessToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjMwMDAiLCJhdWQiOiJhcGkiLCJzdWIiOiJpMm42dG5ncjd2eHBtbnhibnpheGF5MzEiLCJpYXQiOjE3NjUwOTc4MTAsImV4cCI6MTc2NTEwMTQxMH0.1w72tNaPnHHtHva21DjFUFZJa_EuZkYfRrYNlwkerz4&refreshToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjMwMDAiLCJhdWQiOiJhdXRoIiwic3ViIjoiaTJuNnRuZ3I3dnhwbW54Ym56YXhheTMxIiwiaWF0IjoxNzY1MDk3ODEwLCJleHAiOjE3Njc2ODk4MTB9.dga3PUDn1QnamVs112D-CQK4YArRj8m4tT-HEpzK78k&userId=i2n6tngr7vxpmnxbnzaxay31
        final accessToken = uri.queryParameters['accessToken'];
        final refreshToken = uri.queryParameters['refreshToken'];
        // final userId = uri.queryParameters['userId'];

        if (accessToken != null && refreshToken != null) {
          debugPrint("token: $accessToken $refreshToken");
          GlobalStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          _router.go('/');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Sori',
      theme: ThemeData(fontFamily: 'Pretendard'),
    );
  }
}
