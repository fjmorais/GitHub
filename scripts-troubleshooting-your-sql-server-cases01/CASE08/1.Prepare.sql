USE [master]
GO
IF EXISTS(SELECT 1 FROM sys.databases WHERE name='Faturamento')
BEGIN
	ALTER DATABASE [Faturamento] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	ALTER DATABASE [Faturamento] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
END
GO
RESTORE DATABASE [Faturamento] FROM  DISK = N'C:\Scripts\Case08\Faturamento.bak' WITH  FILE = 1,  
MOVE N'Case' TO N'D:\DADOS01\Faturamento.mdf',  
MOVE N'Case_log' TO N'E:\LOG01\Faturamento_log.ldf',  
NOUNLOAD, 
REPLACE,
STATS = 5
GO


