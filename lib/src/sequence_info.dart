
// sequence knowledge_id2_seq:
//     cache_value: 1
//     data_type: integer
//     increment_by: 1
//     max_value: 2147483647
//     min_value: null
//     owner_column: id2
//     owner_table: knowledge
//     start_value: 1
class SequenceInfo {
  static const oidCol = 'oid';

  /// pg_class.relname
  static const sequenceNameCol = 'sequence_name';

  /// pg_namespace.nspname as schema_name
  static const schemaNameCol = 'schema_name';
  static const startValueCol = 'start_value';
  static const incrementByCol = 'increment_by';
  static const minValueCol = 'min_value';
  static const maxValueCol = 'max_value';
  static const cacheValueCol = 'cache_value';

  /// pg_depend.description AS comment
  static const commentCol = 'comment';
  static const ownTableCol = 'own_table';
  static const ownColumnCol = 'own_column';
  static const seqOwnerCol = 'seqowner';
}
