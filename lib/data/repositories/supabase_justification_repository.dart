import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/justification.dart';
import '../../domain/repositories/i_justification_repository.dart';
import '../models/justification_model.dart';

class SupabaseJustificationRepository implements IJustificationRepository {
  SupabaseJustificationRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<List<Justification>> getJustifications({
    String? studentId,
    JustificationStatus? status,
  }) async {
    try {
      sb.PostgrestFilterBuilder<sb.PostgrestList> q =
          _client.from(AppConstants.tableJustifications).select();

      if (studentId != null) q = q.eq('student_id', studentId);
      if (status != null) q = q.eq('status', status.name);

      final data = await q.order('created_at', ascending: false);
      return (data as List)
          .map((e) => JustificationModel.fromJson(e).toEntity())
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener justificantes: $e');
    }
  }

  @override
  Stream<List<Justification>> watchJustifications(String studentId) {
    return _client
        .from(AppConstants.tableJustifications)
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((e) => JustificationModel.fromJson(e).toEntity())
            .toList());
  }

  @override
  Future<Justification> getJustificationById(String id) async {
    final data = await _client
        .from(AppConstants.tableJustifications)
        .select()
        .eq('id', id)
        .single();
    return JustificationModel.fromJson(data).toEntity();
  }

  @override
  Future<Justification> createJustification(
    Justification justification, {
    List<int>? fileBytes,
    String? fileExt,
  }) async {
    try {
      String? fileUrl;

      if (fileBytes != null && fileExt != null) {
        final path =
            '${justification.studentId}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        await _client.storage
            .from(AppConstants.bucketJustificationFiles)
            .uploadBinary(path, Uint8List.fromList(fileBytes),
                fileOptions: const sb.FileOptions(upsert: true));
        fileUrl = await _client.storage
            .from(AppConstants.bucketJustificationFiles)
            .createSignedUrl(path, 60 * 60 * 24 * 365);
      }

      final toInsert = Justification(
        id: justification.id,
        studentId: justification.studentId,
        reason: justification.reason,
        date: justification.date,
        status: justification.status,
        description: justification.description,
        fileUrl: fileUrl ?? justification.fileUrl,
        createdBy: justification.createdBy,
      );

      final model = JustificationModel.fromEntity(toInsert);
      final json = model.toJsonForInsert();

      final data = await _client
          .from(AppConstants.tableJustifications)
          .insert(json)
          .select()
          .single();
      return JustificationModel.fromJson(data).toEntity();
    } on sb.PostgrestException catch (e) {
      throw ServerException('Error en Supabase: ${e.message} (código: ${e.code})');
    } catch (e) {
      throw ServerException('Error al crear justificante: $e');
    }
  }

  @override
  Future<Justification> updateStatus(
      String id, JustificationStatus status) async {
    final data = await _client
        .from(AppConstants.tableJustifications)
        .update({
          'status': status.name,
          'reviewed_by': _client.auth.currentUser?.id,
        })
        .eq('id', id)
        .select()
        .single();
    return JustificationModel.fromJson(data).toEntity();
  }

  @override
  Future<Justification> updateJustification(
    Justification justification, {
    List<int>? fileBytes,
    String? fileExt,
  }) async {
    try {
      String? fileUrl = justification.fileUrl;

      // Upload file if new one is provided
      if (fileBytes != null && fileExt != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'justifications/${justification.id}/$fileName';
        await _client.storage
            .from(AppConstants.bucketJustificationFiles)
            .uploadBinary(filePath, Uint8List.fromList(fileBytes));
        fileUrl = _client.storage
            .from(AppConstants.bucketJustificationFiles)
            .getPublicUrl(filePath);
      }

      final model = JustificationModel.fromEntity(justification.copyWith(
        fileUrl: fileUrl,
      ));
      final json = model.toJson()
        ..remove('created_at')
        ..remove('created_by')
        ..remove('reviewed_by');
      final data = await _client
          .from(AppConstants.tableJustifications)
          .update(json)
          .eq('id', justification.id)
          .select()
          .single();
      return JustificationModel.fromJson(data).toEntity();
    } on sb.PostgrestException catch (e) {
      throw ServerException('Error en Supabase: ${e.message} (código: ${e.code})');
    } catch (e) {
      throw ServerException('Error al actualizar justificante: $e');
    }
  }

  @override
  Future<void> deleteJustification(String id) async {
    await _client
        .from(AppConstants.tableJustifications)
        .delete()
        .eq('id', id);
  }
}
