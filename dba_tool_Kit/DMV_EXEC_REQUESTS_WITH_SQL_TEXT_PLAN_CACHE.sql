select
getdate() as data,
@@SERVERNAME as servidor,
host_name,login_name,login_time,program_name,client_interface_name,nt_domain,c.status,st.text,a.plan_handle,qp.query_plan
from
sys.dm_exec_requests as a
inner join sys.dm_exec_connections as b
on a.session_id  = b.session_id
inner join sys.dm_exec_sessions c
	on b.session_id = c.session_id
cross apply sys.dm_exec_sql_text (a.[sql_handle]) as st
cross apply sys.dm_exec_query_plan (a.plan_handle) as qp
where c.is_user_process = 1
