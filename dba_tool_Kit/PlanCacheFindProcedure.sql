CREATE procedure [dbo].[sp_find_procedure_in_cache] (@procedure varchar(200))      
      
as      
      
select      
    qs.sql_handle      
    , qs.statement_start_offset      
    , qs.statement_end_offset      
    , qs.plan_handle      
    , execution_count      
    , st.text      
    , substring(st.text, (qs.statement_start_offset/2)+1,      
        ((case qs.statement_end_offset      
            when -1      
                then datalength(st.text)      
            else      
                qs.statement_end_offset      
            end - qs.statement_start_offset) / 2 + 1)) as [Filtered text]      , 
			qp.query_plan  , 
			'DBCC FREEPROCCACHE (' ,
			qs.plan_handle ,
			')' AS [End]
from sys.dm_exec_query_stats as qs      
    cross apply sys.dm_exec_sql_text (qs.sql_handle) as st      
    cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp      
where st.text like + '%' +  @procedure + '%'      
order by qs.sql_handle      
    , execution_count desc   
  
GO


