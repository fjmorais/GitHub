use DBA
go
create or alter procedure dbo.sp_GetQueryStats (
   @DbName sysname = null
   ,@SqlText varchar(1000) = null
) as
begin

	select 
		DB_NAME(convert(int,pa.value)) as DbName
	  , cp.objtype as ObjectType
	  , qs.creation_time
	  , qs.last_execution_time
	  , qs.execution_count
	  , ( qs.total_elapsed_time / qs.execution_count ) / 1000 as AvgElapsedTimeMs
	  , qs.total_elapsed_time / 1000 as TotalElapsedTimeMs
	  , qs.min_elapsed_time / 1000 as MinElapsedTimeMs
	  , qs.max_elapsed_time / 1000 as MaxElapsedTimeMs
	  , qs.last_elapsed_time / 1000 as LastElapsedTimeMs
	  , ( qs.total_worker_time / qs.execution_count ) / 1000 as AvgWorkerTimeMs
	  , qs.total_worker_time / 1000 as TotalWorkerTimeMs
	  , qs.min_worker_time / 1000 as MinWorkerTimeMs
	  , qs.max_worker_time / 1000 as MaxWorkerTimeMs
	  , qs.last_worker_time / 1000 as LastWorkerTimeMs
	  , ( qs.total_logical_reads / qs.execution_count ) as AvgLogicalReads
	  , qs.total_logical_reads as TotalLogicalReads
	  , qs.min_logical_reads as MinLogicalReads
	  , qs.max_logical_reads as MaxLogicalReads
	  , qs.last_logical_reads as LastLogicalReads
	  , ( qs.total_physical_reads / qs.execution_count ) as AvgPhysicalReads
	  , qs.total_physical_reads as TotalPhysicalReads
	  , qs.min_physical_reads as MinPhysicalReads
	  , qs.max_physical_reads as MaxPhysicalReads
	  , qs.last_physical_reads as LastPhysicalReads
	  , ( qs.total_logical_writes / qs.execution_count ) as AvgLogicalWrites
	  , qs.total_logical_writes as TotalLogicalWrites
	  , qs.min_logical_writes as MinLogicalWrites
	  , qs.max_logical_writes as MaxLogicalWrites
	  , qs.last_logical_writes as LastLogicalWrites
	  , qp.query_plan
	  , qs.sql_handle
	  , qs.plan_handle
	  , st.text
	from sys.dm_exec_query_stats qs
	left join sys.dm_exec_cached_plans cp on cp.plan_handle = qs.plan_handle
	outer apply sys.dm_exec_query_plan(qs.plan_handle) qp
	outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
	outer apply sys.dm_exec_sql_text(qs.sql_handle) st
	where
	1=1
	and pa.attribute='dbid'
	and (@DbName is null or DB_NAME(convert(int,pa.value)) = @DbName)
	and (@SqlText is null or st.text like '%'+@SqlText+'%')
	order by qs.total_worker_time desc 

end
go
