import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sori/models/sori_item.dart';
import 'package:sori/pages/workspace/id/_widgets/sori_card.dart';
import 'package:sori/theme/theme.dart';

class SoriItemGrid extends StatelessWidget {
  final List<SoriItem> items;
  final Function(SoriItem) onItemClick;

  const SoriItemGrid({
    super.key,
    required this.items,
    required this.onItemClick,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          '폴더가 비어있습니다.',
          style: AppTextStyle.body.copyWith(color: AppColors.gray500),
        ),
      );
    }
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpace.s4,
      crossAxisSpacing: AppSpace.s4,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onItemClick(item),
          child: SoriCard(item: item),
        );
      },
    );
  }
}
