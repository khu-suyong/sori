import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<Stream<Uint8List>?> startRecording() async {
    if (!await hasPermission()) return null;

    if (await _audioRecorder.hasPermission()) {
      return await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
    }
    return null;
  }

  Future<void> stopRecording() async {
    await _audioRecorder.stop();
  }

  Future<void> dispose() async {
    _audioRecorder.dispose();
  }
}
