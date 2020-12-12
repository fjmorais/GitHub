

SELECT
  schema_name(schema_id) as SchemaName, OBJECT_NAME(si.object_id) as TableName, si.name as IndexName,
  (CASE is_primary_key WHEN 1 THEN 'PK' ELSE '' END) as PK,
  (CASE is_unique WHEN 1 THEN '1' ELSE '0' END)+' '+
  (CASE si.type WHEN 1 THEN 'C' WHEN 3 THEN 'X' ELSE 'B' END)+' '+  -- B=basic, C=Clustered, X=XML
  (CASE INDEXKEY_PROPERTY(si.object_id,index_id,1,'IsDescending') WHEN 0 THEN 'A' WHEN 1 THEN 'D' ELSE '' END)+
  (CASE INDEXKEY_PROPERTY(si.object_id,index_id,2,'IsDescending') WHEN 0 THEN 'A' WHEN 1 THEN 'D' ELSE '' END)+
  (CASE INDEXKEY_PROPERTY(si.object_id,index_id,3,'IsDescending') WHEN 0 THEN 'A' WHEN 1 THEN 'D' ELSE '' END)+
  (CASE INDEXKEY_PROPERTY(si.object_id,index_id,4,'IsDescending') WHEN 0 THEN 'A' WHEN 1 THEN 'D' ELSE '' END)+
  (CASE INDEXKEY_PROPERTY(si.object_id,index_id,5,'IsDescending') WHEN 0 THEN 'A' WHEN 1 THEN 'D' ELSE '' END)+
  (CASE INDEXKEY_PROPERTY(si.object_id,index_id,6,'IsDescending') WHEN 0 THEN 'A' WHEN 1 THEN 'D' ELSE '' END)+
  '' as 'Type',
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,1) as Key1,
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,2) as Key2,
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,3) as Key3,
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,4) as Key4,
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,5) as Key5,
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,6) as Key6,
  'ALTER INDEX ' + si.name + ' ON ' +  schema_name(schema_id) + '.' + OBJECT_NAME(si.object_id) + ' REBUILD WITH ( STATISTICS_INCREMENTAL=ON)'
FROM sys.indexes as si
LEFT JOIN sys.objects as so on so.object_id=si.object_id
WHERE index_id>0 -- omit the default heap
  and OBJECTPROPERTY(si.object_id,'IsMsShipped')=0 -- omit system tables
  and not (schema_name(schema_id)='dlkmumps' and OBJECT_NAME(si.object_id)='sysdiagrams') -- omit sysdiagrams
  and OBJECT_NAME(si.object_id) = 'tb_parcelasClb'
ORDER BY SchemaName,TableName,IndexName




ALTER INDEX index_certificadoassistenciasClb ON dlkmumps.tb_certificadoassistenciasClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)
ALTER INDEX PK_tb_certificadoassistenciasClb ON dlkmumps.tb_certificadoassistenciasClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)


ALTER INDEX index_coberturacertificadoClb ON dlkmumps.tb_coberturacertificadoClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)
ALTER INDEX PK_tb_coberturacertificadoClb ON dlkmumps.tb_coberturacertificadoClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)

ALTER INDEX index_historicomovimentacaoClb ON dlkmumps.tb_historicomovimentacaoClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)
ALTER INDEX PK_tb_historicomovimentacaoClb ON dlkmumps.tb_historicomovimentacaoClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)


ALTER INDEX index_parcelasClb ON dlkmumps.tb_parcelasClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)
ALTER INDEX PK_tb_parcelasClb ON dlkmumps.tb_parcelasClb REBUILD WITH ( STATISTICS_INCREMENTAL=ON)



SELECT
	i.name AS Index_name
	, i.Type_Desc AS Type_Desc
	, ds.name AS DataSpaceName
	, ds.type_desc AS DataSpaceTypeDesc
	, st.is_incremental
FROM sys.objects AS o
JOIN sys.indexes AS i 
ON o.object_id = i.object_id
JOIN sys.data_spaces ds 
ON ds.data_space_id = i.data_space_id
JOIN sys.stats st
ON st.object_id = o.object_id AND st.name = i.name
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s 
ON i.object_id = s.object_id 
AND i.index_id = s.index_id AND s.database_id = DB_ID()
WHERE o.type = 'U'
AND i.type <= 2
AND o.object_id = OBJECT_ID('dlkmumps.tb_parcelasClb')
 


 SELECT 
	OBJECT_NAME(a.object_id) TblName
	, a.stats_id
	, b.partition_number
	, b.last_updated
	, b.rows
	, b.rows_sampled
	, b.steps
	,*
FROM sys.stats a
CROSS APPLY sys.dm_db_incremental_stats_properties(a.object_id, a.stats_id) b
WHERE OBJECT_NAME(a.object_id) = 'tb_parcelasClb'


select top 1000 * from 
dlkmumps.tb_parcelasClb
where status_Endosso_parcela = 'PAGO                                                                                                '