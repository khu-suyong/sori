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

    try {
      fetchedWorkspace = await dioClient.client.getWorkspace(
        widget.workspaceId,
      );
    } catch (e) {
      debugPrint('Error fetching workspace: $e');
    }

    fetchedWorkspace?.folders.forEach((it) {
      soriItems.add(
        SoriItem(type: SoriItemType.folder, id: it.id, name: it.name),
      );
    });
    fetchedWorkspace?.notes.forEach((it) {
      soriItems.add(
        SoriItem(type: SoriItemType.note, id: it.id, name: it.name),
      );
    });

    if (mounted) {
      setState(() {
        workspace = fetchedWorkspace;
        items = soriItems;
        isLoading = false;
      });
    }
  }

  Future<void> _createFolder(String name) async {
    try {
      final dioClient = DioClient();
      await dioClient.client.createFolder(widget.workspaceId, {'name': name});
      _fetchData();
    } catch (e) {
      debugPrint('Error creating folder: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('폴더 생성에 실패했습니다.')));
      }
    }
  }

  Future<void> _createNote(String name) async {
    try {
      final dioClient = DioClient();
      await dioClient.client.createNote(widget.workspaceId, {
        'name': name,
        'contents': [],
      });
      _fetchData();
    } catch (e) {
      debugPrint('Error creating note: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('노트 생성에 실패했습니다.')));
      }
    }
  }

  void _showCreateDialog(bool isFolder) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(isFolder ? '폴더 생성' : '노트 생성', style: AppTextStyle.h3),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: '이름을 입력하세요',
              hintStyle: AppTextStyle.body.copyWith(color: AppColors.gray400),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.black),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: AppTextStyle.body.copyWith(color: AppColors.gray500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (nameController.text.trim().isNotEmpty) {
                  if (isFolder) {
                    _createFolder(nameController.text.trim());
                  } else {
                    _createNote(nameController.text.trim());
                  }
                }
              },
              child: Text(
                '생성',
                style: AppTextStyle.body.copyWith(
                  color: AppColors.black,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder, color: AppColors.black),
                title: const Text('폴더 생성', style: AppTextStyle.body),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateDialog(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.note, color: AppColors.black),
                title: const Text('노트 생성', style: AppTextStyle.body),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateDialog(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SoriAppLayout(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        backgroundColor: AppColors.black,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
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
