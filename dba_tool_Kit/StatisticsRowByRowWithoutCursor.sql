CREATE PROCEDURE [dbo].[usp_Atualiza_Estatisticas_I4Pro_ERP_Icatu] (@hora int, @min int,@banco varchar(20))

AS

BEGIN

SET NOCOUNT ON

-- Loop para a procedure não executar depois de 04:50 da manhã.
-- No Job, no SQL Server Agent, o mesmo deve ser agendado, com sugestão, às 02:00 da manhã.          
-- Essa informação de hora deve ser inserida como parâmetro de entrada na procedure.

IF GETDATE()> dateadd(mi,+@min,dateadd(hh,+@hora,cast(floor(cast(getdate()as float))as datetime)))-- hora > a entrada na procedure

BEGIN

RETURN

END



CREATE TABLE #scriptexecuçãoestatistics

(

id_estatistica int identity (1,1),

ds_comando varchar(4000),

nr_linha int)





;WITH script_update AS

(

SELECT o.name AS [Object Name], o.[object_id], o.type_desc, s.name AS [Statistics Name],

       s.stats_id, s.no_recompute, s.auto_created,

    sp.modification_counter, sp.rows, sp.rows_sampled,

    --CAST((sp.rows_sampled/sp.rows*100) as decimal (19,2)) as pctUpToDate,

   100 - (sp.rows_sampled *100/sp.rows) as TotalDesatualizado,

    sp.last_updated, 'UPDATE STATISTICS ' + o.name + ' (['+ s.name +'])' + ' WITH FULLSCAN ,MAXDOP = 2'   as [statement]

FROM sys.objects AS o WITH (NOLOCK)

INNER JOIN sys.stats AS s WITH (NOLOCK)

ON s.object_id = o.object_id

CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp

WHERE o.type_desc NOT IN (N'SYSTEM_TABLE', N'INTERNAL_TABLE')
--AND sp.modification_counter > 0
and sp.rows <> sp.rows_sampled
--and sp.rows_sampled > sp.rows*.010
--and (sp.rows_sampled *100/sp.rows) > 0
and o.name NOT IN  ( 'syscolpars', 'sysobjvalues', 'sysidxstats','plan_persist_runtime_stats_interval','plan_persist_query','plan_persist_plan','plan_persist_runtime_stats','plan_persist_wait_stats') and object_name(s.object_id) not like 'comis%' and obje
ct_name(s.object_id) not like 'premio%' and object_name(s.object_id) not like 'tbl_relatorio%' and object_name(s.object_id) not like 'sys%' and object_name(s.object_id) not like 'sql%'
AND object_name (o.[object_id]) <> 'SQL Results$'
AND object_name (o.[object_id]) not like '%corp_interface_rel_poscad%'
AND object_name (o.[object_id]) not like '%plan_persist_query_text%'


)



INSERT INTO #scriptexecuçãoestatistics (ds_comando,nr_linha)

SELECT [statement],rows

FROM script_update

ORDER BY rows    ASC



declare @Loop int,@comando nvarchar(4000)

set @Loop = 1



while exists (select top 1 null from #scriptexecuçãoestatistics)



begin



-- Loop para a procedure não executar depois de 04:50 da manhã.

-- No Job, no SQL Server Agent, o mesmo deve ser agendado, com sugestão, às 02:00 da manhã.



IF GETDATE()> dateadd(mi,+@min,dateadd(hh,+@hora,cast(floor(cast(getdate()as float))as datetime)))-- hora > a entrada na procedure

BEGIN

BREAK

END



SELECT @comando = ds_comando

from #scriptexecuçãoestatistics

where id_estatistica = @Loop



exec sp_executesql @comando


INSERT INTO DBA.dbo.update_statistics_log

SELECT ds_comando, @banco,GETDATE()

from #scriptexecuçãoestatistics

where id_estatistica = @Loop





delete from #scriptexecuçãoestatistics

where id_estatistica = @Loop



set @loop = @loop + 1

end

END
