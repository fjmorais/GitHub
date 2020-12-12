
select
*
from
sysarticles

DECLARE @publication AS sysname;
DECLARE @article as sysname;
SET @publication=N'AR_PUBLICATION_00005';
SET @article=N'AR_ARTICLE_00005_1525580473';

--Drop the transactional article.
Use DLKMUMPS
EXEC sp_droparticle
   @publication=@publication,
   @article=@article,
   @force_invalidate_snapshot=1;
GO
