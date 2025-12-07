import 'package:json_annotation/json_annotation.dart';
import 'note.dart';
import 'folder.dart';

part 'workspace.g.dart';

@JsonSerializable()
class Workspace {
  final String id;
  final String name;
  final String? image;
  final List<Note> notes;
  final List<Folder> folders;

  Workspace({
    required this.id,
    required this.name,
    this.image,
    required this.notes,
    required this.folders,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);
  Map<String, dynamic> toJson() => _$WorkspaceToJson(this);
}
