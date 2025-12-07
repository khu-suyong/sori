import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sori/api/dio_client.dart';
import 'package:sori/models/sori_item.dart';
import 'package:sori/models/workspace.dart';
import 'package:sori/pages/workspace/(id)/_widgets/sori_card.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/widgets/app_bar.dart';

import '../../../widgets/app_layout.dart';
import '../../../widgets/common/common.dart';

class HomePage extends StatefulWidget {
  final String workspaceId;
  const HomePage({super.key, required this.workspaceId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SoriItem> items = [];
  Workspace? workspace;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final dioClient = DioClient();
    Workspace? fetchedWorkspace;
    List<SoriItem> soriItems = [];

    // Fetch Workspace Details
    try {
      fetchedWorkspace = await dioClient.client.getWorkspace(
        widget.workspaceId,
      );
    } catch (e) {
      debugPrint('Error fetching workspace: $e');
      // If workspace fetch fails, we can't really proceed with a valid UI title, but we can stop loading.
    }

    // Fetch Contents
    if (fetchedWorkspace != null) {
      try {
        final foldersFuture = dioClient.client.getFolders(widget.workspaceId);
        final notesFuture = dioClient.client.getNotes(widget.workspaceId);

        final results = await Future.wait([foldersFuture, notesFuture]);
        final folders = results[0] as List<dynamic>;
        final notes = results[1] as List<dynamic>;

        for (var f in folders) {
          soriItems.add(
            SoriItem(type: SoriItemType.folder, id: f.id, name: f.name),
          );
        }

        for (var n in notes) {
          soriItems.add(
            SoriItem(type: SoriItemType.note, id: n.id, name: n.name),
          );
        }
      } catch (e) {
        debugPrint('Error fetching contents: $e');
      }
    }

    if (mounted) {
      setState(() {
        workspace = fetchedWorkspace;
        items = soriItems;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoriAppLayout(
      appBar: SoriAppBar(
        logo: GestureDetector(
          onTap: () {
            context.go('/workspace');
          },
          child: Row(
            children: [
              Icon(Icons.menu, fill: 0, color: AppColors.gray900),
              const SizedBox(width: AppSpace.s2),
              Text('Sori / ${workspace?.name}', style: AppTextStyle.h3),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, fill: 0, color: AppColors.gray900),
            onPressed: () {
              context.go('/login');
            },
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.black),
                  )
                : Padding(
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
