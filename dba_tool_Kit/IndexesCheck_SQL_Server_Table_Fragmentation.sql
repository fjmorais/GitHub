-- Add a column with ALTER INDEX REBUILD or REORGANIZE LATER.

SELECT OBJECT_NAME(ips.OBJECT_ID) as TableName
 ,sch.name
 ,i.NAME
 ,ips.index_id
 ,index_type_desc
 ,avg_fragmentation_in_percent
 ,avg_page_space_used_in_percent
 ,page_count
 , case when avg_fragmentation_in_percent < 30 THEN 'OK'
        when avg_fragmentation_in_percent >= 30 and avg_fragmentation_in_percent < 50 THEN 'Information'
        when avg_fragmentation_in_percent >= 50 and avg_fragmentation_in_percent < 80 THEN 'Warning - Pay Attention'
        when avg_fragmentation_in_percent >= 80 and avg_fragmentation_in_percent < 99 THEN 'Critical - Please considery REBUILD!'
        ELSE 'Value not Valid' END as [Desc]
 FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
INNER JOIN sys.indexes i ON (ips.object_id = i.object_id)
INNER JOIN sys.objects o on i.object_id = o.object_id
INNER JOIN sys.schemas sch on o.schema_id = sch.schema_id
 AND (ips.index_id = i.index_id)
WHERE
    sch.name = '<PUT THE SCHEMA NAME HERE>' -- eg.: 'CASADOCORRETOR'
and OBJECT_NAME(ips.OBJECT_ID) = '<PUT THE TABLE NAME HERE!>' -- eg.:  'previdencia_pre_implantacao_is'
