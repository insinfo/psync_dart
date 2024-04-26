SELECT C.*,
	pgd.description 
FROM
	pg_catalog.pg_statio_all_tables AS st
	INNER JOIN information_schema.COLUMNS C ON C.table_schema = st.schemaname 
	AND C.TABLE_NAME = st.relname
	LEFT JOIN pg_catalog.pg_description pgd ON pgd.objoid = st.relid 
	AND pgd.objsubid = C.ordinal_position 
WHERE
	st.relname = 'knowledge';