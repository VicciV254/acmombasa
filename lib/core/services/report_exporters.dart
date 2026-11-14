import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/directory_models.dart';
import '../domain/history_models.dart';
import '../utils/date_format.dart';
import '../utils/phone_utils.dart';

/// CSV exports for the Directory and History pages. Files open in Excel.
abstract final class ReportExporters {
  static Future<File> exportHistory(
    List<HistoryEntry> entries,
    HistoryFilters filters,
  ) {
    final lastDay = filters.end.subtract(const Duration(days: 1));
    final name = 'history-${DateFormatter.isoDate(filters.start)}'
        '_to_${DateFormatter.isoDate(lastDay)}.csv';

    return writeCsv(name, [
      [
        'Date',
        'Check-in',
        'Check-out',
        'Minutes on site',
        'Patron',
        'Member ID',
        'Phone',
        'Category',
        'Purpose',
        'Room / Workstation',
        'Checked in by',
      ],
      for (final e in entries)
        [
          DateFormatter.isoDate(e.visit.checkInAt),
          DateFormatter.time12(e.visit.checkInAt),
          e.visit.checkOutAt == null ? '' : DateFormatter.time12(e.visit.checkOutAt!),
          e.duration == null ? '' : '${e.duration!.inMinutes}',
          e.visitor.fullName,
          e.visitor.memberId,
          e.visitor.phone,
          e.visitor.category,
          e.visit.purpose,
          e.space,
          e.staffName,
        ],
    ]);
  }

  static Future<File> exportDirectory(List<DirectoryRow> rows) {
    final name = 'visitor-directory-${DateFormatter.isoDate(DateTime.now())}.csv';

    return writeCsv(name, [
      [
        'Member ID',
        'Name',
        'Phone',
        'Email',
        'Category',
        'Registered',
        'Total visits',
        'Last visit',
        'Status',
      ],
      for (final r in rows)
        [
          r.visitor.memberId,
          r.visitor.fullName,
          PhoneUtils.format(r.visitor.phone),
          r.visitor.email ?? '',
          r.visitor.category,
          DateFormatter.isoDate(r.visitor.registeredAt),
          '${r.totalVisits}',
          r.lastVisitAt == null ? '' : DateFormatter.isoDate(r.lastVisitAt!),
          switch (r.status) {
            RowStatus.insideNow => 'Inside now',
            RowStatus.checkedOut => 'Checked out',
            RowStatus.active => 'Active',
            RowStatus.inactive => 'Inactive',
          },
        ],
    ]);
  }

  /// Saves raw bytes (PDFs) into the same Exports folder.
  static Future<File> writeBytes(String fileName, List<int> bytes) async {
    final file = await _exportFile(fileName);
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File> _exportFile(String fileName) async {
    final documents = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${documents.path}${Platform.pathSeparator}American Corner Mombasa'
      '${Platform.pathSeparator}Exports',
    );
    await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}$fileName');
  }

  static Future<File> writeCsv(String fileName, List<List<String>> rows) async {
    final file = await _exportFile(fileName);

    // BOM so Excel reads UTF-8 names correctly.
    final csv = '﻿${rows.map((r) => r.map(_escape).join(',')).join('\r\n')}\r\n';
    await file.writeAsString(csv);
    return file;
  }

  static String _escape(String value) {
    // Guard against spreadsheet formula injection from typed names.
    final safe = RegExp(r'^[=+\-@]').hasMatch(value) ? "'$value" : value;
    if (safe.contains(',') || safe.contains('"') || safe.contains('\n')) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }
}
