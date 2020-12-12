use Ecom
go

-- Estruta da tabela Pedidos
exec sp_help 'dbo.Pedidos'
select top 100 * from dbo.Pedidos (nolock)
exec sp_spaceused 'dbo.Pedidos'

-- Consulta requests
exec DBA.dbo.sp_requests

-- Wait stats acumulado e sample de 15 segundos
exec DBA.dbo.sp_WaitSample

-- Consulta tempo de execução de procedures
exec DBA.dbo.sp_GetProcStats @ProcName = 'spInserePedido'

-- sp_recompile spInserePedido
