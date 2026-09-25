import 'package:equatable/equatable.dart';

enum SyncStatus { idle, running, success, failure }

class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.idle,
    this.message,
    this.alertHits = 0,
    this.quiet = false,
  });

  final SyncStatus status;
  final String? message;
  final int alertHits;
  /// When true, UI should not spam snackbars (auto-sync).
  final bool quiet;

  bool get isRunning => status == SyncStatus.running;

  SyncState copyWith({
    SyncStatus? status,
    String? message,
    int? alertHits,
    bool? quiet,
    bool clearMessage = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      alertHits: alertHits ?? this.alertHits,
      quiet: quiet ?? this.quiet,
    );
  }

  @override
  List<Object?> get props => [status, message, alertHits, quiet];
}
