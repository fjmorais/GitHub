use DBA
go

create or alter procedure dbo.sp_GetProcStats (
   @DbName sysname = null
   ,@ProcName sysname = null
) as
begin

	select 
		DB_NAME(ps.database_id) as DbName
	  , OBJECT_NAME(ps.object_id, ps.database_id) as ObjectName
	  , ps.cached_time
	  , ps.last_execution_time
	  , ps.execution_count
	  , ( ps.total_elapsed_time / ps.execution_count ) / 1000 as AvgElapsedTimeMs
	  , ps.total_elapsed_time / 1000 as TotalElapsedTimeMs
	  , ps.min_elapsed_time / 1000 as MinElapsedTimeMs
	  , ps.max_elapsed_time / 1000 as MaxElapsedTimeMs
	  , ps.last_elapsed_time / 1000 as LastElapsedTimeMs
	  , ( ps.total_worker_time / ps.execution_count ) / 1000 as AvgWorkerTimeMs
	  , ps.total_worker_time / 1000 as TotalWorkerTimeMs
	  , ps.min_worker_time / 1000 as MinWorkerTimeMs
	  , ps.max_worker_time / 1000 as MaxWorkerTimeMs
	  , ps.last_worker_time / 1000 as LastWorkerTimeMs
	  , ( ps.total_logical_reads / ps.execution_count ) as AvgLogicalReads
	  , ps.total_logical_reads as TotalLogicalReads
	  , ps.min_logical_reads as MinLogicalReads
	  , ps.max_logical_reads as MaxLogicalReads
	  , ps.last_logical_reads as LastLogicalReads
	  , ( ps.total_physical_reads / ps.execution_count ) as AvgPhysicalReads
	  , ps.total_physical_reads as TotalPhysicalReads
	  , ps.min_physical_reads as MinPhysicalReads
	  , ps.max_physical_reads as MaxPhysicalReads
	  , ps.last_physical_reads as LastPhysicalReads
	  , ( ps.total_logical_writes / ps.execution_count ) as AvgLogicalWrites
	  , ps.total_logical_writes as TotalLogicalWrites
	  , ps.min_logical_writes as MinLogicalWrites
	  , ps.max_logical_writes as MaxLogicalWrites
	  , ps.last_logical_writes as LastLogicalWrites
	  , qp.query_plan
	  , ps.sql_handle
	  , ps.plan_handle
	  , st.text
	from 
		sys.dm_exec_procedure_stats ps
	  outer apply
		sys.dm_exec_query_plan(ps.plan_handle) qp
	  outer apply
		sys.dm_exec_sql_text(ps.sql_handle) st
	where
	(@DbName is null or DB_NAME(ps.database_id) = @DbName)
	and (@ProcName is null or object_Name(ps.object_id,ps.database_id) = @ProcName)
	order by ps.total_worker_time desc 

end
go
