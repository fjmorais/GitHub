
SELECT *
FROM sys.tables
WHERE is_replicated = 1
and name in ('
corp_sub_cobertura',
'corp_produto',
'corp_forma_pagamento')


SELECT s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, is_replicated
FROM sys.tables tb
inner join sys.schemas s on s.schema_id = tb.schema_id
WHERE is_replicated = 1
