select
a.session_id,transaction_begin_time,name
from sys.dm_exec_connections a inner join sys.dm_exec_sessions b on a.session_id = b.session_id
inner join sys.dm_tran_session_transactions c on a.session_id = c.session_id
inner join sys.dm_tran_active_transactions d on c.transaction_id = d.transaction_id
where a.session_id = 96
