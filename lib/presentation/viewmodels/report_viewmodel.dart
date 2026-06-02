import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/report.dart';
import '../providers/repository_providers.dart';

final reportsStreamProvider =
    StreamProvider.autoDispose.family<List<Report>, String>((ref, studentId) {
  return ref.watch(reportRepositoryProvider).watchReports(studentId);
});

final allReportsProvider =
    FutureProvider.autoDispose<List<Report>>((ref) {
  return ref.watch(reportRepositoryProvider).getReports();
});

class ReportFormState {
  const ReportFormState({
    this.isLoading = false,
    this.errorMessage,
    this.saved,
  });

  final bool isLoading;
  final String? errorMessage;
  final Report? saved;

  ReportFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    Report? saved,
  }) =>
      ReportFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        saved: saved ?? this.saved,
      );
}

class ReportViewModel extends Notifier<ReportFormState> {
  @override
  ReportFormState build() => const ReportFormState();

  Future<bool> save(
    Report report, {
    List<int>? imageBytes,
    String? imageExt,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await ref.read(reportRepositoryProvider).createReport(
            report,
            imageBytes: imageBytes,
            imageExt: imageExt,
          );
      state = ReportFormState(saved: saved);
      return true;
    } on AppException catch (e) {
      state = ReportFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ref.read(reportRepositoryProvider).deleteReport(id);
      return true;
    } on AppException catch (e) {
      state = ReportFormState(errorMessage: e.message);
      return false;
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final reportViewModelProvider =
    NotifierProvider<ReportViewModel, ReportFormState>(ReportViewModel.new);
