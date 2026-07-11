// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGameSessionModelCollection on Isar {
  IsarCollection<GameSessionModel> get gameSessionModels => this.collection();
}

const GameSessionModelSchema = CollectionSchema(
  name: r'GameSessionModel',
  id: -6004531957099909852,
  properties: {
    r'isActive': PropertySchema(id: 0, name: r'isActive', type: IsarType.bool),
    r'language': PropertySchema(
      id: 1,
      name: r'language',
      type: IsarType.string,
    ),
    r'mode': PropertySchema(id: 2, name: r'mode', type: IsarType.string),
    r'score': PropertySchema(id: 3, name: r'score', type: IsarType.long),
    r'sessionId': PropertySchema(
      id: 4,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'timerSeconds': PropertySchema(
      id: 5,
      name: r'timerSeconds',
      type: IsarType.long,
    ),
    r'usedCityIds': PropertySchema(
      id: 6,
      name: r'usedCityIds',
      type: IsarType.longList,
    ),
  },

  estimateSize: _gameSessionModelEstimateSize,
  serialize: _gameSessionModelSerialize,
  deserialize: _gameSessionModelDeserialize,
  deserializeProp: _gameSessionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _gameSessionModelGetId,
  getLinks: _gameSessionModelGetLinks,
  attach: _gameSessionModelAttach,
  version: '3.3.2',
);

int _gameSessionModelEstimateSize(
  GameSessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.mode.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.usedCityIds.length * 8;
  return bytesCount;
}

void _gameSessionModelSerialize(
  GameSessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isActive);
  writer.writeString(offsets[1], object.language);
  writer.writeString(offsets[2], object.mode);
  writer.writeLong(offsets[3], object.score);
  writer.writeString(offsets[4], object.sessionId);
  writer.writeLong(offsets[5], object.timerSeconds);
  writer.writeLongList(offsets[6], object.usedCityIds);
}

GameSessionModel _gameSessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GameSessionModel();
  object.id = id;
  object.isActive = reader.readBool(offsets[0]);
  object.language = reader.readString(offsets[1]);
  object.mode = reader.readString(offsets[2]);
  object.score = reader.readLong(offsets[3]);
  object.sessionId = reader.readString(offsets[4]);
  object.timerSeconds = reader.readLong(offsets[5]);
  object.usedCityIds = reader.readLongList(offsets[6]) ?? [];
  return object;
}

P _gameSessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gameSessionModelGetId(GameSessionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gameSessionModelGetLinks(GameSessionModel object) {
  return [];
}

void _gameSessionModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  GameSessionModel object,
) {
  object.id = id;
}

extension GameSessionModelQueryWhereSort
    on QueryBuilder<GameSessionModel, GameSessionModel, QWhere> {
  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GameSessionModelQueryWhere
    on QueryBuilder<GameSessionModel, GameSessionModel, QWhereClause> {
  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause>
  sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sessionId', value: [sessionId]),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterWhereClause>
  sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension GameSessionModelQueryFilter
    on QueryBuilder<GameSessionModel, GameSessionModel, QFilterCondition> {
  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isActive', value: value),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'language',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  modeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mode', value: ''),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  modeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mode', value: ''),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  scoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'score', value: value),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  timerSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timerSeconds', value: value),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  timerSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timerSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  timerSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timerSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  timerSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timerSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  usedCityIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'usedCityIds', value: value),
      );
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  usedCityIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', length, true, length, true);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  usedCityIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', 0, true, 0, true);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  usedCityIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  usedCityIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', 0, true, length, include);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
  usedCityIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'usedCityIds', length, include, 999999, true);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterFilterCondition>
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

extension GameSessionModelQueryObject
    on QueryBuilder<GameSessionModel, GameSessionModel, QFilterCondition> {}

extension GameSessionModelQueryLinks
    on QueryBuilder<GameSessionModel, GameSessionModel, QFilterCondition> {}

extension GameSessionModelQuerySortBy
    on QueryBuilder<GameSessionModel, GameSessionModel, QSortBy> {
  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy> sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByTimerSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  sortByTimerSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.desc);
    });
  }
}

extension GameSessionModelQuerySortThenBy
    on QueryBuilder<GameSessionModel, GameSessionModel, QSortThenBy> {
  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy> thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByTimerSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.asc);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QAfterSortBy>
  thenByTimerSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerSeconds', Sort.desc);
    });
  }
}

extension GameSessionModelQueryWhereDistinct
    on QueryBuilder<GameSessionModel, GameSessionModel, QDistinct> {
  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct>
  distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct>
  distinctByLanguage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct> distinctByMode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct>
  distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct>
  distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct>
  distinctByTimerSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timerSeconds');
    });
  }

  QueryBuilder<GameSessionModel, GameSessionModel, QDistinct>
  distinctByUsedCityIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usedCityIds');
    });
  }
}

extension GameSessionModelQueryProperty
    on QueryBuilder<GameSessionModel, GameSessionModel, QQueryProperty> {
  QueryBuilder<GameSessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GameSessionModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<GameSessionModel, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<GameSessionModel, String, QQueryOperations> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mode');
    });
  }

  QueryBuilder<GameSessionModel, int, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<GameSessionModel, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<GameSessionModel, int, QQueryOperations> timerSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timerSeconds');
    });
  }

  QueryBuilder<GameSessionModel, List<int>, QQueryOperations>
  usedCityIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usedCityIds');
    });
  }
}
