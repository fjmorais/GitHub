USE
PGBL
GO


EXEC usp_Rebuild_PGBL 18,00,'PGBL', 200000

ALTER PROCEDURE usp_Rebuild_PGBL

(@hora int, @min int,@banco varchar(20), @logsizefinal int)

AS

BEGIN

SET NOCOUNT ON

--DROP TABLE #TableRebuildScripts

--SELECT char(9) + '[' + c.column_name + '] ' + c.data_type
--   + CASE WHEN c.data_type IN ('decimal')
--      THEN isnull('(' + convert(varchar, c.numeric_precision) + ', ' + convert(varchar, c.numeric_scale) + ')', '')
--      ELSE '' END
--   + CASE WHEN c.IS_NULLABLE = 'YES' THEN ' NULL' ELSE '' END
--   + ','
--From tempdb.INFORMATION_SCHEMA.COLUMNS c
--WHERE TABLE_NAME LIKE '%#TableRebuildScripts%'


IF GETDATE()> dateadd(mi,+@min,dateadd(hh,+@hora,cast(floor(cast(getdate()as float))as datetime)))-- hora > a entrada na procedure
BEGIN
RETURN
END



CREATE TABLE #TableRebuildScripts

(IdLoop int identity,
TableName VARCHAR(200),
IndexName VARCHAR(200),
avg_fragmentation_in_percent float,
page_count bigint,
QtdLinhas bigint,
IndexSizeMB bigint,
SCRIPT varchar (4000))


CREATE TABLE #execute
(idLoop bigint identity,
Script VARCHAR(4000),
Banco VARCHAR(60),
Tabela VARCHAR(120),
Indice VARCHAR(120),
IndexSizeMB bigint,
logSizeMB float,
logSpaceUsedPct float,
logSpaceUsedMB float,
LogSpaceUnusedMB float,
DataIni datetime,
DataFim datetime,
Duration VARCHAR(20)

)


CREATE TABLE #logspace
( [dbname] sysname
, logSizeMB float
, logSpaceUsedPct float
, Status int);


CREATE TABLE #logspace2
( [dbname] sysname
, logSizeMB float
, logSpaceUsedPct float
,LogSpaceUsedMB float
,LogSpaceUnusedMB Float);



INSERT INTO #TableRebuildScripts (TableName,IndexName,avg_fragmentation_in_percent,page_count,QtdLinhas,IndexSizeMB,SCRIPT)

SELECT
t.[name] AS TableName,
    isnull (i.[name],'PK_CLUSTER') AS IndexName,
    avg_fragmentation_in_percent,
  page_count,
 sum(p.rows) AS QtdLinhas,

    (SUM(s.[used_page_count]) * 8)/1024 AS IndexSizeMB  ,
	'ALTER INDEX ' + isnull (i.[name],'PK_CLUSTER') + ' ON ' + t.[name] + ' REBUILD WITH (ONLINE=ON)' AS SCRIPT


FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
INNER JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
						 ON (ips.object_id = i.object_id)
						 AND (ips.index_id = i.index_id)
INNER JOIN sys.tables t ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id
INNER JOIN sys.dm_db_partition_stats AS sts ON sts.[object_id] = i.[object_id]
										  AND sts.[index_id] = i.[index_id]
WHERE
 ips.database_id = DB_ID()
  AND page_count > 1000
  and avg_fragmentation_in_percent > 30
  AND t.[name] NOT IN ('MOVCOMISSAO','FUNDOSLD')
  and isnull (i.[name],'PK_CLUSTER') NOT IN ('PK_CLUSTER')
 GROUP BY isnull (i.[name],'PK_CLUSTER'),
	t.[name] ,
	i.NAME ,
	avg_fragmentation_in_percent,
  page_count
ORDER BY 4 ASC


--DECLARE @hora int
--DECLARE @min int
--DECLARE @banco varchar(20)


--SET @hora = 18
--SET @min = 30
--SET @banco = 'PGBL'

DECLARE @comando nvarchar(4000)
declare @Loop int
set @Loop = 1

DECLARE @logsize bigint
SET  @logsize = 1


--SELECT * FROM #TableRebuildScripts

