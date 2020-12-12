SELECT  session_id AS SessionID,  
        program_name AS ProgramName, 
        DB_NAME(database_id) AS DatabaseName,  
        CASE transaction_isolation_level  
            WHEN 0 THEN 'Unspecified'  
            WHEN 1 THEN 'ReadUncommitted'  
            WHEN 2 THEN 'ReadCommitted'  
            WHEN 3 THEN 'Repeatable'  
            WHEN 4 THEN 'Serializable'  
            WHEN 5 THEN 'Snapshot'  
        END AS Transaction_Isolation_Level 
FROM sys.dm_exec_sessions 
where session_id=@@SPID 