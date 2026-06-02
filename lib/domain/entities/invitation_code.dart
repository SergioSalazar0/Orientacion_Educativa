/// Código de invitación para vincular padre con alumno.
class InvitationCode {
  const InvitationCode({
    required this.id,
    required this.code,
    required this.studentId,
    required this.expiresAt,
    this.usedBy,
    this.createdAt,
  });

  final String id;
  final String code;
  final String studentId;
  final DateTime expiresAt;
  final String? usedBy;
  final DateTime? createdAt;

  bool get isUsed => usedBy != null;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;
}
