
exec dbo.sp_GetProcStats @ProcName = 'spGetNotablePosts'
exec dbo.sp_requests

-- Exemplos de chamadas
set statistics io, time on
exec dbo.spGetNotablePosts @DtInicio = '2009-07-01 00:00:00', @DtFim = '2009-07-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-08-01 00:00:00', @DtFim = '2009-08-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-09-01 00:00:00', @DtFim = '2009-09-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-10-01 00:00:00', @DtFim = '2009-10-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-11-01 00:00:00', @DtFim = '2009-11-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-12-01 00:00:00', @DtFim = '2009-12-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-01-01 00:00:00', @DtFim = '2010-01-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-02-01 00:00:00', @DtFim = '2010-02-28 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-03-01 00:00:00', @DtFim = '2010-03-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-04-01 00:00:00', @DtFim = '2010-04-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-05-01 00:00:00', @DtFim = '2010-05-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-06-01 00:00:00', @DtFim = '2010-06-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-07-01 00:00:00', @DtFim = '2010-07-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-08-01 00:00:00', @DtFim = '2010-08-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-09-01 00:00:00', @DtFim = '2010-09-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-10-01 00:00:00', @DtFim = '2010-10-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-11-01 00:00:00', @DtFim = '2010-11-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-12-01 00:00:00', @DtFim = '2010-12-30 00:00:00'

/*
                 | 1    | 2    | 3   |
				 |------|------|-----|
AvgElapsedTimeMs |      |      |     |
MinElapsedTimeMs |      |      |     |
MaxElapsedTimeMs |      |      |     |
AvgLogicalReads  |      |      |     |

*/



----------------- QUAL O PROBLEMA NO NOSSO INDEX SEEK?
-- RESIDUAL PREDICATE PUSHDOWN
https://www.sqlshack.com/the-impact-of-residual-predicates-in-a-sql-server-index-seek-operation/
https://support.microsoft.com/en-us/help/3107397/improved-diagnostics-for-query-execution-plans-that-involve-residual-p

-- Number of rows read:     Number of actual rows accessed by SQL Server.
-- Actual Number of Rows:   Number of rows output from the operation.


----------------- SOLUÇÃO
USE [StackOverflow2010]
GO
select	(SELECT COUNT(*) FROM dbo.Posts) as TotalPosts
	,	(SELECT COUNT(DISTINCT CreationDate) FROM dbo.Posts) as CreationDate
	,	(SELECT COUNT(DISTINCT ViewCount) FROM dbo.Posts) as ViewCount
	,	(SELECT COUNT(DISTINCT CommentCount) FROM dbo.Posts) as CommentCount
	,	(SELECT COUNT(DISTINCT AnswerCount) FROM dbo.Posts) as AnswerCount
	,	(SELECT COUNT(DISTINCT AnswerQuality) FROM dbo.Posts) as AnswerQuality


-- Porém quase todas as condições sâo de RANGE (between e Maior que)
-- A única com condição de igualdade é AnswerQuality
-- Vamos ver a distribuição dos dados?
select AnswerQuality, COUNT(AnswerQuality) as Cont from dbo.Posts group by AnswerQuality order by AnswerQuality
select CreationDate, COUNT(CreationDate) as Cont from dbo.Posts group by CreationDate order by Cont desc


-- Vamos tentar pelo CreationDate e AnswerQuality?
USE [StackOverflow2010]
GO
-- DROP INDEX [Posts].[IX_Posts_CreationDate_AnswerQuality]
CREATE NONCLUSTERED INDEX [IX_Posts_CreationDate_AnswerQuality]
ON [dbo].[Posts] (CreationDate, AnswerQuality)
INCLUDE (Title, ViewCount, Score, AnswerCount, CommentCount, OwnerUserId)
GO

-- Quantos logical reads efetuamos?


exec sp_recompile spGetNotablePosts
-- Processar novamente


--================= ÍNDICE MAIS SELETIVO
-- E  se criarmos um novo Índice? Melhora?
USE [StackOverflow2010]
GO
-- DROP INDEX [Posts].[IX_Posts_AnswerQuality_CreationDate]
CREATE NONCLUSTERED INDEX [IX_Posts_AnswerQuality_CreationDate]
ON [dbo].[Posts] (AnswerQuality, CreationDate)
INCLUDE (Title, ViewCount, Score, AnswerCount, CommentCount, OwnerUserId)
GO

exec sp_recompile spGetNotablePosts
-- Processar novamente

