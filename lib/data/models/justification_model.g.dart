// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'justification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JustificationModel _$JustificationModelFromJson(Map<String, dynamic> json) =>
    JustificationModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      reason: json['reason'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      createdBy: json['created_by'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$JustificationModelToJson(JustificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'reason': instance.reason,
      'date': instance.date,
      'status': instance.status,
      'description': instance.description,
      'file_url': instance.fileUrl,
      'created_by': instance.createdBy,
      'reviewed_by': instance.reviewedBy,
      'created_at': instance.createdAt,
    };
