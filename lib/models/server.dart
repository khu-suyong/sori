import 'package:json_annotation/json_annotation.dart';

part 'server.g.dart';

@JsonSerializable()
class PublicServer {
  final String id;
  final String name;
  final String url;

  PublicServer({required this.id, required this.name, required this.url});

  factory PublicServer.fromJson(Map<String, dynamic> json) =>
      _$PublicServerFromJson(json);
  Map<String, dynamic> toJson() => _$PublicServerToJson(this);
}
