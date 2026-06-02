// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
  id: json['id'] as String,
  studentCode: json['student_code'] as String,
  fullName: json['full_name'] as String,
  semester: json['semester'] as String,
  group: json['group'] as String,
  specialty: json['specialty'] as String,
  status: json['status'] as String,
  photoUrl: json['photo_url'] as String?,
  birthDate: json['birth_date'] as String?,
  address: json['address'] as String?,
  bloodType: json['blood_type'] as String?,
  insurance: json['insurance'] as String?,
  nss: json['nss'] as String?,
  allergies: json['allergies'] as String?,
  medicalNotes: json['medical_notes'] as String?,
  createdBy: json['created_by'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_code': instance.studentCode,
      'full_name': instance.fullName,
      'semester': instance.semester,
      'group': instance.group,
      'specialty': instance.specialty,
      'status': instance.status,
      'photo_url': instance.photoUrl,
      'birth_date': instance.birthDate,
      'address': instance.address,
      'blood_type': instance.bloodType,
      'insurance': instance.insurance,
      'nss': instance.nss,
      'allergies': instance.allergies,
      'medical_notes': instance.medicalNotes,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
    };
