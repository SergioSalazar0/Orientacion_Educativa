/// Tutor o contacto del alumno.
class Guardian {
  const Guardian({
    required this.id,
    required this.studentId,
    required this.relationship,
    required this.fullName,
    this.phone,
    this.address,
  });

  final String id;
  final String studentId;
  final String relationship;
  final String fullName;
  final String? phone;
  final String? address;
}
