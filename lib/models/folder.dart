import 'package:json_annotation/json_annotation.dart';
import 'note.dart';

part 'folder.g.dart';

@JsonSerializable()
class Folder {
  final String id;
  final String name;
  final List<Note> notes;
  final List<Folder> children;

  Folder({
    required this.id,
    required this.name,
    required this.notes,
    required this.children,
  });

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
  Map<String, dynamic> toJson() => _$FolderToJson(this);
}
