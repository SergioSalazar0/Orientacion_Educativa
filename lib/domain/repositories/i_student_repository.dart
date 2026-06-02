import '../entities/student.dart';
import '../entities/guardian.dart';
import '../entities/invitation_code.dart';

/// Contrato de operaciones sobre alumnos.
abstract interface class IStudentRepository {
  /// Lista paginada de alumnos con filtros opcionales.
  Future<List<Student>> getStudents({
    String? search,
    String? semester,
    String? group,
    String? specialty,
    StudentStatus? status,
    int page = 0,
  });

  /// Stream en tiempo real de alumnos (Realtime de Supabase).
  Stream<List<Student>> watchStudents();

  /// Obtiene un alumno por su ID.
  Future<Student> getStudentById(String id);

  /// Crea un nuevo alumno.
  Future<Student> createStudent(Student student);

  /// Actualiza los datos de un alumno.
  Future<Student> updateStudent(Student student);

  /// Cambia el estado del alumno a 'baja'.
  Future<void> deactivateStudent(String id);

  /// Inserta múltiples alumnos de forma masiva (importación CSV/XLSX).
  Future<List<Student>> bulkInsert(List<Student> students);

  /// Sube la foto del alumno al bucket de Storage y retorna la URL.
  Future<String> uploadStudentPhoto(String studentId, List<int> bytes, String extension);

  // ── Tutores ──────────────────────────────────────────────────────────────

  Future<List<Guardian>> getGuardians(String studentId);
  Future<Guardian> createGuardian(Guardian guardian);
  Future<Guardian> updateGuardian(Guardian guardian);
  Future<void> deleteGuardian(String guardianId);

  // ── Códigos de invitación ─────────────────────────────────────────────────

  /// Genera y persiste un nuevo código de invitación para el alumno.
  Future<InvitationCode> generateInvitationCode(String studentId);

  /// Lista los códigos de invitación del alumno.
  Future<List<InvitationCode>> getInvitationCodes(String studentId);
}
