import 'package:json_annotation/json_annotation.dart';

part 'exception.g.dart';

@JsonSerializable()
class AppException {
  final String code;
  final String? message;

  AppException({required this.code, this.message});

  factory AppException.fromJson(Map<String, dynamic> json) =>
      _$AppExceptionFromJson(json);
  Map<String, dynamic> toJson() => _$AppExceptionToJson(this);
}