while exists (select top 1 null from #TableRebuildScripts) OR @logsize < @logsizefinal

begin

-- Loop para a procedure n�o executar depois de 04:50 da manh�.
-- No Job, no SQL Server Agent, o mesmo deve ser agendado, com sugest�o, �s 02:00 da manh�.


INSERT INTO #logspace
EXEC ('DBCC SQLPERF(LOGSPACE);')

INSERT INTO #logspace2
SELECT dbname
, logSizeMB
, logSpaceUsedPct
, (logSizeMB * logSpaceUsedPct / 100) AS LogSpaceUsedMB
, logSizeMB - (logSizeMB * logSpaceUsedPct / 100) AS LogSpaceUnusedMB --INTO #logspace2
FROM #logspace
WHERE dbname = @banco -- Vari�vel de entrada


IF GETDATE()> dateadd(mi,+@min,dateadd(hh,+@hora,cast(floor(cast(getdate()as float))as datetime)))-- hora > a entrada na procedure

BEGIN
BREAK
END


--DECLARE @hora int
--DECLARE @min int
--DECLARE @banco varchar(20)


--SET @hora = 18
--SET @min = 30
--SET @banco = 'PGBL'


--declare @Loop int
--set @Loop = 2


INSERT INTO #execute (Script,Banco,Tabela,Indice,IndexSizeMB,DataIni,DataFim)
SELECT SCRIPT , @banco, TableName,IndexName,IndexSizeMB,Getdate() AS DataIni,NULL AS DataFim
from #TableRebuildScripts
where idloop = @Loop

--declare @Loop int
--set @Loop = 2

SELECT @comando = script
from #TableRebuildScripts
where idloop = @Loop

execute sp_executesql @comando


--declare @Loop int
--set @Loop = 2


UPDATE #execute SET DataFim = GETDATE()
WHERE DataFim IS NULL
AND idloop = @loop


--declare @Loop int
--set @Loop = 2


UPDATE #execute SET Duration = (SELECT convert(char(8),dateadd(s, datediff (s,DataIni,DataFim ),'1900-1-1'),8) AS DurationHH_MM_ss FROM #execute)
WHERE Duration IS NULL
AND idloop = @loop


--declare @Loop int
--set @Loop = 2


UPDATE #execute SET logSizeMB = (SELECT logSizeMB AS logSizeMB FROM #logspace WHERE dbname = 'PGBL')
WHERE logSizeMB IS NULL
AND idloop = @loop


--declare @Loop int
--set @Loop = 2


UPDATE #execute SET logSpaceUsedPct = (SELECT logSpaceUsedPct AS logSpaceUsedPct FROM #logspace WHERE dbname = 'PGBL')
WHERE logSpaceUsedPct IS NULL
AND idloop = @loop


--declare @Loop int
--set @Loop = 2


UPDATE #execute SET LogSpaceUsedMB = (SELECT LogSpaceUsedMB AS LogSpaceUsedMB FROM #logspace2 WHERE dbname = 'PGBL')
WHERE LogSpaceUsedMB IS NULL
AND idloop = @loop

--declare @Loop int
--set @Loop = 2

UPDATE #execute SET LogSpaceUnusedMB = (SELECT LogSpaceUnusedMB AS LogSpaceUnusedMB FROM #logspace2 WHERE dbname = 'PGBL')
WHERE LogSpaceUnusedMB IS NULL
AND idloop = @loop

--declare @Loop int
--set @Loop = 2


INSERT INTO DBA.dbo.Tb_rebuild_log (Script,Banco,Tabela,Indice,IndexSizeMB,logSizeMB,logSpaceUsedPct,logSpaceUsedMB,LogSpaceUnusedMB,DataIni,DataFim,Duration)
SELECT Script,Banco,Tabela,Indice,IndexSizeMB,logSizeMB,logSpaceUsedPct,logSpaceUsedMB,LogSpaceUnusedMB,DataIni,DataFim,Duration FROM #execute
where idloop = @Loop


delete from #TableRebuildScripts
where idloop = @Loop


delete from #execute
where idloop = @Loop


SELECT
@logsize = logSizeMB
FROM #logspace
WHERE dbname = @banco

SELECT
@logsize = cast( LogSpaceUsedMB AS bigint )
FROM #logspace2
WHERE dbname = @banco

if @logsize < 80000
-- start bkp log on sql server

DELETE FROM #logspace

DELETE FROM #logspace2


set @loop = @loop + 1
end

END


--USE
--DBA
--GO

--CREATE TABLE Tb_rebuild_log
--(id bigint identity,
--Script VARCHAR(4000),
--Banco VARCHAR(60),
--Tabela VARCHAR(120),
--Indice VARCHAR(120),
--IndexSizeMB bigint,
--logSizeMB float,
--logSpaceUsedPct float,
--logSpaceUsedMB float,
--LogSpaceUnusedMB float,
--DataIni datetime,
--DataFim datetime,
--Duration VARCHAR(20)

--)
