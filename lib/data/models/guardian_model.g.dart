// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guardian_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuardianModel _$GuardianModelFromJson(Map<String, dynamic> json) =>
    GuardianModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      relationship: json['relationship'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$GuardianModelToJson(GuardianModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'relationship': instance.relationship,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'address': instance.address,
    };
