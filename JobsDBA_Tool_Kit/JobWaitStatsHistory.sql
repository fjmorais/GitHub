USE [DBA]
GO

/****** Object:  Table [dbo].[WaitStatsHistory]    Script Date: 19/05/2021 15:41:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WaitStatsHistory](
	[SqlServerStartTime] [datetime] NOT NULL,
	[CollectionTime] [datetime] NOT NULL,
	[TimeDiff_ss] [bigint] NOT NULL,
	[WaitType] [nvarchar](60) NOT NULL,
	[WaitingTasksCountCumulative] [bigint] NOT NULL,
	[WaitingTasksCountDiff] [bigint] NOT NULL,
	[WaitTimeCumulative_ss] [bigint] NOT NULL,
	[WaitTimeDiff_ss] [bigint] NOT NULL,
	[MaxWaitTime_ss] [bigint] NOT NULL,
	[SignalWaitTimeCumulative_ss] [bigint] NOT NULL,
	[SignalWaitTimeDiff_ss] [bigint] NOT NULL,
 CONSTRAINT [PK_WaitStatsHistory_1] PRIMARY KEY CLUSTERED
(
	[CollectionTime] ASC,
	[WaitType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO





USE [msdb]
GO

/****** Object:  Job [28_WaitTypeHistory]    Script Date: 19/05/2021 15:39:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 19/05/2021 15:39:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'28_WaitTypeHistory',
		@enabled=1,
		@notify_level_eventlog=0,
		@notify_level_email=0,
		@notify_level_netsend=0,
		@notify_level_page=0,
		@delete_level=0,
		@description=N'Job created to have a idea how SQL Server Waits affected the SQL Server Instace each 15 minutes',
		@category_name=N'[Uncategorized (Local)]',
		@owner_login_name=N'DRMTZ\admbd', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SQL_Wait_Type]    Script Date: 19/05/2021 15:39:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SQL_Wait_Type',
		@step_id=1,
		@cmdexec_success_code=0,
		@on_success_action=1,
		@on_success_step_id=0,
		@on_fail_action=2,
		@on_fail_step_id=0,
		@retry_attempts=0,
		@retry_interval=0,
		@os_run_priority=0, @subsystem=N'TSQL',
		@command=N'/***********************************************
    Schedule this section as an on-going job
***********************************************/

DECLARE
     @CurrentSqlServerStartTime DATETIME
    ,@PreviousSqlServerStartTime DATETIME
    ,@PreviousCollectionTime DATETIME;

SELECT @CurrentSqlServerStartTime = sqlserver_start_time FROM sys.dm_os_sys_info;

-- Get the last collection time
SELECT
     @PreviousSqlServerStartTime = MAX(SqlServerStartTime)
    ,@PreviousCollectionTime = MAX(CollectionTime)
FROM dba.dbo.WaitStatsHistory;

IF @CurrentSqlServerStartTime <> ISNULL(@PreviousSqlServerStartTime,0)
BEGIN
    -- Insert starter values if SQL Server has been recently restarted
    INSERT INTO dbo.WaitStatsHistory
    SELECT
         @CurrentSqlServerStartTime
        ,GETDATE()
        ,DATEDIFF(SS,@CurrentSqlServerStartTime,GETDATE())
        ,wait_type
        ,waiting_tasks_count
        ,0
        ,wait_time_ms/1000
        ,0
        ,max_wait_time_ms/1000
        ,signal_wait_time_ms/1000
        ,0
    FROM sys.dm_os_wait_stats;
END
ELSE
BEGIN
    -- Get the current wait stats
    WITH CurrentWaitStats AS
    (
        SELECT GETDATE() AS ''CollectionTime'',* FROM sys.dm_os_wait_stats
    )
    -- Insert the diff values into the history table
    INSERT dba.dbo.WaitStatsHistory
    SELECT
         @CurrentSqlServerStartTime
        ,cws.CollectionTime
        ,DATEDIFF(SS,@PreviousCollectionTime,cws.CollectionTime)
        ,cws.wait_type
        ,cws.waiting_tasks_count
        ,cws.waiting_tasks_count - hist.WaitingTasksCountCumulative
        ,cws.wait_time_ms
        ,cws.wait_time_ms - hist.WaitTimeCumulative_ss
        ,cws.max_wait_time_ms
        ,cws.signal_wait_time_ms
        ,cws.signal_wait_time_ms - hist.SignalWaitTimeCumulative_ss
    FROM CurrentWaitStats cws INNER JOIN dbo.WaitStatsHistory hist
        ON cws.wait_type = hist.WaitType
        AND hist.CollectionTime = @PreviousCollectionTime;
END
GO',
		@database_name=N'DBA',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diario',
		@enabled=1,
		@freq_type=4,
		@freq_interval=1,
		@freq_subday_type=4,
		@freq_subday_interval=15,
		@freq_relative_interval=0,
		@freq_recurrence_factor=0,
		@active_start_date=20200410,
		@active_end_date=99991231,
		@active_start_time=0,
		@active_end_time=235959,
		@schedule_uid=N'3adf2f52-54a7-4de6-8bd4-560f7766c0ea'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
