
--Verificar as tabelas particionadas

select distinct t.name
from sys.partitions p
inner join sys.tables t
on p.object_id = t.object_id
where p.partition_number <> 1

-- A tabela corp_item_vida_cobertura não está particionadas.
-- faz fk com a tabela I4Pro_ERP_Icatu.dbo.corp_item_vida_cobertura_cancelamento: FK_corp_item_vida_cobertura_cancelamento_corp_item_vida_cobertura


-- Verificar os índices existentes

-- KDF9's concise index list for SQL Server 2005+  (see below for 2000)
--   includes schemas and primary keys, in easy to read format
--   with unique, clustered, and all ascending/descendings in a single column
-- Needs simple manual add or delete to change maximum number of key columns
--   but is easy to understand and modify, with no UDFs or complex logic
--
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
  INDEX_COL(schema_name(schema_id)+'.'+OBJECT_NAME(si.object_id),index_id,6) as Key6
FROM sys.indexes as si
LEFT JOIN sys.objects as so on so.object_id=si.object_id
WHERE index_id>0 -- omit the default heap
  and OBJECTPROPERTY(si.object_id,'IsMsShipped')=0 -- omit system tables
  and not (schema_name(schema_id)='dbo' and OBJECT_NAME(si.object_id)='sysdiagrams') -- omit sysdiagrams
  and OBJECT_NAME(si.object_id) = 'corp_item_vida_cobertura'
ORDER BY SchemaName,TableName,IndexName

-- Verificar Indices query 02

SELECT '[' + s.NAME + '].[' + o.NAME + ']' AS 'table_name'
    ,+ i.NAME AS 'index_name'
    ,LOWER(i.type_desc) + CASE 
        WHEN i.is_unique = 1
            THEN ', unique'
        ELSE ''
        END + CASE 
        WHEN i.is_primary_key = 1
            THEN ', primary key'
        ELSE ''
        END AS 'index_description'
    ,STUFF((
            SELECT ', [' + sc.NAME + ']' AS "text()"
            FROM syscolumns AS sc
            INNER JOIN sys.index_columns AS ic ON ic.object_id = sc.id
                AND ic.column_id = sc.colid
            WHERE sc.id = so.object_id
                AND ic.index_id = i1.indid
                AND ic.is_included_column = 0
            ORDER BY key_ordinal
            FOR XML PATH('')
            ), 1, 2, '') AS 'indexed_columns'
    ,STUFF((
            SELECT ', [' + sc.NAME + ']' AS "text()"
            FROM syscolumns AS sc
            INNER JOIN sys.index_columns AS ic ON ic.object_id = sc.id
                AND ic.column_id = sc.colid
            WHERE sc.id = so.object_id
                AND ic.index_id = i1.indid
                AND ic.is_included_column = 1
            FOR XML PATH('')
            ), 1, 2, '') AS 'included_columns'
FROM sysindexes AS i1
INNER JOIN sys.indexes AS i ON i.object_id = i1.id
    AND i.index_id = i1.indid
INNER JOIN sysobjects AS o ON o.id = i1.id
INNER JOIN sys.objects AS so ON so.object_id = o.id
    AND is_ms_shipped = 0
INNER JOIN sys.schemas AS s ON s.schema_id = so.schema_id
WHERE so.type = 'U'
    AND i1.indid < 255
    AND i1.STATUS & 64 = 0 --index with duplicates
    AND i1.STATUS & 8388608 = 0 --auto created index
    AND i1.STATUS & 16777216 = 0 --stats no recompute
    AND i.type_desc <> 'heap'
    AND so.NAME <> 'sysdiagrams'
	and o.NAME = 'corp_item_vida_cobertura'
ORDER BY table_name
    ,index_name;


-- Query verificação de indices parte 03

SELECT INX.[name] AS [Index Name]
      ,TBL.[name] AS [Table Name]
      ,DS1.[IndexColumnsNames]
      ,DS2.[IncludedColumnsNames]
FROM [sys].[indexes] INX
INNER JOIN [sys].[tables] TBL
    ON INX.[object_id] = TBL.[object_id]
