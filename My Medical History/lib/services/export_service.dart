import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/visit.dart';
import '../models/doctor.dart';

class ExportService {
  static Future<File> generateMedicalHistoryPdf(List<Visit> visits, List<Doctor> doctors) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('My Medical History Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Paragraph(text: 'Generated from My Medical History App'),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text('Doctors (${doctors.length}):', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ...doctors.map((d) => pw.Bullet(text: '${d.name} - ${d.specialization} (${d.phone ?? "No Phone"})')),
          pw.SizedBox(height: 20),
          pw.Text('Visit History (${visits.length}):', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ...visits.map((v) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Paragraph(text: 'Date: ${v.date} | Diagnosis: ${v.diagnosis ?? "General"} \nDoctor: ${v.doctor?.name ?? "Unknown"} \nReason: ${v.reason ?? "-"}'),
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                ],
              )),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/medical_history_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> openExportedPdf(File file) async {
    await OpenFile.open(file.path);
  }
}
