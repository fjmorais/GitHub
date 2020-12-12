;WITH eqs
AS (
    SELECT 
         [execution_count]
        ,[total_worker_time]/1000  AS [TotalCPUTime_ms]
        ,[total_elapsed_time]/1000  AS [TotalDuration_ms]
        ,query_hash
        ,plan_handle
        ,[sql_handle]
    FROM sys.dm_exec_query_stats
    )
SELECT TOP 10 est.[text], eqp.query_plan AS SQLStatement
    ,eqs.*
FROM eqs
OUTER APPLY sys.dm_exec_query_plan(eqs.plan_handle) eqp
OUTER APPLY sys.dm_exec_sql_text(eqs.sql_handle) AS est
ORDER BY [TotalCPUTime_ms] DESC