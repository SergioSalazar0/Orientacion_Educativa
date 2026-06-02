import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/student.dart';

/// Resultado de una fila importada: alumno exitoso o error con descripción.
class ImportRowResult {
  const ImportRowResult.success(this.student) : error = null, rowIndex = null;
  const ImportRowResult.failure(this.error, this.rowIndex) : student = null;

  final Student? student;
  final String? error;
  final int? rowIndex;

  bool get isSuccess => student != null;
}

/// Servicio que parsea archivos .csv y .xlsx y los convierte a entidades Student.
/// Los encabezados mínimos requeridos están en [AppConstants.importHeaders].
class FileImportService {
  /// Parsea bytes de un archivo CSV y retorna resultados por fila.
  List<ImportRowResult> parseCsv(List<int> bytes) {
    final content = String.fromCharCodes(bytes);
    final rows = const CsvToListConverter().convert(content, eol: '\n');
    if (rows.isEmpty) {
      throw const FileImportException('El archivo CSV está vacío.');
    }
    return _processRows(rows);
  }

  /// Parsea bytes de un archivo XLSX y retorna resultados por fila.
  List<ImportRowResult> parseXlsx(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first;
    final rows = sheet.rows
        .map((r) => r.map((c) => c?.value?.toString() ?? '').toList())
        .toList();
    if (rows.isEmpty) {
      throw const FileImportException('El archivo XLSX está vacío.');
    }
    return _processRows(rows);
  }

  List<ImportRowResult> _processRows(List<List<dynamic>> rows) {
    // Primera fila = encabezados
    final headers = rows.first
        .map((h) => h.toString().toLowerCase().trim())
        .toList();

    _validateHeaders(headers);

    final results = <ImportRowResult>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.every((cell) => cell.toString().trim().isEmpty)) continue;

      try {
        final student = _rowToStudent(headers, row, i + 1);
        results.add(ImportRowResult.success(student));
      } on FileImportException catch (e) {
        results.add(ImportRowResult.failure(e.message, i + 1));
      }
    }

    return results;
  }

  void _validateHeaders(List<String> headers) {
    final missing = AppConstants.importHeaders
        .where((h) => !headers.contains(h))
        .toList();
    if (missing.isNotEmpty) {
      throw FileImportException(
        'Encabezados faltantes: ${missing.join(', ')}. '
        'Requeridos: ${AppConstants.importHeaders.join(', ')}',
      );
    }
  }

  Student _rowToStudent(
    List<String> headers,
    List<dynamic> row,
    int rowNumber,
  ) {
    String get(String key) {
      final idx = headers.indexOf(key);
      if (idx == -1 || idx >= row.length) return '';
      return row[idx].toString().trim();
    }

    final studentCode = get('matricula');
    final fullName = get('nombre');
    final semester = get('semestre');
    final group = get('grupo');
    final specialty = get('especialidad');

    if (studentCode.isEmpty) {
      throw FileImportException('Matrícula vacía', row: rowNumber);
    }
    if (fullName.isEmpty) {
      throw FileImportException('Nombre vacío', row: rowNumber);
    }
    if (semester.isEmpty) {
      throw FileImportException('Semestre vacío', row: rowNumber);
    }

    return Student(
      id: '',
      studentCode: studentCode,
      fullName: fullName,
      semester: semester,
      group: group.isNotEmpty ? group : 'A',
      specialty: specialty.isNotEmpty ? specialty : 'General',
      status: StudentStatus.activo,
      birthDate: _parseDate(get('fecha_nacimiento')),
      address: get('domicilio').isEmpty ? null : get('domicilio'),
      bloodType: get('tipo_sangre').isEmpty ? null : get('tipo_sangre'),
      insurance: get('seguro').isEmpty ? null : get('seguro'),
      nss: get('nss').isEmpty ? null : get('nss'),
      allergies: get('alergias').isEmpty ? null : get('alergias'),
      medicalNotes:
          get('notas_medicas').isEmpty ? null : get('notas_medicas'),
    );
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
