import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:sori/constants.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/widgets/common/common.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sori', style: AppTextStyle.h1),
              const SizedBox(height: AppSpace.s8),
              AppButton(
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  try {
                    const baseUrl = AppConstants.baseUrl;
                    const redirectUri = 'sori://login-callback';
                    final authorizationUrl =
                        '$baseUrl/auth/google?redirect=$redirectUri';

                    final appAuth = FlutterAppAuth();

                    await appAuth.authorize(
                      AuthorizationRequest(
                        'google',
                        redirectUri,
                        serviceConfiguration: AuthorizationServiceConfiguration(
                          authorizationEndpoint: authorizationUrl,
                          tokenEndpoint: '$baseUrl/auth/token',
                        ),
                        scopes: ['email', 'profile'],
                      ),
                    );
                  } catch (e) {
                    debugPrint('Login error: $e');
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Google로 계속하기')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
