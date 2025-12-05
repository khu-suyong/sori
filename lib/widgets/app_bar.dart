import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SoriAppBar extends StatelessWidget {
  final List<Widget> actions;

  const SoriAppBar({super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s2,
        ),
        child: Row(
          children: [
            Text('Sori', style: AppTextStyle.h3),
            const Spacer(),
            Row(children: actions),
          ],
        ),
      ),
    );
  }
}
