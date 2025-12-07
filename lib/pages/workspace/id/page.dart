import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sori/api/dio_client.dart';
import 'package:sori/models/sori_item.dart';
import 'package:sori/models/workspace.dart';
import 'package:sori/models/folder.dart';
import 'package:sori/pages/workspace/id/_widgets/item_grid.dart';
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

  // Navigation State
  String? currentFolderId;
  List<Map<String, String>> breadcrumbs = []; // [{id: '...', name: '...'}]

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final dioClient = DioClient();
    Workspace? fetchedWorkspace;

    setState(() {
      isLoading = true;
    });

    try {
      fetchedWorkspace = await dioClient.client.getWorkspace(
        widget.workspaceId,
      );
    } catch (e) {
      debugPrint('Error fetching workspace: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('워크스페이스 정보를 불러오는데 실패했습니다: $e')));
      }
    }

    if (mounted) {
      setState(() {
        workspace = fetchedWorkspace;
        isLoading = false;
      });
      _updateItems();
    }
  }

  void _updateItems() {
    if (workspace == null) return;

    List<SoriItem> newItems = [];
    if (currentFolderId == null) {
      workspace!.folders.forEach((f) {
        newItems.add(
          SoriItem(type: SoriItemType.folder, id: f.id, name: f.name),
        );
      });
      workspace!.notes.forEach((n) {
        newItems.add(SoriItem(type: SoriItemType.note, id: n.id, name: n.name));
      });
    } else {
      final folder = _findFolderById(workspace!.folders, currentFolderId!);
      if (folder != null) {
        folder.children.forEach((f) {
          newItems.add(
            SoriItem(type: SoriItemType.folder, id: f.id, name: f.name),
          );
        });
        folder.notes.forEach((n) {
          newItems.add(
            SoriItem(type: SoriItemType.note, id: n.id, name: n.name),
          );
        });
      }
    }

    setState(() {
      items = newItems;
    });
  }

  Folder? _findFolderById(List<Folder> folders, String id) {
    for (var folder in folders) {
      if (folder.id == id) return folder;
      final found = _findFolderById(folder.children, id);
      if (found != null) return found;
    }
    return null;
  }

  Future<void> _createFolder(String name) async {
    final body = <String, dynamic>{'name': name};
    if (currentFolderId != null) {
      body['parentId'] = currentFolderId!;
    }
    try {
      final dioClient = DioClient();
      await dioClient.client.createFolder(widget.workspaceId, body);
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
    final body = <String, dynamic>{'name': name};
    if (currentFolderId != null) {
      body['folderId'] = currentFolderId!;
    }
    try {
      final dioClient = DioClient();
      await dioClient.client.createNote(widget.workspaceId, body);
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

  void _onItemClick(SoriItem item) {
    if (item.type == SoriItemType.folder) {
      setState(() {
        breadcrumbs.add({'id': item.id, 'name': item.name});
        currentFolderId = item.id;
      });
      _updateItems();
    } else {
      context.go('/workspace/${widget.workspaceId}/note/${item.id}');
    }
  }

  void _navigateToBreadcrumb(int index) {
    if (index == -1) {
      setState(() {
        breadcrumbs.clear();
        currentFolderId = null;
      });
    } else {
      setState(() {
        final target = breadcrumbs[index];
        currentFolderId = target['id'];
        breadcrumbs = breadcrumbs.sublist(0, index + 1);
      });
    }
    _updateItems();
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
              children: [
                const AppTextField(hintText: '노트 검색하기'),
                const SizedBox(height: AppSpace.s4),
                // Breadcrumbs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToBreadcrumb(-1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home,
                              size: 16,
                              color: AppColors.gray600,
                            ),
                            const SizedBox(width: AppSpace.s2),
                            Text(
                              workspace?.name ?? '...',
                              style: AppTextStyle.body.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...breadcrumbs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final crumb = entry.value;
                        return GestureDetector(
                          onTap: () => _navigateToBreadcrumb(index),
                          child: Row(
                            children: [
                              const SizedBox(width: AppSpace.s2),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: AppColors.gray400,
                              ),
                              const SizedBox(width: AppSpace.s2),
                              Text(
                                crumb['name']!,
                                style: AppTextStyle.body.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.black),
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpace.s4),
                    child: SoriItemGrid(
                      items: items,
                      onItemClick: _onItemClick,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