CROSS APPLY 
(
    SELECT STUFF
    (
        (
            SELECT ' [' + CLS.[name] + ']'
            FROM [sys].[index_columns] INXCLS
            INNER JOIN [sys].[columns] CLS 
                ON INXCLS.[object_id] = CLS.[object_id] 
                AND INXCLS.[column_id] = CLS.[column_id]
            WHERE INX.[object_id] = INXCLS.[object_id] 
                AND INX.[index_id] = INXCLS.[index_id]
                AND INXCLS.[is_included_column] = 0
            FOR XML PATH('')
        )
        ,1
        ,1
        ,''
    ) 
) DS1 ([IndexColumnsNames])
CROSS APPLY 
(
    SELECT STUFF
    (
        (
            SELECT ' [' + CLS.[name] + ']'
            FROM [sys].[index_columns] INXCLS
            INNER JOIN [sys].[columns] CLS 
                ON INXCLS.[object_id] = CLS.[object_id] 
                AND INXCLS.[column_id] = CLS.[column_id]
            WHERE INX.[object_id] = INXCLS.[object_id] 
                AND INX.[index_id] = INXCLS.[index_id]
                AND INXCLS.[is_included_column] = 1
            FOR XML PATH('')
        )
        ,1
        ,1
        ,''
    ) 
) DS2 ([IncludedColumnsNames])

WHERE TBL.name = 'corp_item_vida_cobertura'

-- Verificação de Índices parte 04

SELECT
    QUOTENAME(t.name) AS TableName,
    QUOTENAME(i.name) AS IndexName,
    i.is_primary_key,
    i.is_unique,
    i.is_unique_constraint,
    STUFF(REPLACE(REPLACE((
        SELECT QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END AS [data()]
        FROM sys.index_columns AS ic
        INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH
    ), '<row>', ', '), '</row>', ''), 1, 2, '') AS KeyColumns,
    STUFF(REPLACE(REPLACE((
        SELECT QUOTENAME(c.name) AS [data()]
        FROM sys.index_columns AS ic
        INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        ORDER BY ic.index_column_id
        FOR XML PATH
    ), '<row>', ', '), '</row>', ''), 1, 2, '') AS IncludedColumns,
    u.user_seeks,
    u.user_scans,
    u.user_lookups,
    u.user_updates
FROM sys.tables AS t
INNER JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.dm_db_index_usage_stats AS u ON i.object_id = u.object_id AND i.index_id = u.index_id
WHERE t.is_ms_shipped = 0
AND i.type <> 0
and t.name = 'corp_item_vida_cobertura'

-- Indices query 05 já com o create index no final
-- Somente válidos para índices Nonclustered, Não entra PK

