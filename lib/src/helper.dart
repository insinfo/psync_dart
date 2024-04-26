import 'package:libpq_dart/libpq_dart.dart';

// scheme name | function | dataType | args type
// pg_catalog	 lo_create	 oid	      oid
// pg_catalog	 lo_lseek	   integer	  integer, integer, integer
List<Map<String, dynamic>> listLargeObjectsFunctions(LibPq conn) {
  final sql = r''' SELECT n.nspname as "Schema", p.proname as "função",
   pg_catalog.pg_get_function_result(p.oid) as "tipo de dados",
   pg_catalog.pg_get_function_arguments(p.oid) as "tipo de argumento"
   FROM pg_catalog.pg_proc p LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
   WHERE p.proname ~ '^(lo_.*)$'AND pg_catalog.pg_function_is_visible(p.oid)
 ORDER BY 1, 2, 4;
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}

List<Map<String, dynamic>> getTableInfo(LibPq conn, String table,
    {String schemaName = 'public'}) {
  final sql =
      '''SELECT c.oid, n.nspname AS schemaname, c.relname AS tablename, c.relacl, pg_get_userbyid(c.relowner) AS tableowner, 
  obj_description(c.oid) AS description, c.relkind, ci.relname As cluster, c.relhasindex AS hasindexes, 
  c.relhasrules AS hasrules, t.spcname AS tablespace, c.reloptions AS param, c.relhastriggers AS hastriggers,
   c.relpersistence AS unlogged, ft.ftoptions, fs.srvname, c.relispartition,
    pg_get_expr(c.relpartbound, c.oid) AS relpartbound, c.reltuples, 
    ((SELECT count(*) FROM pg_inherits WHERE inhparent = c.oid) > 0) AS inhtable, 
    i2.nspname AS inhschemaname, i2.relname AS inhtablename 
    FROM pg_class c 
    LEFT JOIN pg_namespace n ON n.oid = c.relnamespace 
    LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace 
    LEFT JOIN (pg_inherits i INNER JOIN pg_class c2 ON i.inhparent = c2.oid 
    LEFT JOIN pg_namespace n2 ON n2.oid = c2.relnamespace) i2 ON i2.inhrelid = c.oid 
    LEFT JOIN pg_index ind ON(ind.indrelid = c.oid) and (ind.indisclustered = 't') 
    LEFT JOIN pg_class ci ON ci.oid = ind.indexrelid LEFT JOIN pg_foreign_table ft ON ft.ftrelid = c.oid 
    LEFT JOIN pg_foreign_server fs ON ft.ftserver = fs.oid 
    WHERE ((c.relkind = 'r'::"char") OR (c.relkind = 'f'::"char") OR (c.relkind = 'p'::"char")) 
    AND n.nspname = '$schemaName' AND c.relname = '$table' 
    ORDER BY schemaname, tablename
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}

/// Lists all tables in a database
List<Map<String, dynamic>> getAllTables(LibPq db) {
  final result = db.exec(
      "select table_name from information_schema.tables where table_schema='public' and table_type='BASE TABLE'");
  return result.asMapList();
}

