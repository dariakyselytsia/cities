// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCityModelCollection on Isar {
  IsarCollection<CityModel> get cityModels => this.collection();
}

const CityModelSchema = CollectionSchema(
  name: r'CityModel',
  id: 6875720243144095242,
  properties: {
    r'countryCode': PropertySchema(
      id: 0,
      name: r'countryCode',
      type: IsarType.string,
    ),
    r'firstLetterEN': PropertySchema(
      id: 1,
      name: r'firstLetterEN',
      type: IsarType.string,
    ),
    r'firstLetterUA': PropertySchema(
      id: 2,
      name: r'firstLetterUA',
      type: IsarType.string,
    ),
    r'isCapital': PropertySchema(
      id: 3,
      name: r'isCapital',
      type: IsarType.bool,
    ),
    r'nameEN': PropertySchema(id: 4, name: r'nameEN', type: IsarType.string),
    r'nameUA': PropertySchema(id: 5, name: r'nameUA', type: IsarType.string),
  },

  estimateSize: _cityModelEstimateSize,
  serialize: _cityModelSerialize,
  deserialize: _cityModelDeserialize,
  deserializeProp: _cityModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'nameUA': IndexSchema(
      id: -90422192905996934,
      name: r'nameUA',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameUA',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'nameEN': IndexSchema(
      id: -2175834221958601112,
      name: r'nameEN',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameEN',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'firstLetterUA': IndexSchema(
      id: -2057832643227154729,
      name: r'firstLetterUA',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firstLetterUA',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'firstLetterEN': IndexSchema(
      id: -8947607861363366508,
      name: r'firstLetterEN',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firstLetterEN',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _cityModelGetId,
  getLinks: _cityModelGetLinks,
  attach: _cityModelAttach,
  version: '3.3.2',
);

int _cityModelEstimateSize(
  CityModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.countryCode.length * 3;
  bytesCount += 3 + object.firstLetterEN.length * 3;
  bytesCount += 3 + object.firstLetterUA.length * 3;
  bytesCount += 3 + object.nameEN.length * 3;
  bytesCount += 3 + object.nameUA.length * 3;
  return bytesCount;
}

void _cityModelSerialize(
  CityModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.countryCode);
  writer.writeString(offsets[1], object.firstLetterEN);
  writer.writeString(offsets[2], object.firstLetterUA);
  writer.writeBool(offsets[3], object.isCapital);
  writer.writeString(offsets[4], object.nameEN);
  writer.writeString(offsets[5], object.nameUA);
}

CityModel _cityModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CityModel();
  object.countryCode = reader.readString(offsets[0]);
  object.firstLetterEN = reader.readString(offsets[1]);
  object.firstLetterUA = reader.readString(offsets[2]);
  object.id = id;
  object.isCapital = reader.readBool(offsets[3]);
  object.nameEN = reader.readString(offsets[4]);
  object.nameUA = reader.readString(offsets[5]);
  return object;
}

