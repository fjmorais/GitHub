

DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;

DECLARE @schema VARCHAR(4000) ;
EXEC sp_WhoIsActive
@get_transaction_info = 1,
@get_plans = 1,
@get_outer_command=1,
@find_block_leaders = 1,
@RETURN_SCHEMA = 1,
@SCHEMA = @schema OUTPUT ;

SET @schema = REPLACE(@schema, '&amp;amp;amp;amp;amp;amp;lt;table_name&amp;amp;amp;amp;amp;amp;gt;', @destination_table) ;
PRINT @schema

PRINT(@schema) ;


CREATE TABLE WhoIsActive ( [dd hh:mm:ss.mss] varchar(8000) NULL,
[session_id] smallint NOT NULL,
[sql_text] xml NULL,
[sql_command] xml NULL,
[login_name] nvarchar(128) NOT NULL,
[wait_info] nvarchar(4000) NULL,
[tran_log_writes] nvarchar(4000) NULL,
[CPU] varchar(30) NULL,[tempdb_allocations]
varchar(30) NULL,[tempdb_current]
varchar(30) NULL,[blocking_session_id]
smallint NULL,[blocked_session_count] varchar(30) NULL,
[reads] varchar(30) NULL,[writes] varchar(30) NULL,[physical_reads] varchar(30) NULL,[query_plan] xml NULL,[used_memory] varchar(30) NULL,[status] varchar(30) NOT NULL,[tran_start_time] datetime NULL,[open_tran_count] varchar(30) NULL,[percent_complete] varchar(30) NULL,[host_name] nvarchar(128) NULL,[database_name] nvarchar(128) NULL,[program_name] nvarchar(128) NULL,[start_time] datetime NOT NULL,[login_time] datetime NULL,[request_id] int NULL,[collection_time] datetime NOT NULL)
