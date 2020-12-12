USE [master]
GO

If not Exists (select loginname from master.dbo.syslogins
    where name = 'DRMTZ\sc-sqlbd' )
BEGIN
CREATE LOGIN [DRMTZ\sc-sqlbd] FROM WINDOWS WITH DEFAULT_DATABASE=[msdb]
END


USE [msdb]
GO

If not Exists (select loginname from sys.syslogins
    where name = 'DRMTZ\sc-sqlbd' )
BEGIN
CREATE USER [DRMTZ\sc-sqlbd] FOR LOGIN [DRMTZ\sc-sqlbd]
END


USE [msdb]
GO
ALTER ROLE [PolicyAdministratorRole] ADD MEMBER [DRMTZ\sc-sqlbd]
GO
USE [msdb]
GO
ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [DRMTZ\sc-sqlbd]
GO
USE [msdb]
GO
ALTER ROLE [SQLAgentReaderRole] ADD MEMBER [DRMTZ\sc-sqlbd]
GO
USE [msdb]
GO
ALTER ROLE [SQLAgentUserRole] ADD MEMBER [DRMTZ\sc-sqlbd]
GO

USE [master]
GO

If not Exists (select loginname from master.dbo.syslogins
    where name = 'NT SERVICE\HealthService' )

BEGIN
CREATE LOGIN [NT SERVICE\HealthService] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
END
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT SERVICE\HealthService]
GO

USE [master]
GO


if not exists (
SELECT sys.server_role_members.role_principal_id, role.name AS RoleName,
    sys.server_role_members.member_principal_id, member.name AS MemberName
FROM sys.server_role_members
JOIN sys.server_principals AS role
    ON sys.server_role_members.role_principal_id = role.principal_id
JOIN sys.server_principals AS member
    ON sys.server_role_members.member_principal_id = member.principal_id
WHERE role.name = 'SCOM_HealthService')

BEGIN
CREATE SERVER ROLE [SCOM_HealthService]
END
GO

ALTER SERVER ROLE [SCOM_HealthService] ADD MEMBER [NT SERVICE\HealthService]
GO


USE
msdb

GRANT SELECT ON sysjobschedules  TO [NT SERVICE\HealthService]
GRANT SELECT ON  msdb.dbo.log_shipping_primary_databases TO [NT SERVICE\HealthService]
GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [NT SERVICE\HealthService]
GO

--GRANT EXEC
USE
msdb
go
GRANT SELECT ON sysjobschedules  TO [NT SERVICE\HealthService]
GRANT SELECT ON  msdb.dbo.log_shipping_primary_databases TO [NT SERVICE\HealthService]
GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [NT SERVICE\HealthService]
go

USE
master
GO

GRANT EXECUTE ON xp_readerrorlog TO [NT SERVICE\HealthService]
GO


USE
msdb

GRANT SELECT ON sysjobschedules  TO [DRMTZ\sc-sqlbd]
GRANT SELECT ON  msdb.dbo.log_shipping_primary_databases TO [DRMTZ\sc-sqlbd]
 GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [DRMTZ\sc-sqlbd]
USE
master
GO

GRANT EXECUTE ON xp_readerrorlog TO [DRMTZ\sc-sqlbd]
GO

GRANT EXECUTE ON xp_readerrorlog TO [NT SERVICE\HealthService]
GO


USE
msdb

GRANT SELECT ON sysjobschedules  TO [DRMTZ\sc-sqlbd]
GRANT SELECT ON  msdb.dbo.log_shipping_primary_databases TO [DRMTZ\sc-sqlbd]
GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [DRMTZ\sc-sqlbd]

USE
master
GO

GRANT EXECUTE ON xp_readerrorlog TO [DRMTZ\sc-sqlbd]
GO
