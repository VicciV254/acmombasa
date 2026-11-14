import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/program_models.dart';
import '../domain/report_models.dart';
import '../utils/date_format.dart';
import '../utils/format_utils.dart';

/// PDF documents for the Reports and Programs pages. Aggregated figures only:
/// no phone numbers or other contact details are printed on the ECA report.
abstract final class ReportPdf {
  static final _navy = PdfColor.fromInt(0xFF0A1F44);
  static final _muted = PdfColor.fromInt(0xFF64748B);

  static String _pct(double f) => '${(f * 100).round()}%';

  static Future<Uint8List> ecaReport(MonthlyReport r) async {
    final doc = pw.Document();
    final heading = pw.TextStyle(
        fontSize: 12, fontWeight: pw.FontWeight.bold, color: _navy);

    pw.Widget table(List<String> head, List<List<String>> rows) => pw.TableHelper.fromTextArray(
          headers: head,
          data: rows,
          headerStyle: pw.TextStyle(
              fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: _navy),
          cellStyle: const pw.TextStyle(fontSize: 9),
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text('AMERICAN CORNER MOMBASA',
              style: pw.TextStyle(
                  fontSize: 10, color: _muted, fontWeight: pw.FontWeight.bold)),
          pw.Text('Statistical Report: ${DateFormatter.monthYear(r.month)}',
              style: pw.TextStyle(
                  fontSize: 18, color: _navy, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'Prepared for the Bureau of Educational and Cultural Affairs (ECA). '
              'Generated ${DateFormatter.shortDate(DateTime.now())}.',
              style: pw.TextStyle(fontSize: 9, color: _muted)),
          pw.SizedBox(height: 14),
          pw.Text('Headline figures', style: heading),
          pw.SizedBox(height: 4),
          table(['Measure', 'Value'], [
            ['Total visits (footfall)', groupThousands(r.footfall)],
            ['Monthly target', groupThousands(r.target)],
            ['Previous month', groupThousands(r.previousFootfall)],
            ['Average visits per day', r.dailyAverage.toStringAsFixed(1)],
            ['Unique visitors', groupThousands(r.uniqueVisitors)],
            ['New members registered', groupThousands(r.newMembers)],
            ['Female share (of ${r.genderRecorded} recorded)', _pct(r.femaleShare)],
            ['Male share (of ${r.genderRecorded} recorded)', _pct(r.maleShare)],
            ['Youth 18-35 (of ${r.ageRecorded} recorded)', _pct(r.youthShare)],
            ['EducationUSA & Library visits', groupThousands(r.educationUsaVisits)],
          ]),
          pw.SizedBox(height: 14),
          pw.Text('Six-month footfall', style: heading),
          pw.SizedBox(height: 4),
          table(['Month', 'Walk-in visits', 'Program attendees', 'Total'], [
            for (final b in r.trend)
              [b.label, '${b.walkIns}', '${b.programVisits}', '${b.total}'],
          ]),
          pw.SizedBox(height: 14),
          pw.Text('Strategic pillars', style: heading),
          pw.SizedBox(height: 4),
          table(['Pillar', 'Visits', 'Sessions', 'Unique attendees'], [
            for (final l in r.ledger)
              [l.pillar, '${l.visits}', '${l.sessions}', '${l.uniqueAttendees}'],
          ]),
          pw.SizedBox(height: 14),
          pw.Text('Audience residence', style: heading),
          pw.SizedBox(height: 4),
          table(['Area', 'Visitors', 'Share'], [
            for (final s in r.residence) [s.label, '${s.count}', _pct(s.fraction)],
          ]),
          pw.SizedBox(height: 14),
          pw.Text('Age cohorts', style: heading),
          pw.SizedBox(height: 4),
          table(['Cohort', 'Visitors', 'Share'], [
            for (final s in r.cohorts) [s.label, '${s.count}', _pct(s.fraction)],
          ]),
          pw.SizedBox(height: 14),
          pw.Text(
              'Demographic figures cover only visitors whose details were recorded '
              'with consent at registration. This report contains aggregated '
              'statistics only.',
              style: pw.TextStyle(fontSize: 8, color: _muted)),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> attendanceSheet({
    required SessionView session,
    required List<RosterEntry> entries,
  }) async {
    final p = session.program;
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text('Attendance Sheet',
              style: pw.TextStyle(
                  fontSize: 16, color: _navy, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              '${p.name} • ${p.location} • ${DateFormatter.longDate(session.day)}',
              style: pw.TextStyle(fontSize: 10, color: _muted)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Member ID', 'Name', 'Status', 'Check-in', 'Signature'],
            data: [
              for (var i = 0; i < entries.length; i++)
                [
                  '${i + 1}',
                  entries[i].visitor.memberId,
                  entries[i].visitor.fullName,
                  switch (entries[i].status) {
                    RosterStatus.present => 'Present',
                    RosterStatus.walkIn => 'Walk-in',
                    RosterStatus.awaiting => 'Awaiting',
                  },
                  entries[i].visit == null
                      ? ''
                      : DateFormatter.time12(entries[i].visit!.checkInAt),
                  '',
                ],
            ],
            headerStyle: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: _navy),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellHeight: 22,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
          ),
        ],
      ),
    );
    return doc.save();
  }
}
