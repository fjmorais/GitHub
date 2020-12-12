
--CRIA O LOGIN NA INSTANCIA
USE [master]
GO
CREATE LOGIN [DRMTZ\sc-sqlbd]
FROM WINDOWS
WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english] 

-- CRIA O USUARIO EM TODOS OS BANCOS DE DADOS
BEGIN TRAN
       DECLARE @DBNAME VARCHAR(800)
       DECLARE XCURSOR CURSOR FOR (SELECT name FROM master..sysdatabases)
       OPEN XCURSOR
       FETCH NEXT FROM XCURSOR INTO @DBNAME
       WHILE @@FETCH_STATUS = 0
       BEGIN
              EXECUTE ('USE ['+ @DBNAME +'];
                                  CREATE USER [DRMTZ\sc-sqlbd] FOR LOGIN [DRMTZ\sc-sqlbd];')
              FETCH NEXT FROM XCURSOR INTO @DBNAME
       END
       CLOSE XCURSOR
       DEALLOCATE XCURSOR
COMMIT TRAN

--CONCEDE PERMISSAO DE VIEW
USE master
GO
GRANT VIEW ANY DEFINITION TO [DRMTZ\sc-sqlbd] WITH GRANT OPTION;
GRANT VIEW SERVER STATE TO [DRMTZ\sc-sqlbd] WITH GRANT OPTION;
GRANT VIEW ANY DATABASE TO [DRMTZ\sc-sqlbd] WITH GRANT OPTION;

--ADICIONA O LOGIN NAS ROLES DA MSDB
USE msdb
GO
ALTER ROLE PolicyAdministratorRole ADD MEMBER [DRMTZ\sc-sqlbd]
GO
ALTER ROLE SQLAgentReaderRole ADD MEMBER [DRMTZ\sc-sqlbd]
GO


--- Parte 02

ALTER SERVER ROLE [sysadmin] ADD MEMBER [NT AUTHORITY\SYSTEM]
GO


USE
msdb
go

GRANT SELECT ON sysjobschedules TO [NT SERVICE\HealthService]
GRANT SELECT ON msdb.dbo.log_shipping_primary_databases TO [NT SERVICE\HealthService]
GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [NT SERVICE\HealthService]

USE
master
GO

--GRANT EXEC
USE
msdb
GO

GRANT SELECT ON sysjobschedules TO [NT SERVICE\HealthService]
GRANT SELECT ON msdb.dbo.log_shipping_primary_databases TO [NT SERVICE\HealthService]
GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [NT SERVICE\HealthService]

USE
master
GO

GRANT EXECUTE ON xp_readerrorlog TO [NT SERVICE\HealthService]
GO


USE
msdb
go
GRANT SELECT ON sysjobschedules TO [DRMTZ\sc-sqlbd]
GRANT SELECT ON msdb.dbo.log_shipping_primary_databases TO [DRMTZ\sc-sqlbd]
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

GRANT SELECT ON sysjobschedules TO [DRMTZ\sc-sqlbd]
GRANT SELECT ON msdb.dbo.log_shipping_primary_databases TO [DRMTZ\sc-sqlbd]
GRANT SELECT ON msdb.dbo.log_shipping_secondary_databases TO [DRMTZ\sc-sqlbd]

GRANT EXECUTE ON msdb.dbo.sp_help_jobactivity  TO [DRMTZ\sc-sqlbd]
GRANT EXECUTE ON msdb.dbo.sp_help_job  TO [DRMTZ\sc-sqlbd]

USE
master
GO

GRANT EXECUTE ON xp_readerrorlog TO [DRMTZ\sc-sqlbd]
GO

-- Terceira parte

ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT AUTHORITY\SYSTEM]
GO
