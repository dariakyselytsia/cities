// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserStatsModelCollection on Isar {
  IsarCollection<UserStatsModel> get userStatsModels => this.collection();
}

const UserStatsModelSchema = CollectionSchema(
  name: r'UserStatsModel',
  id: 272209145262056414,
  properties: {
    r'favoriteCountry': PropertySchema(
      id: 0,
      name: r'favoriteCountry',
      type: IsarType.string,
    ),
    r'highScoreUA': PropertySchema(
      id: 1,
      name: r'highScoreUA',
      type: IsarType.long,
    ),
    r'highScoreWorld': PropertySchema(
      id: 2,
      name: r'highScoreWorld',
      type: IsarType.long,
    ),
    r'longestStreak': PropertySchema(
      id: 3,
      name: r'longestStreak',
      type: IsarType.long,
    ),
    r'sessionHistory': PropertySchema(
      id: 4,
      name: r'sessionHistory',
      type: IsarType.objectList,

      target: r'GameSessionSummaryModel',
    ),
    r'usedCityIds': PropertySchema(
      id: 5,
      name: r'usedCityIds',
      type: IsarType.longList,
    ),
  },

  estimateSize: _userStatsModelEstimateSize,
  serialize: _userStatsModelSerialize,
  deserialize: _userStatsModelDeserialize,
  deserializeProp: _userStatsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'GameSessionSummaryModel': GameSessionSummaryModelSchema},

  getId: _userStatsModelGetId,
  getLinks: _userStatsModelGetLinks,
  attach: _userStatsModelAttach,
  version: '3.3.2',
);

int _userStatsModelEstimateSize(
  UserStatsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.favoriteCountry.length * 3;
  bytesCount += 3 + object.sessionHistory.length * 3;
  {
    final offsets = allOffsets[GameSessionSummaryModel]!;
    for (var i = 0; i < object.sessionHistory.length; i++) {
      final value = object.sessionHistory[i];
      bytesCount += GameSessionSummaryModelSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.usedCityIds.length * 8;
  return bytesCount;
}

void _userStatsModelSerialize(
  UserStatsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.favoriteCountry);
  writer.writeLong(offsets[1], object.highScoreUA);
  writer.writeLong(offsets[2], object.highScoreWorld);
  writer.writeLong(offsets[3], object.longestStreak);
  writer.writeObjectList<GameSessionSummaryModel>(
    offsets[4],
    allOffsets,
    GameSessionSummaryModelSchema.serialize,
    object.sessionHistory,
  );
  writer.writeLongList(offsets[5], object.usedCityIds);
}

UserStatsModel _userStatsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserStatsModel();
  object.favoriteCountry = reader.readString(offsets[0]);
  object.highScoreUA = reader.readLong(offsets[1]);
  object.highScoreWorld = reader.readLong(offsets[2]);
  object.id = id;
  object.longestStreak = reader.readLong(offsets[3]);
  object.sessionHistory =
      reader.readObjectList<GameSessionSummaryModel>(
        offsets[4],
        GameSessionSummaryModelSchema.deserialize,
        allOffsets,
        GameSessionSummaryModel(),
      ) ??
      [];
  object.usedCityIds = reader.readLongList(offsets[5]) ?? [];
  return object;
}

P _userStatsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readObjectList<GameSessionSummaryModel>(
                offset,
                GameSessionSummaryModelSchema.deserialize,
                allOffsets,
                GameSessionSummaryModel(),
              ) ??
              [])
          as P;
    case 5:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userStatsModelGetId(UserStatsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userStatsModelGetLinks(UserStatsModel object) {
  return [];
}

void _userStatsModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserStatsModel object,
) {
  object.id = id;
}

