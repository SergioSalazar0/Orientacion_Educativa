/// Constantes globales: nombres de tablas, buckets de Storage y valores fijos.
class AppConstants {
  AppConstants._();

  // ── Tablas de Supabase ────────────────────────────────────────────────────
  static const String tableProfiles = 'profiles';
  static const String tableStudents = 'students';
  static const String tableGuardians = 'guardians';
  static const String tableParentStudents = 'parent_students';
  static const String tableInvitationCodes = 'invitation_codes';
  static const String tableReports = 'reports';
  static const String tableJustifications = 'justifications';
  static const String tableAppointments = 'appointments';

  // ── Buckets de Storage ────────────────────────────────────────────────────
  static const String bucketStudentPhotos = 'student-photos';
  static const String bucketReportImages = 'report-images';
  static const String bucketJustificationFiles = 'justification-files';
  static const String bucketAvatars = 'avatars';

  // ── Rol del usuario ───────────────────────────────────────────────────────
  static const String roleOrientador = 'orientador';
  static const String rolePadre = 'padre';

  // ── Encabezados esperados en la importación CSV/XLSX ─────────────────────
  static const List<String> importHeaders = [
    'matricula',
    'nombre',
    'semestre',
    'grupo',
    'especialidad',
  ];

  // ── Paginación ────────────────────────────────────────────────────────────
  static const int pageSize = 20;

  // ── Expiración del código de invitación (días) ────────────────────────────
  static const int invitationExpiryDays = 30;
}