List<Map<String, dynamic>> getTableFields(LibPq conn, String table,
    {String schemaName = 'public'}) {
  final sql = '''
SELECT
	col.table_schema AS table_schema,
	col.table_name,
	col.column_name,
	col.character_maximum_length,
	col.is_nullable,
	col.numeric_precision,
	col.numeric_scale,
	col.datetime_precision,
	col.ordinal_position,
	b.atttypmod,
	b.attndims,
	col.data_type AS col_type,
	et.typelem,
	et.typlen,
	et.typtype,
	nbt.nspname AS elem_schema,
	bt.typname AS elem_name,
	b.atttypid,
	col.udt_schema,
	col.udt_name,
	col.domain_catalog,
	col.domain_schema,
	col.domain_name,
	col_description ( C.OID, col.ordinal_position ) AS comment,
	col.column_default AS col_default,
	col.is_identity,
	col.identity_generation,
	col.identity_start,
	col.identity_increment,
	col.identity_maximum,
	col.identity_minimum,
	seq.seqcache::information_schema.character_data AS identity_cache,
	col.identity_cycle,
	col.is_generated,
	col.generation_expression,
	b.attacl,
	colnsp.nspname AS collation_schema_name,
	coll.collname,
	C.relkind,
	b.attfdwoptions AS foreign_options 
FROM
	information_schema.COLUMNS AS col
	LEFT JOIN pg_namespace ns ON ns.nspname = col.table_schema
	LEFT JOIN pg_class C ON col.TABLE_NAME = C.relname 
	AND C.relnamespace = ns.
	OID LEFT JOIN pg_attrdef A ON C.OID = A.adrelid 
	AND col.ordinal_position = A.adnum
	LEFT JOIN pg_attribute b ON b.attrelid = C.OID 
	AND b.attname = col.
	COLUMN_NAME LEFT JOIN pg_type et ON et.OID = b.atttypid
	LEFT JOIN pg_collation coll ON coll.OID = b.attcollation
	LEFT JOIN pg_namespace colnsp ON coll.collnamespace = colnsp.
	OID LEFT JOIN (
		pg_depend dep
		JOIN pg_sequence seq ON dep.classid = 'pg_class' :: REGCLASS :: OID 
		AND dep.objid = seq.seqrelid 
		AND dep.deptype = 'i' :: "char" 
	) ON dep.refclassid = 'pg_class' :: REGCLASS :: OID 
	AND dep.refobjid = C.OID 
	AND dep.refobjsubid = b.attnum
	LEFT JOIN pg_type bt ON et.typelem = bt.
	OID LEFT JOIN pg_namespace nbt ON bt.typnamespace = nbt.OID 
WHERE
	col.table_schema = '$schemaName' 
	AND col.TABLE_NAME = '$table' 
ORDER BY
	col.table_schema,
	col.TABLE_NAME,
	col.ordinal_position
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}

List<Map<String, dynamic>> getTriggerInfo(LibPq conn, String table,
    {String schemaName = 'public'}) {
  final sql = '''
SELECT t.oid AS oid, (n.nspname)::information_schema.sql_identifier AS trigger_schema, 
(t.tgname)::information_schema.sql_identifier AS trigger_name, (c.relname)::information_schema.sql_identifier AS trigger_table_name,
 (em.text)::information_schema.character_data AS event_manipulation, (c.relkind)::information_schema.sql_identifier AS trigger_table_type, 
 (nsp.nspname)::information_schema.sql_identifier AS referenced_table_schema,
  (cs.relname)::information_schema.sql_identifier AS referenced_table, t.tgdeferrable AS is_deferrable,
   t.tginitdeferred AS is_deferred, (np.nspname)::information_schema.sql_identifier AS function_schema, 
   (p.proname)::information_schema.sql_identifier AS function_name, 
   ("substring"(pg_get_triggerdef(t.oid), 
   ("position"("substring"(pg_get_triggerdef(t.oid), 48), 'EXECUTE FUNCTION'::text) + 47)))::information_schema.character_data AS action_statement,
    (CASE WHEN (((t.tgtype)::integer & 1) = 1) THEN 
    'ROW'::text ELSE 'STATEMENT'::text END)::information_schema.character_data AS for_each,
     (CASE WHEN (((t.tgtype)::integer & 2) = 2) THEN 'BEFORE'::text ELSE 'AFTER'::text END)::information_schema.character_data AS fire_time,
      t.tgenabled AS enabled, (CASE WHEN pg_has_role(c.relowner, 'USAGE'::text) 
      THEN (SELECT rm.m[1] AS m FROM regexp_matches(pg_get_triggerdef(t.oid), (E'.{35,} WHEN \((.+)\) EXECUTE FUNCTION'::text)) rm(m) LIMIT 1)
       ELSE NULL::text END)::information_schema.character_data AS condition, tc.event_object_column AS update_columns, 
       (t.tgconstraint > 0) AS is_constraint, t.tgisinternal AS is_internal, obj_description(t.oid) AS comment 
       FROM pg_trigger t 
       INNER JOIN pg_class c ON t.tgrelid = c.oid 
       LEFT JOIN pg_namespace n ON c.relnamespace = n.oid 
       LEFT JOIN pg_proc p ON t.tgfoid = p.oid 
       LEFT JOIN pg_namespace np ON p.pronamespace = np.oid 
       LEFT JOIN (((SELECT 4, 'INSERT' UNION ALL SELECT 8, 'DELETE') 
       UNION ALL SELECT 16, 'UPDATE') UNION ALL SELECT 32, 'TRUNCATE') em(num, text) ON ((t.tgtype)::integer & em.num) <> 0 
       LEFT OUTER JOIN (SELECT oid, relnamespace, relname FROM pg_class) cs ON (t.tgconstrrelid = cs.oid) 
       LEFT OUTER JOIN (SELECT oid, nspname FROM pg_namespace) nsp ON (cs.relnamespace = nsp.oid) 
       LEFT JOIN information_schema.triggered_update_columns tc ON (tc.trigger_schema = n.nspname) 
       AND (tc.trigger_name = t.tgname) AND (tc.event_object_schema = n.nspname) 
       AND (tc.event_object_table = c.relname) 
WHERE (n.nspname)::information_schema.sql_identifier = '$schemaName'
AND (c.relname)::information_schema.sql_identifier = '$table' 
ORDER BY c.relname, t.tgname ASC
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}

