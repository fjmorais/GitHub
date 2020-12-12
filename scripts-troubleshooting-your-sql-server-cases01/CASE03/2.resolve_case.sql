
-- Comando Inicial
-- Pegando o tempo do backup antes de fazer as movimentações
BACKUP DATABASE StackOverflow50bkpcase TO 
	DISK = 'G:\BACKUP01\StackOverflw50_FULL.bak'
WITH
	CHECKSUM,
	STATS = 10,
	FORMAT
GO

-- Tempos variando entre 10m e 25m

-- Repositório sobre informações das Trace Flags (Documentadas e não documentadas)
-- https://github.com/ktaranov/sqlserver-kit/blob/master/SQL%20Server%20Trace%20Flag.md

/*
Trace Flag: 3004
Function: Returns more info about Instant File Initialization. Shows information about backups and 
file creations use with 3605 to direct to error log. Can be used to ensure that SQL Server has been configured to take advantage of IFI correctly.

Trace Flag: 3014
Function: Returns more info about backups to the errorlog: Backup activity, Restore activity, File creation.

Trace Flag: 3605
Function: Sends a variety of types of information to the SQL Server error log instead of to the user console. 
Often referenced in KB and blog articles in the context of other trace flags (e.g. 3604).
*/

-- Ativando traceflags para melhor visualização das estatisticas de backup
-- Utilizar estas apenas em momentos de troubleshooting, não as deixem habilitadas 
-- pois podem "sejar" seu Errorlog, prejudicando futuras analises de problemas
DBCC TRACEON(3004, 3014, 3605, -1)
GO

-- Efetuando backup com arquivos particionados e passando parametro COMPRESSION.
-- Verifique que a performance já é bem melhor, isso acontece pois, distribuindo
-- os arquivos de backup em mais arquivos o SQL paraleliza a leitura dos Datafiles, aumentando o Throughput de transferencia
-- dos dados para os arquivos. O Compression coloca a CPU para trabalhar junto, aumentando ainda mais a performance.
BACKUP DATABASE StackOverflow50bkpcase TO 
	DISK = 'G:\BACKUP01\StackOverflw50_pt1.bak',
	DISK = 'G:\BACKUP02\StackOverflw50_pt2.bak',
	DISK = 'G:\BACKUP03\StackOverflw50_pt3.bak',
	DISK = 'G:\BACKUP04\StackOverflw50_pt4.bak'
WITH
	COMPRESSION,
	CHECKSUM,
	STATS = 10,
	FORMAT
GO

-- BACKUP DATABASE successfully processed 6360001 pages in 300.026 seconds (165.610 MB/sec). - 5 min

-- Distribua os Datafiles do banco de dados entre os demais discos de dados
ALTER DATABASE StackOverflow50bkpcase
MODIFY FILE
(
    NAME = StackOverflow2013_2,
    FILENAME = N'D:\DADOS02\StackOverflow2013_bkp_2.ndf'
)
GO
ALTER DATABASE StackOverflow50bkpcase
MODIFY FILE
(
    NAME = StackOverflow2013_3,
    FILENAME = N'D:\DADOS03\StackOverflow2013_bkp_3.ndf'
)
GO
ALTER DATABASE StackOverflow50bkpcase
MODIFY FILE
(
    NAME = StackOverflow2013_4,
    FILENAME = N'D:\DADOS04\StackOverflow2013_bkp_4.ndf'
)
GO
ALTER DATABASE StackOverflow50bkpcase
MODIFY FILE
(
      NAME = StackOverflow2013_5,
    FILENAME = N'D:\DADOS04\StackOverflow2013_bkp_5.ndf'
)
GO

ALTER DATABASE StackOverflow50bkpcase SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE StackOverflow50bkpcase SET OFFLINE
GO

EXEC xp_cmdshell 'COPY D:\DADOS01\StackOverflow2013_bkp_2.ndf D:\DADOS02\';
EXEC xp_cmdshell 'COPY D:\DADOS01\StackOverflow2013_bkp_3.ndf D:\DADOS03\';
EXEC xp_cmdshell 'COPY D:\DADOS01\StackOverflow2013_bkp_4.ndf D:\DADOS04\';
EXEC xp_cmdshell 'COPY D:\DADOS01\StackOverflow2013_bkp_5.ndf D:\DADOS04\';

ALTER DATABASE StackOverflow50bkpcase SET ONLINE
GO
ALTER DATABASE StackOverflow50bkpcase SET MULTI_USER
GO

-- Verifique a performance, agora temos um backup com o maximo de performance pois paralelizamos a leitura
-- entre os Datafiles do banco de dados que estão distribuidos em discos diferentes e armazenados em mais 
-- de um arquivo de backup, aumentando a velocidade de escrita do backup
-- Repare na CPU, no lab tivemos a CPU quase 100% durante o backup, por conta disso, avalie bem o ambiente
-- evitando deixar com que o backup impacte a performance da aplicação.

BACKUP DATABASE StackOverflow50bkpcase TO 
	DISK = 'G:\BACKUP01\StackOverflw50_pt1.bak',
	DISK = 'G:\BACKUP02\StackOverflw50_pt2.bak',
	DISK = 'G:\BACKUP03\StackOverflw50_pt3.bak',
	DISK = 'G:\BACKUP04\StackOverflw50_pt4.bak'
WITH
	COMPRESSION,
	CHECKSUM,
	STATS = 10,
	FORMAT
GO

-- BACKUP DATABASE successfully processed 6360001 pages in 205.921 seconds (241.293 MB/sec).
