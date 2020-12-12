use StackOverflow2010
go

-- Consulta requests
exec DBA.dbo.sp_requests

-- Wait stats acumulado e sample de 15 segundos
exec DBA.dbo.sp_WaitSample

-- Consulta tempo de execução de procedures
exec DBA.dbo.sp_GetProcStats @ProcName = 'nomeProc'


