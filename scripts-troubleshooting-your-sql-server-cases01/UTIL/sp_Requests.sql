USE DBA
GO
CREATE OR ALTER PROCEDURE dbo.sp_requests
 @spid int = null                   
,@blocking tinyint = null                    
,@db_name sysname = null
,@login_name sysname = null
,@host_name sysname = null
,@text varchar(1000) = null
,@no_text bit = 0
,@no_plan bit = 0
as                            
begin 
 DECLARE @SQL NVARCHAR(4000) = ''
 SET @SQL =
 'SELECT                             
 RIGHT(''0'' + CONVERT(varchar(6), DATEDIFF(SECOND,r.start_time,getdate())/86400),2)                        
 + '' '' + RIGHT(''0'' + CONVERT(varchar(6), DATEDIFF(SECOND,r.start_time,getdate()) % 86400 / 3600), 2)                        
 + '':'' + RIGHT(''0'' + CONVERT(varchar(2), (DATEDIFF(SECOND,r.start_time,getdate()) % 3600) / 60), 2)                        
 + '':'' + RIGHT(''0'' + CONVERT(varchar(2), DATEDIFF(SECOND,r.start_time,getdate()) % 60), 2) as [dd hh:mm:ss]                        
 ,r.session_id as spid
 ,r.blocking_session_id as blk_spid
 ,r.dop as dop
 ,[db_name] = db_name(r.database_id)
 ,s.login_name
 ,s.host_name
 ,s.program_name
 ,r.status
 ,r.command
 ,isnull(object_name(qt.objectid, qt.dbid),''Ad-Hoc'') as ObjName
 '
 +CASE WHEN @no_text = 1 THEN '' 
 ELSE 
 ',actual_query = SUBSTRING(qt.text, (r.statement_start_offset/2)+1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text) WHEN 0 THEN DATALENGTH(qt.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2)+1)
 ,qt.text
 ' 
 END
 +CASE WHEN @no_plan = 1 THEN '' ELSE 
 ',query_plan = [plan].query_plan
 ' 
 END
 +',r.wait_time
 ,r.wait_type
 ,r.cpu_time
 ,r.total_elapsed_time
 ,r.logical_reads
 ,r.writes     
 ,r.sql_handle
 ,r.plan_handle
 ,qt.objectid
 ,r.percent_complete
 FROM sys.dm_exec_requests r      
 CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) qt
 OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) as [plan]
 LEFT JOIN sys.dm_exec_sessions s on s.session_id = r.session_id
 where 1=1
 and r.session_id > 50
 and r.session_id <> @@SPID
 and (@spid is null or r.session_id = @spid or r.blocking_session_id = @spid)
 and (@blocking is null or @blocking is not null and r.blocking_session_id > 0)
 and (@db_name is null or db_name(r.database_id) = @db_name)
 and (@login_name is null or s.login_name = @login_name)
 and (@host_name is null or s.host_name = @host_name)
 and (@text is null or qt.text like @text)
 order by r.start_time
 '
 EXEC sp_executesql @SQL,N'@spid INT,@blocking INT,@db_name sysname,@login_name sysname,@host_name sysname,@text varchar(1000)',@spid = @spid,@blocking = @blocking,@db_name = @db_name,@login_name = @login_name,@host_name = @host_name,@text = @text
 
end