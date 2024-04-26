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
	col_description ( C.OID, col.ordinal_position ) AS description,
	col.column_default AS col_default,
	col.is_identity,
	col.identity_generation,
	col.identity_start,
	col.identity_increment,
	col.identity_maximum,
	col.identity_minimum,
	seq.seqcache :: information_schema.character_data AS identity_cache,
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
	col.table_schema = 'public' 
	AND col.TABLE_NAME = 'knowledge' 
ORDER BY
	col.table_schema,
	col.TABLE_NAME,
	col.ordinal_position