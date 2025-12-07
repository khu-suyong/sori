// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppException _$AppExceptionFromJson(Map<String, dynamic> json) => AppException(
      code: json['code'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AppExceptionToJson(AppException instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
