import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sori/api/dio_client.dart';
import 'package:sori/models/workspace.dart';
import 'package:sori/services/global_storage.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/widgets/app_bar.dart';
import 'package:sori/widgets/app_layout.dart';
import 'package:sori/widgets/common/common.dart';

import '_widgets/workspace_card.dart';

class WorkspaceListPage extends StatefulWidget {
  const WorkspaceListPage({super.key});

  @override
  State<WorkspaceListPage> createState() => _WorkspaceListPageState();
}

class _WorkspaceListPageState extends State<WorkspaceListPage> {
  List<Workspace> workspaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkspaces();
  }

  Future<void> _fetchWorkspaces() async {
    try {
      final dioClient = DioClient();
      final response = await dioClient.client.getWorkspaces();
      if (mounted) {
        setState(() {
          workspaces = response.items;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching workspaces: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _onWorkspaceSelected(Workspace workspace) async {
    await GlobalStorage.saveLastWorkspaceId(workspace.id);
    if (mounted) {
      context.push('/workspace/${workspace.id}/home');
    }
  }

  Future<void> _createWorkspace() async {
    final nameController = TextEditingController();
    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('워크스페이스 생성', style: AppTextStyle.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: '워크스페이스 이름',
                  hintStyle: AppTextStyle.body.copyWith(
                    color: AppColors.gray400,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.black),
                  ),
                ),
                style: AppTextStyle.body,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                '취소',
                style: AppTextStyle.body.copyWith(color: AppColors.gray500),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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

    if (shouldCreate == true && nameController.text.trim().isNotEmpty) {
      try {
        final dioClient = DioClient();
        final newWorkspace = await dioClient.client.createWorkspace({
          'name': nameController.text.trim(),
        });

        await _onWorkspaceSelected(newWorkspace);
      } catch (e) {
        debugPrint('Error creating workspace: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('워크스페이스 생성에 실패했습니다.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoriAppLayout(
      appBar: SoriAppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.black)
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.s8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('워크스페이스를 선택하세요', style: AppTextStyle.h2),
                      const SizedBox(height: AppSpace.s8),
                      Wrap(
                        spacing: AppSpace.s2,
                        runSpacing: AppSpace.s2,
                        alignment: WrapAlignment.center,
                        children: [
                          ...workspaces.map(
                            (w) => WorkspaceCard(
                              name: w.name,
                              onTap: () => _onWorkspaceSelected(w),
                            ),
                          ),
                          AppButton(
                            onPressed: _createWorkspace,
                            child: const Text('워크스페이스 추가'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
