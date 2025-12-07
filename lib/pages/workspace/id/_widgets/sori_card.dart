import 'package:flutter/material.dart';
import 'package:sori/models/sori_item.dart';
import 'package:sori/theme/theme.dart';

enum SoriCardVariant { note, folder }

class SoriCard extends StatelessWidget {
  final SoriItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SoriCard({super.key, required this.item, this.onEdit, this.onDelete});

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
            children: [
              Icon(_icon, color: _iconColor, size: 24),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('이름 변경')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      '삭제',
                      style: TextStyle(color: AppColors.red500),
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.gray400,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s4),
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
