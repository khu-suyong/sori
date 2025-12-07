import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class PublicNoteContent {
  final String content;
  final String rawContent;
  final double? durationStart;
  final double? durationEnd;

  PublicNoteContent({
    required this.content,
    required this.rawContent,
    this.durationStart,
    this.durationEnd,
  });

  factory PublicNoteContent.fromJson(Map<String, dynamic> json) =>
      _$PublicNoteContentFromJson(json);
  Map<String, dynamic> toJson() => _$PublicNoteContentToJson(this);
}

@JsonSerializable()
class Note {
  final String id;
  final String name;
  final List<PublicNoteContent> contents;

  Note({required this.id, required this.name, this.contents = const []});

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
