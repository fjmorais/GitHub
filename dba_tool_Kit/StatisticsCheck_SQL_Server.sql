USE
I4Pro_ERP_Icatu
GO

SELECT o.name AS [Object Name],
    o.[object_id],
    o.type_desc,
    s.name AS [Statistics Name],
       s.stats_id,
    s.no_recompute,
    s.auto_created,
    sp.modification_counter,
    sp.rows AS [Rows] , sp.rows_sampled,
       --CAST((sp.rows_sampled/sp.rows*100) as decimal (19,2)) as pctUpToDate,
       --100 - (sp.rows_sampled *100/sp.rows) as TotalDesatualizado,
       CASE rows WHEN 0 THEN 0 ELSE cast ((modification_counter*1./rows)*100 as numeric (18,2)) END AS ModificationPercentage,
       sp.last_updated,
    ' /* TAREFA IMPORTANTE PARA PERFORMANCE DA APLICAÇÂO NÂO FAZER KILL*/   UPDATE STATISTICS ' + o.name + ' (['+ s.name +'])' + ' WITH FULLSCAN , MAXDOP=2 '   as [statement]

FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.stats AS s WITH (NOLOCK)
ON s.object_id = o.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE o.type_desc NOT IN (N'SYSTEM_TABLE', N'INTERNAL_TABLE')
--AND sp.modification_counter > 0
--and sp.rows <> sp.rows_sampled
--AND o.name = 'corp_pessoas'
AND cast ((modification_counter*1./rows)*100 as numeric (18,2)) > 2.00
AND rows > 40000000
--AND s.name not LIKE '_WA%'
--and sp.rows_sampled > sp.rows*.010
--and (sp.rows_sampled *100/sp.rows) > 0
and o.name NOT IN  ('change_tables','captured_columns','syscolpars', 'sysobjvalues', 'sysidxstats','plan_persist_runtime_stats_interval','plan_persist_query','plan_persist_plan','plan_persist_runtime_stats','plan_persist_wait_stats') and object_name(s.object_id) not like 'comis%' and object_name(s.object_id) not like 'premio%' and object_name(s.object_id) not like 'tbl_relatorio%' and object_name(s.object_id) not like 'sys%' and object_name(s.object_id) not like 'sql%'
AND object_name (o.[object_id]) <> 'SQL Results$'
AND object_name (o.[object_id]) not like '%corp_interface_rel_poscad%'  AND object_name (o.[object_id]) not like '%plan_persist_query_text%'
