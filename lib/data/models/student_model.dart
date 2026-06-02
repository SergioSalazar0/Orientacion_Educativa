import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/student.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel {
  const StudentModel({
    required this.id,
    @JsonKey(name: 'student_code') required this.studentCode,
    @JsonKey(name: 'full_name') required this.fullName,
    required this.semester,
    @JsonKey(name: 'group') required this.group,
    required this.specialty,
    required this.status,
    @JsonKey(name: 'photo_url') this.photoUrl,
    @JsonKey(name: 'birth_date') this.birthDate,
    this.address,
    @JsonKey(name: 'blood_type') this.bloodType,
    this.insurance,
    this.nss,
    this.allergies,
    @JsonKey(name: 'medical_notes') this.medicalNotes,
    @JsonKey(name: 'created_by') this.createdBy,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  final String id;
  final String studentCode;
  final String fullName;
  final String semester;
  final String group;
  final String specialty;
  final String status;
  final String? photoUrl;
  final String? birthDate;
  final String? address;
  final String? bloodType;
  final String? insurance;
  final String? nss;
  final String? allergies;
  final String? medicalNotes;
  final String? createdBy;
  final String? createdAt;

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  Student toEntity() => Student(
        id: id,
        studentCode: studentCode,
        fullName: fullName,
        semester: semester,
        group: group,
        specialty: specialty,
        status: status == 'baja' ? StudentStatus.baja : StudentStatus.activo,
        photoUrl: photoUrl,
        birthDate: birthDate != null ? DateTime.tryParse(birthDate!) : null,
        address: address,
        bloodType: bloodType,
        insurance: insurance,
        nss: nss,
        allergies: allergies,
        medicalNotes: medicalNotes,
        createdBy: createdBy,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  factory StudentModel.fromEntity(Student s) => StudentModel(
        id: s.id,
        studentCode: s.studentCode,
        fullName: s.fullName,
        semester: s.semester,
        group: s.group,
        specialty: s.specialty,
        status: s.status == StudentStatus.baja ? 'baja' : 'activo',
        photoUrl: s.photoUrl,
        birthDate: s.birthDate?.toIso8601String().substring(0, 10),
        address: s.address,
        bloodType: s.bloodType,
        insurance: s.insurance,
        nss: s.nss,
        allergies: s.allergies,
        medicalNotes: s.medicalNotes,
        createdBy: s.createdBy,
        createdAt: s.createdAt?.toIso8601String(),
      );
}
