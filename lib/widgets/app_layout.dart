import 'package:flutter/material.dart';

import 'package:sori/theme/theme.dart';

import 'app_bar.dart';

class SoriAppLayout extends StatelessWidget {
  final SoriAppBar appBar;
  final Widget child;
  final Widget? floatingActionButton;

  const SoriAppLayout({
    super.key,
    this.appBar = const SoriAppBar(),
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          children: [
            appBar,
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
