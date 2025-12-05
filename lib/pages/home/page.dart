import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sori/models/sori_item.dart';
import 'package:sori/pages/home/_widgets/sori_card.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/widgets/app_bar.dart';

import '../../widgets/app_layout.dart';
import '../../widgets/common/common.dart';

class HomePage extends StatelessWidget {
  static const List<SoriItem> items = [
    SoriItem(type: SoriItemType.folder, id: 'id', name: '폴더1'),
    SoriItem(type: SoriItemType.note, id: 'test', name: '노트1'),
  ];

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SoriAppLayout(
      appBar: SoriAppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person, fill: 0, color: AppColors.gray900),
            onPressed: () {},
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const AppTextField(hintText: '노트 검색하기')],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.s4),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpace.s4,
                crossAxisSpacing: AppSpace.s4,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return SoriCard(item: items[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
