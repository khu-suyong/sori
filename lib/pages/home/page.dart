import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/app_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SoriAppLayout(child: Text('Home'));
  }
}
