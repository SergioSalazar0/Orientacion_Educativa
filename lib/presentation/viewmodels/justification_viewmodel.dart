import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/justification.dart';
import '../providers/repository_providers.dart';

final justificationsStreamProvider = StreamProvider.autoDispose
    .family<List<Justification>, String>((ref, studentId) {
  return ref.watch(justificationRepositoryProvider).watchJustifications(studentId);
});

final allJustificationsProvider =
    FutureProvider.autoDispose<List<Justification>>((ref) {
  return ref.watch(justificationRepositoryProvider).getJustifications();
});

class JustificationFormState {
  const JustificationFormState({
    this.isLoading = false,
    this.errorMessage,
    this.saved,
  });

  final bool isLoading;
  final String? errorMessage;
  final Justification? saved;

  JustificationFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    Justification? saved,
  }) =>
      JustificationFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        saved: saved ?? this.saved,
      );
}

class JustificationViewModel extends Notifier<JustificationFormState> {
  @override
  JustificationFormState build() => const JustificationFormState();

  Future<bool> save(
    Justification justification, {
    List<int>? fileBytes,
    String? fileExt,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await ref
          .read(justificationRepositoryProvider)
          .createJustification(justification,
              fileBytes: fileBytes, fileExt: fileExt);
      state = JustificationFormState(saved: saved);
      // ✅ Invalidar el stream para refrescar los datos
      ref.invalidate(justificationsStreamProvider(justification.studentId));
      ref.invalidate(allJustificationsProvider);
      return true;
    } on AppException catch (e) {
      state = JustificationFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> update(
    Justification justification, {
    List<int>? fileBytes,
    String? fileExt,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await ref
          .read(justificationRepositoryProvider)
          .updateJustification(
            justification,
            fileBytes: fileBytes,
            fileExt: fileExt,
          );
      state = JustificationFormState(saved: updated);
      // ✅ Invalidar el stream para refrescar los datos
      ref.invalidate(justificationsStreamProvider(justification.studentId));
      ref.invalidate(allJustificationsProvider);
      return true;
    } on AppException catch (e) {
      state = JustificationFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> delete(String justificationId, String studentId) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref
          .read(justificationRepositoryProvider)
          .deleteJustification(justificationId);
      // ✅ Invalidar el stream para refrescar los datos
      ref.invalidate(justificationsStreamProvider(studentId));
      ref.invalidate(allJustificationsProvider);
      state = const JustificationFormState();
      return true;
    } on AppException catch (e) {
      state = JustificationFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> updateStatus(String id, JustificationStatus status) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await ref
          .read(justificationRepositoryProvider)
          .updateStatus(id, status);
      state = JustificationFormState(saved: saved);
      return true;
    } on AppException catch (e) {
      state = JustificationFormState(errorMessage: e.message);
      return false;
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final justificationViewModelProvider =
    NotifierProvider<JustificationViewModel, JustificationFormState>(
        JustificationViewModel.new);
