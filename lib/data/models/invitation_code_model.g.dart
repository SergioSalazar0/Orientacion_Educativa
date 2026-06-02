// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationCodeModel _$InvitationCodeModelFromJson(Map<String, dynamic> json) =>
    InvitationCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      studentId: json['student_id'] as String,
      expiresAt: json['expires_at'] as String,
      usedBy: json['used_by'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$InvitationCodeModelToJson(
  InvitationCodeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'student_id': instance.studentId,
  'expires_at': instance.expiresAt,
  'used_by': instance.usedBy,
  'created_at': instance.createdAt,
};
