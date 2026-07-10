// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_summary_model.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const GameSessionSummaryModelSchema = Schema(
  name: r'GameSessionSummaryModel',
  id: 7226917099695748962,
  properties: {
    r'durationSeconds': PropertySchema(
      id: 0,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'mode': PropertySchema(id: 1, name: r'mode', type: IsarType.string),
    r'score': PropertySchema(id: 2, name: r'score', type: IsarType.long),
    r'sessionId': PropertySchema(
      id: 3,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'uniqueCities': PropertySchema(
      id: 4,
      name: r'uniqueCities',
      type: IsarType.long,
    ),
  },

  estimateSize: _gameSessionSummaryModelEstimateSize,
  serialize: _gameSessionSummaryModelSerialize,
  deserialize: _gameSessionSummaryModelDeserialize,
  deserializeProp: _gameSessionSummaryModelDeserializeProp,
);

int _gameSessionSummaryModelEstimateSize(
  GameSessionSummaryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mode.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  return bytesCount;
}

void _gameSessionSummaryModelSerialize(
  GameSessionSummaryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.durationSeconds);
  writer.writeString(offsets[1], object.mode);
  writer.writeLong(offsets[2], object.score);
  writer.writeString(offsets[3], object.sessionId);
  writer.writeLong(offsets[4], object.uniqueCities);
}

GameSessionSummaryModel _gameSessionSummaryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GameSessionSummaryModel();
  object.durationSeconds = reader.readLong(offsets[0]);
  object.mode = reader.readString(offsets[1]);
  object.score = reader.readLong(offsets[2]);
  object.sessionId = reader.readString(offsets[3]);
  object.uniqueCities = reader.readLong(offsets[4]);
  return object;
}

P _gameSessionSummaryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension GameSessionSummaryModelQueryFilter
    on
        QueryBuilder<
          GameSessionSummaryModel,
          GameSessionSummaryModel,
          QFilterCondition
        > {
  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationSeconds', value: value),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  durationSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'durationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  durationSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'durationSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'durationSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mode', value: ''),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  modeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mode', value: ''),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  scoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'score', value: value),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  scoreGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'score',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  scoreLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'score',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'score',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  uniqueCitiesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uniqueCities', value: value),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  uniqueCitiesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uniqueCities',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  uniqueCitiesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uniqueCities',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    GameSessionSummaryModel,
    GameSessionSummaryModel,
    QAfterFilterCondition
  >
  uniqueCitiesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uniqueCities',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension GameSessionSummaryModelQueryObject
    on
        QueryBuilder<
          GameSessionSummaryModel,
          GameSessionSummaryModel,
          QFilterCondition
        > {}
