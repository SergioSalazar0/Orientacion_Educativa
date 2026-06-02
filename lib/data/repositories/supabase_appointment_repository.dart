import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/i_appointment_repository.dart';
import '../models/appointment_model.dart';

class SupabaseAppointmentRepository implements IAppointmentRepository {
  SupabaseAppointmentRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<List<Appointment>> getAppointments({
    String? studentId,
    AppointmentStatus? status,
    DateTime? fromDate,
  }) async {
    try {
      sb.PostgrestFilterBuilder<sb.PostgrestList> q =
          _client.from(AppConstants.tableAppointments).select('*, students(full_name)');

      if (studentId != null) q = q.eq('student_id', studentId);
      if (status != null) q = q.eq('status', status.name);
      if (fromDate != null) {
        q = q.gte('date', fromDate.toIso8601String().substring(0, 10));
      }

      final data = await q.order('date').order('time');
      return (data as List)
          .map((e) => AppointmentModel.fromJson(e).toEntity())
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener citas: $e');
    }
  }

  @override
  Stream<List<Appointment>> watchAppointments({String? studentId}) {
    // stream() acepta eq como filtro directo (retorna SupabaseStreamBuilder)
    var stream = studentId != null
        ? _client
            .from(AppConstants.tableAppointments)
            .stream(primaryKey: ['id'])
            .eq('student_id', studentId)
            .order('date')
        : _client
            .from(AppConstants.tableAppointments)
            .stream(primaryKey: ['id'])
            .order('date');

    return stream.map((data) =>
        data.map((e) => AppointmentModel.fromJson(e).toEntity()).toList());
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    final data = await _client
        .from(AppConstants.tableAppointments)
        .select('*, students(full_name)')
        .eq('id', id)
        .single();
    return AppointmentModel.fromJson(data).toEntity();
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    final model = AppointmentModel.fromEntity(appointment);
    final json = model.toJson()
      ..remove('id')
      ..remove('students');

    final data = await _client
        .from(AppConstants.tableAppointments)
        .insert(json)
        .select('*, students(full_name)')
        .single();
    return AppointmentModel.fromJson(data).toEntity();
  }

  @override
  Future<Appointment> updateStatus(String id, AppointmentStatus status) async {
    final data = await _client
        .from(AppConstants.tableAppointments)
        .update({'status': status.name})
        .eq('id', id)
        .select('*, students(full_name)')
        .single();
    return AppointmentModel.fromJson(data).toEntity();
  }

  @override
  Future<Appointment> markAsRead(String id) async {
    final data = await _client
        .from(AppConstants.tableAppointments)
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select('*, students(full_name)')
        .single();
    return AppointmentModel.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteAppointment(String id) async {
    await _client
        .from(AppConstants.tableAppointments)
        .delete()
        .eq('id', id);
  }
}
