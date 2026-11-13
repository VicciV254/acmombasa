import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/app_database.dart';
import '../utils/date_format.dart';

/// Builds a visitor badge (credit-card size) and opens the system print dialog.
/// The QR code holds the member ID, so scanners can check the visitor in.
abstract final class BadgePrinter {
  static Future<void> print({required Visitor visitor, Visit? visit}) async {
    final doc = pw.Document();
    final navy = PdfColor.fromInt(0xFF0A1F44);
    final red = PdfColor.fromInt(0xFFB22234);
    final muted = PdfColor.fromInt(0xFF64748B);
    final today = DateFormatter.longDate(DateTime.now());

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          86 * PdfPageFormat.mm,
          54 * PdfPageFormat.mm,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              color: navy,
              width: double.infinity,
              child: pw.Text(
                'AMERICAN CORNER MOMBASA',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            pw.Container(height: 1.5, color: red),
            pw.SizedBox(height: 6),
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          visitor.fullName,
                          maxLines: 2,
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(visitor.category,
                            style: pw.TextStyle(fontSize: 9, color: muted)),
                        pw.SizedBox(height: 5),
                        pw.Text(visitor.memberId,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        if (visit != null) ...[
                          pw.SizedBox(height: 3),
                          pw.Text(visit.purpose,
                              maxLines: 2,
                              style: pw.TextStyle(fontSize: 8.5, color: muted)),
                          if (visit.workstation != null)
                            pw.Text('Workstation: ${visit.workstation}',
                                style: pw.TextStyle(fontSize: 8.5, color: muted)),
                        ],
                        pw.Spacer(),
                        pw.Text(today,
                            style: pw.TextStyle(fontSize: 8, color: muted)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: visitor.memberId,
                    width: 62,
                    height: 62,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      name: 'Badge ${visitor.memberId}',
      onLayout: (_) => doc.save(),
    );
  }
}
