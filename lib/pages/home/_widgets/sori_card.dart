import 'package:flutter/material.dart';
import 'package:sori/models/sori_item.dart';
import 'package:sori/theme/theme.dart';

enum SoriCardVariant { note, folder }

class SoriCard extends StatelessWidget {
  final SoriItem item;

  const SoriCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.x2l),
        boxShadow: [AppShadow.base],
      ),
      padding: const EdgeInsets.all(AppSpace.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(_icon, color: _iconColor, size: 24)],
          ),
          SizedBox(height: AppSpace.s4),
          Text(
            item.name,
            style: AppTextStyle.h3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (item.type) {
      case SoriItemType.folder:
        return AppColors.yellow100;
      case SoriItemType.note:
        return AppColors.white;
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case SoriItemType.folder:
        return AppColors.yellow500;
      case SoriItemType.note:
        return AppColors.gray500;
    }
  }

  IconData get _icon {
    switch (item.type) {
      case SoriItemType.folder:
        return Icons.folder_open_rounded;
      case SoriItemType.note:
        return Icons.book_rounded;
    }
  }
}
