import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/guardian.dart';
import '../../domain/entities/invitation_code.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/i_student_repository.dart';
import '../models/guardian_model.dart';
import '../models/invitation_code_model.dart';
import '../models/student_model.dart';

class SupabaseStudentRepository implements IStudentRepository {
  SupabaseStudentRepository(this._client);

  final sb.SupabaseClient _client;
  final _uuid = const Uuid();

  @override
  Future<List<Student>> getStudents({
    String? search,
    String? semester,
    String? group,
    String? specialty,
    StudentStatus? status,
    int page = 0,
  }) async {
    try {
      // Construir el filtro antes del orden para respetar la API de Supabase
      sb.PostgrestFilterBuilder<sb.PostgrestList> q =
          _client.from(AppConstants.tableStudents).select();

      if (status != null) q = q.eq('status', status.name);
      if (semester != null && semester.isNotEmpty) q = q.eq('semester', semester);
      if (group != null && group.isNotEmpty) q = q.eq('group', group);
      if (specialty != null && specialty.isNotEmpty) q = q.eq('specialty', specialty);
      if (search != null && search.isNotEmpty) {
        q = q.ilike('full_name', '%$search%');
      }

      final data = await q
          .order('full_name')
          .range(
            page * AppConstants.pageSize,
            (page + 1) * AppConstants.pageSize - 1,
          );

      return (data as List)
          .map((e) => StudentModel.fromJson(e).toEntity())
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener alumnos: $e');
    }
  }

  @override
  Stream<List<Student>> watchStudents() {
    return _client
        .from(AppConstants.tableStudents)
        .stream(primaryKey: ['id'])
        .order('full_name')
        .map((data) =>
            data.map((e) => StudentModel.fromJson(e).toEntity()).toList());
  }

  @override
  Future<Student> getStudentById(String id) async {
    try {
      final data = await _client
          .from(AppConstants.tableStudents)
          .select()
          .eq('id', id)
          .single();
      return StudentModel.fromJson(data).toEntity();
    } on sb.PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw NotFoundException('Alumno no encontrado.');
      throw ServerException(e.message);
    }
  }

  @override
  Future<Student> createStudent(Student student) async {
    try {
      final model = StudentModel.fromEntity(student);
      final json = model.toJson()..remove('id');
      final data = await _client
          .from(AppConstants.tableStudents)
          .insert(json)
          .select()
          .single();
      return StudentModel.fromJson(data).toEntity();
    } on sb.PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ValidationException('La matrícula ya existe.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<Student> updateStudent(Student student) async {
    try {
      final model = StudentModel.fromEntity(student);
      final data = await _client
          .from(AppConstants.tableStudents)
          .update(model.toJson())
          .eq('id', student.id)
          .select()
          .single();
      return StudentModel.fromJson(data).toEntity();
    } on sb.PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deactivateStudent(String id) async {
    await _client
        .from(AppConstants.tableStudents)
        .update({'status': 'baja'})
        .eq('id', id);
  }

  @override
  Future<List<Student>> bulkInsert(List<Student> students) async {
    try {
      final rows = students
          .map((s) => StudentModel.fromEntity(s).toJson()..remove('id'))
          .toList();
      final data = await _client
          .from(AppConstants.tableStudents)
          .insert(rows)
          .select();
      return (data as List)
          .map((e) => StudentModel.fromJson(e).toEntity())
          .toList();
    } on sb.PostgrestException catch (e) {
      throw ServerException('Error en importación masiva: ${e.message}');
    }
  }

  @override
  Future<String> uploadStudentPhoto(
    String studentId,
    List<int> bytes,
    String extension,
  ) async {
    final path = '$studentId/photo.$extension';
    await _client.storage
        .from(AppConstants.bucketStudentPhotos)
        .uploadBinary(path, Uint8List.fromList(bytes), fileOptions: sb.FileOptions(upsert: true));

    return _client.storage
        .from(AppConstants.bucketStudentPhotos)
        .createSignedUrl(path, 60 * 60 * 24 * 7); // 7 días
  }

  // ── Tutores ───────────────────────────────────────────────────────────────

  @override
  Future<List<Guardian>> getGuardians(String studentId) async {
    final data = await _client
        .from(AppConstants.tableGuardians)
        .select()
        .eq('student_id', studentId);
    return (data as List)
        .map((e) => GuardianModel.fromJson(e).toEntity())
        .toList();
  }

  @override
  Future<Guardian> createGuardian(Guardian guardian) async {
    final model = GuardianModel.fromEntity(guardian);
    final json = model.toJson()..remove('id');
    final data = await _client
        .from(AppConstants.tableGuardians)
        .insert(json)
        .select()
        .single();
    return GuardianModel.fromJson(data).toEntity();
  }

  @override
  Future<Guardian> updateGuardian(Guardian guardian) async {
    final model = GuardianModel.fromEntity(guardian);
    final data = await _client
        .from(AppConstants.tableGuardians)
        .update(model.toJson())
        .eq('id', guardian.id)
        .select()
        .single();
    return GuardianModel.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteGuardian(String guardianId) async {
    await _client
        .from(AppConstants.tableGuardians)
        .delete()
        .eq('id', guardianId);
  }

  // ── Códigos de invitación ─────────────────────────────────────────────────

  @override
  Future<InvitationCode> generateInvitationCode(String studentId) async {
    final code = _uuid.v4().substring(0, 8).toUpperCase();
    final expiresAt = DateTime.now()
        .add(const Duration(days: AppConstants.invitationExpiryDays));

    final data = await _client
        .from(AppConstants.tableInvitationCodes)
        .insert({
          'code': code,
          'student_id': studentId,
          'expires_at': expiresAt.toIso8601String(),
        })
        .select()
        .single();
    return InvitationCodeModel.fromJson(data).toEntity();
  }

  @override
  Future<List<InvitationCode>> getInvitationCodes(String studentId) async {
    final data = await _client
        .from(AppConstants.tableInvitationCodes)
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => InvitationCodeModel.fromJson(e).toEntity())
        .toList();
  }
}
