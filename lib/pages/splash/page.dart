import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sori/api/dio_client.dart';
import 'package:sori/services/global_storage.dart';
import 'package:sori/theme/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final dioClient = DioClient();
      await dioClient.client.getUser();
      if (mounted) {
        final lastWorkspaceId = await GlobalStorage.getLastWorkspaceId();
        if (lastWorkspaceId != null) {
          context.go('/workspace/$lastWorkspaceId/home');
        } else {
          context.go('/workspace');
        }
      }
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(child: CircularProgressIndicator(color: AppColors.black)),
    );
  }
}
