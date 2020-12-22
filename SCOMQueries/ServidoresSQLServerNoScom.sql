
-- Servidores com SQL Server sendo monitorado no SCOM

USE OperationsManager
GO
select distinct
replace(LEFT(Path,PATINDEX('%.%',[Path])),'.','') as Servidor
from BaseManagedEntity
where FullName like '%SQL%'
