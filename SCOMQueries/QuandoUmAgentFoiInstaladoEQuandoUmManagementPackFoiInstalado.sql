Olá Fabiano, seguem as queries para consulta conforme solicitado:

--Select para saber quando o agente foi instalado:

USE OperationsManager
GO
select [Path], FullName, TimeAdded from BaseManagedEntity
where FullName like 'Microsoft.SystemCenter.HealthService:%'

--Select para saber quando o Management Pack foi instalado:

USE OperationsManager
GO
select MPFriendlyName, MPCreated from ManagementPack
where MPFriendlyName like '%active directory%'

Best regards
