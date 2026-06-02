import '../entities/appointment.dart';

/// Contrato de operaciones sobre citas.
abstract interface class IAppointmentRepository {
  Future<List<Appointment>> getAppointments({
    String? studentId,
    AppointmentStatus? status,
    DateTime? fromDate,
  });
  Stream<List<Appointment>> watchAppointments({String? studentId});
  Future<Appointment> getAppointmentById(String id);
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> updateStatus(String id, AppointmentStatus status);
  Future<Appointment> markAsRead(String id);
  Future<void> deleteAppointment(String id);
}
