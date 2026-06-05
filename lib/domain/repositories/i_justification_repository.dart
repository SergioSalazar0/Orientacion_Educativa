import '../entities/justification.dart';

/// Contrato de operaciones sobre justificantes.
abstract interface class IJustificationRepository {
  Future<List<Justification>> getJustifications({
    String? studentId,
    JustificationStatus? status,
  });
  Stream<List<Justification>> watchJustifications(String studentId);
  Future<Justification> getJustificationById(String id);
  Future<Justification> createJustification(
    Justification justification, {
    List<int>? fileBytes,
    String? fileExt,
  });
  Future<Justification> updateJustification(
    Justification justification, {
    List<int>? fileBytes,
    String? fileExt,
  });
  Future<Justification> updateStatus(String id, JustificationStatus status);
  Future<void> deleteJustification(String id);
}
