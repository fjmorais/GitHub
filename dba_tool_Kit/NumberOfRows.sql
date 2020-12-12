DECLARE @TableName sysname
SET @TableName = 'tb_tracking_resolution_state'

SELECT TBL.object_id, TBL.name, SUM(PART.rows) AS rows
FROM sys.tables TBL
INNER JOIN sys.partitions PART ON TBL.object_id = PART.object_id
INNER JOIN sys.indexes IDX ON PART.object_id = IDX.object_id
AND PART.index_id = IDX.index_id
WHERE TBL.name = @TableName
AND IDX.index_id < 2
GROUP BY TBL.object_id, TBL.name;
