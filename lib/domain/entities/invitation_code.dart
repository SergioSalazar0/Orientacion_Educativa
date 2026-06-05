/// Código de invitación para vincular padre con alumno.
/// El código es reutilizable y no expira, vinculado a un alumno específico.
class InvitationCode {
  const InvitationCode({
    required this.id,
    required this.code,
    required this.studentId,
    this.createdAt,
  });

  final String id;
  final String code;
  final String studentId;
  final DateTime? createdAt;
}
