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