select
a.session_id, a.blocking_session_id, waiting_task_address,a.wait_type,wait_duration_ms,b.command,b.percent_complete,b.last_wait_type,b.cpu_time,b.total_elapsed_time,b.reads,b.writes,b.logical_reads,
c.host_name,c.program_name,c.client_interface_name,c.login_name,c.status,c.open_transaction_count
from
sys.dm_os_waiting_tasks a inner join sys.dm_exec_requests b
	on a.session_id = b.session_id
	inner join sys.dm_exec_sessions c
		on b.session_id = c.session_id
where a.session_id = 71
