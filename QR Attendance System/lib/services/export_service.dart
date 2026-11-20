import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/app_models.dart';

class ExportService {
  ExportService._();

  /// Escapes CSV values to prevent formula injection (=, +, -, @)
  static String _sanitizeCsvCell(String value) {
    if (value.startsWith('=') || value.startsWith('+') || value.startsWith('-') || value.startsWith('@')) {
      return "'$value";
    }
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Generates a sanitized CSV string formatted for spreadsheet applications
  static String generateCsvReport({
    required List<AttendanceRecord> records,
    String institutionName = 'QR Attendance System',
    String? className,
    String? subjectName,
  }) {
    final buffer = StringBuffer();
    // Metadata Header
    buffer.writeln('# Institution: ${_sanitizeCsvCell(institutionName)}');
    buffer.writeln('# Generated At: ${DateTime.now().toIso8601String()}');
    if (className != null) buffer.writeln('# Class: ${_sanitizeCsvCell(className)}');
    if (subjectName != null) buffer.writeln('# Subject: ${_sanitizeCsvCell(subjectName)}');
    buffer.writeln();

    // Table Column Headers
    buffer.writeln('Record ID,Session ID,Student ID,Scanned Date,Scanned Time,Status,Sync Status');

    for (final r in records) {
      final dateStr = r.scannedAt.toLocal().toString().substring(0, 10);
      final timeStr = r.scannedAt.toLocal().toString().substring(11, 19);
      final row = [
        _sanitizeCsvCell(r.id),
        _sanitizeCsvCell(r.sessionId),
        _sanitizeCsvCell(r.studentId),
        _sanitizeCsvCell(dateStr),
        _sanitizeCsvCell(timeStr),
        _sanitizeCsvCell(r.status.toUpperCase()),
        _sanitizeCsvCell(r.isOfflineSynced ? 'Server Confirmed' : 'Pending Sync'),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Generates and renders a professional PDF Report with Print/Share preview
  static Future<void> generateAndPrintPdfReport({
    required List<AttendanceRecord> records,
    required String title,
    String institutionName = 'QR Attendance System',
    String? filterSummary,
  }) async {
    final pdf = pw.Document();

    int presentCount = 0;
    int lateCount = 0;
    for (final r in records) {
      if (r.status.toLowerCase() == 'present') presentCount++;
      if (r.status.toLowerCase() == 'late') lateCount++;
    }
    final total = records.length;
    final percentage = total > 0 ? ((presentCount + lateCount) / total * 100).toStringAsFixed(1) : '0.0';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    institutionName,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Smart Attendance. Simple & Secure.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  pw.Text('Generated: ${DateTime.now().toLocal().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 1.5, color: PdfColors.blue700),
          pw.SizedBox(height: 12),

          // Filters summary
          if (filterSummary != null) ...[
            pw.Text('Filter: $filterSummary', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
            pw.SizedBox(height: 8),
          ],

          // Summary Statistics Row
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Text('Total Scans: $total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.Text('Present: $presentCount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800, fontSize: 11)),
                pw.Text('Late: $lateCount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.amber800, fontSize: 11)),
                pw.Text('Attendance: $percentage%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900, fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Attendance Records Table
          records.isEmpty
              ? pw.Center(child: pw.Text('No attendance records found for this period.'))
              : pw.TableHelper.fromTextArray(
                  headers: ['#', 'Student Identifier', 'Date', 'Time', 'Status', 'Sync'],
                  headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.centerLeft,
                  data: List.generate(records.length, (index) {
                    final r = records[index];
                    return [
                      '${index + 1}',
                      r.studentId.substring(0, r.studentId.length > 8 ? 8 : r.studentId.length),
                      r.scannedAt.toLocal().toString().substring(0, 10),
                      r.scannedAt.toLocal().toString().substring(11, 19),
                      r.status.toUpperCase(),
                      r.isOfflineSynced ? 'Confirmed' : 'Pending',
                    ];
                  }),
                ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '$title.pdf',
    );
  }
}
