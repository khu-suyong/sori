import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SoriAppBar extends StatelessWidget {
  final List<Widget> actions;
  final Widget? logo;

  const SoriAppBar({super.key, this.actions = const [], this.logo});

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpace.s2),
              child:
                  logo ??
                  Text(
                    'Sori',
                    style: AppTextStyle.h3.copyWith(
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
            ),
            Row(children: actions),
          ],
        ),
      ),
    );
  }
}
