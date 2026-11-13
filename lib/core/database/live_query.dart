import 'dart:async';

import 'package:drift/drift.dart';

/// Emits the result of [load] immediately, again whenever any table in [db]
/// changes, and (optionally) on a timer for time-dependent results.
///
/// Overlapping refreshes are coalesced so [load] never runs concurrently.
Stream<T> watchQuery<T>(
  GeneratedDatabase db,
  Future<T> Function() load, {
  Duration? every,
}) {
  late final StreamController<T> controller;
  StreamSubscription<Object?>? updates;
  StreamSubscription<Object?>? ticker;
  var running = false;
  var rerun = false;

  Future<void> refresh() async {
    if (running) {
      rerun = true;
      return;
    }
    running = true;
    try {
      do {
        rerun = false;
        final value = await load();
        if (!controller.isClosed) controller.add(value);
      } while (rerun);
    } catch (error, stackTrace) {
      if (!controller.isClosed) controller.addError(error, stackTrace);
    } finally {
      running = false;
    }
  }

  controller = StreamController<T>(
    onListen: () {
      refresh();
      updates = db.tableUpdates().listen((_) => refresh());
      if (every != null) {
        ticker = Stream<void>.periodic(every).listen((_) => refresh());
      }
    },
    onCancel: () async {
      await updates?.cancel();
      await ticker?.cancel();
    },
  );
  return controller.stream;
}
