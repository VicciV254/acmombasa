import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/history_models.dart';
import '../utils/date_format.dart';
import '../utils/format_utils.dart';

/// Prints the entries currently shown on the history page as an A4 landscape
/// log sheet, through the system print dialog.
abstract final class LogSheetPrinter {
  static Future<void> print({
    required List<HistoryEntry> entries,
    required String rangeLabel,
  }) async {
    final navy = PdfColor.fromInt(0xFF0A1F44);
    const cell = pw.TextStyle(fontSize: 8);
    const head = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    pw.Widget c(String text, {pw.TextStyle style = cell}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: pw.Text(text, style: style),
        );

    const headers = [
      'Date',
      'Time window',
      'Patron',
      'Member ID',
      'Purpose',
      'Room / workstation',
      'Checked in by',
    ];

    final header = pw.TableRow(
      decoration: pw.BoxDecoration(color: navy),
      children: [for (final h in headers) c(h, style: head)],
    );

    final rows = [
      for (final e in entries)
        pw.TableRow(children: [
          c(DateFormatter.shortDate(e.visit.checkInAt)),
          c(
            e.visit.checkOutAt == null
                ? '${DateFormatter.time12(e.visit.checkInAt)} - inside'
                : '${DateFormatter.time12(e.visit.checkInAt)} - '
                    '${DateFormatter.time12(e.visit.checkOutAt!)} '
                    '(${formatDuration(e.duration!)})',
          ),
          c(e.visitor.fullName),
          c(e.visitor.memberId),
          c(e.visit.purpose),
          c(e.space),
          c(e.staffName),
        ]),
    ];

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'AMERICAN CORNER MOMBASA: Visit Log Sheet',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '$rangeLabel  •  ${entries.length} '
            '${entries.length == 1 ? 'entry' : 'entries'}  •  Printed '
            '${DateFormatter.shortDate(DateTime.now())} '
            '${DateFormatter.time12(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(2.4),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(1.4),
              4: pw.FlexColumnWidth(2.2),
              5: pw.FlexColumnWidth(1.6),
              6: pw.FlexColumnWidth(1.6),
            },
            children: [header, ...rows],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(name: 'Visit Log Sheet', onLayout: (_) => doc.save());
  }
}
