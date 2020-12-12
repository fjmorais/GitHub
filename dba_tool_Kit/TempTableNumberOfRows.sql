




 SELECT [st].[name] AS [TableName],
           [partitionStatistics].[row_count] AS [RowCount]
    FROM [tempdb].[sys].[dm_db_partition_stats] AS [partitionStatistics]
    INNER JOIN [tempdb].[sys].[tables] AS [st] ON [st].[object_id] = [partitionStatistics].[object_id]
    WHERE [st].[name] LIKE '%segs%'
      AND ([partitionStatistics].[index_id] = 0  --Table is a heap
           OR
           [partitionStatistics].[index_id] = 1  --Table has a clustered index
          )
