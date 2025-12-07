import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:typed_data';

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String url, {Map<String, dynamic>? headers}) {
    _channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
  }

  void sendAudio(Uint8List data) {
    _channel?.sink.add(data);
  }

  Stream<dynamic>? get stream => _channel?.stream;

  void close() {
    _channel?.sink.close();
    _channel = null;
  }
}
