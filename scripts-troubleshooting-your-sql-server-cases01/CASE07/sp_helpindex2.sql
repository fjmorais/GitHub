-- Link: https://www.mssqltips.com/sqlservertip/3450/sql-server-index-report-with-included-columns-storage-and-more-for-all-tables-in-a-database/
-- Créditos a: Percy Reyes is a SQL Server MVP and Sr. Database
-- 

use dt_alunos
go
create proc  dbo.sp_helpindex2 
( @SchemaName sysname=NULL
, @TableName sysname=NULL
, @IndexName sysname=NULL 
, @dataspace sysname=NULL
)
AS

BEGIN
SET NOCOUNT ON
declare @_SchemaName varchar(100)
declare @_TableName varchar(256)
declare @_IndexName varchar(256)
declare @ColumnName varchar(256)
declare @is_unique varchar(100)
declare @IndexTypeDesc varchar(100)
declare @FileGroupName varchar(100)
declare @is_disabled varchar(100)
declare @IndexColumnId int
declare @IsDescendingKey int 
declare @IsIncludedColumn int

-- getting the index sizes
SELECT schema_name(t.schema_id) [SchemaName],
 OBJECT_NAME(ix.OBJECT_ID) AS TableName,
 ix.name AS IndexName,
CAST( 8 * SUM(a.used_pages)/1024.0 AS DECIMAL(20,1))AS 'Indexsize(MB)'
INTO  #IndexSizeTable
from sys.tables t 
inner join sys.indexes ix on t.object_id=ix.object_id
inner join sys.partitions AS p ON p.OBJECT_ID = ix.OBJECT_ID AND p.index_id = ix.index_id
inner join sys.allocation_units AS a ON a.container_id = p.partition_id
 WHERE ix.type>0 and t.is_ms_shipped=0  
 and schema_name(t.schema_id)= isnull(@SchemaName,schema_name(t.schema_id)) and t.name=isnull(@TableName,t.name) AND ix.name=isnull(@IndexName, ix.name)
 GROUP BY schema_name(t.schema_id), ix.OBJECT_ID,ix.name
 ORDER BY OBJECT_NAME(ix.OBJECT_ID),ix.name

 --getting important properties of indexes
select schema_name(t.schema_id) [SchemaName], t.name TableName, ix.name IndexName,
cast( '' as varchar(max)) AS IndexKeys, casT('' as varchar(max)) AS IncludedColumns,
    ix.is_unique
 , ix.type_desc,  ix.fill_factor as [Fill_Factor]
 , ix.is_disabled ,  da.name as data_space,
  ix.is_padded,
     ix.allow_page_locks,
  ix.allow_row_locks,
  INDEXPROPERTY(t.object_id, ix.name, 'IsAutoStatistics') IsAutoStatistics ,
  ix.ignore_dup_key 
 INTO #helpindex
 from sys.tables t 
 inner join sys.indexes ix on t.object_id=ix.object_id
 inner join sys.data_spaces da on da.data_space_id= ix.data_space_id
 where ix.type>0 and t.is_ms_shipped=0  
 and schema_name(t.schema_id)= isnull(@SchemaName,schema_name(t.schema_id)) and t.name=isnull(@TableName,t.name) AND ix.name=isnull(@IndexName, ix.name)
 and da.name=isnull(@dataspace,da.name) 
 order by schema_name(t.schema_id), t.name, ix.name

---getting the index keys and included columns
declare CursorIndex cursor for
 select schema_name(t.schema_id) [schema_name], t.name, ix.name
    from sys.tables t 
 inner join sys.indexes ix on t.object_id=ix.object_id
 where ix.type>0 and t.is_ms_shipped=0 
 and schema_name(t.schema_id)= isnull(@SchemaName,schema_name(t.schema_id)) and t.name=isnull(@TableName,t.name) AND ix.name=isnull(@IndexName, ix.name) 
 order by schema_name(t.schema_id), t.name, ix.name
open CursorIndex
fetch next from CursorIndex into  @_SchemaName, @_TableName, @_IndexName
while (@@fetch_status=0)
begin
 declare @IndexColumns varchar(4000)
 declare @IncludedColumns varchar(4000)
 set @IndexColumns=''
 set @IncludedColumns=''
 declare CursorIndexColumn cursor for 
  select col.name, ixc.is_descending_key, ixc.is_included_column
  from sys.tables tb 
  inner join sys.indexes ix on tb.object_id=ix.object_id
  inner join sys.index_columns ixc on ix.object_id=ixc.object_id and ix.index_id= ixc.index_id
  inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
  where ix.type>0 and tb.is_ms_shipped=0 
  and schema_name(tb.schema_id)=@_SchemaName and tb.name=@_TableName and ix.name=@_IndexName
  

 open CursorIndexColumn 
 fetch next from CursorIndexColumn into  @ColumnName, @IsDescendingKey, @IsIncludedColumn
 while (@@fetch_status=0)
 begin
  if @IsIncludedColumn=0 
    set @IndexColumns=@IndexColumns + @ColumnName +', ' 
  else 
   set @IncludedColumns=@IncludedColumns  + @ColumnName  +', ' 
     
  fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn
 end
 close CursorIndexColumn
 deallocate CursorIndexColumn

 set @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns)-1)
 set @IncludedColumns = case when len(@IncludedColumns) >0 then substring(@IncludedColumns, 1, len(@IncludedColumns)-1) else '' end

    UPDATE #helpindex 
 SET IndexKeys = @IndexColumns, IncludedColumns=@IncludedColumns
 WHERE [SchemaName]=@_SchemaName and TableName=@_TableName and IndexName=@_IndexName
 
fetch next from CursorIndex into  @_SchemaName, @_TableName, @_IndexName

end
close CursorIndex
deallocate CursorIndex

--showing the results
SELECT hi.SchemaName, hi.TableName, hi.IndexName, hi.IndexKeys, hi.IncludedColumns, ixs.[Indexsize(MB)],
hi.is_unique, hi.type_desc,hi.data_space, hi.Fill_Factor, hi.IsAutoStatistics,
hi.is_disabled, hi.is_padded, hi.allow_page_locks, hi.allow_row_locks,hi.ignore_dup_key
 FROM #helpindex hi
INNER JOIN #IndexSizeTable ixs ON  hi.SchemaName=ixs.SchemaName and hi.TableName=ixs.TableName and hi.IndexName=ixs.IndexName
order by hi.SchemaName, hi.TableName, hi.IndexKeys, hi.IncludedColumns

drop table #helpindex
drop table #IndexSizeTable

set nocount off
end