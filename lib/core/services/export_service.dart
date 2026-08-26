import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../data/models/registration_model.dart';
import '../utils/formatters.dart';

enum ExportFormat { csv, excel, pdf }

class ExportService {
  ExportService._();

  /// Export Registration Responses to CSV format
  static Future<String> generateCsv(List<RegistrationModel> registrations) async {
    final List<List<dynamic>> rows = [
      ['Registration ID', 'Event Title', 'Student Name', 'USN', 'Email', 'Phone', 'Branch', 'Semester', 'Status', 'Date'],
    ];

    for (final reg in registrations) {
      rows.add([
        reg.id,
        reg.eventTitle,
        reg.studentName,
        reg.studentUSN,
        reg.studentEmail,
        reg.studentPhone,
        reg.branch,
        reg.semester,
        reg.status.name.toUpperCase(),
        Formatters.formatDate(reg.registrationDate),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Export Registration Responses to Excel (.xlsx) format
  static Future<Uint8List> generateExcel(List<RegistrationModel> registrations) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Registrations'];
    excel.delete('Sheet1');

    // Header styling
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headers = [
      'Registration ID',
      'Event Title',
      'Student Name',
      'USN',
      'Email',
      'Phone',
      'Branch',
      'Semester',
      'Status',
      'Registration Date',
    ];

    // Append Header Row
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Apply header style
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerStyle;
    }

    // Append Data Rows
    for (final reg in registrations) {
      sheet.appendRow([
        TextCellValue(reg.id),
        TextCellValue(reg.eventTitle),
        TextCellValue(reg.studentName),
        TextCellValue(reg.studentUSN),
        TextCellValue(reg.studentEmail),
        TextCellValue(reg.studentPhone),
        TextCellValue(reg.branch),
        IntCellValue(reg.semester),
        TextCellValue(reg.status.name.toUpperCase()),
        TextCellValue(Formatters.formatDate(reg.registrationDate)),
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes ?? []);
  }

  /// Export Registration Responses to PDF format
  static Future<Uint8List> generatePdf(List<RegistrationModel> registrations, {String eventTitle = 'Campus Connect Registrations'}) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Campus Connect - Event Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text(eventTitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('Total: ${registrations.length} Students', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: ['#', 'Student Name', 'USN', 'Branch', 'Sem', 'Email', 'Phone', 'Status'],
              data: List<List<dynamic>>.generate(
                registrations.length,
                (index) {
                  final reg = registrations[index];
                  return [
                    '${index + 1}',
                    reg.studentName,
                    reg.studentUSN,
                    reg.branch,
                    'Sem ${reg.semester}',
                    reg.studentEmail,
                    reg.studentPhone,
                    reg.status.name.toUpperCase(),
                  ];
                },
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0057E7)),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Powered by GDG UVCE', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Save and Share or Download File
  static Future<void> exportAndShare({
    required List<RegistrationModel> registrations,
    required ExportFormat format,
    String eventTitle = 'Campus_Registrations',
  }) async {
    final sanitizedTitle = eventTitle.replaceAll(RegExp(r'\s+'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (kIsWeb) {
      // In web, trigger data URI share or file save
      if (format == ExportFormat.csv) {
        final csvData = await generateCsv(registrations);
        final bytes = utf8.encode(csvData);
        await Share.shareXFiles([
          XFile.fromData(Uint8List.fromList(bytes), name: '$sanitizedTitle-$timestamp.csv', mimeType: 'text/csv'),
        ]);
      } else if (format == ExportFormat.excel) {
        final bytes = await generateExcel(registrations);
        await Share.shareXFiles([
          XFile.fromData(bytes, name: '$sanitizedTitle-$timestamp.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ]);
      } else if (format == ExportFormat.pdf) {
        final bytes = await generatePdf(registrations, eventTitle: eventTitle);
        await Share.shareXFiles([
          XFile.fromData(bytes, name: '$sanitizedTitle-$timestamp.pdf', mimeType: 'application/pdf'),
        ]);
      }
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    String filePath = '';

    switch (format) {
      case ExportFormat.csv:
        final csvData = await generateCsv(registrations);
        final file = File('${directory.path}/$sanitizedTitle-$timestamp.csv');
        await file.writeAsString(csvData);
        filePath = file.path;
        break;

      case ExportFormat.excel:
        final bytes = await generateExcel(registrations);
        final file = File('${directory.path}/$sanitizedTitle-$timestamp.xlsx');
        await file.writeAsBytes(bytes);
        filePath = file.path;
        break;

      case ExportFormat.pdf:
        final bytes = await generatePdf(registrations, eventTitle: eventTitle);
        final file = File('${directory.path}/$sanitizedTitle-$timestamp.pdf');
        await file.writeAsBytes(bytes);
        filePath = file.path;
        break;
    }

    if (filePath.isNotEmpty) {
      await Share.shareXFiles([XFile(filePath)], text: 'Exported $eventTitle data from Campus Connect');
    }
  }
}
