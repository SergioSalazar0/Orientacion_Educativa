import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/guardian.dart';
import '../../domain/entities/invitation_code.dart';
import '../../data/services/file_import_service.dart';
import '../providers/repository_providers.dart';

// ── Lista de alumnos (Realtime) ────────────────────────────────────────────

final studentsStreamProvider = StreamProvider<List<Student>>((ref) {
  return ref.watch(studentRepositoryProvider).watchStudents();
});

// ── Filtros de búsqueda ────────────────────────────────────────────────────

class StudentFilter {
  const StudentFilter({
    this.search = '',
    this.semester,
    this.group,
    this.specialty,
    this.status = StudentStatus.activo,
  });

  final String search;
  final String? semester;
  final String? group;
  final String? specialty;
  final StudentStatus? status;
}

final studentFilterProvider =
    StateProvider<StudentFilter>((_) => const StudentFilter());

final filteredStudentsProvider =
    FutureProvider.autoDispose<List<Student>>((ref) {
  final filter = ref.watch(studentFilterProvider);
  return ref.watch(studentRepositoryProvider).getStudents(
        search: filter.search.isNotEmpty ? filter.search : null,
        semester: filter.semester,
        group: filter.group,
        specialty: filter.specialty,
        status: filter.status,
      );
});

// ── Detalle de alumno ──────────────────────────────────────────────────────

final studentDetailProvider =
    FutureProvider.autoDispose.family<Student, String>((ref, id) {
  return ref.watch(studentRepositoryProvider).getStudentById(id);
});

final studentGuardiansProvider =
    FutureProvider.autoDispose.family<List<Guardian>, String>((ref, studentId) {
  return ref.watch(studentRepositoryProvider).getGuardians(studentId);
});

final invitationCodesProvider =
    FutureProvider.autoDispose.family<List<InvitationCode>, String>(
        (ref, studentId) {
  return ref.watch(studentRepositoryProvider).getInvitationCodes(studentId);
});

// ── ViewModel de creación/edición ──────────────────────────────────────────

class StudentFormState {
  const StudentFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedStudent,
    this.importResults,
  });

  final bool isLoading;
  final String? errorMessage;
  final Student? savedStudent;
  final List<ImportRowResult>? importResults;

  StudentFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    Student? savedStudent,
    List<ImportRowResult>? importResults,
  }) =>
      StudentFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        savedStudent: savedStudent ?? this.savedStudent,
        importResults: importResults ?? this.importResults,
      );
}

class StudentFormViewModel extends Notifier<StudentFormState> {
  @override
  StudentFormState build() => const StudentFormState();

  Future<bool> save(Student student, {List<int>? photoBytes, String? photoExt}) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(studentRepositoryProvider);
      Student saved;
      if (student.id.isEmpty) {
        saved = await repo.createStudent(student);
        // ✅ Generar código de invitación automáticamente
        await repo.generateInvitationCode(saved.id);
        // ✅ Invalidar providers para que se vea el código
        ref.invalidate(invitationCodesProvider(saved.id));
      } else {
        saved = await repo.updateStudent(student);
      }

      if (photoBytes != null && photoExt != null) {
        final url = await repo.uploadStudentPhoto(saved.id, photoBytes, photoExt);
        saved = await repo.updateStudent(saved.copyWith(photoUrl: url));
      }

      state = StudentFormState(savedStudent: saved);
      // Invalidar lista de estudiantes para refrescar
      ref.invalidate(studentsStreamProvider);
      ref.invalidate(filteredStudentsProvider);
      return true;
    } on AppException catch (e) {
      state = StudentFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> importFromFile(List<int> bytes, String extension) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(fileImportServiceProvider);
      final results = extension.toLowerCase() == 'csv'
          ? service.parseCsv(bytes)
          : service.parseXlsx(bytes);

      final toInsert = results
          .where((r) => r.isSuccess)
          .map((r) => r.student!)
          .toList();

      if (toInsert.isNotEmpty) {
        await ref.read(studentRepositoryProvider).bulkInsert(toInsert);
      }

      state = StudentFormState(importResults: results);
      return true;
    } on AppException catch (e) {
      state = StudentFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<void> generateInvitationCode(String studentId) async {
    await ref.read(studentRepositoryProvider).generateInvitationCode(studentId);
    ref.invalidate(invitationCodesProvider(studentId));
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final studentFormViewModelProvider =
    NotifierProvider<StudentFormViewModel, StudentFormState>(
        StudentFormViewModel.new);