List<Map<String, dynamic>> getAllOperatorName(LibPq conn) {
  final sql = '''
 SELECT opc.oid, opc.opcname, nsp.nspname FROM pg_opclass opc, pg_namespace nsp WHERE opc.opcnamespace = nsp.oid
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}

List<Map<String, dynamic>> getAllOperator(LibPq conn) {
  final sql = '''
 SELECT opr.oid, opr.oprname, nsp.nspname FROM pg_operator opr, pg_namespace nsp WHERE opr.oprnamespace = nsp.oid
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}

void addColComment(LibPq conn, String comment, String col, String table,
    {String schemaName = 'public'}) {
  final sql = '''COMMENT ON COLUMN "$schemaName"."$table"."$col" IS \$1;''';
  conn.execParams(sql, [comment]);
}

/// [col] column name
void addPrimaryKey(LibPq conn, String col, String table,
    {String schemaName = 'public'}) {
  final sql = '''ALTER TABLE "$schemaName"."$table" ADD PRIMARY KEY (\$1)''';
  conn.execParams(sql, [col]);
}

/// [col] column name
void removePrimaryKey(LibPq conn, String col, String table,
    {String schemaName = 'public'}) {
  //knowledge_pkey
  final pkey = '${col}_pkey';
  final sql = '''ALTER TABLE "$schemaName"."$table" DROP CONSTRAINT \$1''';
  conn.execParams(sql, [pkey]);
}

void addColSerial(LibPq conn, String col, String table,
    {String schemaName = 'public'}) {
  final sql = '''ALTER TABLE "$schemaName"."$table" ADD COLUMN "$col" serial''';
  conn.execParams(sql, [col]);
}

void removeCol(LibPq conn, String col, String table,
    {String schemaName = 'public'}) {
  final sql = '''ALTER TABLE "$schemaName"."$table" DROP COLUMN "$col"''';
  conn.execParams(sql, [col]);
}

List<Map<String, dynamic>> getAllSequence(LibPq conn) {
  final sql = '''
 SELECT 
cl.oid AS oid, 
ns.nspname AS schema_name, 
cl.relname AS sequence_name, 
dep.deptype AS deptype, 
seq.seqstart AS start_value, 
seq.seqincrement AS increment_by, 
seq.seqmin AS min_value, 
seq.seqmax AS max_value, 
seq.seqcache AS cache_value, 
seq.seqcycle AS is_cycled, 
pg_get_userbyid(cl.relowner) AS seqowner, 
cl.relacl AS acl, des.description AS comment, 
cl2.relname AS own_table, 
att.attname AS own_column 
FROM pg_class cl 
LEFT JOIN pg_namespace ns ON ns.oid = relnamespace 
LEFT JOIN pg_description des ON des.objoid = cl.oid 
LEFT JOIN pg_depend dep ON dep.objid = cl.oid 
LEFT JOIN pg_class cl2 ON cl2.oid = dep.refobjid 
LEFT JOIN pg_attribute att ON att.attrelid = dep.refobjid AND att.attnum = dep.refobjsubid 
LEFT JOIN pg_sequence seq ON seq.seqrelid = cl.oid 
WHERE cl.relkind = 'S' AND ns.nspname = 'public' 
ORDER BY cl.relname, dep.deptype DESC
 ''';
  final result = conn.exec(sql);
  return result.asMapList();
}
