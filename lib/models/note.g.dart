// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicNoteContent _$PublicNoteContentFromJson(Map<String, dynamic> json) =>
    PublicNoteContent(
      content: json['content'] as String,
      rawContent: json['rawContent'] as String,
      durationStart: (json['durationStart'] as num?)?.toDouble(),
      durationEnd: (json['durationEnd'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PublicNoteContentToJson(PublicNoteContent instance) =>
    <String, dynamic>{
      'content': instance.content,
      'rawContent': instance.rawContent,
      'durationStart': instance.durationStart,
      'durationEnd': instance.durationEnd,
    };

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      name: json['name'] as String,
      contents: (json['contents'] as List<dynamic>?)
              ?.map(
                  (e) => PublicNoteContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'contents': instance.contents,
    };
