import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (context, state) => HomePage())],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router, title: 'Sori');
  }
}
