import 'package:flutter/material.dart';

import 'package:sori/theme/theme.dart';

import 'app_bar.dart';

class SoriAppLayout extends StatelessWidget {
  final SoriAppBar appBar;
  final Widget child;

  const SoriAppLayout({
    super.key,
    this.appBar = const SoriAppBar(),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(child: Column(children: [appBar, child])),
    );
  }
}
