sp_WhoIsactive @get_plans=1,@get_outer_command=1

dbcc sqlperf('logspace')

select
name,state_desc,log_reuse_wait_desc
from
sys.databases

USE msdb ;
GO

EXEC msdb.dbo.sp_start_job N'BACKUP_LOG_Attunity_I4pro_ERP_RG' ;
GO

EXEC msdb.dbo.sp_help_job @job_name = 'BACKUP_LOG_Attunity_I4pro_ERP_RG', @job_aspect = 'JOB'


--EXEC msdb.dbo.sp_help_job @Job_name = 'Your Job Name'
--check field execution_status

--0 - Returns only those jobs that are not idle or suspended.
--1 - Executing.
--2 - Waiting for thread.
--3 - Between retries.
--4 - Idle.
--5 - Suspended.
--7 - Performing completion actions.

--If you need the result of execution, check the field last_run_outcome

--0 = Failed
--1 = Succeeded
--3 = Canceled
--5 = Unknown

use
I4Pro_ERP_RG
go

exec sp_repldone null, null, 0,0,1

USE msdb ;
GO

EXEC msdb.dbo.sp_start_job N'BACKUP_LOG_Attunity_I4pro_ERP_RG' ;
GO


select
name,state_desc,log_reuse_wait_desc
from
sys.databases


select
*
from
sys.dm_exec_sessions
where login_name like '%admbd%'
and program_name like '%SQL Server Management%'


dbcc sqlperf('logspace')

select
*
from
sys.dm_exec_sessions
where login_name like '%fjmorais%'
and program_name like '%SQL Server Management%'


-- MUITO IMPORTANTE, DEPOIS QUE EXECUTAR O COMANDO exec sp_repldone null, null, 0,0,1, FECHAR A JANELA DO SCRIPT EXECUTADO!!!!!
-- SENÃO, NO PRÓXIMO CENÁRIO, O SCRIPT VAI APRESENTAR ERRO.
