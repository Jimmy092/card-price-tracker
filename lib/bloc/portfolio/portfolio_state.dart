import 'package:equatable/equatable.dart';

import '../../data/database.dart';

enum PortfolioSort { newest, biggestLoser, biggestWinner, name }

enum PortfolioFilter { open, sold, all, foil, thisMonth }

enum PortfolioStatus { loading, ready, error }

class PortfolioState extends Equatable {
  const PortfolioState({
    this.status = PortfolioStatus.loading,
    this.rows = const [],
    this.visible = const [],
    this.sort = PortfolioSort.newest,
    this.filter = PortfolioFilter.open,
    this.error,
    this.snackMessage,
  });

  final PortfolioStatus status;
  final List<TrackedRow> rows;
  final List<TrackedRow> visible;
  final PortfolioSort sort;
  final PortfolioFilter filter;
  final String? error;
  final String? snackMessage;

  PortfolioState copyWith({
    PortfolioStatus? status,
    List<TrackedRow>? rows,
    List<TrackedRow>? visible,
    PortfolioSort? sort,
    PortfolioFilter? filter,
    String? error,
    String? snackMessage,
    bool clearError = false,
    bool clearSnack = false,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      rows: rows ?? this.rows,
      visible: visible ?? this.visible,
      sort: sort ?? this.sort,
      filter: filter ?? this.filter,
      error: clearError ? null : (error ?? this.error),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, rows, visible, sort, filter, error, snackMessage];
}
