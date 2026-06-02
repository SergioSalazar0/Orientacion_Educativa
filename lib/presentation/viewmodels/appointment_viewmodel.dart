import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/appointment.dart';
import '../providers/repository_providers.dart';

final appointmentsStreamProvider =
    StreamProvider.autoDispose<List<Appointment>>((ref) {
  return ref.watch(appointmentRepositoryProvider).watchAppointments();
});

final studentAppointmentsStreamProvider = StreamProvider.autoDispose
    .family<List<Appointment>, String>((ref, studentId) {
  return ref
      .watch(appointmentRepositoryProvider)
      .watchAppointments(studentId: studentId);
});

final upcomingAppointmentsProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) {
  return ref.watch(appointmentRepositoryProvider).getAppointments(
        fromDate: DateTime.now(),
        status: AppointmentStatus.programada,
      );
});

class AppointmentFormState {
  const AppointmentFormState({
    this.isLoading = false,
    this.errorMessage,
    this.saved,
  });

  final bool isLoading;
  final String? errorMessage;
  final Appointment? saved;

  AppointmentFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    Appointment? saved,
  }) =>
      AppointmentFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        saved: saved ?? this.saved,
      );
}

class AppointmentViewModel extends Notifier<AppointmentFormState> {
  @override
  AppointmentFormState build() => const AppointmentFormState();

  Future<bool> create(Appointment appointment) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await ref
          .read(appointmentRepositoryProvider)
          .createAppointment(appointment);
      state = AppointmentFormState(saved: saved);
      return true;
    } on AppException catch (e) {
      state = AppointmentFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> updateStatus(String id, AppointmentStatus status) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved = await ref
          .read(appointmentRepositoryProvider)
          .updateStatus(id, status);
      state = AppointmentFormState(saved: saved);
      return true;
    } on AppException catch (e) {
      state = AppointmentFormState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      await ref.read(appointmentRepositoryProvider).markAsRead(id);
      return true;
    } on AppException catch (e) {
      state = AppointmentFormState(errorMessage: e.message);
      return false;
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

final appointmentViewModelProvider =
    NotifierProvider<AppointmentViewModel, AppointmentFormState>(
        AppointmentViewModel.new);
