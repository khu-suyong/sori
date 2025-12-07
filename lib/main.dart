import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:sori/services/global_storage.dart';
import 'pages/workspace/id/page.dart';
import 'pages/login/page.dart';
import 'pages/splash/page.dart';
import 'pages/workspace/page.dart';
import 'pages/workspace/id/note/page.dart';
import 'pages/settings/page.dart';

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
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/workspace',
        builder: (context, state) => const WorkspaceListPage(),
      ),
      GoRoute(
        path: '/workspace/:workspaceId',
        redirect: (context, state) {
          final workspaceId = state.pathParameters['workspaceId'];
          // Prevent infinite redirect if we are already at a sub-location handled by this route check
          // actually this is a parent route.
          // If the location matches exactly this path (no subroutes), redirect to home.
          if (state.fullPath == '/workspace/$workspaceId') {
            return '/workspace/$workspaceId/home';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) {
              final workspaceId = state.pathParameters['workspaceId']!;
              return HomePage(workspaceId: workspaceId);
            },
          ),
          GoRoute(
            path: 'note/:noteId',
            builder: (context, state) {
              final workspaceId = state.pathParameters['workspaceId']!;
              final noteId = state.pathParameters['noteId']!;
              return NoteViewPage(workspaceId: workspaceId, noteId: noteId);
            },
          ),
        ],
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

        final accessToken = uri.queryParameters['accessToken'];
        final refreshToken = uri.queryParameters['refreshToken'];

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
