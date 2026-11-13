import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/models.dart';
import '../utils/date_format.dart';

/// Writes a day's visit log to a CSV file that opens in Excel.
abstract final class VisitExporter {
  static Future<File> exportDay(DateTime day, List<VisitLogEntry> entries) async {
    final documents = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${documents.path}${Platform.pathSeparator}American Corner Mombasa'
      '${Platform.pathSeparator}Exports',
    );
    await dir.create(recursive: true);

    final file = File(
      '${dir.path}${Platform.pathSeparator}visits-${DateFormatter.isoDate(day)}.csv',
    );

    final rows = <List<String>>[
      [
        'Visitor',
        'Member ID',
        'Phone',
        'Category',
        'Purpose',
        'Workstation',
        'Check-in',
        'Check-out',
        'Minutes on site',
      ],
      for (final e in entries.reversed)
        [
          e.visitor.fullName,
          e.visitor.memberId,
          e.visitor.phone,
          e.visitor.category,
          e.visit.purpose,
          e.visit.workstation ?? '',
          DateFormatter.time12(e.visit.checkInAt),
          e.visit.checkOutAt == null ? '' : DateFormatter.time12(e.visit.checkOutAt!),
          e.visit.checkOutAt == null
              ? ''
              : e.visit.checkOutAt!.difference(e.visit.checkInAt).inMinutes.toString(),
        ],
    ];

    // BOM so Excel reads UTF-8 names correctly.
    final csv = '﻿${rows.map((r) => r.map(_escape).join(',')).join('\r\n')}\r\n';
    await file.writeAsString(csv);
    return file;
  }

  /// Reveals the file in Explorer (Windows) or opens its folder elsewhere.
  static Future<void> reveal(File file) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,', file.path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', file.path]);
      } else {
        await Process.run('xdg-open', [file.parent.path]);
      }
    } catch (_) {
      // Nothing useful to do; the path is shown to the user anyway.
    }
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
