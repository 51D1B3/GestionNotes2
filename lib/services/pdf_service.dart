import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'firestore_service.dart';

class PdfService {
  Future<String> generateSemesterPdf(
    String semesterName,
    List<Map<String, dynamic>> subjects,
    double average,
    String faculty, 
    String department,
    String level
  ) async {
    final pdf = pw.Document();
    final firestoreService = FirestoreService();
    final profile = await firestoreService.getProfile();
    
    String studentName = "";
    String genderTitle = "Étudiant"; // Par défaut

    if (profile != null) {
      String lastName = profile['lastName']?.toUpperCase() ?? "";
      String firstName = profile['firstName'] ?? "";
      String gender = profile['gender'] ?? "Homme";

      if (firstName.isNotEmpty) {
        firstName = firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
      }
      studentName = "$firstName $lastName";

      // Si c'est une femme, on change le titre en "Étudiante"
      if (gender == "Femme") {
        genderTitle = "Étudiante";
      }
    }
    
    final ByteData bytes = await rootBundle.load('assets/applogo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();
    final image = pw.MemoryImage(byteList);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('UniNotes', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Relevé de notes officiel', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Image(image, width: 60, height: 60),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),
              
              if (studentName.isNotEmpty) ...[
                pw.Text('$genderTitle : $studentName', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
              ],

              pw.Text('Informations Académiques', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Faculté : $faculty'),
              pw.Text('Département : $department'),
              pw.Text('Niveau : $level'),
              pw.Text('Semestre : $semesterName'),
              pw.SizedBox(height: 20),
              
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                },
                headers: ['Matière', 'Note E', 'Note G', 'Note F', 'Moyenne', 'Mention'],
                data: subjects.map((s) => [
                  s['name'],
                  s['ne']?.toStringAsFixed(2) ?? '-',
                  s['ndg']?.toStringAsFixed(2) ?? '-',
                  s['nef']?.toStringAsFixed(2) ?? '-',
                  s['moyenneMatiere'].toStringAsFixed(2),
                  s['mention'],
                ]).toList(),
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('MOYENNE DU SEMESTRE : ${average.toStringAsFixed(2)}', 
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 5),
                    pw.Text('Date de génération : ${DateTime.now().toString().substring(0, 16)}', 
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    String? downloadPath;
    if (Platform.isAndroid) {
      downloadPath = "/storage/emulated/0/Download";
      final dir = Directory(downloadPath);
      if (!await dir.exists()) {
        final externalDir = await getExternalStorageDirectory();
        downloadPath = externalDir?.path;
      }
    } else {
      final downloadDir = await getDownloadsDirectory();
      downloadPath = downloadDir?.path;
    }

    final String fileName = 'UniNotes_${semesterName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final String fullPath = '$downloadPath/$fileName';
    
    final file = File(fullPath);
    await file.writeAsBytes(await pdf.save());
    
    return fullPath;
  }
}
