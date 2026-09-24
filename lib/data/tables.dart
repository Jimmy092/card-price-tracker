import 'package:drift/drift.dart';

/// Multi-game ready; v1 seeds only `mtg`.
class Games extends Table {
  TextColumn get id => text()(); // e.g. 'mtg'
  TextColumn get name => text()();
  IntColumn get cardTraderGameId => integer().nullable()();
  IntColumn get cardmarketGameId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get name => text()();
  TextColumn get expansion => text().withDefault(const Constant(''))();
  IntColumn get cardmarketProductId => integer().nullable()();
  IntColumn get cardTraderBlueprintId => integer().nullable()();
  IntColumn get cardTraderExpansionId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class WatchlistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer().references(Cards, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get targetBuyCents => integer().nullable()();
  IntColumn get targetSellCents => integer().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Never blend Cardmarket and CardTrader values in one row.
class PriceSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer().references(Cards, #id)();
  TextColumn get source => text()(); // 'cardmarket' | 'cardtrader'
  DateTimeColumn get capturedAt => dateTime()();

  // Cardmarket guide fields (EUR cents). Null for CT-only rows.
  IntColumn get cmTrendCents => integer().nullable()();
  IntColumn get cmLowCents => integer().nullable()();
  IntColumn get cmAvgCents => integer().nullable()();
  IntColumn get cmAvg7Cents => integer().nullable()();
  IntColumn get cmAvg30Cents => integer().nullable()();

  // CardTrader live mins (EUR cents). Null for CM-only rows.
  IntColumn get ctMinDirectCents => integer().nullable()();
  IntColumn get ctMinZeroCents => integer().nullable()();
  IntColumn get ctListingCount => integer().nullable()();
  IntColumn get ctZeroListingCount => integer().nullable()();
}

class SyncRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get source => text()(); // 'cardmarket' | 'cardtrader' | 'all'
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get status => text()(); // running | ok | error
  TextColumn get message => text().withDefault(const Constant(''))();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
}
