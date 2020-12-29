
SELECT *
FROM sys.tables
WHERE is_replicated = 1
and name in ('
corp_sub_cobertura',
'corp_produto',
'corp_forma_pagamento')
