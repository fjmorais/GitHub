-- Performance Backup Case

/*
	1. Baixem o banco StackOverflow de 50GB: https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/
	2. Edite o arquivo Start.ps1 da seguinte maneira:
	   "-SEC2AMAZ-N9T8T09" --Colocar o nome da sua instância SQL Server 2019 após o -S;
	   "-dStackOverflow50" --Colocar o nome do banco de dados do StackOverflow que você criou, após o -d;
	3. Execute o script abaixo para criar alguns objetos necessários para o case.
*/

-- Fazer backup da base StackOverflow50

BACKUP DATABASE StackOverflow50 TO 
	DISK = 'G:\BACKUP01\StackOverflw50.bak'
WITH
	COMPRESSION,
	CHECKSUM,
	STATS = 10,
	FORMAT
GO

-- Retaurar o banco StackOverflow50 com outro nome e com os arquivos de dados no mesmo disco.
RESTORE DATABASE StackOverflow50bkpcase FROM
	DISK = 'G:\BACKUP01\StackOverflow50_FULL.bak'
WITH
	MOVE 'StackOverflow2013_1' TO 'D:\DADOS01\StackOverflow2013_bkp_1.mdf',
	MOVE 'StackOverflow2013_2' TO 'D:\DADOS01\StackOverflow2013_bkp_2.ndf',
	MOVE 'StackOverflow2013_3' TO 'D:\DADOS01\StackOverflow2013_bkp_3.ndf',
	MOVE 'StackOverflow2013_4' TO 'D:\DADOS01\StackOverflow2013_bkp_4.ndf',
	MOVE 'StackOverflow2013_5' TO 'D:\DADOS01\StackOverflow2013_bkp_5.ndf',
	MOVE 'StackOverflow2013_log' TO 'E:\LOG01\StackOverflow2013_bkp_log.ldf',
	STATS = 10,
	FILE = 1,
	REPLACE
GO

-- Delete backup history
USE [msdb];
GO

DECLARE @today DATETIME = GETDATE();
EXEC sp_delete_backuphistory @oldest_date = @today;
GO

-- Efeturar o primeiro backup e verificar o tempo
BACKUP DATABASE StackOverflow50bkpcase TO DISK = 'G:\BACKUP02\StackOverflow50bkpcase_FULL.bak'
WITH
	CHECKSUM,
	FORMAT,
	STATS = 10
GO

-- BACKUP DATABASE successfully processed 6360001 pages in 760.189 seconds (65.362 MB/sec).

-- Verificando histórico e estatisticas do ultimo backup
exec DBA..sp_ListBackups 'StackOverflow50'
GO
