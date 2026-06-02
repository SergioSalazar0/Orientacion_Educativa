// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  category: json['category'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['image_url'] as String?,
  createdBy: json['created_by'] as String?,
  createdAt: json['created_at'] as String?,
  profiles: json['profiles'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'category': instance.category,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
      'profiles': instance.profiles,
    };
