import 'package:equatable/equatable.dart';

import '../../data/database.dart';

enum WatchlistStatus { loading, ready, error }

class WatchlistState extends Equatable {
  const WatchlistState({
    this.status = WatchlistStatus.loading,
    this.rows = const [],
    this.error,
    this.snackMessage,
  });

  final WatchlistStatus status;
  final List<WatchlistRow> rows;
  final String? error;
  final String? snackMessage;

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<WatchlistRow>? rows,
    String? error,
    String? snackMessage,
    bool clearError = false,
    bool clearSnack = false,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      rows: rows ?? this.rows,
      error: clearError ? null : (error ?? this.error),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }

  @override
  List<Object?> get props => [status, rows, error, snackMessage];
}
