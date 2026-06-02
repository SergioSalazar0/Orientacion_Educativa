import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_appointment_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_justification_repository.dart';
import '../../data/repositories/supabase_report_repository.dart';
import '../../data/repositories/supabase_student_repository.dart';
import '../../data/services/file_import_service.dart';
import '../../domain/repositories/i_appointment_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_justification_repository.dart';
import '../../domain/repositories/i_report_repository.dart';
import '../../domain/repositories/i_student_repository.dart';

/// Cliente de Supabase inyectado como dependencia raíz.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Para intercambiar Supabase por Firebase basta con cambiar
/// la implementación aquí sin tocar ningún ViewModel.
final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

final studentRepositoryProvider = Provider<IStudentRepository>(
  (ref) => SupabaseStudentRepository(ref.watch(supabaseClientProvider)),
);

final reportRepositoryProvider = Provider<IReportRepository>(
  (ref) => SupabaseReportRepository(ref.watch(supabaseClientProvider)),
);

final justificationRepositoryProvider = Provider<IJustificationRepository>(
  (ref) => SupabaseJustificationRepository(ref.watch(supabaseClientProvider)),
);

final appointmentRepositoryProvider = Provider<IAppointmentRepository>(
  (ref) => SupabaseAppointmentRepository(ref.watch(supabaseClientProvider)),
);

final fileImportServiceProvider = Provider<FileImportService>(
  (_) => FileImportService(),
);
