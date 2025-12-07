import 'package:flutter/material.dart';

import 'package:sori/widgets/common/button.dart';

class WorkspaceCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final bool isAdd;

  const WorkspaceCard({
    required this.name,
    required this.onTap,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onTap,
      variant: AppButtonVariant.outline,
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(name)]),
    );
  }
}
