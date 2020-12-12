SELECT TOP 50
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
 --AND t.[name] = 'MOVCOMISSAO'
 GROUP BY isnull (i.[name],'PK_CLUSTER'),
	t.[name] ,
	i.NAME ,
	avg_fragmentation_in_percent,
  page_count
ORDER BY 4 ASC



