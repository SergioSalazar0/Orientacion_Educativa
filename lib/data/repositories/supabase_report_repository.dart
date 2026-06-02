import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/i_report_repository.dart';
import '../models/report_model.dart';

class SupabaseReportRepository implements IReportRepository {
  SupabaseReportRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<List<Report>> getReports({
    String? studentId,
    ReportCategory? category,
  }) async {
    try {
      sb.PostgrestFilterBuilder<sb.PostgrestList> q =
          _client.from(AppConstants.tableReports).select('*, profiles(full_name)');

      if (studentId != null) q = q.eq('student_id', studentId);
      if (category != null) q = q.eq('category', category.name);

      final data = await q.order('created_at', ascending: false);
      return (data as List)
          .map((e) => ReportModel.fromJson(e).toEntity())
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener reportes: $e');
    }
  }

  @override
  Stream<List<Report>> watchReports(String studentId) {
    return _client
        .from(AppConstants.tableReports)
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((e) => ReportModel.fromJson(e).toEntity()).toList());
  }

  @override
  Future<Report> getReportById(String id) async {
    final data = await _client
        .from(AppConstants.tableReports)
        .select('*, profiles(full_name)')
        .eq('id', id)
        .single();
    return ReportModel.fromJson(data).toEntity();
  }

  @override
  Future<Report> createReport(
    Report report, {
    List<int>? imageBytes,
    String? imageExt,
  }) async {
    String? imageUrl;

    if (imageBytes != null && imageExt != null) {
      final path = '${report.studentId}/${DateTime.now().millisecondsSinceEpoch}.$imageExt';
      await _client.storage
          .from(AppConstants.bucketReportImages)
          .uploadBinary(path, Uint8List.fromList(imageBytes),
              fileOptions: sb.FileOptions(upsert: true));
      imageUrl = await _client.storage
          .from(AppConstants.bucketReportImages)
          .createSignedUrl(path, 60 * 60 * 24 * 365);
    }

    final model = ReportModel.fromEntity(
      imageUrl != null ? Report(
        id: report.id,
        studentId: report.studentId,
        category: report.category,
        title: report.title,
        description: report.description,
        imageUrl: imageUrl,
        createdBy: report.createdBy,
      ) : report,
    );
    final json = model.toJson()
      ..remove('id')
      ..remove('profiles');

    final data = await _client
        .from(AppConstants.tableReports)
        .insert(json)
        .select('*, profiles(full_name)')
        .single();
    return ReportModel.fromJson(data).toEntity();
  }

  @override
  Future<Report> updateReport(Report report) async {
    final model = ReportModel.fromEntity(report);
    final data = await _client
        .from(AppConstants.tableReports)
        .update(model.toJson()..remove('profiles'))
        .eq('id', report.id)
        .select('*, profiles(full_name)')
        .single();
    return ReportModel.fromJson(data).toEntity();
  }

  @override
  Future<void> deleteReport(String id) async {
    await _client.from(AppConstants.tableReports).delete().eq('id', id);
  }
}
