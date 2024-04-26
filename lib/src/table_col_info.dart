class TableColInfo {
  static const fqtn = 'information_schema.columns';

  static const columnNameCol = 'column_name';
  static const isNullableCol = 'is_nullable';
  static const dataTypeCol = 'data_type';
  static const columnDefaultCol = 'column_default';
  static const tableCatalogCol = 'table_catalog';
  static const tableSchemaCol = 'table_schema';
  static const tableNameCol = 'table_name';
  static const ordinalPositionCol = 'ordinal_position';
  static const characterMaximumLengthCol = 'character_maximum_length';

  /// comment from pg_catalog.pg_description
  static const descriptionCol = 'comment';

  String columnName;
  String isNullable;
  String dataType;
  String? columnDefault;
  String tableCatalog;
  String tableSchema;
  String tableName;
  String ordinalPosition;
  String? characterMaximumLength;

  /// comment from pg_catalog.pg_description
  String? description;

  bool get notNull {
    return isNullable != 'YES';
  }

  TableColInfo({
    required this.columnName,
    required this.isNullable,
    required this.dataType,
    this.columnDefault,
    required this.tableCatalog,
    required this.tableSchema,
    required this.tableName,
    required this.ordinalPosition,
    this.characterMaximumLength,
    this.description,
  });

  factory TableColInfo.fromMap(Map<String, dynamic> map) {
    final tableInfo = TableColInfo(
      columnName: map[columnNameCol],
      isNullable: map[TableColInfo.isNullableCol],
      dataType: map[TableColInfo.dataTypeCol],
      columnDefault: map[TableColInfo.columnDefaultCol],
      tableCatalog: map[TableColInfo.tableCatalogCol],
      tableSchema: map[TableColInfo.tableSchemaCol],
      tableName: map[TableColInfo.tableNameCol],
      ordinalPosition: map[TableColInfo.ordinalPositionCol],
      characterMaximumLength: map[TableColInfo.characterMaximumLengthCol],
      description: map[TableColInfo.descriptionCol],
    );

    return tableInfo;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      TableColInfo.columnNameCol: columnName,
      TableColInfo.isNullableCol: isNullable,
      TableColInfo.dataTypeCol: dataType,
      TableColInfo.columnDefaultCol: columnDefault,
      TableColInfo.tableCatalogCol: tableCatalog,
      TableColInfo.tableSchemaCol: tableSchema,
      TableColInfo.tableNameCol: tableName,
      TableColInfo.ordinalPositionCol: ordinalPosition,
      TableColInfo.characterMaximumLengthCol: characterMaximumLength
    };

    if (description != null) {
      map[TableColInfo.descriptionCol] = description;
    }

    return map;
  }
}
