import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sori/constants.dart';
import 'package:sori/theme/theme.dart';
import 'package:sori/services/audio_recorder_service.dart';
import 'package:sori/services/websocket_service.dart';
import 'package:sori/models/note.dart';
import 'package:sori/api/dio_client.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:sori/services/global_storage.dart';
import 'package:sori/pages/workspace/id/note/_widgets/audio_waveform.dart';

class NoteViewPage extends StatefulWidget {
  final String workspaceId;
  final String noteId;

  const NoteViewPage({
    super.key,
    required this.workspaceId,
    required this.noteId,
  });

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final WebSocketService _webSocketService = WebSocketService();

  Note? note;
  bool isLoading = true;
  bool isRecording = false;
  Duration recordingDuration = Duration.zero;
  Timer? _timer;
  StreamSubscription? _audioSubscription;
  StreamSubscription? _socketSubscription;

  List<PublicNoteContent> segments = [];
  List<PublicNoteContent> _realtimeSegments = [];
  String currentStreamingText = "";

  @override
  void initState() {
    super.initState();
    _fetchNote();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioSubscription?.cancel();
    _socketSubscription?.cancel();
    _recorderService.dispose();
    _webSocketService.close();
    super.dispose();
  }

  Future<void> _fetchNote() async {
    try {
      final dioClient = DioClient();
      final fetchedNote = await dioClient.client.getNote(
        widget.workspaceId,
        widget.noteId,
      );
      if (mounted) {
        setState(() {
          note = fetchedNote;
          segments = List.from(fetchedNote.contents);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching note: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _startRecording() async {
    final stream = await _recorderService.startRecording();
    if (stream == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('마이크 권한이 필요합니다.')));
      }
      return;
    }

    final token = await GlobalStorage.getAccessToken();
    final wsUrl =
        'wss://${AppConstants.domain}/api/v1/workspace/${widget.workspaceId}/note/${widget.noteId}/transcribe';

    _webSocketService.connect(
      wsUrl,
      headers: {'Authorization': 'Bearer $token'},
    );

    _socketSubscription = _webSocketService.stream?.listen(
      (message) {
        debugPrint("received from Server $message");
        _handleServerMessage(message);
      },
      onError: (e) {
        debugPrint('WS Error: $e');
      },
    );

    _audioSubscription = stream.listen((chunk) {
      _webSocketService.sendAudio(chunk);
    });

    setState(() {
      isRecording = true;
      recordingDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _audioSubscription?.cancel();
    await _recorderService.stopRecording();
    _webSocketService.close();

    setState(() {
      isRecording = false;
      currentStreamingText = "";
    });

    _fetchNote();
  }

  void _handleServerMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      if (data is Map<String, dynamic> && data.containsKey('status')) {
        final lines = data['lines'] as List<dynamic>? ?? [];
        final buffer = data['buffer_transcription'] as String? ?? "";

        setState(() {
          _realtimeSegments = lines
              .map(
                (l) => PublicNoteContent(
                  content: l['text'] as String? ?? "",
                  rawContent: l['text'] as String? ?? "",
                ),
              )
              .where((s) => s.content.trim().isNotEmpty)
              .toList();

          currentStreamingText = buffer;
        });
        return;
      }

      final text = data['text'] as String?;
      final isFinal = data['is_final'] as bool? ?? false;

      if (text != null) {
        if (isFinal) {
          setState(() {
            segments.add(PublicNoteContent(content: text, rawContent: text));
            currentStreamingText = "";
          });
        } else {
          setState(() {
            currentStreamingText = text;
          });
        }
      }
    } catch (e) {
      debugPrint('Error parsing WS message: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.gray50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(note?.name ?? 'Loading...', style: AppTextStyle.h1),
            ),
          ),
          const SizedBox(height: AppSpace.s5),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.black),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s5,
                    ),
                    itemCount:
                        segments.length +
                        _realtimeSegments.length +
                        (currentStreamingText.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < segments.length) {
                        final segment = segments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                segment.content,
                                style: AppTextStyle.body.copyWith(height: 1.6),
                              ),
                            ],
                          ),
                        );
                      } else if (index <
                          segments.length + _realtimeSegments.length) {
                        final segment =
                            _realtimeSegments[index - segments.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                segment.content,
                                style: AppTextStyle.body.copyWith(
                                  height: 1.6,
                                  color: AppColors.gray700,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s4),
                          child: Text(
                            currentStreamingText,
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.gray700,
                              height: 1.6,
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.s5),
            child: Center(
              child: GestureDetector(
                onTap: isRecording ? _stopRecording : _startRecording,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s6,
                    vertical: AppSpace.s3,
                  ),
                  decoration: BoxDecoration(
                    color: isRecording
                        ? AppColors.danger.withValues(alpha: 0.1)
                        : AppColors.black,
                    borderRadius: BorderRadius.circular(30),
                    gradient: isRecording
                        ? const LinearGradient(
                            colors: [Color(0xFFFFA0A0), Color(0xFFFF7070)],
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRecording) ...[
                        const AudioWaveform(isRecording: true),
                        const SizedBox(width: AppSpace.s3),
                        Text(
                          _formatDuration(recordingDuration),
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.danger,
                            fontWeight: AppFontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.mic, color: AppColors.white),
                        const SizedBox(width: AppSpace.s2),
                        Text(
                          '녹음 시작',
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