SELECT I.name as IndexName, 
        -- Uncommnent line below to include checking for index exists as part of the script
        'IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = '''+ I.name +''') ' +
        'CREATE ' + CASE WHEN I.is_unique = 1 THEN ' UNIQUE ' ELSE '' END +
        I.type_desc COLLATE DATABASE_DEFAULT + ' INDEX [' +
        I.name + '] ON [' + SCHEMA_NAME(T.schema_id) + '].[' + T.name + '] (' + STUFF(
        (SELECT ', [' + C.name + CASE WHEN IC.is_descending_key = 0 THEN '] ASC' ELSE '] DESC' END
            FROM sys.index_columns IC INNER JOIN sys.columns C ON  IC.object_id = C.object_id  AND IC.column_id = C.column_id
            WHERE IC.is_included_column = 0 AND IC.object_id = I.object_id AND IC.index_id = I.Index_id
            FOR XML PATH('')), 1, 2, '')  + ') ' +
        ISNULL(' INCLUDE (' + IncludedColumns + ') ', '') +
        ISNULL(' WHERE ' + I.filter_definition, '') + 
        'WITH (PAD_INDEX = ' + CASE WHEN I.is_padded = 1 THEN 'ON' ELSE 'OFF' END + 
        ', STATISTICS_NORECOMPUTE = ' + CASE WHEN ST.no_recompute = 0 THEN 'OFF' ELSE 'ON' END + 
        ', SORT_IN_TEMPDB = OFF' + 
        ', FILLFACTOR = ' + CONVERT(VARCHAR(5), CASE WHEN I.fill_factor = 0 THEN 100 ELSE I.fill_factor END) +
        ', IGNORE_DUP_KEY = ' + CASE WHEN I.ignore_dup_key = 1 THEN 'ON' ELSE 'OFF' END +      
        ', ONLINE = OFF' + 
        ', ALLOW_ROW_LOCKS = ' + CASE WHEN I.allow_row_locks = 1 THEN 'ON' ELSE 'OFF' END + 
        ', ALLOW_PAGE_LOCKS = ' + CASE WHEN I.allow_page_locks = 1 THEN 'ON' ELSE 'OFF' END + 
        ') ON [' + DS.name + '];' + CHAR(13) + CHAR(10) + 'GO' as [CreateIndex],
        'DROP INDEX ['+ I.name +'] ON ['+ SCHEMA_NAME(T.schema_id) +'].['+ T.name +'];' +
        CHAR(13) + CHAR(10) + 'GO' AS [DropIndex]
FROM    sys.indexes I INNER JOIN        
        sys.tables T ON  T.object_id = I.object_id INNER JOIN       
        sys.stats ST ON  ST.object_id = I.object_id AND ST.stats_id = I.index_id INNER JOIN 
        sys.data_spaces DS ON  I.data_space_id = DS.data_space_id INNER JOIN 
        sys.filegroups FG ON  I.data_space_id = FG.data_space_id LEFT OUTER JOIN 
        (SELECT * FROM 
            (SELECT IC2.object_id, IC2.index_id,
                STUFF((SELECT ', ' + C.name FROM sys.index_columns IC1 INNER JOIN 
                    sys.columns C ON C.object_id = IC1.object_id
                        AND C.column_id = IC1.column_id
                        AND IC1.is_included_column = 1
                    WHERE  IC1.object_id = IC2.object_id AND IC1.index_id = IC2.index_id
                    GROUP BY IC1.object_id, C.name, index_id  FOR XML PATH('')
                ), 1, 2, '') as IncludedColumns
            FROM sys.index_columns IC2
            GROUP BY IC2.object_id, IC2.index_id) tmp1
            WHERE IncludedColumns IS NOT NULL
        ) tmp2
        ON tmp2.object_id = I.object_id AND tmp2.index_id = I.index_id
WHERE I.is_primary_key = 0 AND I.is_unique_constraint = 0 
and t.name = 'corp_item_vida_cobertura'

-- Indice parte 06
-- Incluindo PK

SELECT
'CREATE ' + 
CASE WHEN is_primary_key=1 THEN 'CLUSTERED' 
WHEN is_primary_key=0 and is_unique_constraint=0 THEN 'NONCLUSTERED'
WHEN is_primary_key=0 and is_unique_constraint=1 THEN 'UNIQUE' END  
+ ' INDEX ' +
QUOTENAME(i.name) + ' ON ' +
QUOTENAME(t.name) + ' ( '  + 
STUFF(REPLACE(REPLACE((
        SELECT QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END AS [data()]
        FROM sys.index_columns AS ic
        INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH
    ), '<row>', ', '), '</row>', ''), 1, 2, '') + ' ) '  -- keycols
+ COALESCE(' INCLUDE ( ' +
    STUFF(REPLACE(REPLACE((
        SELECT QUOTENAME(c.name) AS [data()]
        FROM sys.index_columns AS ic
        INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        ORDER BY ic.index_column_id
        FOR XML PATH
    ), '<row>', ', '), '</row>', ''), 1, 2, '') + ' ) ',    -- included cols
    '') as [Create],
'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(t.name) as [Drop],
'ALTER INDEX ' + QUOTENAME(i.name)  + ' ON ' +QUOTENAME(t.name) + ' REBUILD ' as [Rebuild]
FROM sys.tables AS t
INNER JOIN sys.indexes AS i ON t.object_id = i.object_id
LEFT JOIN sys.dm_db_index_usage_stats AS u ON i.object_id = u.object_id AND i.index_id = u.index_id
WHERE t.is_ms_shipped = 0
AND i.type <> 0
and t.name = 'corp_item_vida_cobertura'
order by QUOTENAME(t.name), is_primary_key desc