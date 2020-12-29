

SELECT *
FROM sys.tables
WHERE is_replicated = 0
and name in ('
corp_sub_cobertura',
'corp_produto',
'corp_forma_pagamento')


EXEC sp_droparticle
@publication= 'AR_PUBLICATION_00005',
@article= 'teste',
@force_invalidate_snapshot= 0


EXEC sp_addarticle
@publication = N'AR_PUBLICATION_00005',
@article = N'teste',
@source_owner = N'dbo',
@source_object = N'teste'
