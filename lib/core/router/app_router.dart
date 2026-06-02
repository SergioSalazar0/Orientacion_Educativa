import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_user.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/shared/splash_screen.dart';
import '../../presentation/screens/shared/link_child_screen.dart';
import '../../presentation/screens/orientador/dashboard_screen.dart';
import '../../presentation/screens/orientador/students_list_screen.dart';
import '../../presentation/screens/orientador/student_form_screen.dart';
import '../../presentation/screens/orientador/student_detail_screen.dart';
import '../../presentation/screens/orientador/report_form_screen.dart';
import '../../presentation/screens/orientador/reports_history_screen.dart';
import '../../presentation/screens/orientador/justification_form_screen.dart';
import '../../presentation/screens/orientador/appointments_list_screen.dart';
import '../../presentation/screens/orientador/appointment_form_screen.dart';
import '../../presentation/screens/parent/parent_home_screen.dart';
import '../../presentation/screens/parent/child_profile_screen.dart';
import '../../presentation/screens/parent/parent_reports_screen.dart';
import '../../presentation/screens/parent/parent_justifications_screen.dart';
import '../../presentation/screens/parent/parent_appointments_screen.dart';
import '../../presentation/screens/parent/appointment_notification_screen.dart';

/// Rutas nombradas de la aplicación.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String linkChild = '/link-child';

  // Orientador
  static const String orientadorDashboard = '/orientador';
  static const String studentsList = '/orientador/alumnos';
  static const String studentNew = '/orientador/alumnos/nuevo';
  static const String studentDetail = '/orientador/alumnos/:id';
  static const String studentEdit = '/orientador/alumnos/:id/editar';
  static const String reportNew = '/orientador/alumnos/:id/reporte';
  static const String reportsHistory = '/orientador/reportes';
  static const String justificationNew = '/orientador/alumnos/:id/justificante';
  static const String appointmentsList = '/orientador/citas';
  static const String appointmentNew = '/orientador/citas/nueva';

  // Padre
  static const String parentHome = '/padre';
  static const String childProfile = '/padre/perfil';
  static const String parentReports = '/padre/reportes';
  static const String parentJustifications = '/padre/justificantes';
  static const String parentAppointments = '/padre/citas';
  static const String appointmentNotification = '/padre/citas/:id/notificacion';
}

/// El router se crea UNA sola vez (keepAlive).
/// Los re-evaluos de redirect se disparan via [_AuthNotifier] (Listenable),
/// no recreando el GoRouter — eso rompería la navegación interna.
final appRouterProvider = Provider<GoRouter>((ref) {
  ref.keepAlive();

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthNotifier(ref),
    redirect: (context, state) {
      // Leer (no watch) — el Listenable ya dispara el refresh
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;

      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      if (isLoggedIn && (isAuthRoute || isSplash)) {
        return user.role == UserRole.orientador
            ? AppRoutes.orientadorDashboard
            : AppRoutes.parentHome;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.linkChild, builder: (_, __) => const LinkChildScreen()),

      // ── Orientador ────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.orientadorDashboard, builder: (_, __) => const DashboardScreen()),
      GoRoute(path: AppRoutes.studentsList, builder: (_, __) => const StudentsListScreen()),
      GoRoute(path: AppRoutes.studentNew, builder: (_, __) => const StudentFormScreen()),
      GoRoute(
        path: AppRoutes.studentDetail,
        builder: (_, state) => StudentDetailScreen(studentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.studentEdit,
        builder: (_, state) => StudentFormScreen(studentId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.reportNew,
        builder: (_, state) => ReportFormScreen(studentId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.reportsHistory, builder: (_, __) => const ReportsHistoryScreen()),
      GoRoute(
        path: AppRoutes.justificationNew,
        builder: (_, state) => JustificationFormScreen(studentId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.appointmentsList, builder: (_, __) => const AppointmentsListScreen()),
      GoRoute(path: AppRoutes.appointmentNew, builder: (_, __) => const AppointmentFormScreen()),

      // ── Padre ─────────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.parentHome, builder: (_, __) => const ParentHomeScreen()),
      GoRoute(path: AppRoutes.childProfile, builder: (_, __) => const ChildProfileScreen()),
      GoRoute(path: AppRoutes.parentReports, builder: (_, __) => const ParentReportsScreen()),
      GoRoute(path: AppRoutes.parentJustifications, builder: (_, __) => const ParentJustificationsScreen()),
      GoRoute(path: AppRoutes.parentAppointments, builder: (_, __) => const ParentAppointmentsScreen()),
      GoRoute(
        path: AppRoutes.appointmentNotification,
        builder: (_, state) => AppointmentNotificationScreen(
          appointmentId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Página no encontrada: ${state.error}')),
    ),
  );

  return router;
});

/// Notifica al GoRouter cuando cambia el estado de auth para re-evaluar redirects.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
