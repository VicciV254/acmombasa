import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/supabase_config.dart';
import '../database/live_query.dart';
import '../domain/app_exception.dart';
import '../providers.dart';
import 'sync_service.dart';

enum SyncPhase {
  /// No Supabase URL/key supplied, or the client failed to start.
  notConfigured,

  /// Configured, but nobody has signed in to the cloud account yet.
  signedOut,

  idle,
  syncing,
  error,
}

class SyncState {
  const SyncState({
    required this.phase,
    this.lastSyncedAt,
    this.message,
    this.cloudEmail,
  });

  final SyncPhase phase;
  final DateTime? lastSyncedAt;
  final String? message;
  final String? cloudEmail;

  SyncState copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    String? message,
    String? cloudEmail,
    bool clearMessage = false,
  }) {
    return SyncState(
      phase: phase ?? this.phase,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: clearMessage ? null : (message ?? this.message),
      cloudEmail: cloudEmail ?? this.cloudEmail,
    );
  }
}

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    ref.watch(databaseProvider),
    ref.watch(settingsRepositoryProvider),
  ),
);

/// Rows waiting to be uploaded; the number on the "Sync Queue" button.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final service = ref.watch(syncServiceProvider);
  return watchQuery(db, service.pendingCount);
});

final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);

class SyncController extends Notifier<SyncState> {
  Timer? _timer;
  bool _started = false;

  static const _interval = Duration(minutes: 1);

  SyncService get _service => ref.read(syncServiceProvider);

  @override
  SyncState build() {
    ref.onDispose(() => _timer?.cancel());
    return _baseState();
  }

  SyncState _baseState() {
    if (!SupabaseConfig.isAvailable) {
      return const SyncState(phase: SyncPhase.notConfigured);
    }
    if (!_service.isSignedIn) {
      return const SyncState(phase: SyncPhase.signedOut);
    }
    return SyncState(phase: SyncPhase.idle, cloudEmail: _service.cloudEmail);
  }

  /// Starts background syncing (idempotent). Call once the dashboard is shown.
  void start() {
    if (_started) return;
    _started = true;
    state = _baseState();
    _timer = Timer.periodic(_interval, (_) {
      if (state.phase == SyncPhase.idle || state.phase == SyncPhase.error) {
        syncNow(silent: true);
      }
    });
    if (state.phase == SyncPhase.idle) syncNow(silent: true);
  }

  /// Syncs immediately. Returns a short message describing the outcome.
  Future<String> syncNow({bool silent = false}) async {
    if (state.phase == SyncPhase.syncing) return 'A sync is already running.';
    if (state.phase == SyncPhase.notConfigured) {
      return 'Cloud sync is not configured on this terminal.';
    }
    if (!_service.isSignedIn) {
      state = _baseState();
      return 'Sign in to the cloud account to sync.';
    }

    state = state.copyWith(phase: SyncPhase.syncing, clearMessage: true);
    try {
      final result = await _service.sync();
      state = SyncState(
        phase: SyncPhase.idle,
        lastSyncedAt: DateTime.now(),
        cloudEmail: _service.cloudEmail,
      );
      if (result.pushed == 0 && result.pulled == 0) return 'Everything is up to date.';
      return 'Synced: ${result.pushed} uploaded, ${result.pulled} downloaded.';
    } catch (e) {
      final message = friendlyError(e);
      state = state.copyWith(phase: SyncPhase.error, message: message);
      return message;
    }
  }

  Future<void> signInToCloud(String email, String password) async {
    await _service.signIn(email, password);
    state = _baseState();
    await syncNow();
  }

  Future<void> signOutOfCloud() async {
    await _service.signOut();
    state = _baseState();
  }
}
