/// Estado académico del alumno.
enum StudentStatus { activo, baja }

/// Entidad pura del alumno.
class Student {
  const Student({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.semester,
    required this.group,
    required this.specialty,
    required this.status,
    this.photoUrl,
    this.birthDate,
    this.address,
    this.bloodType,
    this.insurance,
    this.nss,
    this.allergies,
    this.medicalNotes,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String studentCode;
  final String fullName;
  final String semester;
  final String group;
  final String specialty;
  final StudentStatus status;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? address;
  final String? bloodType;
  final String? insurance;
  final String? nss;
  final String? allergies;
  final String? medicalNotes;
  final String? createdBy;
  final DateTime? createdAt;

  String get displayName => fullName;
  String get semesterGroup => '$semester° Semestre • Grupo $group';

  Student copyWith({
    String? fullName,
    String? semester,
    String? group,
    String? specialty,
    StudentStatus? status,
    String? photoUrl,
    DateTime? birthDate,
    String? address,
    String? bloodType,
    String? insurance,
    String? nss,
    String? allergies,
    String? medicalNotes,
  }) =>
      Student(
        id: id,
        studentCode: studentCode,
        fullName: fullName ?? this.fullName,
        semester: semester ?? this.semester,
        group: group ?? this.group,
        specialty: specialty ?? this.specialty,
        status: status ?? this.status,
        photoUrl: photoUrl ?? this.photoUrl,
        birthDate: birthDate ?? this.birthDate,
        address: address ?? this.address,
        bloodType: bloodType ?? this.bloodType,
        insurance: insurance ?? this.insurance,
        nss: nss ?? this.nss,
        allergies: allergies ?? this.allergies,
        medicalNotes: medicalNotes ?? this.medicalNotes,
        createdBy: createdBy,
        createdAt: createdAt,
      );
}