extension UserStatsModelQueryWhereSort
    on QueryBuilder<UserStatsModel, UserStatsModel, QWhere> {
  QueryBuilder<UserStatsModel, UserStatsModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserStatsModelQueryWhere
    on QueryBuilder<UserStatsModel, UserStatsModel, QWhereClause> {
  QueryBuilder<UserStatsModel, UserStatsModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserStatsModelQueryFilter
    on QueryBuilder<UserStatsModel, UserStatsModel, QFilterCondition> {
  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'favoriteCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'favoriteCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'favoriteCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'favoriteCountry',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'favoriteCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'favoriteCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'favoriteCountry',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'favoriteCountry',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'favoriteCountry', value: ''),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  favoriteCountryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'favoriteCountry', value: ''),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreUAEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'highScoreUA', value: value),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreUAGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'highScoreUA',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreUALessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'highScoreUA',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreUABetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'highScoreUA',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreWorldEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'highScoreWorld', value: value),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreWorldGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'highScoreWorld',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreWorldLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'highScoreWorld',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  highScoreWorldBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'highScoreWorld',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  longestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'longestStreak', value: value),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  longestStreakGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'longestStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  longestStreakLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'longestStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  longestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'longestStreak',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sessionHistory', length, true, length, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sessionHistory', 0, true, 0, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sessionHistory', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sessionHistory', 0, true, length, include);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sessionHistory', length, include, 999999, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sessionHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'usedCityIds', value: value),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'usedCityIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'usedCityIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'usedCityIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', length, true, length, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', 0, true, 0, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', 0, true, length, include);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', length, include, 999999, true);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  usedCityIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'usedCityIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension UserStatsModelQueryObject
    on QueryBuilder<UserStatsModel, UserStatsModel, QFilterCondition> {
  QueryBuilder<UserStatsModel, UserStatsModel, QAfterFilterCondition>
  sessionHistoryElement(FilterQuery<GameSessionSummaryModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sessionHistory');
    });
  }
}

extension UserStatsModelQueryLinks
    on QueryBuilder<UserStatsModel, UserStatsModel, QFilterCondition> {}

extension UserStatsModelQuerySortBy
    on QueryBuilder<UserStatsModel, UserStatsModel, QSortBy> {
  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByFavoriteCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteCountry', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByFavoriteCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteCountry', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByHighScoreUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreUA', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByHighScoreUADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreUA', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByHighScoreWorld() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreWorld', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByHighScoreWorldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreWorld', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  sortByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.desc);
    });
  }
}

extension UserStatsModelQuerySortThenBy
    on QueryBuilder<UserStatsModel, UserStatsModel, QSortThenBy> {
  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByFavoriteCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteCountry', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByFavoriteCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'favoriteCountry', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByHighScoreUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreUA', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByHighScoreUADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreUA', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByHighScoreWorld() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreWorld', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByHighScoreWorldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highScoreWorld', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QAfterSortBy>
  thenByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.desc);
    });
  }
}

extension UserStatsModelQueryWhereDistinct
    on QueryBuilder<UserStatsModel, UserStatsModel, QDistinct> {
  QueryBuilder<UserStatsModel, UserStatsModel, QDistinct>
  distinctByFavoriteCountry({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'favoriteCountry',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QDistinct>
  distinctByHighScoreUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highScoreUA');
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QDistinct>
  distinctByHighScoreWorld() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highScoreWorld');
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QDistinct>
  distinctByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreak');
    });
  }

  QueryBuilder<UserStatsModel, UserStatsModel, QDistinct>
  distinctByUsedCityIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usedCityIds');
    });
  }
}

extension UserStatsModelQueryProperty
    on QueryBuilder<UserStatsModel, UserStatsModel, QQueryProperty> {
  QueryBuilder<UserStatsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserStatsModel, String, QQueryOperations>
  favoriteCountryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoriteCountry');
    });
  }

  QueryBuilder<UserStatsModel, int, QQueryOperations> highScoreUAProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highScoreUA');
    });
  }

  QueryBuilder<UserStatsModel, int, QQueryOperations> highScoreWorldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highScoreWorld');
    });
  }

  QueryBuilder<UserStatsModel, int, QQueryOperations> longestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreak');
    });
  }

  QueryBuilder<UserStatsModel, List<GameSessionSummaryModel>, QQueryOperations>
  sessionHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionHistory');
    });
  }

  QueryBuilder<UserStatsModel, List<int>, QQueryOperations>
  usedCityIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usedCityIds');
    });
  }
}
