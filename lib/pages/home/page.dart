import 'package:flutter/material.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/widgets/app_bar.dart';

import '../../widgets/app_layout.dart';
import '../../widgets/common/common.dart';

class HomePage extends StatelessWidget {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const AppTextField(hintText: '노트 검색하기')],
        ),
      ),
    );
  }
}
