import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sori/api/dio_client.dart';
import 'package:sori/models/user.dart';
import 'package:sori/models/server.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/widgets/common/button.dart';
import 'package:sori/services/global_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? _user;
  List<PublicServer> _servers = [];
  bool _isLoading = true;

  final TextEditingController _serverNameController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dio = DioClient();
      final user = await dio.client.getUser();
      // Server fetching might fail if backend isn't ready or auth issue, handle gracefully
      List<PublicServer> servers = [];
      try {
        final serverResponse = await dio.client.getServers();
        servers = serverResponse.items;
      } catch (e) {
        debugPrint('Error fetching servers: $e');
      }

      if (mounted) {
        setState(() {
          _user = user;
          _servers = servers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching settings data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await GlobalStorage.deleteTokens();
    await GlobalStorage.deleteLastWorkspaceId();
    if (mounted) context.go('/login');
  }

  Future<bool> _addServer() async {
    final name = _serverNameController.text.trim();
    final url = _serverUrlController.text.trim();
    if (name.isEmpty || url.isEmpty) return false;

    try {
      final dio = DioClient();
      await dio.client.createServer({'name': name, 'url': url});
      _serverNameController.clear();
      _serverUrlController.clear();
      _fetchData(); // Refresh list
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add server: $e')));
      }
      return false;
    }
  }

  Future<bool> _editServer(String id, String name, String url) async {
    try {
      final dio = DioClient();
      await dio.client.updateServer(id, {'name': name, 'url': url});
      _fetchData();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update server: $e')));
      }
      return false;
    }
  }

  Future<void> _deleteServer(String id) async {
    try {
      final dio = DioClient();
      await dio.client.deleteServer(id);
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete server: $e')));
      }
    }
  }

  Future<void> _showEditServerDialog(PublicServer server) async {
    final nameController = TextEditingController(text: server.name);
    final urlController = TextEditingController(text: server.url);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: const Text('서버 수정', style: AppTextStyle.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '서버 이름 (Name)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.s3),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '서버 주소 (IP/URL)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.gray500)),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                final success = await _editServer(server.id, name, url);
                if (success && mounted) {
                  context.pop();
                }
              }
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddServerDialog() async {
    _serverNameController.clear();
    _serverUrlController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: const Text('서버 추가', style: AppTextStyle.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _serverNameController,
              decoration: const InputDecoration(
                labelText: '서버 이름 (Name)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.s3),
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: '서버 주소 (IP/URL)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.gray500)),
          ),
          TextButton(
            onPressed: () async {
              final success = await _addServer();
              if (success && mounted) {
                context.pop();
              }
            },
            child: const Text(
              '추가',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: const Text('Sori', style: AppTextStyle.h3),
        centerTitle: false,
        backgroundColor: AppColors.gray50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Text(
                    '내 계정',
                    style: AppTextStyle.body.copyWith(color: AppColors.gray500),
                  ),
                  const SizedBox(height: AppSpace.s4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.white,
                        backgroundImage: _user?.image != null
                            ? NetworkImage(_user!.image!)
                            : null,
                        child: _user?.image == null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.black,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpace.s4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user?.name ?? 'Unknown',
                            style: AppTextStyle.h3,
                          ),
                          Text(
                            _user?.email ?? '',
                            style: AppTextStyle.caption.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s6),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onPressed: () {}, // TODO: Edit profile
                          variant: AppButtonVariant.secondary,
                          child: const Text('프로필 편집'),
                        ),
                      ),
                      const SizedBox(width: AppSpace.s3),
                      Expanded(
                        child: AppButton(
                          onPressed: _logout,
                          variant: AppButtonVariant
                              .destructive, // Using destructive color for logout visually
                          // Or use a custom button if destructive variant isn't pink enough
                          child: Container(
                            // Hack just for color override if needed, but variant should work
                            alignment: Alignment.center,
                            child: const Text(
                              '로그아웃',
                            ), // AppButton handles text color
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.s8),

                  // Server Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '서버 설정',
                        style: AppTextStyle.body.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      AppButton(
                        onPressed: _showAddServerDialog,
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.sm,
                        child: const Text('서버 추가'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s4),

                  // Server List Container
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.all(AppSpace.s5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_servers.isNotEmpty) ...[
                          ..._servers.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpace.s2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: AppTextStyle.body.copyWith(
                                            fontWeight: AppFontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          s.url,
                                          style: AppTextStyle.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditServerDialog(s);
                                      } else if (value == 'delete') {
                                        _deleteServer(s.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('서버 수정'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          '서버 삭제',
                                          style: TextStyle(
                                            color: AppColors.red500,
                                          ),
                                        ),
                                      ),
                                    ],
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
