import '../entities/report.dart';

/// Contrato de operaciones sobre reportes de orientación.
abstract interface class IReportRepository {
  Future<List<Report>> getReports({String? studentId, ReportCategory? category});
  Stream<List<Report>> watchReports(String studentId);
  Future<Report> getReportById(String id);
  Future<Report> createReport(Report report, {List<int>? imageBytes, String? imageExt});
  Future<Report> updateReport(Report report);
  Future<void> deleteReport(String id);
}
