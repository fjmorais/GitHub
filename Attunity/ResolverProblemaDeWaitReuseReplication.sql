

-- REF : https://blog.sqlauthority.com/2016/04/07/sql-server-huge-transaction-log-snapshot-replication/

DBCC SQLPERF('LOGSPACE')

select
name,state_desc,log_reuse_wait_desc,is_cdc_enabled
from
sys.databases
where name = 'I4Pro_ERP_RG'


sp_WhoIsActive @get_plans=1, @get_outer_command=1


CHECKPOINT


SELECT DATABASEPROPERTYEX('I4Pro_ERP_RG', 'IsPublished');


DBCC OPENTRAN;

select
*
from

select
open_transaction_count,*
from
sys.dm_exec_sessions
where is_user_process = 1
and login_name  in ('ATTUNITY')

EXEC sp_replcounters;



Select *from master..sysprocesses where status <> 'Sleeping'
and spid > 50
order by login_time,last_batch desc


select
*
from
sys.databases

sp_helppublication 'I4Pro_ERP_RG'

exec sp_repldone null, null, 0,0,1