P _cityModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cityModelGetId(CityModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cityModelGetLinks(CityModel object) {
  return [];
}

void _cityModelAttach(IsarCollection<dynamic> col, Id id, CityModel object) {
  object.id = id;
}

extension CityModelQueryWhereSort
    on QueryBuilder<CityModel, CityModel, QWhere> {
  QueryBuilder<CityModel, CityModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CityModelQueryWhere
    on QueryBuilder<CityModel, CityModel, QWhereClause> {
  QueryBuilder<CityModel, CityModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> nameUAEqualTo(
    String nameUA,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nameUA', value: [nameUA]),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> nameUANotEqualTo(
    String nameUA,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameUA',
                lower: [],
                upper: [nameUA],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameUA',
                lower: [nameUA],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameUA',
                lower: [nameUA],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameUA',
                lower: [],
                upper: [nameUA],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> nameENEqualTo(
    String nameEN,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nameEN', value: [nameEN]),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> nameENNotEqualTo(
    String nameEN,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameEN',
                lower: [],
                upper: [nameEN],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameEN',
                lower: [nameEN],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameEN',
                lower: [nameEN],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameEN',
                lower: [],
                upper: [nameEN],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> firstLetterUAEqualTo(
    String firstLetterUA,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'firstLetterUA',
          value: [firstLetterUA],
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> firstLetterUANotEqualTo(
    String firstLetterUA,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterUA',
                lower: [],
                upper: [firstLetterUA],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterUA',
                lower: [firstLetterUA],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterUA',
                lower: [firstLetterUA],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterUA',
                lower: [],
                upper: [firstLetterUA],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> firstLetterENEqualTo(
    String firstLetterEN,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'firstLetterEN',
          value: [firstLetterEN],
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterWhereClause> firstLetterENNotEqualTo(
    String firstLetterEN,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterEN',
                lower: [],
                upper: [firstLetterEN],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterEN',
                lower: [firstLetterEN],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterEN',
                lower: [firstLetterEN],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'firstLetterEN',
                lower: [],
                upper: [firstLetterEN],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CityModelQueryFilter
    on QueryBuilder<CityModel, CityModel, QFilterCondition> {
  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> countryCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'countryCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  countryCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'countryCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> countryCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'countryCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> countryCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'countryCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  countryCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'countryCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> countryCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'countryCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> countryCodeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'countryCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> countryCodeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'countryCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  countryCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'countryCode', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  countryCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'countryCode', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'firstLetterEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstLetterEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstLetterEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstLetterEN',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'firstLetterEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'firstLetterEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'firstLetterEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'firstLetterEN',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstLetterEN', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterENIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'firstLetterEN', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'firstLetterUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstLetterUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUALessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstLetterUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUABetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstLetterUA',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'firstLetterUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'firstLetterUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'firstLetterUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'firstLetterUA',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstLetterUA', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition>
  firstLetterUAIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'firstLetterUA', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> isCapitalEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isCapital', value: value),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameEN',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameEN',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameEN',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameEN', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameENIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameEN', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUALessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUABetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameUA',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameUA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameUA',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameUA', value: ''),
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterFilterCondition> nameUAIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameUA', value: ''),
      );
    });
  }
}

extension CityModelQueryObject
    on QueryBuilder<CityModel, CityModel, QFilterCondition> {}

extension CityModelQueryLinks
    on QueryBuilder<CityModel, CityModel, QFilterCondition> {}

extension CityModelQuerySortBy on QueryBuilder<CityModel, CityModel, QSortBy> {
  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByFirstLetterEN() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterEN', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByFirstLetterENDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterEN', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByFirstLetterUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterUA', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByFirstLetterUADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterUA', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByIsCapital() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCapital', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByIsCapitalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCapital', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByNameEN() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEN', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByNameENDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEN', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByNameUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUA', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> sortByNameUADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUA', Sort.desc);
    });
  }
}

extension CityModelQuerySortThenBy
    on QueryBuilder<CityModel, CityModel, QSortThenBy> {
  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByFirstLetterEN() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterEN', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByFirstLetterENDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterEN', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByFirstLetterUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterUA', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByFirstLetterUADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLetterUA', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByIsCapital() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCapital', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByIsCapitalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCapital', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByNameEN() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEN', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByNameENDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEN', Sort.desc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByNameUA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUA', Sort.asc);
    });
  }

  QueryBuilder<CityModel, CityModel, QAfterSortBy> thenByNameUADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameUA', Sort.desc);
    });
  }
}

extension CityModelQueryWhereDistinct
    on QueryBuilder<CityModel, CityModel, QDistinct> {
  QueryBuilder<CityModel, CityModel, QDistinct> distinctByCountryCode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countryCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CityModel, CityModel, QDistinct> distinctByFirstLetterEN({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'firstLetterEN',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QDistinct> distinctByFirstLetterUA({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'firstLetterUA',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CityModel, CityModel, QDistinct> distinctByIsCapital() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCapital');
    });
  }

  QueryBuilder<CityModel, CityModel, QDistinct> distinctByNameEN({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameEN', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CityModel, CityModel, QDistinct> distinctByNameUA({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameUA', caseSensitive: caseSensitive);
    });
  }
}

extension CityModelQueryProperty
    on QueryBuilder<CityModel, CityModel, QQueryProperty> {
  QueryBuilder<CityModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CityModel, String, QQueryOperations> countryCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countryCode');
    });
  }

  QueryBuilder<CityModel, String, QQueryOperations> firstLetterENProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstLetterEN');
    });
  }

  QueryBuilder<CityModel, String, QQueryOperations> firstLetterUAProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstLetterUA');
    });
  }

  QueryBuilder<CityModel, bool, QQueryOperations> isCapitalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCapital');
    });
  }

  QueryBuilder<CityModel, String, QQueryOperations> nameENProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameEN');
    });
  }

  QueryBuilder<CityModel, String, QQueryOperations> nameUAProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameUA');
    });
  }
}
