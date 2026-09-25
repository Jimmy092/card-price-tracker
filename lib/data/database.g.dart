// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardTraderGameIdMeta = const VerificationMeta(
    'cardTraderGameId',
  );
  @override
  late final GeneratedColumn<int> cardTraderGameId = GeneratedColumn<int>(
    'card_trader_game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardmarketGameIdMeta = const VerificationMeta(
    'cardmarketGameId',
  );
  @override
  late final GeneratedColumn<int> cardmarketGameId = GeneratedColumn<int>(
    'cardmarket_game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cardTraderGameId,
    cardmarketGameId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('card_trader_game_id')) {
      context.handle(
        _cardTraderGameIdMeta,
        cardTraderGameId.isAcceptableOrUnknown(
          data['card_trader_game_id']!,
          _cardTraderGameIdMeta,
        ),
      );
    }
    if (data.containsKey('cardmarket_game_id')) {
      context.handle(
        _cardmarketGameIdMeta,
        cardmarketGameId.isAcceptableOrUnknown(
          data['cardmarket_game_id']!,
          _cardmarketGameIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cardTraderGameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_trader_game_id'],
      ),
      cardmarketGameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cardmarket_game_id'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final String id;
  final String name;
  final int? cardTraderGameId;
  final int? cardmarketGameId;
  const Game({
    required this.id,
    required this.name,
    this.cardTraderGameId,
    this.cardmarketGameId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || cardTraderGameId != null) {
      map['card_trader_game_id'] = Variable<int>(cardTraderGameId);
    }
    if (!nullToAbsent || cardmarketGameId != null) {
      map['cardmarket_game_id'] = Variable<int>(cardmarketGameId);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      name: Value(name),
      cardTraderGameId: cardTraderGameId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardTraderGameId),
      cardmarketGameId: cardmarketGameId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardmarketGameId),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cardTraderGameId: serializer.fromJson<int?>(json['cardTraderGameId']),
      cardmarketGameId: serializer.fromJson<int?>(json['cardmarketGameId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cardTraderGameId': serializer.toJson<int?>(cardTraderGameId),
      'cardmarketGameId': serializer.toJson<int?>(cardmarketGameId),
    };
  }

  Game copyWith({
    String? id,
    String? name,
    Value<int?> cardTraderGameId = const Value.absent(),
    Value<int?> cardmarketGameId = const Value.absent(),
  }) => Game(
    id: id ?? this.id,
    name: name ?? this.name,
    cardTraderGameId: cardTraderGameId.present
        ? cardTraderGameId.value
        : this.cardTraderGameId,
    cardmarketGameId: cardmarketGameId.present
        ? cardmarketGameId.value
        : this.cardmarketGameId,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cardTraderGameId: data.cardTraderGameId.present
          ? data.cardTraderGameId.value
          : this.cardTraderGameId,
      cardmarketGameId: data.cardmarketGameId.present
          ? data.cardmarketGameId.value
          : this.cardmarketGameId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cardTraderGameId: $cardTraderGameId, ')
          ..write('cardmarketGameId: $cardmarketGameId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cardTraderGameId, cardmarketGameId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.name == this.name &&
          other.cardTraderGameId == this.cardTraderGameId &&
          other.cardmarketGameId == this.cardmarketGameId);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> cardTraderGameId;
  final Value<int?> cardmarketGameId;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cardTraderGameId = const Value.absent(),
    this.cardmarketGameId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    required String name,
    this.cardTraderGameId = const Value.absent(),
    this.cardmarketGameId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Game> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? cardTraderGameId,
    Expression<int>? cardmarketGameId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cardTraderGameId != null) 'card_trader_game_id': cardTraderGameId,
      if (cardmarketGameId != null) 'cardmarket_game_id': cardmarketGameId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? cardTraderGameId,
    Value<int?>? cardmarketGameId,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cardTraderGameId: cardTraderGameId ?? this.cardTraderGameId,
      cardmarketGameId: cardmarketGameId ?? this.cardmarketGameId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cardTraderGameId.present) {
      map['card_trader_game_id'] = Variable<int>(cardTraderGameId.value);
    }
    if (cardmarketGameId.present) {
      map['cardmarket_game_id'] = Variable<int>(cardmarketGameId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cardTraderGameId: $cardTraderGameId, ')
          ..write('cardmarketGameId: $cardmarketGameId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expansionMeta = const VerificationMeta(
    'expansion',
  );
  @override
  late final GeneratedColumn<String> expansion = GeneratedColumn<String>(
    'expansion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardmarketProductIdMeta =
      const VerificationMeta('cardmarketProductId');
  @override
  late final GeneratedColumn<int> cardmarketProductId = GeneratedColumn<int>(
    'cardmarket_product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardTraderBlueprintIdMeta =
      const VerificationMeta('cardTraderBlueprintId');
  @override
  late final GeneratedColumn<int> cardTraderBlueprintId = GeneratedColumn<int>(
    'card_trader_blueprint_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardTraderExpansionIdMeta =
      const VerificationMeta('cardTraderExpansionId');
  @override
  late final GeneratedColumn<int> cardTraderExpansionId = GeneratedColumn<int>(
    'card_trader_expansion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    name,
    expansion,
    imageUrl,
    cardmarketProductId,
    cardTraderBlueprintId,
    cardTraderExpansionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('expansion')) {
      context.handle(
        _expansionMeta,
        expansion.isAcceptableOrUnknown(data['expansion']!, _expansionMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('cardmarket_product_id')) {
      context.handle(
        _cardmarketProductIdMeta,
        cardmarketProductId.isAcceptableOrUnknown(
          data['cardmarket_product_id']!,
          _cardmarketProductIdMeta,
        ),
      );
    }
    if (data.containsKey('card_trader_blueprint_id')) {
      context.handle(
        _cardTraderBlueprintIdMeta,
        cardTraderBlueprintId.isAcceptableOrUnknown(
          data['card_trader_blueprint_id']!,
          _cardTraderBlueprintIdMeta,
        ),
      );
    }
    if (data.containsKey('card_trader_expansion_id')) {
      context.handle(
        _cardTraderExpansionIdMeta,
        cardTraderExpansionId.isAcceptableOrUnknown(
          data['card_trader_expansion_id']!,
          _cardTraderExpansionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      expansion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expansion'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      cardmarketProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cardmarket_product_id'],
      ),
      cardTraderBlueprintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_trader_blueprint_id'],
      ),
      cardTraderExpansionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_trader_expansion_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final int id;
  final String gameId;
  final String name;
  final String expansion;
  final String? imageUrl;
  final int? cardmarketProductId;
  final int? cardTraderBlueprintId;
  final int? cardTraderExpansionId;
  final DateTime createdAt;
  const Card({
    required this.id,
    required this.gameId,
    required this.name,
    required this.expansion,
    this.imageUrl,
    this.cardmarketProductId,
    this.cardTraderBlueprintId,
    this.cardTraderExpansionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<String>(gameId);
    map['name'] = Variable<String>(name);
    map['expansion'] = Variable<String>(expansion);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || cardmarketProductId != null) {
      map['cardmarket_product_id'] = Variable<int>(cardmarketProductId);
    }
    if (!nullToAbsent || cardTraderBlueprintId != null) {
      map['card_trader_blueprint_id'] = Variable<int>(cardTraderBlueprintId);
    }
    if (!nullToAbsent || cardTraderExpansionId != null) {
      map['card_trader_expansion_id'] = Variable<int>(cardTraderExpansionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      name: Value(name),
      expansion: Value(expansion),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      cardmarketProductId: cardmarketProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardmarketProductId),
      cardTraderBlueprintId: cardTraderBlueprintId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardTraderBlueprintId),
      cardTraderExpansionId: cardTraderExpansionId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardTraderExpansionId),
      createdAt: Value(createdAt),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      name: serializer.fromJson<String>(json['name']),
      expansion: serializer.fromJson<String>(json['expansion']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      cardmarketProductId: serializer.fromJson<int?>(
        json['cardmarketProductId'],
      ),
      cardTraderBlueprintId: serializer.fromJson<int?>(
        json['cardTraderBlueprintId'],
      ),
      cardTraderExpansionId: serializer.fromJson<int?>(
        json['cardTraderExpansionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<String>(gameId),
      'name': serializer.toJson<String>(name),
      'expansion': serializer.toJson<String>(expansion),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'cardmarketProductId': serializer.toJson<int?>(cardmarketProductId),
      'cardTraderBlueprintId': serializer.toJson<int?>(cardTraderBlueprintId),
      'cardTraderExpansionId': serializer.toJson<int?>(cardTraderExpansionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Card copyWith({
    int? id,
    String? gameId,
    String? name,
    String? expansion,
    Value<String?> imageUrl = const Value.absent(),
    Value<int?> cardmarketProductId = const Value.absent(),
    Value<int?> cardTraderBlueprintId = const Value.absent(),
    Value<int?> cardTraderExpansionId = const Value.absent(),
    DateTime? createdAt,
  }) => Card(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    name: name ?? this.name,
    expansion: expansion ?? this.expansion,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    cardmarketProductId: cardmarketProductId.present
        ? cardmarketProductId.value
        : this.cardmarketProductId,
    cardTraderBlueprintId: cardTraderBlueprintId.present
        ? cardTraderBlueprintId.value
        : this.cardTraderBlueprintId,
    cardTraderExpansionId: cardTraderExpansionId.present
        ? cardTraderExpansionId.value
        : this.cardTraderExpansionId,
    createdAt: createdAt ?? this.createdAt,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      name: data.name.present ? data.name.value : this.name,
      expansion: data.expansion.present ? data.expansion.value : this.expansion,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      cardmarketProductId: data.cardmarketProductId.present
          ? data.cardmarketProductId.value
          : this.cardmarketProductId,
      cardTraderBlueprintId: data.cardTraderBlueprintId.present
          ? data.cardTraderBlueprintId.value
          : this.cardTraderBlueprintId,
      cardTraderExpansionId: data.cardTraderExpansionId.present
          ? data.cardTraderExpansionId.value
          : this.cardTraderExpansionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('name: $name, ')
          ..write('expansion: $expansion, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('cardmarketProductId: $cardmarketProductId, ')
          ..write('cardTraderBlueprintId: $cardTraderBlueprintId, ')
          ..write('cardTraderExpansionId: $cardTraderExpansionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    name,
    expansion,
    imageUrl,
    cardmarketProductId,
    cardTraderBlueprintId,
    cardTraderExpansionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.name == this.name &&
          other.expansion == this.expansion &&
          other.imageUrl == this.imageUrl &&
          other.cardmarketProductId == this.cardmarketProductId &&
          other.cardTraderBlueprintId == this.cardTraderBlueprintId &&
          other.cardTraderExpansionId == this.cardTraderExpansionId &&
          other.createdAt == this.createdAt);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<int> id;
  final Value<String> gameId;
  final Value<String> name;
  final Value<String> expansion;
  final Value<String?> imageUrl;
  final Value<int?> cardmarketProductId;
  final Value<int?> cardTraderBlueprintId;
  final Value<int?> cardTraderExpansionId;
  final Value<DateTime> createdAt;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.name = const Value.absent(),
    this.expansion = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.cardmarketProductId = const Value.absent(),
    this.cardTraderBlueprintId = const Value.absent(),
    this.cardTraderExpansionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    required String gameId,
    required String name,
    this.expansion = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.cardmarketProductId = const Value.absent(),
    this.cardTraderBlueprintId = const Value.absent(),
    this.cardTraderExpansionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : gameId = Value(gameId),
       name = Value(name);
  static Insertable<Card> custom({
    Expression<int>? id,
    Expression<String>? gameId,
    Expression<String>? name,
    Expression<String>? expansion,
    Expression<String>? imageUrl,
    Expression<int>? cardmarketProductId,
    Expression<int>? cardTraderBlueprintId,
    Expression<int>? cardTraderExpansionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (name != null) 'name': name,
      if (expansion != null) 'expansion': expansion,
      if (imageUrl != null) 'image_url': imageUrl,
      if (cardmarketProductId != null)
        'cardmarket_product_id': cardmarketProductId,
      if (cardTraderBlueprintId != null)
        'card_trader_blueprint_id': cardTraderBlueprintId,
      if (cardTraderExpansionId != null)
        'card_trader_expansion_id': cardTraderExpansionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CardsCompanion copyWith({
    Value<int>? id,
    Value<String>? gameId,
    Value<String>? name,
    Value<String>? expansion,
    Value<String?>? imageUrl,
    Value<int?>? cardmarketProductId,
    Value<int?>? cardTraderBlueprintId,
    Value<int?>? cardTraderExpansionId,
    Value<DateTime>? createdAt,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      name: name ?? this.name,
      expansion: expansion ?? this.expansion,
      imageUrl: imageUrl ?? this.imageUrl,
      cardmarketProductId: cardmarketProductId ?? this.cardmarketProductId,
      cardTraderBlueprintId:
          cardTraderBlueprintId ?? this.cardTraderBlueprintId,
      cardTraderExpansionId:
          cardTraderExpansionId ?? this.cardTraderExpansionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (expansion.present) {
      map['expansion'] = Variable<String>(expansion.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (cardmarketProductId.present) {
      map['cardmarket_product_id'] = Variable<int>(cardmarketProductId.value);
    }
    if (cardTraderBlueprintId.present) {
      map['card_trader_blueprint_id'] = Variable<int>(
        cardTraderBlueprintId.value,
      );
    }
    if (cardTraderExpansionId.present) {
      map['card_trader_expansion_id'] = Variable<int>(
        cardTraderExpansionId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('name: $name, ')
          ..write('expansion: $expansion, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('cardmarketProductId: $cardmarketProductId, ')
          ..write('cardTraderBlueprintId: $cardTraderBlueprintId, ')
          ..write('cardTraderExpansionId: $cardTraderExpansionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WatchlistItemsTable extends WatchlistItems
    with TableInfo<$WatchlistItemsTable, WatchlistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _foilMeta = const VerificationMeta('foil');
  @override
  late final GeneratedColumn<bool> foil = GeneratedColumn<bool>(
    'foil',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("foil" IN (0, 1))',
    ),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minConditionMeta = const VerificationMeta(
    'minCondition',
  );
  @override
  late final GeneratedColumn<String> minCondition = GeneratedColumn<String>(
    'min_condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellerNameMeta = const VerificationMeta(
    'sellerName',
  );
  @override
  late final GeneratedColumn<String> sellerName = GeneratedColumn<String>(
    'seller_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minSellerQuantityMeta = const VerificationMeta(
    'minSellerQuantity',
  );
  @override
  late final GeneratedColumn<int> minSellerQuantity = GeneratedColumn<int>(
    'min_seller_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetBuyCentsMeta = const VerificationMeta(
    'targetBuyCents',
  );
  @override
  late final GeneratedColumn<int> targetBuyCents = GeneratedColumn<int>(
    'target_buy_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSellCentsMeta = const VerificationMeta(
    'targetSellCents',
  );
  @override
  late final GeneratedColumn<int> targetSellCents = GeneratedColumn<int>(
    'target_sell_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    quantity,
    notes,
    foil,
    language,
    minCondition,
    sellerName,
    minSellerQuantity,
    targetBuyCents,
    targetSellCents,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchlistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('foil')) {
      context.handle(
        _foilMeta,
        foil.isAcceptableOrUnknown(data['foil']!, _foilMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('min_condition')) {
      context.handle(
        _minConditionMeta,
        minCondition.isAcceptableOrUnknown(
          data['min_condition']!,
          _minConditionMeta,
        ),
      );
    }
    if (data.containsKey('seller_name')) {
      context.handle(
        _sellerNameMeta,
        sellerName.isAcceptableOrUnknown(data['seller_name']!, _sellerNameMeta),
      );
    }
    if (data.containsKey('min_seller_quantity')) {
      context.handle(
        _minSellerQuantityMeta,
        minSellerQuantity.isAcceptableOrUnknown(
          data['min_seller_quantity']!,
          _minSellerQuantityMeta,
        ),
      );
    }
    if (data.containsKey('target_buy_cents')) {
      context.handle(
        _targetBuyCentsMeta,
        targetBuyCents.isAcceptableOrUnknown(
          data['target_buy_cents']!,
          _targetBuyCentsMeta,
        ),
      );
    }
    if (data.containsKey('target_sell_cents')) {
      context.handle(
        _targetSellCentsMeta,
        targetSellCents.isAcceptableOrUnknown(
          data['target_sell_cents']!,
          _targetSellCentsMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchlistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      foil: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}foil'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      minCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}min_condition'],
      ),
      sellerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seller_name'],
      ),
      minSellerQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_seller_quantity'],
      ),
      targetBuyCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_buy_cents'],
      ),
      targetSellCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sell_cents'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $WatchlistItemsTable createAlias(String alias) {
    return $WatchlistItemsTable(attachedDatabase, alias);
  }
}

class WatchlistItem extends DataClass implements Insertable<WatchlistItem> {
  final int id;
  final int cardId;
  final int quantity;
  final String notes;

  /// null = any; true = foil only; false = non-foil only (CardTrader filter).
  final bool? foil;

  /// CardTrader language code (e.g. `en`), null = any.
  final String? language;

  /// Minimum condition label (e.g. `Near Mint`), null = any.
  final String? minCondition;

  /// Seller username substring filter (CardTrader), null/empty = any.
  final String? sellerName;

  /// Minimum copies a listing must have, null = any.
  final int? minSellerQuantity;
  final int? targetBuyCents;
  final int? targetSellCents;
  final DateTime addedAt;
  const WatchlistItem({
    required this.id,
    required this.cardId,
    required this.quantity,
    required this.notes,
    this.foil,
    this.language,
    this.minCondition,
    this.sellerName,
    this.minSellerQuantity,
    this.targetBuyCents,
    this.targetSellCents,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['quantity'] = Variable<int>(quantity);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || foil != null) {
      map['foil'] = Variable<bool>(foil);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || minCondition != null) {
      map['min_condition'] = Variable<String>(minCondition);
    }
    if (!nullToAbsent || sellerName != null) {
      map['seller_name'] = Variable<String>(sellerName);
    }
    if (!nullToAbsent || minSellerQuantity != null) {
      map['min_seller_quantity'] = Variable<int>(minSellerQuantity);
    }
    if (!nullToAbsent || targetBuyCents != null) {
      map['target_buy_cents'] = Variable<int>(targetBuyCents);
    }
    if (!nullToAbsent || targetSellCents != null) {
      map['target_sell_cents'] = Variable<int>(targetSellCents);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  WatchlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WatchlistItemsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      quantity: Value(quantity),
      notes: Value(notes),
      foil: foil == null && nullToAbsent ? const Value.absent() : Value(foil),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      minCondition: minCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(minCondition),
      sellerName: sellerName == null && nullToAbsent
          ? const Value.absent()
          : Value(sellerName),
      minSellerQuantity: minSellerQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(minSellerQuantity),
      targetBuyCents: targetBuyCents == null && nullToAbsent
          ? const Value.absent()
          : Value(targetBuyCents),
      targetSellCents: targetSellCents == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSellCents),
      addedAt: Value(addedAt),
    );
  }

  factory WatchlistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistItem(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      notes: serializer.fromJson<String>(json['notes']),
      foil: serializer.fromJson<bool?>(json['foil']),
      language: serializer.fromJson<String?>(json['language']),
      minCondition: serializer.fromJson<String?>(json['minCondition']),
      sellerName: serializer.fromJson<String?>(json['sellerName']),
      minSellerQuantity: serializer.fromJson<int?>(json['minSellerQuantity']),
      targetBuyCents: serializer.fromJson<int?>(json['targetBuyCents']),
      targetSellCents: serializer.fromJson<int?>(json['targetSellCents']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'quantity': serializer.toJson<int>(quantity),
      'notes': serializer.toJson<String>(notes),
      'foil': serializer.toJson<bool?>(foil),
      'language': serializer.toJson<String?>(language),
      'minCondition': serializer.toJson<String?>(minCondition),
      'sellerName': serializer.toJson<String?>(sellerName),
      'minSellerQuantity': serializer.toJson<int?>(minSellerQuantity),
      'targetBuyCents': serializer.toJson<int?>(targetBuyCents),
      'targetSellCents': serializer.toJson<int?>(targetSellCents),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  WatchlistItem copyWith({
    int? id,
    int? cardId,
    int? quantity,
    String? notes,
    Value<bool?> foil = const Value.absent(),
    Value<String?> language = const Value.absent(),
    Value<String?> minCondition = const Value.absent(),
    Value<String?> sellerName = const Value.absent(),
    Value<int?> minSellerQuantity = const Value.absent(),
    Value<int?> targetBuyCents = const Value.absent(),
    Value<int?> targetSellCents = const Value.absent(),
    DateTime? addedAt,
  }) => WatchlistItem(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    quantity: quantity ?? this.quantity,
    notes: notes ?? this.notes,
    foil: foil.present ? foil.value : this.foil,
    language: language.present ? language.value : this.language,
    minCondition: minCondition.present ? minCondition.value : this.minCondition,
    sellerName: sellerName.present ? sellerName.value : this.sellerName,
    minSellerQuantity: minSellerQuantity.present
        ? minSellerQuantity.value
        : this.minSellerQuantity,
    targetBuyCents: targetBuyCents.present
        ? targetBuyCents.value
        : this.targetBuyCents,
    targetSellCents: targetSellCents.present
        ? targetSellCents.value
        : this.targetSellCents,
    addedAt: addedAt ?? this.addedAt,
  );
  WatchlistItem copyWithCompanion(WatchlistItemsCompanion data) {
    return WatchlistItem(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      notes: data.notes.present ? data.notes.value : this.notes,
      foil: data.foil.present ? data.foil.value : this.foil,
      language: data.language.present ? data.language.value : this.language,
      minCondition: data.minCondition.present
          ? data.minCondition.value
          : this.minCondition,
      sellerName: data.sellerName.present
          ? data.sellerName.value
          : this.sellerName,
      minSellerQuantity: data.minSellerQuantity.present
          ? data.minSellerQuantity.value
          : this.minSellerQuantity,
      targetBuyCents: data.targetBuyCents.present
          ? data.targetBuyCents.value
          : this.targetBuyCents,
      targetSellCents: data.targetSellCents.present
          ? data.targetSellCents.value
          : this.targetSellCents,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItem(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('foil: $foil, ')
          ..write('language: $language, ')
          ..write('minCondition: $minCondition, ')
          ..write('sellerName: $sellerName, ')
          ..write('minSellerQuantity: $minSellerQuantity, ')
          ..write('targetBuyCents: $targetBuyCents, ')
          ..write('targetSellCents: $targetSellCents, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    quantity,
    notes,
    foil,
    language,
    minCondition,
    sellerName,
    minSellerQuantity,
    targetBuyCents,
    targetSellCents,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistItem &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.quantity == this.quantity &&
          other.notes == this.notes &&
          other.foil == this.foil &&
          other.language == this.language &&
          other.minCondition == this.minCondition &&
          other.sellerName == this.sellerName &&
          other.minSellerQuantity == this.minSellerQuantity &&
          other.targetBuyCents == this.targetBuyCents &&
          other.targetSellCents == this.targetSellCents &&
          other.addedAt == this.addedAt);
}

class WatchlistItemsCompanion extends UpdateCompanion<WatchlistItem> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<int> quantity;
  final Value<String> notes;
  final Value<bool?> foil;
  final Value<String?> language;
  final Value<String?> minCondition;
  final Value<String?> sellerName;
  final Value<int?> minSellerQuantity;
  final Value<int?> targetBuyCents;
  final Value<int?> targetSellCents;
  final Value<DateTime> addedAt;
  const WatchlistItemsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.foil = const Value.absent(),
    this.language = const Value.absent(),
    this.minCondition = const Value.absent(),
    this.sellerName = const Value.absent(),
    this.minSellerQuantity = const Value.absent(),
    this.targetBuyCents = const Value.absent(),
    this.targetSellCents = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  WatchlistItemsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.foil = const Value.absent(),
    this.language = const Value.absent(),
    this.minCondition = const Value.absent(),
    this.sellerName = const Value.absent(),
    this.minSellerQuantity = const Value.absent(),
    this.targetBuyCents = const Value.absent(),
    this.targetSellCents = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : cardId = Value(cardId);
  static Insertable<WatchlistItem> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<int>? quantity,
    Expression<String>? notes,
    Expression<bool>? foil,
    Expression<String>? language,
    Expression<String>? minCondition,
    Expression<String>? sellerName,
    Expression<int>? minSellerQuantity,
    Expression<int>? targetBuyCents,
    Expression<int>? targetSellCents,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (foil != null) 'foil': foil,
      if (language != null) 'language': language,
      if (minCondition != null) 'min_condition': minCondition,
      if (sellerName != null) 'seller_name': sellerName,
      if (minSellerQuantity != null) 'min_seller_quantity': minSellerQuantity,
      if (targetBuyCents != null) 'target_buy_cents': targetBuyCents,
      if (targetSellCents != null) 'target_sell_cents': targetSellCents,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  WatchlistItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<int>? quantity,
    Value<String>? notes,
    Value<bool?>? foil,
    Value<String?>? language,
    Value<String?>? minCondition,
    Value<String?>? sellerName,
    Value<int?>? minSellerQuantity,
    Value<int?>? targetBuyCents,
    Value<int?>? targetSellCents,
    Value<DateTime>? addedAt,
  }) {
    return WatchlistItemsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      foil: foil ?? this.foil,
      language: language ?? this.language,
      minCondition: minCondition ?? this.minCondition,
      sellerName: sellerName ?? this.sellerName,
      minSellerQuantity: minSellerQuantity ?? this.minSellerQuantity,
      targetBuyCents: targetBuyCents ?? this.targetBuyCents,
      targetSellCents: targetSellCents ?? this.targetSellCents,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (foil.present) {
      map['foil'] = Variable<bool>(foil.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (minCondition.present) {
      map['min_condition'] = Variable<String>(minCondition.value);
    }
    if (sellerName.present) {
      map['seller_name'] = Variable<String>(sellerName.value);
    }
    if (minSellerQuantity.present) {
      map['min_seller_quantity'] = Variable<int>(minSellerQuantity.value);
    }
    if (targetBuyCents.present) {
      map['target_buy_cents'] = Variable<int>(targetBuyCents.value);
    }
    if (targetSellCents.present) {
      map['target_sell_cents'] = Variable<int>(targetSellCents.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('foil: $foil, ')
          ..write('language: $language, ')
          ..write('minCondition: $minCondition, ')
          ..write('sellerName: $sellerName, ')
          ..write('minSellerQuantity: $minSellerQuantity, ')
          ..write('targetBuyCents: $targetBuyCents, ')
          ..write('targetSellCents: $targetSellCents, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $TrackedItemsTable extends TrackedItems
    with TableInfo<$TrackedItemsTable, TrackedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _paidCentsMeta = const VerificationMeta(
    'paidCents',
  );
  @override
  late final GeneratedColumn<int> paidCents = GeneratedColumn<int>(
    'paid_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foilMeta = const VerificationMeta('foil');
  @override
  late final GeneratedColumn<bool> foil = GeneratedColumn<bool>(
    'foil',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("foil" IN (0, 1))',
    ),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastCmTrendCentsMeta = const VerificationMeta(
    'lastCmTrendCents',
  );
  @override
  late final GeneratedColumn<int> lastCmTrendCents = GeneratedColumn<int>(
    'last_cm_trend_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCmAvg7CentsMeta = const VerificationMeta(
    'lastCmAvg7Cents',
  );
  @override
  late final GeneratedColumn<int> lastCmAvg7Cents = GeneratedColumn<int>(
    'last_cm_avg7_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCmAvg30CentsMeta = const VerificationMeta(
    'lastCmAvg30Cents',
  );
  @override
  late final GeneratedColumn<int> lastCmAvg30Cents = GeneratedColumn<int>(
    'last_cm_avg30_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCtBestCentsMeta = const VerificationMeta(
    'lastCtBestCents',
  );
  @override
  late final GeneratedColumn<int> lastCtBestCents = GeneratedColumn<int>(
    'last_ct_best_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCtZeroCentsMeta = const VerificationMeta(
    'lastCtZeroCents',
  );
  @override
  late final GeneratedColumn<int> lastCtZeroCents = GeneratedColumn<int>(
    'last_ct_zero_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCtDirectCentsMeta = const VerificationMeta(
    'lastCtDirectCents',
  );
  @override
  late final GeneratedColumn<int> lastCtDirectCents = GeneratedColumn<int>(
    'last_ct_direct_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valuedAtMeta = const VerificationMeta(
    'valuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> valuedAt = GeneratedColumn<DateTime>(
    'valued_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    quantity,
    paidCents,
    purchasedAt,
    foil,
    language,
    condition,
    notes,
    lastCmTrendCents,
    lastCmAvg7Cents,
    lastCmAvg30Cents,
    lastCtBestCents,
    lastCtZeroCents,
    lastCtDirectCents,
    valuedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('paid_cents')) {
      context.handle(
        _paidCentsMeta,
        paidCents.isAcceptableOrUnknown(data['paid_cents']!, _paidCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_paidCentsMeta);
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasedAtMeta);
    }
    if (data.containsKey('foil')) {
      context.handle(
        _foilMeta,
        foil.isAcceptableOrUnknown(data['foil']!, _foilMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('last_cm_trend_cents')) {
      context.handle(
        _lastCmTrendCentsMeta,
        lastCmTrendCents.isAcceptableOrUnknown(
          data['last_cm_trend_cents']!,
          _lastCmTrendCentsMeta,
        ),
      );
    }
    if (data.containsKey('last_cm_avg7_cents')) {
      context.handle(
        _lastCmAvg7CentsMeta,
        lastCmAvg7Cents.isAcceptableOrUnknown(
          data['last_cm_avg7_cents']!,
          _lastCmAvg7CentsMeta,
        ),
      );
    }
    if (data.containsKey('last_cm_avg30_cents')) {
      context.handle(
        _lastCmAvg30CentsMeta,
        lastCmAvg30Cents.isAcceptableOrUnknown(
          data['last_cm_avg30_cents']!,
          _lastCmAvg30CentsMeta,
        ),
      );
    }
    if (data.containsKey('last_ct_best_cents')) {
      context.handle(
        _lastCtBestCentsMeta,
        lastCtBestCents.isAcceptableOrUnknown(
          data['last_ct_best_cents']!,
          _lastCtBestCentsMeta,
        ),
      );
    }
    if (data.containsKey('last_ct_zero_cents')) {
      context.handle(
        _lastCtZeroCentsMeta,
        lastCtZeroCents.isAcceptableOrUnknown(
          data['last_ct_zero_cents']!,
          _lastCtZeroCentsMeta,
        ),
      );
    }
    if (data.containsKey('last_ct_direct_cents')) {
      context.handle(
        _lastCtDirectCentsMeta,
        lastCtDirectCents.isAcceptableOrUnknown(
          data['last_ct_direct_cents']!,
          _lastCtDirectCentsMeta,
        ),
      );
    }
    if (data.containsKey('valued_at')) {
      context.handle(
        _valuedAtMeta,
        valuedAt.isAcceptableOrUnknown(data['valued_at']!, _valuedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      paidCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_cents'],
      )!,
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      )!,
      foil: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}foil'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      lastCmTrendCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_cm_trend_cents'],
      ),
      lastCmAvg7Cents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_cm_avg7_cents'],
      ),
      lastCmAvg30Cents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_cm_avg30_cents'],
      ),
      lastCtBestCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ct_best_cents'],
      ),
      lastCtZeroCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ct_zero_cents'],
      ),
      lastCtDirectCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ct_direct_cents'],
      ),
      valuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}valued_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TrackedItemsTable createAlias(String alias) {
    return $TrackedItemsTable(attachedDatabase, alias);
  }
}

class TrackedItem extends DataClass implements Insertable<TrackedItem> {
  final int id;
  final int cardId;
  final int quantity;

  /// What the user paid per copy (EUR cents).
  final int paidCents;
  final DateTime purchasedAt;

  /// Exact owned finish: true foil, false non-foil, null unknown.
  final bool? foil;

  /// Owned language code (e.g. `en`), null = unspecified.
  final String? language;

  /// Owned condition label (e.g. `Near Mint`), null = unspecified.
  final String? condition;
  final String notes;

  /// Last foil-aware CM trend (EUR cents) for this lot.
  final int? lastCmTrendCents;
  final int? lastCmAvg7Cents;
  final int? lastCmAvg30Cents;

  /// Last foil/language/condition-aware CT best (Zero else Direct).
  final int? lastCtBestCents;
  final int? lastCtZeroCents;
  final int? lastCtDirectCents;
  final DateTime? valuedAt;
  final DateTime createdAt;
  const TrackedItem({
    required this.id,
    required this.cardId,
    required this.quantity,
    required this.paidCents,
    required this.purchasedAt,
    this.foil,
    this.language,
    this.condition,
    required this.notes,
    this.lastCmTrendCents,
    this.lastCmAvg7Cents,
    this.lastCmAvg30Cents,
    this.lastCtBestCents,
    this.lastCtZeroCents,
    this.lastCtDirectCents,
    this.valuedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['quantity'] = Variable<int>(quantity);
    map['paid_cents'] = Variable<int>(paidCents);
    map['purchased_at'] = Variable<DateTime>(purchasedAt);
    if (!nullToAbsent || foil != null) {
      map['foil'] = Variable<bool>(foil);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || lastCmTrendCents != null) {
      map['last_cm_trend_cents'] = Variable<int>(lastCmTrendCents);
    }
    if (!nullToAbsent || lastCmAvg7Cents != null) {
      map['last_cm_avg7_cents'] = Variable<int>(lastCmAvg7Cents);
    }
    if (!nullToAbsent || lastCmAvg30Cents != null) {
      map['last_cm_avg30_cents'] = Variable<int>(lastCmAvg30Cents);
    }
    if (!nullToAbsent || lastCtBestCents != null) {
      map['last_ct_best_cents'] = Variable<int>(lastCtBestCents);
    }
    if (!nullToAbsent || lastCtZeroCents != null) {
      map['last_ct_zero_cents'] = Variable<int>(lastCtZeroCents);
    }
    if (!nullToAbsent || lastCtDirectCents != null) {
      map['last_ct_direct_cents'] = Variable<int>(lastCtDirectCents);
    }
    if (!nullToAbsent || valuedAt != null) {
      map['valued_at'] = Variable<DateTime>(valuedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TrackedItemsCompanion toCompanion(bool nullToAbsent) {
    return TrackedItemsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      quantity: Value(quantity),
      paidCents: Value(paidCents),
      purchasedAt: Value(purchasedAt),
      foil: foil == null && nullToAbsent ? const Value.absent() : Value(foil),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      notes: Value(notes),
      lastCmTrendCents: lastCmTrendCents == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCmTrendCents),
      lastCmAvg7Cents: lastCmAvg7Cents == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCmAvg7Cents),
      lastCmAvg30Cents: lastCmAvg30Cents == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCmAvg30Cents),
      lastCtBestCents: lastCtBestCents == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCtBestCents),
      lastCtZeroCents: lastCtZeroCents == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCtZeroCents),
      lastCtDirectCents: lastCtDirectCents == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCtDirectCents),
      valuedAt: valuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(valuedAt),
      createdAt: Value(createdAt),
    );
  }

  factory TrackedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedItem(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      paidCents: serializer.fromJson<int>(json['paidCents']),
      purchasedAt: serializer.fromJson<DateTime>(json['purchasedAt']),
      foil: serializer.fromJson<bool?>(json['foil']),
      language: serializer.fromJson<String?>(json['language']),
      condition: serializer.fromJson<String?>(json['condition']),
      notes: serializer.fromJson<String>(json['notes']),
      lastCmTrendCents: serializer.fromJson<int?>(json['lastCmTrendCents']),
      lastCmAvg7Cents: serializer.fromJson<int?>(json['lastCmAvg7Cents']),
      lastCmAvg30Cents: serializer.fromJson<int?>(json['lastCmAvg30Cents']),
      lastCtBestCents: serializer.fromJson<int?>(json['lastCtBestCents']),
      lastCtZeroCents: serializer.fromJson<int?>(json['lastCtZeroCents']),
      lastCtDirectCents: serializer.fromJson<int?>(json['lastCtDirectCents']),
      valuedAt: serializer.fromJson<DateTime?>(json['valuedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'quantity': serializer.toJson<int>(quantity),
      'paidCents': serializer.toJson<int>(paidCents),
      'purchasedAt': serializer.toJson<DateTime>(purchasedAt),
      'foil': serializer.toJson<bool?>(foil),
      'language': serializer.toJson<String?>(language),
      'condition': serializer.toJson<String?>(condition),
      'notes': serializer.toJson<String>(notes),
      'lastCmTrendCents': serializer.toJson<int?>(lastCmTrendCents),
      'lastCmAvg7Cents': serializer.toJson<int?>(lastCmAvg7Cents),
      'lastCmAvg30Cents': serializer.toJson<int?>(lastCmAvg30Cents),
      'lastCtBestCents': serializer.toJson<int?>(lastCtBestCents),
      'lastCtZeroCents': serializer.toJson<int?>(lastCtZeroCents),
      'lastCtDirectCents': serializer.toJson<int?>(lastCtDirectCents),
      'valuedAt': serializer.toJson<DateTime?>(valuedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TrackedItem copyWith({
    int? id,
    int? cardId,
    int? quantity,
    int? paidCents,
    DateTime? purchasedAt,
    Value<bool?> foil = const Value.absent(),
    Value<String?> language = const Value.absent(),
    Value<String?> condition = const Value.absent(),
    String? notes,
    Value<int?> lastCmTrendCents = const Value.absent(),
    Value<int?> lastCmAvg7Cents = const Value.absent(),
    Value<int?> lastCmAvg30Cents = const Value.absent(),
    Value<int?> lastCtBestCents = const Value.absent(),
    Value<int?> lastCtZeroCents = const Value.absent(),
    Value<int?> lastCtDirectCents = const Value.absent(),
    Value<DateTime?> valuedAt = const Value.absent(),
    DateTime? createdAt,
  }) => TrackedItem(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    quantity: quantity ?? this.quantity,
    paidCents: paidCents ?? this.paidCents,
    purchasedAt: purchasedAt ?? this.purchasedAt,
    foil: foil.present ? foil.value : this.foil,
    language: language.present ? language.value : this.language,
    condition: condition.present ? condition.value : this.condition,
    notes: notes ?? this.notes,
    lastCmTrendCents: lastCmTrendCents.present
        ? lastCmTrendCents.value
        : this.lastCmTrendCents,
    lastCmAvg7Cents: lastCmAvg7Cents.present
        ? lastCmAvg7Cents.value
        : this.lastCmAvg7Cents,
    lastCmAvg30Cents: lastCmAvg30Cents.present
        ? lastCmAvg30Cents.value
        : this.lastCmAvg30Cents,
    lastCtBestCents: lastCtBestCents.present
        ? lastCtBestCents.value
        : this.lastCtBestCents,
    lastCtZeroCents: lastCtZeroCents.present
        ? lastCtZeroCents.value
        : this.lastCtZeroCents,
    lastCtDirectCents: lastCtDirectCents.present
        ? lastCtDirectCents.value
        : this.lastCtDirectCents,
    valuedAt: valuedAt.present ? valuedAt.value : this.valuedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  TrackedItem copyWithCompanion(TrackedItemsCompanion data) {
    return TrackedItem(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      paidCents: data.paidCents.present ? data.paidCents.value : this.paidCents,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      foil: data.foil.present ? data.foil.value : this.foil,
      language: data.language.present ? data.language.value : this.language,
      condition: data.condition.present ? data.condition.value : this.condition,
      notes: data.notes.present ? data.notes.value : this.notes,
      lastCmTrendCents: data.lastCmTrendCents.present
          ? data.lastCmTrendCents.value
          : this.lastCmTrendCents,
      lastCmAvg7Cents: data.lastCmAvg7Cents.present
          ? data.lastCmAvg7Cents.value
          : this.lastCmAvg7Cents,
      lastCmAvg30Cents: data.lastCmAvg30Cents.present
          ? data.lastCmAvg30Cents.value
          : this.lastCmAvg30Cents,
      lastCtBestCents: data.lastCtBestCents.present
          ? data.lastCtBestCents.value
          : this.lastCtBestCents,
      lastCtZeroCents: data.lastCtZeroCents.present
          ? data.lastCtZeroCents.value
          : this.lastCtZeroCents,
      lastCtDirectCents: data.lastCtDirectCents.present
          ? data.lastCtDirectCents.value
          : this.lastCtDirectCents,
      valuedAt: data.valuedAt.present ? data.valuedAt.value : this.valuedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedItem(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('quantity: $quantity, ')
          ..write('paidCents: $paidCents, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('foil: $foil, ')
          ..write('language: $language, ')
          ..write('condition: $condition, ')
          ..write('notes: $notes, ')
          ..write('lastCmTrendCents: $lastCmTrendCents, ')
          ..write('lastCmAvg7Cents: $lastCmAvg7Cents, ')
          ..write('lastCmAvg30Cents: $lastCmAvg30Cents, ')
          ..write('lastCtBestCents: $lastCtBestCents, ')
          ..write('lastCtZeroCents: $lastCtZeroCents, ')
          ..write('lastCtDirectCents: $lastCtDirectCents, ')
          ..write('valuedAt: $valuedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    quantity,
    paidCents,
    purchasedAt,
    foil,
    language,
    condition,
    notes,
    lastCmTrendCents,
    lastCmAvg7Cents,
    lastCmAvg30Cents,
    lastCtBestCents,
    lastCtZeroCents,
    lastCtDirectCents,
    valuedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedItem &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.quantity == this.quantity &&
          other.paidCents == this.paidCents &&
          other.purchasedAt == this.purchasedAt &&
          other.foil == this.foil &&
          other.language == this.language &&
          other.condition == this.condition &&
          other.notes == this.notes &&
          other.lastCmTrendCents == this.lastCmTrendCents &&
          other.lastCmAvg7Cents == this.lastCmAvg7Cents &&
          other.lastCmAvg30Cents == this.lastCmAvg30Cents &&
          other.lastCtBestCents == this.lastCtBestCents &&
          other.lastCtZeroCents == this.lastCtZeroCents &&
          other.lastCtDirectCents == this.lastCtDirectCents &&
          other.valuedAt == this.valuedAt &&
          other.createdAt == this.createdAt);
}

class TrackedItemsCompanion extends UpdateCompanion<TrackedItem> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<int> quantity;
  final Value<int> paidCents;
  final Value<DateTime> purchasedAt;
  final Value<bool?> foil;
  final Value<String?> language;
  final Value<String?> condition;
  final Value<String> notes;
  final Value<int?> lastCmTrendCents;
  final Value<int?> lastCmAvg7Cents;
  final Value<int?> lastCmAvg30Cents;
  final Value<int?> lastCtBestCents;
  final Value<int?> lastCtZeroCents;
  final Value<int?> lastCtDirectCents;
  final Value<DateTime?> valuedAt;
  final Value<DateTime> createdAt;
  const TrackedItemsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.paidCents = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.foil = const Value.absent(),
    this.language = const Value.absent(),
    this.condition = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastCmTrendCents = const Value.absent(),
    this.lastCmAvg7Cents = const Value.absent(),
    this.lastCmAvg30Cents = const Value.absent(),
    this.lastCtBestCents = const Value.absent(),
    this.lastCtZeroCents = const Value.absent(),
    this.lastCtDirectCents = const Value.absent(),
    this.valuedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TrackedItemsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    this.quantity = const Value.absent(),
    required int paidCents,
    required DateTime purchasedAt,
    this.foil = const Value.absent(),
    this.language = const Value.absent(),
    this.condition = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastCmTrendCents = const Value.absent(),
    this.lastCmAvg7Cents = const Value.absent(),
    this.lastCmAvg30Cents = const Value.absent(),
    this.lastCtBestCents = const Value.absent(),
    this.lastCtZeroCents = const Value.absent(),
    this.lastCtDirectCents = const Value.absent(),
    this.valuedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : cardId = Value(cardId),
       paidCents = Value(paidCents),
       purchasedAt = Value(purchasedAt);
  static Insertable<TrackedItem> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<int>? quantity,
    Expression<int>? paidCents,
    Expression<DateTime>? purchasedAt,
    Expression<bool>? foil,
    Expression<String>? language,
    Expression<String>? condition,
    Expression<String>? notes,
    Expression<int>? lastCmTrendCents,
    Expression<int>? lastCmAvg7Cents,
    Expression<int>? lastCmAvg30Cents,
    Expression<int>? lastCtBestCents,
    Expression<int>? lastCtZeroCents,
    Expression<int>? lastCtDirectCents,
    Expression<DateTime>? valuedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (quantity != null) 'quantity': quantity,
      if (paidCents != null) 'paid_cents': paidCents,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (foil != null) 'foil': foil,
      if (language != null) 'language': language,
      if (condition != null) 'condition': condition,
      if (notes != null) 'notes': notes,
      if (lastCmTrendCents != null) 'last_cm_trend_cents': lastCmTrendCents,
      if (lastCmAvg7Cents != null) 'last_cm_avg7_cents': lastCmAvg7Cents,
      if (lastCmAvg30Cents != null) 'last_cm_avg30_cents': lastCmAvg30Cents,
      if (lastCtBestCents != null) 'last_ct_best_cents': lastCtBestCents,
      if (lastCtZeroCents != null) 'last_ct_zero_cents': lastCtZeroCents,
      if (lastCtDirectCents != null) 'last_ct_direct_cents': lastCtDirectCents,
      if (valuedAt != null) 'valued_at': valuedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TrackedItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<int>? quantity,
    Value<int>? paidCents,
    Value<DateTime>? purchasedAt,
    Value<bool?>? foil,
    Value<String?>? language,
    Value<String?>? condition,
    Value<String>? notes,
    Value<int?>? lastCmTrendCents,
    Value<int?>? lastCmAvg7Cents,
    Value<int?>? lastCmAvg30Cents,
    Value<int?>? lastCtBestCents,
    Value<int?>? lastCtZeroCents,
    Value<int?>? lastCtDirectCents,
    Value<DateTime?>? valuedAt,
    Value<DateTime>? createdAt,
  }) {
    return TrackedItemsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      quantity: quantity ?? this.quantity,
      paidCents: paidCents ?? this.paidCents,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      foil: foil ?? this.foil,
      language: language ?? this.language,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      lastCmTrendCents: lastCmTrendCents ?? this.lastCmTrendCents,
      lastCmAvg7Cents: lastCmAvg7Cents ?? this.lastCmAvg7Cents,
      lastCmAvg30Cents: lastCmAvg30Cents ?? this.lastCmAvg30Cents,
      lastCtBestCents: lastCtBestCents ?? this.lastCtBestCents,
      lastCtZeroCents: lastCtZeroCents ?? this.lastCtZeroCents,
      lastCtDirectCents: lastCtDirectCents ?? this.lastCtDirectCents,
      valuedAt: valuedAt ?? this.valuedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (paidCents.present) {
      map['paid_cents'] = Variable<int>(paidCents.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (foil.present) {
      map['foil'] = Variable<bool>(foil.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lastCmTrendCents.present) {
      map['last_cm_trend_cents'] = Variable<int>(lastCmTrendCents.value);
    }
    if (lastCmAvg7Cents.present) {
      map['last_cm_avg7_cents'] = Variable<int>(lastCmAvg7Cents.value);
    }
    if (lastCmAvg30Cents.present) {
      map['last_cm_avg30_cents'] = Variable<int>(lastCmAvg30Cents.value);
    }
    if (lastCtBestCents.present) {
      map['last_ct_best_cents'] = Variable<int>(lastCtBestCents.value);
    }
    if (lastCtZeroCents.present) {
      map['last_ct_zero_cents'] = Variable<int>(lastCtZeroCents.value);
    }
    if (lastCtDirectCents.present) {
      map['last_ct_direct_cents'] = Variable<int>(lastCtDirectCents.value);
    }
    if (valuedAt.present) {
      map['valued_at'] = Variable<DateTime>(valuedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedItemsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('quantity: $quantity, ')
          ..write('paidCents: $paidCents, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('foil: $foil, ')
          ..write('language: $language, ')
          ..write('condition: $condition, ')
          ..write('notes: $notes, ')
          ..write('lastCmTrendCents: $lastCmTrendCents, ')
          ..write('lastCmAvg7Cents: $lastCmAvg7Cents, ')
          ..write('lastCmAvg30Cents: $lastCmAvg30Cents, ')
          ..write('lastCtBestCents: $lastCtBestCents, ')
          ..write('lastCtZeroCents: $lastCtZeroCents, ')
          ..write('lastCtDirectCents: $lastCtDirectCents, ')
          ..write('valuedAt: $valuedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PriceSnapshotsTable extends PriceSnapshots
    with TableInfo<$PriceSnapshotsTable, PriceSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id)',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cmTrendCentsMeta = const VerificationMeta(
    'cmTrendCents',
  );
  @override
  late final GeneratedColumn<int> cmTrendCents = GeneratedColumn<int>(
    'cm_trend_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cmLowCentsMeta = const VerificationMeta(
    'cmLowCents',
  );
  @override
  late final GeneratedColumn<int> cmLowCents = GeneratedColumn<int>(
    'cm_low_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cmAvgCentsMeta = const VerificationMeta(
    'cmAvgCents',
  );
  @override
  late final GeneratedColumn<int> cmAvgCents = GeneratedColumn<int>(
    'cm_avg_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cmAvg7CentsMeta = const VerificationMeta(
    'cmAvg7Cents',
  );
  @override
  late final GeneratedColumn<int> cmAvg7Cents = GeneratedColumn<int>(
    'cm_avg7_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cmAvg30CentsMeta = const VerificationMeta(
    'cmAvg30Cents',
  );
  @override
  late final GeneratedColumn<int> cmAvg30Cents = GeneratedColumn<int>(
    'cm_avg30_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ctMinDirectCentsMeta = const VerificationMeta(
    'ctMinDirectCents',
  );
  @override
  late final GeneratedColumn<int> ctMinDirectCents = GeneratedColumn<int>(
    'ct_min_direct_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ctMinZeroCentsMeta = const VerificationMeta(
    'ctMinZeroCents',
  );
  @override
  late final GeneratedColumn<int> ctMinZeroCents = GeneratedColumn<int>(
    'ct_min_zero_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ctListingCountMeta = const VerificationMeta(
    'ctListingCount',
  );
  @override
  late final GeneratedColumn<int> ctListingCount = GeneratedColumn<int>(
    'ct_listing_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ctZeroListingCountMeta =
      const VerificationMeta('ctZeroListingCount');
  @override
  late final GeneratedColumn<int> ctZeroListingCount = GeneratedColumn<int>(
    'ct_zero_listing_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    source,
    capturedAt,
    cmTrendCents,
    cmLowCents,
    cmAvgCents,
    cmAvg7Cents,
    cmAvg30Cents,
    ctMinDirectCents,
    ctMinZeroCents,
    ctListingCount,
    ctZeroListingCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('cm_trend_cents')) {
      context.handle(
        _cmTrendCentsMeta,
        cmTrendCents.isAcceptableOrUnknown(
          data['cm_trend_cents']!,
          _cmTrendCentsMeta,
        ),
      );
    }
    if (data.containsKey('cm_low_cents')) {
      context.handle(
        _cmLowCentsMeta,
        cmLowCents.isAcceptableOrUnknown(
          data['cm_low_cents']!,
          _cmLowCentsMeta,
        ),
      );
    }
    if (data.containsKey('cm_avg_cents')) {
      context.handle(
        _cmAvgCentsMeta,
        cmAvgCents.isAcceptableOrUnknown(
          data['cm_avg_cents']!,
          _cmAvgCentsMeta,
        ),
      );
    }
    if (data.containsKey('cm_avg7_cents')) {
      context.handle(
        _cmAvg7CentsMeta,
        cmAvg7Cents.isAcceptableOrUnknown(
          data['cm_avg7_cents']!,
          _cmAvg7CentsMeta,
        ),
      );
    }
    if (data.containsKey('cm_avg30_cents')) {
      context.handle(
        _cmAvg30CentsMeta,
        cmAvg30Cents.isAcceptableOrUnknown(
          data['cm_avg30_cents']!,
          _cmAvg30CentsMeta,
        ),
      );
    }
    if (data.containsKey('ct_min_direct_cents')) {
      context.handle(
        _ctMinDirectCentsMeta,
        ctMinDirectCents.isAcceptableOrUnknown(
          data['ct_min_direct_cents']!,
          _ctMinDirectCentsMeta,
        ),
      );
    }
    if (data.containsKey('ct_min_zero_cents')) {
      context.handle(
        _ctMinZeroCentsMeta,
        ctMinZeroCents.isAcceptableOrUnknown(
          data['ct_min_zero_cents']!,
          _ctMinZeroCentsMeta,
        ),
      );
    }
    if (data.containsKey('ct_listing_count')) {
      context.handle(
        _ctListingCountMeta,
        ctListingCount.isAcceptableOrUnknown(
          data['ct_listing_count']!,
          _ctListingCountMeta,
        ),
      );
    }
    if (data.containsKey('ct_zero_listing_count')) {
      context.handle(
        _ctZeroListingCountMeta,
        ctZeroListingCount.isAcceptableOrUnknown(
          data['ct_zero_listing_count']!,
          _ctZeroListingCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      cmTrendCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cm_trend_cents'],
      ),
      cmLowCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cm_low_cents'],
      ),
      cmAvgCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cm_avg_cents'],
      ),
      cmAvg7Cents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cm_avg7_cents'],
      ),
      cmAvg30Cents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cm_avg30_cents'],
      ),
      ctMinDirectCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ct_min_direct_cents'],
      ),
      ctMinZeroCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ct_min_zero_cents'],
      ),
      ctListingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ct_listing_count'],
      ),
      ctZeroListingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ct_zero_listing_count'],
      ),
    );
  }

  @override
  $PriceSnapshotsTable createAlias(String alias) {
    return $PriceSnapshotsTable(attachedDatabase, alias);
  }
}

class PriceSnapshot extends DataClass implements Insertable<PriceSnapshot> {
  final int id;
  final int cardId;
  final String source;
  final DateTime capturedAt;
  final int? cmTrendCents;
  final int? cmLowCents;
  final int? cmAvgCents;
  final int? cmAvg7Cents;
  final int? cmAvg30Cents;
  final int? ctMinDirectCents;
  final int? ctMinZeroCents;
  final int? ctListingCount;
  final int? ctZeroListingCount;
  const PriceSnapshot({
    required this.id,
    required this.cardId,
    required this.source,
    required this.capturedAt,
    this.cmTrendCents,
    this.cmLowCents,
    this.cmAvgCents,
    this.cmAvg7Cents,
    this.cmAvg30Cents,
    this.ctMinDirectCents,
    this.ctMinZeroCents,
    this.ctListingCount,
    this.ctZeroListingCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['source'] = Variable<String>(source);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || cmTrendCents != null) {
      map['cm_trend_cents'] = Variable<int>(cmTrendCents);
    }
    if (!nullToAbsent || cmLowCents != null) {
      map['cm_low_cents'] = Variable<int>(cmLowCents);
    }
    if (!nullToAbsent || cmAvgCents != null) {
      map['cm_avg_cents'] = Variable<int>(cmAvgCents);
    }
    if (!nullToAbsent || cmAvg7Cents != null) {
      map['cm_avg7_cents'] = Variable<int>(cmAvg7Cents);
    }
    if (!nullToAbsent || cmAvg30Cents != null) {
      map['cm_avg30_cents'] = Variable<int>(cmAvg30Cents);
    }
    if (!nullToAbsent || ctMinDirectCents != null) {
      map['ct_min_direct_cents'] = Variable<int>(ctMinDirectCents);
    }
    if (!nullToAbsent || ctMinZeroCents != null) {
      map['ct_min_zero_cents'] = Variable<int>(ctMinZeroCents);
    }
    if (!nullToAbsent || ctListingCount != null) {
      map['ct_listing_count'] = Variable<int>(ctListingCount);
    }
    if (!nullToAbsent || ctZeroListingCount != null) {
      map['ct_zero_listing_count'] = Variable<int>(ctZeroListingCount);
    }
    return map;
  }

  PriceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PriceSnapshotsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      source: Value(source),
      capturedAt: Value(capturedAt),
      cmTrendCents: cmTrendCents == null && nullToAbsent
          ? const Value.absent()
          : Value(cmTrendCents),
      cmLowCents: cmLowCents == null && nullToAbsent
          ? const Value.absent()
          : Value(cmLowCents),
      cmAvgCents: cmAvgCents == null && nullToAbsent
          ? const Value.absent()
          : Value(cmAvgCents),
      cmAvg7Cents: cmAvg7Cents == null && nullToAbsent
          ? const Value.absent()
          : Value(cmAvg7Cents),
      cmAvg30Cents: cmAvg30Cents == null && nullToAbsent
          ? const Value.absent()
          : Value(cmAvg30Cents),
      ctMinDirectCents: ctMinDirectCents == null && nullToAbsent
          ? const Value.absent()
          : Value(ctMinDirectCents),
      ctMinZeroCents: ctMinZeroCents == null && nullToAbsent
          ? const Value.absent()
          : Value(ctMinZeroCents),
      ctListingCount: ctListingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ctListingCount),
      ctZeroListingCount: ctZeroListingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ctZeroListingCount),
    );
  }

  factory PriceSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceSnapshot(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      source: serializer.fromJson<String>(json['source']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      cmTrendCents: serializer.fromJson<int?>(json['cmTrendCents']),
      cmLowCents: serializer.fromJson<int?>(json['cmLowCents']),
      cmAvgCents: serializer.fromJson<int?>(json['cmAvgCents']),
      cmAvg7Cents: serializer.fromJson<int?>(json['cmAvg7Cents']),
      cmAvg30Cents: serializer.fromJson<int?>(json['cmAvg30Cents']),
      ctMinDirectCents: serializer.fromJson<int?>(json['ctMinDirectCents']),
      ctMinZeroCents: serializer.fromJson<int?>(json['ctMinZeroCents']),
      ctListingCount: serializer.fromJson<int?>(json['ctListingCount']),
      ctZeroListingCount: serializer.fromJson<int?>(json['ctZeroListingCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'source': serializer.toJson<String>(source),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'cmTrendCents': serializer.toJson<int?>(cmTrendCents),
      'cmLowCents': serializer.toJson<int?>(cmLowCents),
      'cmAvgCents': serializer.toJson<int?>(cmAvgCents),
      'cmAvg7Cents': serializer.toJson<int?>(cmAvg7Cents),
      'cmAvg30Cents': serializer.toJson<int?>(cmAvg30Cents),
      'ctMinDirectCents': serializer.toJson<int?>(ctMinDirectCents),
      'ctMinZeroCents': serializer.toJson<int?>(ctMinZeroCents),
      'ctListingCount': serializer.toJson<int?>(ctListingCount),
      'ctZeroListingCount': serializer.toJson<int?>(ctZeroListingCount),
    };
  }

  PriceSnapshot copyWith({
    int? id,
    int? cardId,
    String? source,
    DateTime? capturedAt,
    Value<int?> cmTrendCents = const Value.absent(),
    Value<int?> cmLowCents = const Value.absent(),
    Value<int?> cmAvgCents = const Value.absent(),
    Value<int?> cmAvg7Cents = const Value.absent(),
    Value<int?> cmAvg30Cents = const Value.absent(),
    Value<int?> ctMinDirectCents = const Value.absent(),
    Value<int?> ctMinZeroCents = const Value.absent(),
    Value<int?> ctListingCount = const Value.absent(),
    Value<int?> ctZeroListingCount = const Value.absent(),
  }) => PriceSnapshot(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    source: source ?? this.source,
    capturedAt: capturedAt ?? this.capturedAt,
    cmTrendCents: cmTrendCents.present ? cmTrendCents.value : this.cmTrendCents,
    cmLowCents: cmLowCents.present ? cmLowCents.value : this.cmLowCents,
    cmAvgCents: cmAvgCents.present ? cmAvgCents.value : this.cmAvgCents,
    cmAvg7Cents: cmAvg7Cents.present ? cmAvg7Cents.value : this.cmAvg7Cents,
    cmAvg30Cents: cmAvg30Cents.present ? cmAvg30Cents.value : this.cmAvg30Cents,
    ctMinDirectCents: ctMinDirectCents.present
        ? ctMinDirectCents.value
        : this.ctMinDirectCents,
    ctMinZeroCents: ctMinZeroCents.present
        ? ctMinZeroCents.value
        : this.ctMinZeroCents,
    ctListingCount: ctListingCount.present
        ? ctListingCount.value
        : this.ctListingCount,
    ctZeroListingCount: ctZeroListingCount.present
        ? ctZeroListingCount.value
        : this.ctZeroListingCount,
  );
  PriceSnapshot copyWithCompanion(PriceSnapshotsCompanion data) {
    return PriceSnapshot(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      source: data.source.present ? data.source.value : this.source,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      cmTrendCents: data.cmTrendCents.present
          ? data.cmTrendCents.value
          : this.cmTrendCents,
      cmLowCents: data.cmLowCents.present
          ? data.cmLowCents.value
          : this.cmLowCents,
      cmAvgCents: data.cmAvgCents.present
          ? data.cmAvgCents.value
          : this.cmAvgCents,
      cmAvg7Cents: data.cmAvg7Cents.present
          ? data.cmAvg7Cents.value
          : this.cmAvg7Cents,
      cmAvg30Cents: data.cmAvg30Cents.present
          ? data.cmAvg30Cents.value
          : this.cmAvg30Cents,
      ctMinDirectCents: data.ctMinDirectCents.present
          ? data.ctMinDirectCents.value
          : this.ctMinDirectCents,
      ctMinZeroCents: data.ctMinZeroCents.present
          ? data.ctMinZeroCents.value
          : this.ctMinZeroCents,
      ctListingCount: data.ctListingCount.present
          ? data.ctListingCount.value
          : this.ctListingCount,
      ctZeroListingCount: data.ctZeroListingCount.present
          ? data.ctZeroListingCount.value
          : this.ctZeroListingCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceSnapshot(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('cmTrendCents: $cmTrendCents, ')
          ..write('cmLowCents: $cmLowCents, ')
          ..write('cmAvgCents: $cmAvgCents, ')
          ..write('cmAvg7Cents: $cmAvg7Cents, ')
          ..write('cmAvg30Cents: $cmAvg30Cents, ')
          ..write('ctMinDirectCents: $ctMinDirectCents, ')
          ..write('ctMinZeroCents: $ctMinZeroCents, ')
          ..write('ctListingCount: $ctListingCount, ')
          ..write('ctZeroListingCount: $ctZeroListingCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    source,
    capturedAt,
    cmTrendCents,
    cmLowCents,
    cmAvgCents,
    cmAvg7Cents,
    cmAvg30Cents,
    ctMinDirectCents,
    ctMinZeroCents,
    ctListingCount,
    ctZeroListingCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceSnapshot &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.source == this.source &&
          other.capturedAt == this.capturedAt &&
          other.cmTrendCents == this.cmTrendCents &&
          other.cmLowCents == this.cmLowCents &&
          other.cmAvgCents == this.cmAvgCents &&
          other.cmAvg7Cents == this.cmAvg7Cents &&
          other.cmAvg30Cents == this.cmAvg30Cents &&
          other.ctMinDirectCents == this.ctMinDirectCents &&
          other.ctMinZeroCents == this.ctMinZeroCents &&
          other.ctListingCount == this.ctListingCount &&
          other.ctZeroListingCount == this.ctZeroListingCount);
}

class PriceSnapshotsCompanion extends UpdateCompanion<PriceSnapshot> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> source;
  final Value<DateTime> capturedAt;
  final Value<int?> cmTrendCents;
  final Value<int?> cmLowCents;
  final Value<int?> cmAvgCents;
  final Value<int?> cmAvg7Cents;
  final Value<int?> cmAvg30Cents;
  final Value<int?> ctMinDirectCents;
  final Value<int?> ctMinZeroCents;
  final Value<int?> ctListingCount;
  final Value<int?> ctZeroListingCount;
  const PriceSnapshotsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.source = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.cmTrendCents = const Value.absent(),
    this.cmLowCents = const Value.absent(),
    this.cmAvgCents = const Value.absent(),
    this.cmAvg7Cents = const Value.absent(),
    this.cmAvg30Cents = const Value.absent(),
    this.ctMinDirectCents = const Value.absent(),
    this.ctMinZeroCents = const Value.absent(),
    this.ctListingCount = const Value.absent(),
    this.ctZeroListingCount = const Value.absent(),
  });
  PriceSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String source,
    required DateTime capturedAt,
    this.cmTrendCents = const Value.absent(),
    this.cmLowCents = const Value.absent(),
    this.cmAvgCents = const Value.absent(),
    this.cmAvg7Cents = const Value.absent(),
    this.cmAvg30Cents = const Value.absent(),
    this.ctMinDirectCents = const Value.absent(),
    this.ctMinZeroCents = const Value.absent(),
    this.ctListingCount = const Value.absent(),
    this.ctZeroListingCount = const Value.absent(),
  }) : cardId = Value(cardId),
       source = Value(source),
       capturedAt = Value(capturedAt);
  static Insertable<PriceSnapshot> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? source,
    Expression<DateTime>? capturedAt,
    Expression<int>? cmTrendCents,
    Expression<int>? cmLowCents,
    Expression<int>? cmAvgCents,
    Expression<int>? cmAvg7Cents,
    Expression<int>? cmAvg30Cents,
    Expression<int>? ctMinDirectCents,
    Expression<int>? ctMinZeroCents,
    Expression<int>? ctListingCount,
    Expression<int>? ctZeroListingCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (source != null) 'source': source,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (cmTrendCents != null) 'cm_trend_cents': cmTrendCents,
      if (cmLowCents != null) 'cm_low_cents': cmLowCents,
      if (cmAvgCents != null) 'cm_avg_cents': cmAvgCents,
      if (cmAvg7Cents != null) 'cm_avg7_cents': cmAvg7Cents,
      if (cmAvg30Cents != null) 'cm_avg30_cents': cmAvg30Cents,
      if (ctMinDirectCents != null) 'ct_min_direct_cents': ctMinDirectCents,
      if (ctMinZeroCents != null) 'ct_min_zero_cents': ctMinZeroCents,
      if (ctListingCount != null) 'ct_listing_count': ctListingCount,
      if (ctZeroListingCount != null)
        'ct_zero_listing_count': ctZeroListingCount,
    });
  }

  PriceSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? source,
    Value<DateTime>? capturedAt,
    Value<int?>? cmTrendCents,
    Value<int?>? cmLowCents,
    Value<int?>? cmAvgCents,
    Value<int?>? cmAvg7Cents,
    Value<int?>? cmAvg30Cents,
    Value<int?>? ctMinDirectCents,
    Value<int?>? ctMinZeroCents,
    Value<int?>? ctListingCount,
    Value<int?>? ctZeroListingCount,
  }) {
    return PriceSnapshotsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      cmTrendCents: cmTrendCents ?? this.cmTrendCents,
      cmLowCents: cmLowCents ?? this.cmLowCents,
      cmAvgCents: cmAvgCents ?? this.cmAvgCents,
      cmAvg7Cents: cmAvg7Cents ?? this.cmAvg7Cents,
      cmAvg30Cents: cmAvg30Cents ?? this.cmAvg30Cents,
      ctMinDirectCents: ctMinDirectCents ?? this.ctMinDirectCents,
      ctMinZeroCents: ctMinZeroCents ?? this.ctMinZeroCents,
      ctListingCount: ctListingCount ?? this.ctListingCount,
      ctZeroListingCount: ctZeroListingCount ?? this.ctZeroListingCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (cmTrendCents.present) {
      map['cm_trend_cents'] = Variable<int>(cmTrendCents.value);
    }
    if (cmLowCents.present) {
      map['cm_low_cents'] = Variable<int>(cmLowCents.value);
    }
    if (cmAvgCents.present) {
      map['cm_avg_cents'] = Variable<int>(cmAvgCents.value);
    }
    if (cmAvg7Cents.present) {
      map['cm_avg7_cents'] = Variable<int>(cmAvg7Cents.value);
    }
    if (cmAvg30Cents.present) {
      map['cm_avg30_cents'] = Variable<int>(cmAvg30Cents.value);
    }
    if (ctMinDirectCents.present) {
      map['ct_min_direct_cents'] = Variable<int>(ctMinDirectCents.value);
    }
    if (ctMinZeroCents.present) {
      map['ct_min_zero_cents'] = Variable<int>(ctMinZeroCents.value);
    }
    if (ctListingCount.present) {
      map['ct_listing_count'] = Variable<int>(ctListingCount.value);
    }
    if (ctZeroListingCount.present) {
      map['ct_zero_listing_count'] = Variable<int>(ctZeroListingCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('cmTrendCents: $cmTrendCents, ')
          ..write('cmLowCents: $cmLowCents, ')
          ..write('cmAvgCents: $cmAvgCents, ')
          ..write('cmAvg7Cents: $cmAvg7Cents, ')
          ..write('cmAvg30Cents: $cmAvg30Cents, ')
          ..write('ctMinDirectCents: $ctMinDirectCents, ')
          ..write('ctMinZeroCents: $ctMinZeroCents, ')
          ..write('ctListingCount: $ctListingCount, ')
          ..write('ctZeroListingCount: $ctZeroListingCount')
          ..write(')'))
        .toString();
  }
}

class $SyncRunsTable extends SyncRuns with TableInfo<$SyncRunsTable, SyncRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    startedAt,
    finishedAt,
    status,
    message,
    itemCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
    );
  }

  @override
  $SyncRunsTable createAlias(String alias) {
    return $SyncRunsTable(attachedDatabase, alias);
  }
}

class SyncRun extends DataClass implements Insertable<SyncRun> {
  final int id;
  final String source;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String status;
  final String message;
  final int itemCount;
  const SyncRun({
    required this.id,
    required this.source,
    required this.startedAt,
    this.finishedAt,
    required this.status,
    required this.message,
    required this.itemCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source'] = Variable<String>(source);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['status'] = Variable<String>(status);
    map['message'] = Variable<String>(message);
    map['item_count'] = Variable<int>(itemCount);
    return map;
  }

  SyncRunsCompanion toCompanion(bool nullToAbsent) {
    return SyncRunsCompanion(
      id: Value(id),
      source: Value(source),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      status: Value(status),
      message: Value(message),
      itemCount: Value(itemCount),
    );
  }

  factory SyncRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRun(
      id: serializer.fromJson<int>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String>(json['message']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<String>(source),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String>(message),
      'itemCount': serializer.toJson<int>(itemCount),
    };
  }

  SyncRun copyWith({
    int? id,
    String? source,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    String? status,
    String? message,
    int? itemCount,
  }) => SyncRun(
    id: id ?? this.id,
    source: source ?? this.source,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    status: status ?? this.status,
    message: message ?? this.message,
    itemCount: itemCount ?? this.itemCount,
  );
  SyncRun copyWithCompanion(SyncRunsCompanion data) {
    return SyncRun(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRun(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    startedAt,
    finishedAt,
    status,
    message,
    itemCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRun &&
          other.id == this.id &&
          other.source == this.source &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.status == this.status &&
          other.message == this.message &&
          other.itemCount == this.itemCount);
}

class SyncRunsCompanion extends UpdateCompanion<SyncRun> {
  final Value<int> id;
  final Value<String> source;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String> status;
  final Value<String> message;
  final Value<int> itemCount;
  const SyncRunsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.itemCount = const Value.absent(),
  });
  SyncRunsCompanion.insert({
    this.id = const Value.absent(),
    required String source,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required String status,
    this.message = const Value.absent(),
    this.itemCount = const Value.absent(),
  }) : source = Value(source),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<SyncRun> custom({
    Expression<int>? id,
    Expression<String>? source,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? status,
    Expression<String>? message,
    Expression<int>? itemCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (itemCount != null) 'item_count': itemCount,
    });
  }

  SyncRunsCompanion copyWith({
    Value<int>? id,
    Value<String>? source,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String>? status,
    Value<String>? message,
    Value<int>? itemCount,
  }) {
    return SyncRunsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      message: message ?? this.message,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRunsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $WatchlistItemsTable watchlistItems = $WatchlistItemsTable(this);
  late final $TrackedItemsTable trackedItems = $TrackedItemsTable(this);
  late final $PriceSnapshotsTable priceSnapshots = $PriceSnapshotsTable(this);
  late final $SyncRunsTable syncRuns = $SyncRunsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    cards,
    watchlistItems,
    trackedItems,
    priceSnapshots,
    syncRuns,
  ];
}

typedef $$GamesTableCreateCompanionBuilder = GamesCompanion Function({
  required String id,
  required String name,
  Value<int?> cardTraderGameId,
  Value<int?> cardmarketGameId,
  Value<int> rowid,
});
typedef $$GamesTableUpdateCompanionBuilder = GamesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> cardTraderGameId,
  Value<int?> cardmarketGameId,
  Value<int> rowid,
});

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: 'games__id__cards__game_id',
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardTraderGameId => $composableBuilder(
    column: $table.cardTraderGameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardmarketGameId => $composableBuilder(
    column: $table.cardmarketGameId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardTraderGameId => $composableBuilder(
    column: $table.cardTraderGameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardmarketGameId => $composableBuilder(
    column: $table.cardmarketGameId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cardTraderGameId => $composableBuilder(
    column: $table.cardTraderGameId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardmarketGameId => $composableBuilder(
    column: $table.cardmarketGameId,
    builder: (column) => column,
  );

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> cardTraderGameId = const Value.absent(),
                Value<int?> cardmarketGameId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                name: name,
                cardTraderGameId: cardTraderGameId,
                cardmarketGameId: cardmarketGameId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> cardTraderGameId = const Value.absent(),
                Value<int?> cardmarketGameId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                name: name,
                cardTraderGameId: cardTraderGameId,
                cardmarketGameId: cardmarketGameId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GamesTable, Game>(table),
                  $$GamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, Card>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences._cardsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GamesTableReferences(db, table, p0).cardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  Value<int> id,
  required String gameId,
  required String name,
  Value<String> expansion,
  Value<String?> imageUrl,
  Value<int?> cardmarketProductId,
  Value<int?> cardTraderBlueprintId,
  Value<int?> cardTraderExpansionId,
  Value<DateTime> createdAt,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<int> id,
  Value<String> gameId,
  Value<String> name,
  Value<String> expansion,
  Value<String?> imageUrl,
  Value<int?> cardmarketProductId,
  Value<int?> cardTraderBlueprintId,
  Value<int?> cardTraderExpansionId,
  Value<DateTime> createdAt,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('cards__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WatchlistItemsTable, List<WatchlistItem>>
  _watchlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchlistItems,
    aliasName: 'cards__id__watchlist_items__card_id',
  );

  $$WatchlistItemsTableProcessedTableManager get watchlistItemsRefs {
    final manager = $$WatchlistItemsTableTableManager(
      $_db,
      $_db.watchlistItems,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_watchlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackedItemsTable, List<TrackedItem>>
  _trackedItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackedItems,
    aliasName: 'cards__id__tracked_items__card_id',
  );

  $$TrackedItemsTableProcessedTableManager get trackedItemsRefs {
    final manager = $$TrackedItemsTableTableManager(
      $_db,
      $_db.trackedItems,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackedItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PriceSnapshotsTable, List<PriceSnapshot>>
  _priceSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.priceSnapshots,
    aliasName: 'cards__id__price_snapshots__card_id',
  );

  $$PriceSnapshotsTableProcessedTableManager get priceSnapshotsRefs {
    final manager = $$PriceSnapshotsTableTableManager(
      $_db,
      $_db.priceSnapshots,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_priceSnapshotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expansion => $composableBuilder(
    column: $table.expansion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardmarketProductId => $composableBuilder(
    column: $table.cardmarketProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardTraderBlueprintId => $composableBuilder(
    column: $table.cardTraderBlueprintId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardTraderExpansionId => $composableBuilder(
    column: $table.cardTraderExpansionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> watchlistItemsRefs(
    Expression<bool> Function($$WatchlistItemsTableFilterComposer f) f,
  ) {
    final $$WatchlistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchlistItems,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchlistItemsTableFilterComposer(
            $db: $db,
            $table: $db.watchlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackedItemsRefs(
    Expression<bool> Function($$TrackedItemsTableFilterComposer f) f,
  ) {
    final $$TrackedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackedItems,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedItemsTableFilterComposer(
            $db: $db,
            $table: $db.trackedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> priceSnapshotsRefs(
    Expression<bool> Function($$PriceSnapshotsTableFilterComposer f) f,
  ) {
    final $$PriceSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.priceSnapshots,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PriceSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.priceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expansion => $composableBuilder(
    column: $table.expansion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardmarketProductId => $composableBuilder(
    column: $table.cardmarketProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardTraderBlueprintId => $composableBuilder(
    column: $table.cardTraderBlueprintId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardTraderExpansionId => $composableBuilder(
    column: $table.cardTraderExpansionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get expansion =>
      $composableBuilder(column: $table.expansion, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get cardmarketProductId => $composableBuilder(
    column: $table.cardmarketProductId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardTraderBlueprintId => $composableBuilder(
    column: $table.cardTraderBlueprintId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardTraderExpansionId => $composableBuilder(
    column: $table.cardTraderExpansionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> watchlistItemsRefs<T extends Object>(
    Expression<T> Function($$WatchlistItemsTableAnnotationComposer a) f,
  ) {
    final $$WatchlistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchlistItems,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchlistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.watchlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trackedItemsRefs<T extends Object>(
    Expression<T> Function($$TrackedItemsTableAnnotationComposer a) f,
  ) {
    final $$TrackedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackedItems,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> priceSnapshotsRefs<T extends Object>(
    Expression<T> Function($$PriceSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$PriceSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.priceSnapshots,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PriceSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.priceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, $$CardsTableReferences),
          Card,
          PrefetchHooks Function({
            bool gameId,
            bool watchlistItemsRefs,
            bool trackedItemsRefs,
            bool priceSnapshotsRefs,
          })
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> expansion = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> cardmarketProductId = const Value.absent(),
                Value<int?> cardTraderBlueprintId = const Value.absent(),
                Value<int?> cardTraderExpansionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                gameId: gameId,
                name: name,
                expansion: expansion,
                imageUrl: imageUrl,
                cardmarketProductId: cardmarketProductId,
                cardTraderBlueprintId: cardTraderBlueprintId,
                cardTraderExpansionId: cardTraderExpansionId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String gameId,
                required String name,
                Value<String> expansion = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> cardmarketProductId = const Value.absent(),
                Value<int?> cardTraderBlueprintId = const Value.absent(),
                Value<int?> cardTraderExpansionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                gameId: gameId,
                name: name,
                expansion: expansion,
                imageUrl: imageUrl,
                cardmarketProductId: cardmarketProductId,
                cardTraderBlueprintId: cardTraderBlueprintId,
                cardTraderExpansionId: cardTraderExpansionId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, Card>(table),
                  $$CardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameId = false,
                watchlistItemsRefs = false,
                trackedItemsRefs = false,
                priceSnapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (watchlistItemsRefs) db.watchlistItems,
                    if (trackedItemsRefs) db.trackedItems,
                    if (priceSnapshotsRefs) db.priceSnapshots,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.gameId,
                            referencedTable: $$CardsTableReferences
                                ._gameIdTable(db),
                            referencedColumn: $$CardsTableReferences
                                ._gameIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (watchlistItemsRefs)
                        await $_getPrefetchedData<
                          Card,
                          $CardsTable,
                          WatchlistItem
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._watchlistItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).watchlistItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackedItemsRefs)
                        await $_getPrefetchedData<
                          Card,
                          $CardsTable,
                          TrackedItem
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._trackedItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).trackedItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (priceSnapshotsRefs)
                        await $_getPrefetchedData<
                          Card,
                          $CardsTable,
                          PriceSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._priceSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).priceSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, $$CardsTableReferences),
      Card,
      PrefetchHooks Function({
        bool gameId,
        bool watchlistItemsRefs,
        bool trackedItemsRefs,
        bool priceSnapshotsRefs,
      })
    >;
typedef $$WatchlistItemsTableCreateCompanionBuilder =
    WatchlistItemsCompanion Function({
      Value<int> id,
      required int cardId,
      Value<int> quantity,
      Value<String> notes,
      Value<bool?> foil,
      Value<String?> language,
      Value<String?> minCondition,
      Value<String?> sellerName,
      Value<int?> minSellerQuantity,
      Value<int?> targetBuyCents,
      Value<int?> targetSellCents,
      Value<DateTime> addedAt,
    });
typedef $$WatchlistItemsTableUpdateCompanionBuilder =
    WatchlistItemsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<int> quantity,
      Value<String> notes,
      Value<bool?> foil,
      Value<String?> language,
      Value<String?> minCondition,
      Value<String?> sellerName,
      Value<int?> minSellerQuantity,
      Value<int?> targetBuyCents,
      Value<int?> targetSellCents,
      Value<DateTime> addedAt,
    });

final class $$WatchlistItemsTableReferences
    extends BaseReferences<_$AppDatabase, $WatchlistItemsTable, WatchlistItem> {
  $$WatchlistItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('watchlist_items__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get minCondition => $composableBuilder(
    column: $table.minCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sellerName => $composableBuilder(
    column: $table.sellerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minSellerQuantity => $composableBuilder(
    column: $table.minSellerQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetBuyCents => $composableBuilder(
    column: $table.targetBuyCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSellCents => $composableBuilder(
    column: $table.targetSellCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minCondition => $composableBuilder(
    column: $table.minCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sellerName => $composableBuilder(
    column: $table.sellerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minSellerQuantity => $composableBuilder(
    column: $table.minSellerQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetBuyCents => $composableBuilder(
    column: $table.targetBuyCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSellCents => $composableBuilder(
    column: $table.targetSellCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTable> {
  $$WatchlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get foil =>
      $composableBuilder(column: $table.foil, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get minCondition => $composableBuilder(
    column: $table.minCondition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sellerName => $composableBuilder(
    column: $table.sellerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minSellerQuantity => $composableBuilder(
    column: $table.minSellerQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetBuyCents => $composableBuilder(
    column: $table.targetBuyCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetSellCents => $composableBuilder(
    column: $table.targetSellCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchlistItemsTable,
          WatchlistItem,
          $$WatchlistItemsTableFilterComposer,
          $$WatchlistItemsTableOrderingComposer,
          $$WatchlistItemsTableAnnotationComposer,
          $$WatchlistItemsTableCreateCompanionBuilder,
          $$WatchlistItemsTableUpdateCompanionBuilder,
          (WatchlistItem, $$WatchlistItemsTableReferences),
          WatchlistItem,
          PrefetchHooks Function({bool cardId})
        > {
  $$WatchlistItemsTableTableManager(
    _$AppDatabase db,
    $WatchlistItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool?> foil = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> minCondition = const Value.absent(),
                Value<String?> sellerName = const Value.absent(),
                Value<int?> minSellerQuantity = const Value.absent(),
                Value<int?> targetBuyCents = const Value.absent(),
                Value<int?> targetSellCents = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => WatchlistItemsCompanion(
                id: id,
                cardId: cardId,
                quantity: quantity,
                notes: notes,
                foil: foil,
                language: language,
                minCondition: minCondition,
                sellerName: sellerName,
                minSellerQuantity: minSellerQuantity,
                targetBuyCents: targetBuyCents,
                targetSellCents: targetSellCents,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                Value<int> quantity = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool?> foil = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> minCondition = const Value.absent(),
                Value<String?> sellerName = const Value.absent(),
                Value<int?> minSellerQuantity = const Value.absent(),
                Value<int?> targetBuyCents = const Value.absent(),
                Value<int?> targetSellCents = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => WatchlistItemsCompanion.insert(
                id: id,
                cardId: cardId,
                quantity: quantity,
                notes: notes,
                foil: foil,
                language: language,
                minCondition: minCondition,
                sellerName: sellerName,
                minSellerQuantity: minSellerQuantity,
                targetBuyCents: targetBuyCents,
                targetSellCents: targetSellCents,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchlistItemsTable, WatchlistItem>(table),
                  $$WatchlistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$WatchlistItemsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$WatchlistItemsTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WatchlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchlistItemsTable,
      WatchlistItem,
      $$WatchlistItemsTableFilterComposer,
      $$WatchlistItemsTableOrderingComposer,
      $$WatchlistItemsTableAnnotationComposer,
      $$WatchlistItemsTableCreateCompanionBuilder,
      $$WatchlistItemsTableUpdateCompanionBuilder,
      (WatchlistItem, $$WatchlistItemsTableReferences),
      WatchlistItem,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$TrackedItemsTableCreateCompanionBuilder =
    TrackedItemsCompanion Function({
      Value<int> id,
      required int cardId,
      Value<int> quantity,
      required int paidCents,
      required DateTime purchasedAt,
      Value<bool?> foil,
      Value<String?> language,
      Value<String?> condition,
      Value<String> notes,
      Value<int?> lastCmTrendCents,
      Value<int?> lastCmAvg7Cents,
      Value<int?> lastCmAvg30Cents,
      Value<int?> lastCtBestCents,
      Value<int?> lastCtZeroCents,
      Value<int?> lastCtDirectCents,
      Value<DateTime?> valuedAt,
      Value<DateTime> createdAt,
    });
typedef $$TrackedItemsTableUpdateCompanionBuilder =
    TrackedItemsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<int> quantity,
      Value<int> paidCents,
      Value<DateTime> purchasedAt,
      Value<bool?> foil,
      Value<String?> language,
      Value<String?> condition,
      Value<String> notes,
      Value<int?> lastCmTrendCents,
      Value<int?> lastCmAvg7Cents,
      Value<int?> lastCmAvg30Cents,
      Value<int?> lastCtBestCents,
      Value<int?> lastCtZeroCents,
      Value<int?> lastCtDirectCents,
      Value<DateTime?> valuedAt,
      Value<DateTime> createdAt,
    });

final class $$TrackedItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackedItemsTable, TrackedItem> {
  $$TrackedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('tracked_items__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidCents => $composableBuilder(
    column: $table.paidCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCmTrendCents => $composableBuilder(
    column: $table.lastCmTrendCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCmAvg7Cents => $composableBuilder(
    column: $table.lastCmAvg7Cents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCmAvg30Cents => $composableBuilder(
    column: $table.lastCmAvg30Cents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCtBestCents => $composableBuilder(
    column: $table.lastCtBestCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCtZeroCents => $composableBuilder(
    column: $table.lastCtZeroCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCtDirectCents => $composableBuilder(
    column: $table.lastCtDirectCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get valuedAt => $composableBuilder(
    column: $table.valuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidCents => $composableBuilder(
    column: $table.paidCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCmTrendCents => $composableBuilder(
    column: $table.lastCmTrendCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCmAvg7Cents => $composableBuilder(
    column: $table.lastCmAvg7Cents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCmAvg30Cents => $composableBuilder(
    column: $table.lastCmAvg30Cents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCtBestCents => $composableBuilder(
    column: $table.lastCtBestCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCtZeroCents => $composableBuilder(
    column: $table.lastCtZeroCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCtDirectCents => $composableBuilder(
    column: $table.lastCtDirectCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get valuedAt => $composableBuilder(
    column: $table.valuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get paidCents =>
      $composableBuilder(column: $table.paidCents, builder: (column) => column);

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get foil =>
      $composableBuilder(column: $table.foil, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get lastCmTrendCents => $composableBuilder(
    column: $table.lastCmTrendCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCmAvg7Cents => $composableBuilder(
    column: $table.lastCmAvg7Cents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCmAvg30Cents => $composableBuilder(
    column: $table.lastCmAvg30Cents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCtBestCents => $composableBuilder(
    column: $table.lastCtBestCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCtZeroCents => $composableBuilder(
    column: $table.lastCtZeroCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCtDirectCents => $composableBuilder(
    column: $table.lastCtDirectCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get valuedAt =>
      $composableBuilder(column: $table.valuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackedItemsTable,
          TrackedItem,
          $$TrackedItemsTableFilterComposer,
          $$TrackedItemsTableOrderingComposer,
          $$TrackedItemsTableAnnotationComposer,
          $$TrackedItemsTableCreateCompanionBuilder,
          $$TrackedItemsTableUpdateCompanionBuilder,
          (TrackedItem, $$TrackedItemsTableReferences),
          TrackedItem,
          PrefetchHooks Function({bool cardId})
        > {
  $$TrackedItemsTableTableManager(_$AppDatabase db, $TrackedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> paidCents = const Value.absent(),
                Value<DateTime> purchasedAt = const Value.absent(),
                Value<bool?> foil = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int?> lastCmTrendCents = const Value.absent(),
                Value<int?> lastCmAvg7Cents = const Value.absent(),
                Value<int?> lastCmAvg30Cents = const Value.absent(),
                Value<int?> lastCtBestCents = const Value.absent(),
                Value<int?> lastCtZeroCents = const Value.absent(),
                Value<int?> lastCtDirectCents = const Value.absent(),
                Value<DateTime?> valuedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TrackedItemsCompanion(
                id: id,
                cardId: cardId,
                quantity: quantity,
                paidCents: paidCents,
                purchasedAt: purchasedAt,
                foil: foil,
                language: language,
                condition: condition,
                notes: notes,
                lastCmTrendCents: lastCmTrendCents,
                lastCmAvg7Cents: lastCmAvg7Cents,
                lastCmAvg30Cents: lastCmAvg30Cents,
                lastCtBestCents: lastCtBestCents,
                lastCtZeroCents: lastCtZeroCents,
                lastCtDirectCents: lastCtDirectCents,
                valuedAt: valuedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                Value<int> quantity = const Value.absent(),
                required int paidCents,
                required DateTime purchasedAt,
                Value<bool?> foil = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int?> lastCmTrendCents = const Value.absent(),
                Value<int?> lastCmAvg7Cents = const Value.absent(),
                Value<int?> lastCmAvg30Cents = const Value.absent(),
                Value<int?> lastCtBestCents = const Value.absent(),
                Value<int?> lastCtZeroCents = const Value.absent(),
                Value<int?> lastCtDirectCents = const Value.absent(),
                Value<DateTime?> valuedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TrackedItemsCompanion.insert(
                id: id,
                cardId: cardId,
                quantity: quantity,
                paidCents: paidCents,
                purchasedAt: purchasedAt,
                foil: foil,
                language: language,
                condition: condition,
                notes: notes,
                lastCmTrendCents: lastCmTrendCents,
                lastCmAvg7Cents: lastCmAvg7Cents,
                lastCmAvg30Cents: lastCmAvg30Cents,
                lastCtBestCents: lastCtBestCents,
                lastCtZeroCents: lastCtZeroCents,
                lastCtDirectCents: lastCtDirectCents,
                valuedAt: valuedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackedItemsTable, TrackedItem>(table),
                  $$TrackedItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$TrackedItemsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$TrackedItemsTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackedItemsTable,
      TrackedItem,
      $$TrackedItemsTableFilterComposer,
      $$TrackedItemsTableOrderingComposer,
      $$TrackedItemsTableAnnotationComposer,
      $$TrackedItemsTableCreateCompanionBuilder,
      $$TrackedItemsTableUpdateCompanionBuilder,
      (TrackedItem, $$TrackedItemsTableReferences),
      TrackedItem,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$PriceSnapshotsTableCreateCompanionBuilder =
    PriceSnapshotsCompanion Function({
      Value<int> id,
      required int cardId,
      required String source,
      required DateTime capturedAt,
      Value<int?> cmTrendCents,
      Value<int?> cmLowCents,
      Value<int?> cmAvgCents,
      Value<int?> cmAvg7Cents,
      Value<int?> cmAvg30Cents,
      Value<int?> ctMinDirectCents,
      Value<int?> ctMinZeroCents,
      Value<int?> ctListingCount,
      Value<int?> ctZeroListingCount,
    });
typedef $$PriceSnapshotsTableUpdateCompanionBuilder =
    PriceSnapshotsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> source,
      Value<DateTime> capturedAt,
      Value<int?> cmTrendCents,
      Value<int?> cmLowCents,
      Value<int?> cmAvgCents,
      Value<int?> cmAvg7Cents,
      Value<int?> cmAvg30Cents,
      Value<int?> ctMinDirectCents,
      Value<int?> ctMinZeroCents,
      Value<int?> ctListingCount,
      Value<int?> ctZeroListingCount,
    });

final class $$PriceSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $PriceSnapshotsTable, PriceSnapshot> {
  $$PriceSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('price_snapshots__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PriceSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $PriceSnapshotsTable> {
  $$PriceSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cmTrendCents => $composableBuilder(
    column: $table.cmTrendCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cmLowCents => $composableBuilder(
    column: $table.cmLowCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cmAvgCents => $composableBuilder(
    column: $table.cmAvgCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cmAvg7Cents => $composableBuilder(
    column: $table.cmAvg7Cents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cmAvg30Cents => $composableBuilder(
    column: $table.cmAvg30Cents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ctMinDirectCents => $composableBuilder(
    column: $table.ctMinDirectCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ctMinZeroCents => $composableBuilder(
    column: $table.ctMinZeroCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ctListingCount => $composableBuilder(
    column: $table.ctListingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ctZeroListingCount => $composableBuilder(
    column: $table.ctZeroListingCount,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PriceSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceSnapshotsTable> {
  $$PriceSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cmTrendCents => $composableBuilder(
    column: $table.cmTrendCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cmLowCents => $composableBuilder(
    column: $table.cmLowCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cmAvgCents => $composableBuilder(
    column: $table.cmAvgCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cmAvg7Cents => $composableBuilder(
    column: $table.cmAvg7Cents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cmAvg30Cents => $composableBuilder(
    column: $table.cmAvg30Cents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ctMinDirectCents => $composableBuilder(
    column: $table.ctMinDirectCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ctMinZeroCents => $composableBuilder(
    column: $table.ctMinZeroCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ctListingCount => $composableBuilder(
    column: $table.ctListingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ctZeroListingCount => $composableBuilder(
    column: $table.ctZeroListingCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PriceSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceSnapshotsTable> {
  $$PriceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cmTrendCents => $composableBuilder(
    column: $table.cmTrendCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cmLowCents => $composableBuilder(
    column: $table.cmLowCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cmAvgCents => $composableBuilder(
    column: $table.cmAvgCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cmAvg7Cents => $composableBuilder(
    column: $table.cmAvg7Cents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cmAvg30Cents => $composableBuilder(
    column: $table.cmAvg30Cents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ctMinDirectCents => $composableBuilder(
    column: $table.ctMinDirectCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ctMinZeroCents => $composableBuilder(
    column: $table.ctMinZeroCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ctListingCount => $composableBuilder(
    column: $table.ctListingCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ctZeroListingCount => $composableBuilder(
    column: $table.ctZeroListingCount,
    builder: (column) => column,
  );

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PriceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceSnapshotsTable,
          PriceSnapshot,
          $$PriceSnapshotsTableFilterComposer,
          $$PriceSnapshotsTableOrderingComposer,
          $$PriceSnapshotsTableAnnotationComposer,
          $$PriceSnapshotsTableCreateCompanionBuilder,
          $$PriceSnapshotsTableUpdateCompanionBuilder,
          (PriceSnapshot, $$PriceSnapshotsTableReferences),
          PriceSnapshot,
          PrefetchHooks Function({bool cardId})
        > {
  $$PriceSnapshotsTableTableManager(
    _$AppDatabase db,
    $PriceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int?> cmTrendCents = const Value.absent(),
                Value<int?> cmLowCents = const Value.absent(),
                Value<int?> cmAvgCents = const Value.absent(),
                Value<int?> cmAvg7Cents = const Value.absent(),
                Value<int?> cmAvg30Cents = const Value.absent(),
                Value<int?> ctMinDirectCents = const Value.absent(),
                Value<int?> ctMinZeroCents = const Value.absent(),
                Value<int?> ctListingCount = const Value.absent(),
                Value<int?> ctZeroListingCount = const Value.absent(),
              }) => PriceSnapshotsCompanion(
                id: id,
                cardId: cardId,
                source: source,
                capturedAt: capturedAt,
                cmTrendCents: cmTrendCents,
                cmLowCents: cmLowCents,
                cmAvgCents: cmAvgCents,
                cmAvg7Cents: cmAvg7Cents,
                cmAvg30Cents: cmAvg30Cents,
                ctMinDirectCents: ctMinDirectCents,
                ctMinZeroCents: ctMinZeroCents,
                ctListingCount: ctListingCount,
                ctZeroListingCount: ctZeroListingCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String source,
                required DateTime capturedAt,
                Value<int?> cmTrendCents = const Value.absent(),
                Value<int?> cmLowCents = const Value.absent(),
                Value<int?> cmAvgCents = const Value.absent(),
                Value<int?> cmAvg7Cents = const Value.absent(),
                Value<int?> cmAvg30Cents = const Value.absent(),
                Value<int?> ctMinDirectCents = const Value.absent(),
                Value<int?> ctMinZeroCents = const Value.absent(),
                Value<int?> ctListingCount = const Value.absent(),
                Value<int?> ctZeroListingCount = const Value.absent(),
              }) => PriceSnapshotsCompanion.insert(
                id: id,
                cardId: cardId,
                source: source,
                capturedAt: capturedAt,
                cmTrendCents: cmTrendCents,
                cmLowCents: cmLowCents,
                cmAvgCents: cmAvgCents,
                cmAvg7Cents: cmAvg7Cents,
                cmAvg30Cents: cmAvg30Cents,
                ctMinDirectCents: ctMinDirectCents,
                ctMinZeroCents: ctMinZeroCents,
                ctListingCount: ctListingCount,
                ctZeroListingCount: ctZeroListingCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceSnapshotsTable, PriceSnapshot>(table),
                  $$PriceSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$PriceSnapshotsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$PriceSnapshotsTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PriceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceSnapshotsTable,
      PriceSnapshot,
      $$PriceSnapshotsTableFilterComposer,
      $$PriceSnapshotsTableOrderingComposer,
      $$PriceSnapshotsTableAnnotationComposer,
      $$PriceSnapshotsTableCreateCompanionBuilder,
      $$PriceSnapshotsTableUpdateCompanionBuilder,
      (PriceSnapshot, $$PriceSnapshotsTableReferences),
      PriceSnapshot,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$SyncRunsTableCreateCompanionBuilder = SyncRunsCompanion Function({
  Value<int> id,
  required String source,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  required String status,
  Value<String> message,
  Value<int> itemCount,
});
typedef $$SyncRunsTableUpdateCompanionBuilder = SyncRunsCompanion Function({
  Value<int> id,
  Value<String> source,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<String> status,
  Value<String> message,
  Value<int> itemCount,
});

class $$SyncRunsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRunsTable> {
  $$SyncRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRunsTable> {
  $$SyncRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRunsTable> {
  $$SyncRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);
}

class $$SyncRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncRunsTable,
          SyncRun,
          $$SyncRunsTableFilterComposer,
          $$SyncRunsTableOrderingComposer,
          $$SyncRunsTableAnnotationComposer,
          $$SyncRunsTableCreateCompanionBuilder,
          $$SyncRunsTableUpdateCompanionBuilder,
          (SyncRun, BaseReferences<_$AppDatabase, $SyncRunsTable, SyncRun>),
          SyncRun,
          PrefetchHooks Function()
        > {
  $$SyncRunsTableTableManager(_$AppDatabase db, $SyncRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
              }) => SyncRunsCompanion(
                id: id,
                source: source,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                message: message,
                itemCount: itemCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String source,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required String status,
                Value<String> message = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
              }) => SyncRunsCompanion.insert(
                id: id,
                source: source,
                startedAt: startedAt,
                finishedAt: finishedAt,
                status: status,
                message: message,
                itemCount: itemCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncRunsTable, SyncRun>(table),
                  BaseReferences<_$AppDatabase, $SyncRunsTable, SyncRun>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncRunsTable,
      SyncRun,
      $$SyncRunsTableFilterComposer,
      $$SyncRunsTableOrderingComposer,
      $$SyncRunsTableAnnotationComposer,
      $$SyncRunsTableCreateCompanionBuilder,
      $$SyncRunsTableUpdateCompanionBuilder,
      (SyncRun, BaseReferences<_$AppDatabase, $SyncRunsTable, SyncRun>),
      SyncRun,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$WatchlistItemsTableTableManager get watchlistItems =>
      $$WatchlistItemsTableTableManager(_db, _db.watchlistItems);
  $$TrackedItemsTableTableManager get trackedItems =>
      $$TrackedItemsTableTableManager(_db, _db.trackedItems);
  $$PriceSnapshotsTableTableManager get priceSnapshots =>
      $$PriceSnapshotsTableTableManager(_db, _db.priceSnapshots);
  $$SyncRunsTableTableManager get syncRuns =>
      $$SyncRunsTableTableManager(_db, _db.syncRuns);
}
