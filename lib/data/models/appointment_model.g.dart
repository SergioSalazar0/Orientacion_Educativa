// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      guardianName: json['guardian_name'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      orientadorId: json['orientador_id'] as String?,
      createdBy: json['created_by'] as String?,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
      students: json['students'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'guardian_name': instance.guardianName,
      'date': instance.date,
      'time': instance.time,
      'reason': instance.reason,
      'status': instance.status,
      'notes': instance.notes,
      'orientador_id': instance.orientadorId,
      'created_by': instance.createdBy,
      'read_at': instance.readAt,
      'created_at': instance.createdAt,
      'students': instance.students,
    };
