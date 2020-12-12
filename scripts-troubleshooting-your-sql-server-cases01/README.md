#### Índice dos cases apresentados
[CASE 01 - Alto consumo de CPU](#case01-alto-consumo-cpu)
<br/>
[CASE 02 - PAGE_LATCH(Hot page)](#case02-page-latch)
<br/>
[CASE 03 - Backup Performance](#backup-performance)
<br/>
[CASE 04 - Corruption T-LOG](#corruption-tlog)
<br/>
[CASE 05 - Multi-Predicates](#multi-predicates)
<br/>
[CASE 06 - Non-Sargable](#non-sargable)
<br/>
[CASE 07 - Corruption Clustered Index](#corruption-clustered-index)
<br/>
[CASE 08 - ERROR 666](#error-666)
<br/>
[CASE 09 - TempDB Problem](#tempdb-problem)
<br/>
[CASE 10 - Trigger Logon](#trigger-logon)

<a id="case01-alto-consumo-cpu"></a>
## CASE 01 - Alto consumo de CPU
### Preparação
1. Baixem o banco [STACKOVERFLOW] de 50GB.
2. Edite o arquivo Start.ps1 da seguinte maneira:
-"-SEC2AMAZ-N9T8T09" --Colocar o nome da sua instância SQL Server 2019 após o -S;
-"-dStackOverflow50" --Colocar o nome do banco de dados do StackOverflow que você criou, após o -d;
3. Execute o script abaixo na base do StackOverflow que foi restaurada:
```tsql
DROP INDEX IF EXISTS IDX_Posts_CreationDate ON dbo.Posts
GO
CREATE INDEX IDX_Posts_CreationDate ON dbo.Posts(CreationDate) INCLUDE(Title)
GO
DROP INDEX IF EXISTS IDX_Comments_PostId ON dbo.Comments
GO
CREATE INDEX IDX_Comments_PostId ON dbo.Comments(PostId)
GO
CREATE OR ALTER PROCEDURE dbo.sp_get_latest_questions
AS
BEGIN
	SELECT TOP 100 p.Id, p.PostTypeId, p.CreationDate, p.Title 
	FROM Posts p
	WHERE
	p.PostTypeId=1 and 
	CAST(p.CreationDate AS DATE) = (SELECT CAST(MAX(CreationDate) AS DATE) FROM Posts)
	ORDER BY CommentCount DESC
END
GO
CREATE OR ALTER PROCEDURE dbo.sp_posts_stats
@tipo varchar(20) = 'Comentario'/*1 - Posts mais comentados | 2 - Posts mais votados*/,
@dataInicio datetime = null,
@dataTermino datetime = null
AS 
BEGIN
	IF @tipo = 'Comentario'
	BEGIN
		SELECT p.Title,COUNT(0) AS totalComentarios
		FROM Posts p
		JOIN Comments c ON c.PostId = p.Id
		WHERE p.CreationDate BETWEEN @dataInicio AND @dataTermino AND p.Title IS NOT NULL
		GROUP BY p.Title
		ORDER BY count(0) DESC
	END
	ELSE IF @tipo = 'Voto'
	BEGIN
		SELECT p.Title,COUNT(0) AS totalVotos 
		FROM Posts p
		JOIN Votes v ON v.PostId = p.Id
		GROUP BY p.Title
		ORDER BY count(0) DESC
	END
END
GO
```
### Simulação
1. Execute o arquivo Start.bat que está no diretório CASE01 para iniciar a simulação do case;
2. Para encerrar a simulação basta fechar a sessão do powershell, ou digitar .\Stop.ps1 e dar ENTER;
3. Caso esteja com a sessão do Powershell aberta, digite .\Start.ps1 e dê ENTER;

### Solução
```tsql
USE StackOverflow50
GO
/*
 Refatoração do código da procedure para ser SARGABLE
*/
CREATE OR ALTER PROCEDURE dbo.sp_get_latest_questions
AS
BEGIN
DECLARE @DATA DATE = (SELECT CAST(MAX(CreationDate) AS DATE) FROM Posts)
SELECT TOP 100 p.Id, p.PostTypeId, p.CreationDate, p.Title 
FROM Posts p
WHERE
p.PostTypeId=1 and 
p.CreationDate  BETWEEN CAST(CAST(@DATA AS VARCHAR(10)) + ' 00:00:00.000' AS DATETIME) AND CAST(CAST(@DATA AS VARCHAR(10)) + ' 23:59:59.997' AS DATETIME)
ORDER BY CommentCount DESC
END
GO
/*
Criação de índice que atende melhor as necessidades da query
*/
DROP INDEX IF EXISTS IDX_Posts_PostTypeId_CreationDate_CommentCount ON dbo.Posts
CREATE NONCLUSTERED INDEX IDX_Posts_PostTypeId_CreationDate_CommentCount ON dbo.Posts(PostTypeId,CreationDate,CommentCount) 
INCLUDE(Title) 
GO
```
<a id="case02-page-latch"></a>
## CASE 02 - PAGE_LATCH(Hot page)
### Preparação
Execute o script abaixo na sua instância SQL Server 2019.
```tsql
use master
go

if not exists (select * from sys.databases where name = 'Ecom')
	create database Ecom
go

alter database Ecom set recovery simple
go

use Ecom
GO

--Criação da tabela de Pedidos
if exists(select 1 from sys.tables where name = 'Pedidos')
begin
	drop table dbo.Pedidos
end
go
create table dbo.Pedidos (
	idPedido		int identity(1,1)	not null
,	CodTransacao	uniqueidentifier	not null
,	DtPedido		datetime
,	ValorTotal		numeric(16,2)
	constraint PK_Pedidos PRIMARY KEY(idPedido)
)
go

-- Procedure para inserção de novos pedidos com valores rand�micos
create or alter procedure dbo.spInserePedido
as
begin

	set nocount on;

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 712637)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 19238)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 91283)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 126712)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 9283)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 10283)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 91821)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 12213)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 123)

	insert into dbo.Pedidos (CodTransacao, DtPedido, ValorTotal) values (newid(), GETDATE() - (rand() * 231), rand() * 5642)

end
go
```
### Simulação
1. Execute o arquivo Inicio_Carga.bat que está no diretório CASE02.

### Solução
Nesse link há uma vasta documentação do problema de PAGE_LATCH relacionado [LAST PAGE INSERT].

Abaixo as soluções apresentadas no treinamento.
```tsql
use Ecom
GO

/******************************************************************
Criação do campo Hash para ser o campo de particionamento da tabela
*******************************************************************/

exec sp_spaceused Pedidos

truncate table Pedidos

ALTER TABLE dbo.Pedidos ADD hashValue AS (CONVERT([INT], abs([idPedido])%(40))) PERSISTED NOT NULL

/*
Lógica do campo Hash. Dividir igualmente os registros entre as partições
select 1%40
select 2%40
select 3%40
select 4%40
select 5%40
select 6%40
select 7%40
select 8%40
select 9%40
select 10%40
select 16%40
select 40%40
select 41%40
select 60%40
*/

ALTER TABLE dbo.Pedidos DROP CONSTRAINT PK_Pedidos
GO
--DROP PARTITION SCHEME [PS_hashValue]
--GO
--DROP PARTITION FUNCTION [PF_hashValue]
--GO
CREATE PARTITION FUNCTION PF_hashValue (int)  
AS RANGE LEFT FOR VALUES (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39) ;  
GO  
CREATE PARTITION SCHEME PS_hashValue   
AS PARTITION PF_hashValue ALL TO([PRIMARY]) ;  
GO

ALTER TABLE dbo.Pedidos ADD CONSTRAINT PK_Pedidos PRIMARY KEY(idPedido,hashValue) ON PS_hashValue(hashValue)
go

sp_recompile spInserePedido
-- Iniciar .BAT novamente e retestar o cenário

/**************************************************************
Query para consultar a distribuição dos registros nas partições
**************************************************************/
SELECT
 T.OBJECT_ID,
 T.NAME,
 P.PARTITION_ID,
 P.PARTITION_NUMBER,
 P.ROWS
FROM SYS.PARTITIONS P
INNER JOIN SYS.TABLES T ON P.OBJECT_ID = T.OBJECT_ID
WHERE P.PARTITION_ID IS NOT NULL
AND T.NAME = 'Pedidos'
AND P.index_id = 1
ORDER BY P.partition_number
GO
/*
                                     AvgTimeMs    MinMaxTimeMs     MaxTimeMs
                        ORIGINAL     173          0                1056
                       PARTITION     34           6                969
PARTITION COM DELAYED DURABILITY     2            0                902                           
      OPTMIZE FOR SEQUENTIAL KEY     89           7                2430
                       IN-MEMORY     33           7                617
IN-MEMORY COM DELAYED DURABILITY     1            0                376
*/
use ecom
go

truncate table Pedidos

checkpoint
go

ALTER DATABASE Ecom SET DELAYED_DURABILITY = FORCED
go

ALTER DATABASE Ecom SET DELAYED_DURABILITY = disabled
go

sp_recompile spInserePedido

-- Obs: IMPORTANTE
-- Ao particionar uma tabela deve-se entender também as consultas de busca. Ignorar isso pode gerar lentidão nas leituras.

/**************************************************************
    OPTIMIZE_FOR_SEQUENTIAL_KEY - SQL Server 2019 CTP 3.1
**************************************************************/
-- https://techcommunity.microsoft.com/t5/SQL-Server/Behind-the-Scenes-on-OPTIMIZE-FOR-SEQUENTIAL-KEY/ba-p/806888

--Criação da tabela
if exists(select 1 from sys.tables where name = 'Pedidos')
begin
	drop table dbo.Pedidos
end
create table dbo.Pedidos (
	idPedido		int identity(1,1)	not null
,	CodTransacao	uniqueidentifier	not null
,	DtPedido		datetime
,	ValorTotal		numeric(14,2)
	constraint PK_Pedidos PRIMARY KEY(idPedido)
	WITH (OPTIMIZE_FOR_SEQUENTIAL_KEY = ON)
)
go

/**************************************************************
    IN-MEMORY
**************************************************************/
-- Como boa prática, lembrar de limitar a memória a ser utilizada com o Resource Governor.


USE [master]
GO
ALTER DATABASE Ecom ADD FILEGROUP [FG_InMemory] CONTAINS MEMORY_OPTIMIZED_DATA 
GO
 
ALTER DATABASE Ecom ADD FILE ( NAME = [InMemory_File], FILENAME = 'D:\FG_InMemory\' ) TO FILEGROUP [FG_InMemory]
GO

USE Ecom
GO

sp_spaceused Pedidos

--Criação da tabela (Alterando estrutura para InMemory)
if exists(select 1 from sys.tables where name = 'Pedidos')
begin
	drop table dbo.Pedidos
end
create table dbo.Pedidos (
	idPedido		int identity(1,1)	not null PRIMARY KEY NONCLUSTERED HASH WITH(BUCKET_COUNT = 20000000)
,	CodTransacao	uniqueidentifier	not null
,	DtPedido		datetime
,	ValorTotal		numeric(14,2)
)
WITH ( MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA );
go
-- In most cases the bucket count should be between 1 and 2 times the number of distinct values in the index key.
https://docs.microsoft.com/en-us/sql/database-engine/determining-the-correct-bucket-count-for-hash-indexes?view=sql-server-2014

-- Iniciar .BAT novamente e retestar o cenário
--- ALTER DATABASE ... SET DELAYED_DURABILITY = { DISABLED | ALLOWED | FORCED }    
use ecom
go

checkpoint
go

ALTER DATABASE Ecom SET DELAYED_DURABILITY = FORCED
go

ALTER DATABASE Ecom SET DELAYED_DURABILITY = disabled
go

```
<a id="backup-performance"></a>
## CASE 03 - Backup Performance
### Preparação
1. Baixem o banco [STACKOVERFLOW] de 50GB.
2. Faça o attach dos datafiles tudo em um mesmo disco(importante para conseguir simular o problema).
### Simulação
Script para simular o tempo de backup.
```tsql
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
```
### Solução
```tsql
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
```
<a id="corruption-tlog"></a>
## CASE 04 - Corruption T-LOG
### Preparação
Execute o script northwind.sql que está do diretório CASE04.

### Simulação
```tsql
-- Alterar recovery para FULL
ALTER DATABASE Northwind  SET RECOVERY FULL;

-- Iniciar uma carga
INSERT INTO Products(ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
VALUES ('teste01',1,1,'teste',1.00,1,1,1,1)
GO 10000

-- Abrir uma outra sessão e executar os scripts abaixo
-- Baixar o banco de dados
ALTER DATABASE Northwind SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE Northwind SET OFFLINE;

-- Alterar o caminho dos arquivos do banco
ALTER DATABASE Northwind
MODIFY FILE
(
	NAME = Northwind,
	FILENAME = N'D:\DADOS01\northwnd.mdf'
);

ALTER DATABASE Northwind
MODIFY FILE
(
	NAME = Northwind,
	FILENAME = N'E:\LOG01\northwnd.ldf'
);

-- Deletar o log file
EXEC xp_cmdshell 'del "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\northwnd.ldf"';
-- Mover o datafile de lugar
EXEC xp_cmdshell 'move "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\northwnd.mdf" D:\DADOS01\';

--- Tentar subir a base, irá receber o erro
ALTER DATABASE Northwind SET ONLINE;
```

### Solução
```tsql
-- Criar um banco de dados vazio com o mesmo nome
CREATE DATABASE [Northwind]
CONTAINMENT = NONE
ON PRIMARY 
	( NAME = N'Northwind', FILENAME = N'D:\DADOS01\northwnd.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
LOG ON 
	( NAME = N'Northwind_log', FILENAME = N'E:\LOG01\northwndl.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO

-- Setar o banco para OFFLINE para poder liberar os arquivos de dados e log
ALTER DATABASE [Northwind] SET OFFLINE;

-- Movimentar arquivos
EXEC xp_cmdshell 'del "D:\DADOS01\northwnd.mdf"';
EXEC xp_cmdshell 'copy D:\DADOS01\northwind\northwnd.mdf D:\DADOS01\northwnd.mdf';

-- Alterar o nome do arquivo northwndl.ldf para northwndl_new.ldf
EXEC xp_cmdshell 'copy E:\LOG01\northwndl.ldf E:\LOG01\northwndl_new.ldf';
EXEC xp_cmdshell 'del E:\LOG01\northwndl.ldf';

-- Efetuar o rebuild do log, neste momento o SQL Server discarta todas as transa��es existentes e cria um novo arquivo de log para o banco.
ALTER DATABASE [Northwind] REBUILD LOG ON
	(NAME= 'Northwind_log', FILENAME='E:\LOG01\northwndl.ldf')
GO

-- Colocar banco online e aberto
ALTER DATABASE [Northwind] SET ONLINE;
ALTER DATABASE [Northwind] SET MULTI_USER
GO

-- Verificar a consistencia do banco de dados
USE master
GO
DBCC CHECKDB ([Northwind]) WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

-- Verificando se os dados est�o nas tabelas
USE Northwind
GO

SELECT * FROM Employees;
SELECT * FROM Categories;
SELECT * FROM Customers;
GO

--#############################################################################################################################

-- EXTRA - TENTATIVA DE SOLUÇÃO - Attach File

--USE master;
--ALTER DATABASE [Northwind] SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE
--DROP DATABASE [Northwind];

EXEC xp_cmdshell 'copy D:\DADOS01\northwind\northwnd.mdf D:\DADOS01\northwnd.mdf';
 
CREATE DATABASE [Northwind] 
ON (FILENAME = 'D:\DADOS01\northwnd.mdf') 
FOR ATTACH_REBUILD_LOG

-- File activation failure. The physical file name "C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\northwnd.ldf" may be incorrect.
-- The log cannot be rebuilt because there were open transactions/users when the database was shutdown, no checkpoint occurred to the database, or the database was read-only. This error could occur if the transaction log file was manually deleted or lost due to a hardware or environment failure.
-- Msg 1813, Level 16, State 2, Line 63
-- Could not open new database 'Northwind'. CREATE DATABASE is aborted.

--#############################################################################################################################

-- SOLU��O EXTRA

-- Solu��o para caso seja perdido o .LDF com a base transacionando e haja "dados sujos" nas paginas da mem�ria, a instancia venha a cair e o disco\arquivo de log seja perdido. 
-- O Banco de dados precisa estar em recovery FULL, caso esteja em SIMPLE o SQL consegue efetuar o rebuild do log.

-- Para o Lab:
-- 1. Desabilitar o servi�o da instancia para garantir que, quando a maquina suba, o servi�o fique disponivel. 
-- 2. Gerar a carga transacional e desligar a maquina (dedoff)
USE Northwind
GO

INSERT INTO Products(ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
VALUES ('teste01',1,1,'teste',1.00,1,1,1,1)
GO 10000

-- 3. Desligar a maquina.
-- 4. Apagar o arquivo de log
-- 5. Iniciar o serviço da instancia


ALTER DATABASE [Northwind] SET ONLINE
GO
ALTER DATABASE [Northwind] SET EMERGENCY
GO
ALTER DATABASE [Northwind] SET SINGLE_USER
GO
DBCC CHECKDB ([Northwind], REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO
ALTER DATABASE [Northwind] set multi_user
GO
```

<a id="multi-predicates"></a>
## CASE 05 - Multi-Predicates
### Preparação
Realizar download do arquivo .bak do [STACKOVERFLOW 2010] modificado e realizar o restore conforme script abaixo.
Obs: Essa base foi alterado para esse LAB. Obrigatório usar esse arquivo de backup para funcionar.
```tsql
-- ALTERAR OS DIRETÓRIOS
RESTORE FILELISTONLY FROM DISK = 'C:\temp\bkp\StackOverflow2010_case05.bak'

RESTORE DATABASE StackOverflow2010
WITH MOVE 'StackOverflow2010'     TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\StackOverflow2010.mdf'
   , MOVE 'StackOverflow2010_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\StackOverflow2010_log.ldf'
   , RECOVERY
```
Realizar a criação dos objetos abaixo.
```tsql
use StackOverflow2010
go

alter database StackOverflow2010 set recovery simple
-- Estamos usando o SQL 2019, mas pode ser qualquer compatibilidade
alter database StackOverflow2010 set compatibility_level = 150
-- Ativar TraceFlag para esconder possíveis dicas de Missing Index
dbcc traceon(2392)



go

create or alter procedure dbo.spGetNotablePosts (
	@DtInicio	datetime
,	@DtFim		datetime
)
as
begin

	set nocount on
	
	-- Regras minimas para definir que é um Post notavel.
	-- Esses numeros foram definidos pelo negocio e nao podem ser alterados
	declare @minViewCount  int = 500
		,	@CommentCount  int = 3
		,	@AnswerCount   int = 3
		,	@AnswerQuality int = 10
		,	@UserViews     int = 1500

	-- Busca Posts de acordo com regras acima
	select  
			p.Id
		,	p.Title
		,	p.CreationDate
		,	u.DisplayName
		,	p.ViewCount
		,	p.Score
		,	p.AnswerQuality
		,	p.AnswerCount
		,	p.CommentCount
	from
				dbo.Posts p 
	inner join	dbo.Users u on p.OwnerUserId = u.Id
	where
			p.CreationDate between @DtInicio and @DtFim
		and p.ViewCount     >= @minViewCount
		and p.CommentCount  >= @CommentCount
		and p.AnswerCount   >= @AnswerCount
		and p.AnswerQuality =  @AnswerQuality
		and u.Views         >= @UserViews
	order by
			p.ViewCount desc

end
GO

create nonclustered index ix_posts_report on dbo.Posts (CommentCount, AnswerCount, ViewCount) 
include (AnswerQuality, CreationDate, Title, Score)
```
### Simulação
Executar o script FogoNoParquinho.bat que está disponível CASE05
### Solução
Abaixo a soluçaõ apresentada no treinamento para o case.
```tsql
exec dbo.sp_GetProcStats @ProcName = 'spGetNotablePosts'
exec dbo.sp_requests

-- Exemplos de chamadas
set statistics io, time on
exec dbo.spGetNotablePosts @DtInicio = '2009-07-01 00:00:00', @DtFim = '2009-07-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-08-01 00:00:00', @DtFim = '2009-08-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-09-01 00:00:00', @DtFim = '2009-09-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-10-01 00:00:00', @DtFim = '2009-10-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-11-01 00:00:00', @DtFim = '2009-11-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2009-12-01 00:00:00', @DtFim = '2009-12-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-01-01 00:00:00', @DtFim = '2010-01-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-02-01 00:00:00', @DtFim = '2010-02-28 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-03-01 00:00:00', @DtFim = '2010-03-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-04-01 00:00:00', @DtFim = '2010-04-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-05-01 00:00:00', @DtFim = '2010-05-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-06-01 00:00:00', @DtFim = '2010-06-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-07-01 00:00:00', @DtFim = '2010-07-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-08-01 00:00:00', @DtFim = '2010-08-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-09-01 00:00:00', @DtFim = '2010-09-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-10-01 00:00:00', @DtFim = '2010-10-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-11-01 00:00:00', @DtFim = '2010-11-30 00:00:00'
exec dbo.spGetNotablePosts @DtInicio = '2010-12-01 00:00:00', @DtFim = '2010-12-30 00:00:00'

/*
                 | 1    | 2    | 3   |
				 |------|------|-----|
AvgElapsedTimeMs |      |      |     |
MinElapsedTimeMs |      |      |     |
MaxElapsedTimeMs |      |      |     |
AvgLogicalReads  |      |      |     |

*/

----------------- QUAL O PROBLEMA NO NOSSO INDEX SEEK?
-- RESIDUAL PREDICATE PUSHDOWN
https://www.sqlshack.com/the-impact-of-residual-predicates-in-a-sql-server-index-seek-operation/
https://support.microsoft.com/en-us/help/3107397/improved-diagnostics-for-query-execution-plans-that-involve-residual-p

-- Number of rows read:     Number of actual rows accessed by SQL Server.
-- Actual Number of Rows:   Number of rows output from the operation.

----------------- SOLUÇÃO
USE [StackOverflow2010]
GO
select	(SELECT COUNT(*) FROM dbo.Posts) as TotalPosts
	,	(SELECT COUNT(DISTINCT CreationDate) FROM dbo.Posts) as CreationDate
	,	(SELECT COUNT(DISTINCT ViewCount) FROM dbo.Posts) as ViewCount
	,	(SELECT COUNT(DISTINCT CommentCount) FROM dbo.Posts) as CommentCount
	,	(SELECT COUNT(DISTINCT AnswerCount) FROM dbo.Posts) as AnswerCount
	,	(SELECT COUNT(DISTINCT AnswerQuality) FROM dbo.Posts) as AnswerQuality

-- Porém quase todas as condições sâo de RANGE (between e Maior que)
-- A única com condição de igualdade é AnswerQuality
-- Vamos ver a distribuição dos dados?
select AnswerQuality, COUNT(AnswerQuality) as Cont from dbo.Posts group by AnswerQuality order by AnswerQuality
select CreationDate, COUNT(CreationDate) as Cont from dbo.Posts group by CreationDate order by Cont desc

-- Vamos tentar pelo CreationDate e AnswerQuality?
USE [StackOverflow2010]
GO
-- DROP INDEX [Posts].[IX_Posts_CreationDate_AnswerQuality]
CREATE NONCLUSTERED INDEX [IX_Posts_CreationDate_AnswerQuality]
ON [dbo].[Posts] (CreationDate, AnswerQuality)
INCLUDE (Title, ViewCount, Score, AnswerCount, CommentCount, OwnerUserId)
GO
-- Quantos logical reads efetuamos?

exec sp_recompile spGetNotablePosts
-- Processar novamente

--================= ÍNDICE MAIS SELETIVO
-- E  se criarmos um novo Índice? Melhora?
USE [StackOverflow2010]
GO
-- DROP INDEX [Posts].[IX_Posts_AnswerQuality_CreationDate]
CREATE NONCLUSTERED INDEX [IX_Posts_AnswerQuality_CreationDate]
ON [dbo].[Posts] (AnswerQuality, CreationDate)
INCLUDE (Title, ViewCount, Score, AnswerCount, CommentCount, OwnerUserId)
GO

exec sp_recompile spGetNotablePosts
-- Processar novamente
```

<a id="non-sargable"></a>
## CASE 06 - Non-Sargable
### Preparação
1. Baixem o banco [STACKOVERFLOW] de 50GB.
2. Criem a procedure abaixo.
```tsql
USE StackOverflow50
GO
CREATE OR ALTER PROCEDURE dbo.sp_get_posts_report
 @TypePost VARCHAR(100) = NULL
,@OwnerUserName VARCHAR(80) = NULL
,@ViewCounts INT = NULL
,@CreationDate VARCHAR(8) = NULL
,@ClosedDate VARCHAR(8) = NULL
AS
BEGIN
	DECLARE @PostTypeId INT
	SELECT @PostTypeId = Id from PostTypes WHERE Type = @TypePost

	SELECT P.Id, P.CreationDate, P.ClosedDate, PT.Type, P.Title, UO.DisplayName, ViewCount
	FROM Posts P
	JOIN PostTypes PT ON PT.Id = P.PostTypeId
	JOIN Users UO ON UO.Id = P.OwnerUserId
	WHERE
	    (@PostTypeId IS NULL OR PostTypeId = @PostTypeId )
	AND (@ViewCounts IS NULL OR ViewCount >= @ViewCounts )
	AND (@OwnerUserName IS NULL OR UO.DisplayName LIKE @OwnerUserName)
	AND (ISNULL(@CreationDate,'') = '' 
	     OR (LEN(@CreationDate) = 4 AND YEAR(P.CreationDate) = CAST(SUBSTRING(@CreationDate,1,4) AS INT)) 
		 OR (LEN(@CreationDate) = 6 AND LEFT(CONVERT(VARCHAR(8),P.CreationDate,112),6) = @CreationDate) 
		 OR (LEN(@CreationDate) = 8 AND LEFT(CONVERT(VARCHAR(8),P.CreationDate,112),8) = @CreationDate))
	AND (ISNULL(@ClosedDate,'') = '' 
	     OR (LEN(@ClosedDate) = 4 AND YEAR(P.ClosedDate) = SUBSTRING(@ClosedDate,1,4)) 
		 OR (LEN(@ClosedDate) = 6 AND YEAR(P.ClosedDate) = SUBSTRING(@ClosedDate,1,4) AND MONTH(P.ClosedDate) = SUBSTRING(@ClosedDate,5,2)) 
		 OR (LEN(@ClosedDate) = 8 AND YEAR(P.ClosedDate) = SUBSTRING(@ClosedDate,1,4) AND MONTH(P.ClosedDate) = SUBSTRING(@ClosedDate,5,2) AND DAY(P.ClosedDate) = SUBSTRING(@ClosedDate,7,2)) 
		 )
END
GO
```
### Simulação
Abaixo alguns exemplos da chamada da procedure que está apresentando lentidão.
```tsql
/*
Procedure:
	sp_get_posts_report
Parametros:
	@TypePost......: Tipo da postagem podendo ser Question, Answer, Wiki, TagWikiExerpt, TagWiki, ModeratorNomination, 
	                 WikiPlaceholder, PrivilegeWiki
	@OwnerUserName.: Matt Mitchell, Nick Berardi, Ryan Eastabrook, etc...
	@ViewCounts....: Quantidade de views de uma determinada postagem...
	@CreationDate..: Data de criação no formado YYYMMDD, podendo ser apenas o ano no formato YYYY ou ano e mês no formato YYYYMM
	@ClosedDate....: Data de encerramento para alguns tipos de postagem no formato YYYYMMDD, podendo ser apenas o ano no formato YYYY 
	                 ou ano e mês no formato YYYYMM
*/

/*
90% das execuções da procedure são passando @TypePost, @CreationDate e @ViewCounts
*/
EXEC dbo.sp_get_posts_report @TypePost = 'Question', @CreationDate = '20130505', @ViewCounts = 10000

/***********************************************************************************************
***********Demais formas de execução da procedure por outros departamentos da empresa***********
************************************************************************************************/

--Todas as perguntas com mais de 80 mil visualizacoes, criadas em 2008 por um determinado usuario.
EXEC dbo.sp_get_posts_report @TypePost = 'Question',@ViewCounts = 80000, @OwnerUserName = 'Matt Mitchell', @CreationDate = '2008'

--Todos as respostas, perguntas, wiki, etc... criados em um determinado dia
EXEC dbo.sp_get_posts_report @CreationDate = '20130704'

--Todas as respostas de um determinado dia
EXEC dbo.sp_get_posts_report @TypePost = 'Answer', @CreationDate = '20130505'

--Todas as postagens encerradas em 20131231
EXEC dbo.sp_get_posts_report @ClosedDate = '20131231'

--Todas as postagens criadas em 201201 e fechadas em 201301
EXEC dbo.sp_get_posts_report @CreationDate = '201201', @ClosedDate = '201301'

--Todas as postagens com mais de 1.000.000 de visualizações
EXEC dbo.sp_get_posts_report @ViewCounts = 1000000
```
### Solução
Reescrita da procedure é uma das soluções.
```tsql
use StackOverflow50
go
/*
Solução:
Reescrita da procedure de forma dinâmica executando via sp_executesql
*/
USE StackOverflow50
GO
CREATE OR ALTER PROCEDURE dbo.sp_get_posts_report_new
 @TypePost VARCHAR(100) = NULL
,@OwnerUserName VARCHAR(80) = NULL
,@ViewCounts INT = NULL
,@CreationDate VARCHAR(8) = NULL
,@ClosedDate VARCHAR(8) = NULL
AS
BEGIN
    DECLARE @SQL NVARCHAR(4000) = ''

	DECLARE @PostTypeId INT
	SELECT @PostTypeId = Id from PostTypes WHERE Type = @TypePost

	SET @SQL = 
	'
	SELECT P.Id, P.CreationDate, P.ClosedDate, PT.Type, P.Title, UO.DisplayName, ViewCount
	FROM Posts P
	JOIN PostTypes PT ON PT.Id = P.PostTypeId
	JOIN Users UO ON UO.Id = P.OwnerUserId
	WHERE 1=1'
	+ CASE WHEN @PostTypeId IS NOT NULL    THEN ' AND PostTypeId = @PostTypeId'              ELSE '' END
	+ CASE WHEN @ViewCounts IS NOT NULL    THEN ' AND ViewCount >= @ViewCounts'              ELSE '' END
	+ CASE WHEN @OwnerUserName IS NOT NULL THEN ' AND UO.DisplayName LIKE @OwnerUserName'    ELSE '' END
    + CASE WHEN @CreationDate IS NOT NULL THEN 
	      CASE LEN(@CreationDate) 
	      WHEN 4 THEN ' AND P.CreationDate BETWEEN CAST(@CreationDate +''0101 00:00:00.000'' AS DATETIME) AND CAST(@CreationDate +''1231 23:59:59.997'' AS DATETIME)'  
	      WHEN 6 THEN ' AND P.CreationDate BETWEEN CAST(@CreationDate +''01 00:00:00.000'' AS DATETIME) AND DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@CreationDate +''01 23:59:59.997'' AS DATETIME)))'  
	      WHEN 8 THEN ' AND P.CreationDate BETWEEN CAST(@CreationDate +'' 00:00:00.000'' AS DATETIME) AND CAST(@CreationDate +'' 23:59:59.997'' AS DATETIME)'  
		  ELSE ''
	      END
	  ELSE ''
      END
    + CASE WHEN @ClosedDate IS NOT NULL THEN 
	      CASE LEN(@ClosedDate) 
	      WHEN 4 THEN ' AND P.ClosedDate BETWEEN CAST(@ClosedDate +''0101 00:00:00.000'' AS DATETIME) AND CAST(@ClosedDate +''1231 23:59:59.997'' AS DATETIME)'  
	      WHEN 6 THEN ' AND P.ClosedDate BETWEEN CAST(@ClosedDate +''01 00:00:00.000'' AS DATETIME) AND DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@ClosedDate +''01 23:59:59.997'' AS DATETIME)))'  
	      WHEN 8 THEN ' AND P.ClosedDate BETWEEN CAST(@ClosedDate +'' 00:00:00.000'' AS DATETIME) AND CAST(@ClosedDate +'' 23:59:59.997'' AS DATETIME)'  
		  ELSE ''
	      END
      ELSE ''
	  END
	  print @SQL
	  exec sp_executesql @SQL,N'@PostTypeId INT,@ViewCounts INT,@OwnerUserName VARCHAR(80),@CreationDate VARCHAR(8), @ClosedDate VARCHAR(8)',@PostTypeId = @PostTypeId,@ViewCounts = @ViewCounts,@OwnerUserName = @OwnerUserName,@CreationDate = @CreationDate,@ClosedDate = @ClosedDate
END
/*
Análise de estatística de execução dos planos
*/
exec DBA..sp_GetProcStats
go
exec DBA..sp_GetQueryStats @sqltext = 'posts'
go
```
<a id="corruption-clustered-index"></a>
## CASE 07 - Corruption Clustered Index
### Preparação
Realize o restore do backup dt_alunos_FULL.bak que está disponível no diretório CASE07.
```tsql
RESTORE DATABASE dt_alunos FROM DISK = 'dt_alunos_FULL.bak'
WITH   
    REPLACE,
    STATS = 25
```
### Simulação
Ao executar o select abaixo está dando erro.
```tsql
USE dt_alunos
GO

-- Ao executar a query do relatório de notas para montar o histórico escolar dos alunos
-- a surpresa:

SELECT 
	idAluno,
	dataProva,
	notaProva
FROM nota_aluno
WHERE
	dataProva >= '1990-01-01 00:00:00';
GO
```
### Solução
Abaixo a solução apresentada no treinamento.
```tsql
-- Verificando erros que reportam a corrupção
DBCC CHECKDB (dt_alunos) WITH NO_INFOMSGS;
GO

-- Conectando na base para tentar repurar o maximo de dados possíveis
USE dt_alunos
GO

-- Pegar ultimo ID retornado
SELECT * FROM nota_aluno
GO

-- Pegar primeiro ID retornado
SELECT * FROM nota_aluno
ORDER BY id DESC
GO

-- Declarando variaveis e passando os IDs retirados das querys acima
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX

-- Verificando os indices e se os mesmos possuem colunas incluidas
EXEC sp_helpindex2
GO

-- Podemos utilizar o HINT INDEX(XX) para percorrer pelos dados de um indice 
-- existente dentro da tabela, neste caso, estamos percorrendo pelo indice de ID 2
-- De dentro dele podemos retirar os dados da coluna idAluno
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX
SELECT
	id, idAluno
FROM nota_aluno	WITH (INDEX(2))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

-- Podemos utilizar o HINT INDEX(XX) para percorrer pelos dados de um indice 
-- existente dentro da tabela, neste caso, estamos percorrendo pelo indice de ID 3
-- De dentro dele podemos retirar os dados da coluna idCurso
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX
SELECT
	id, idCurso
FROM nota_aluno	WITH (INDEX(3))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

-- Podemos utilizar o HINT INDEX(XX) para percorrer pelos dados de um indice 
-- existente dentro da tabela, neste caso, estamos percorrendo pelo indice de ID 4
-- De dentro dele podemos retirar os dados das colunas idMateria, dataProva, notaProva
-- Vide que foi possível até retonar os dados das colunas incluidas no indice, desta
-- forma confirmamos que, ao incluir as colunas em um indice não precisamos mais ir no
-- indice clusterizado\head para pegar os dados.
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX
SELECT
	id, idMateria, dataProva, notaProva
FROM nota_aluno	WITH (INDEX(4))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

-- Crie uma tabela temporaria para armazenar os dados da pagina corrompida e que
-- achamos em nossos indices
CREATE TABLE nota_aluno_temp (
	id INT
	,idAluno INT 
	,idCurso INT 
	,idMateria INT 
	,dataProva DATETIME
	,notaProva DECIMAL(4,2)
);

-- Inserindo os dados do indice 2 na tabela temporaria
INSERT INTO nota_aluno_temp(id, idAluno, idCurso, idMateria, dataProva, notaProva)
SELECT 
	id,	idAluno, NULL, NULL, NULL, NULL
FROM nota_aluno	WITH (INDEX(2))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

SELECT * FROM nota_aluno_temp;
GO

-- Completando a tabela com os demais dados
UPDATE nota_aluno_temp
SET
	idCurso = nota_aluno_idx3.idCurso,
	idMateria = nota_aluno_idx4.idMateria, 
	dataProva = nota_aluno_idx4.dataProva, 
	notaProva = nota_aluno_idx4.notaProva
FROM nota_aluno_temp
INNER JOIN (
		SELECT
			  id
			, idCurso
		FROM nota_aluno	WITH (INDEX(3))
		WHERE id > @id_inic and id < @id_fim
	) AS nota_aluno_idx3 ON nota_aluno_temp.id = nota_aluno_idx3.id
INNER JOIN (
		SELECT
			  id
			, idMateria
			, dataProva
			, notaProva
		FROM nota_aluno	WITH (INDEX(4))
		WHERE id > @id_inic and id < @id_fim
	) AS nota_aluno_idx4 ON nota_aluno_temp.id = nota_aluno_idx4.id
GO

-- Agora vamos reparar a tabela, retirando a pagina corrompida da tabela
ALTER DATABASE dt_alunos SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DBCC CHECKDB('dt_alunos', REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS
GO
ALTER DATABASE dt_alunos SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE
GO

-- Verificando a consistencia da tabela e verificando se não há mais problemas de corrupção
DBCC CHECKDB('dt_alunos') WITH NO_INFOMSGS
GO

-- Verifique a quantidade de dados, verifique que perdemos parte dos registros da tabela.
SELECT * FROM nota_aluno
GO

-- Reinserindo os dados recuperados na tabela original
SET IDENTITY_INSERT nota_aluno ON;
GO
INSERT INTO nota_aluno(id, idAluno,idCurso, idMateria, dataProva, notaProva)
SELECT 
	id
	, idAluno
	, idCurso
	, idMateria
	, dataProva
	, notaProva 
FROM nota_aluno_temp
GO

-- Dados totalmente recuperados
SELECT * FROM nota_aluno
GO
```
<a id="error-666"></a>
## CASE 08 - ERROR 666
### Preparação
Realize o restore do backup Faturamento.bak que está no diretório CASE08.
```tsql
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
```
### Simulação
Execute os scripts abaixo para simular o problema.
```tsql
USE Faturamento
GO
/*
Simiulação de 500 pedidos para cada Filial
*/
exec sp_fatura_pedido @IdFilial = 1--Aqui deve dar errro
exec sp_fatura_pedido @IdFilial = 2
exec sp_fatura_pedido @IdFilial = 3
exec sp_fatura_pedido @IdFilial = 4
GO
```
### Solução
Abaixo troubleshooting e solução para o case apresentado no treinamento.
```tsql
use Faturamento
go
/*
O problema?
Sistema de faturamento está tentando faturar um lote de pedidos e está 
tomando erro quando executa a procedure para a filial 1.
*/
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1
/*
E para as demais filiais, ocorre o erro?
Vamos testar...
*/

exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 4
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 2
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 3
/*
Tem espaço no banco de dados?
*/
SELECT DB_NAME() AS DbName, 
    name AS FileName, 
    type_desc,
    size/128.0 AS CurrentSizeMB,  
    size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files
WHERE type IN (0,1);
/*
Quantos registros temos nessa tabela?
*/
exec sp_spaceused Pedidos
/*
Como é a estrutura dessa tabela?
*/
exec sp_help Pedidos


--Acharam algo estranho?
/*
E se faturar MENOS pedidos para a filial 1, funciona?
*/
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 100
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 50
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 60
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 30
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 100
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 60
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 90
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 1,@NumPedidos = 10
/*
WTF???????????
Alguém arrisca um palpite???
Porque eu consegui inserir 490 registros e não 500 para a filial 1? Porque somente a filial 1?

ERRO:
	Msg 666, Level 16, State 2, Procedure Faturamento.dbo.sp_fatura_pedido, Line 6 [Batch Start Line 6]
	The maximum system-generated unique value for a duplicate group was exceeded for index with partition 
	ID 72057594045595648. 
	Dropping and re-creating the index may resolve this; otherwise, use another clustering key.

Que DUPLICATE GROUP é esse?
R: CLUSTERED INDEX sem UNICIDADE

Que UNIQUE VALUE é esse?
R: Coluna UNIQUIFIER(4-bytes)

Qual a causa do problema?
R: Estouro de capacidade do UNIQUIFIER(INT 4-bytes - Valor Max: 2.147.483.647)

Porque o SQL Server criou a coluna UNIQUIFIER?
Resposta: 
	https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver15
	
	If the clustered index is not created with the UNIQUE property, the Database Engine automatically 
	adds a 4-byte uniqueifier column to the table. When it is required, the Database Engine automatically 
	adds a uniqueifier value to a row to make each key unique. 
	This column and its values are used internally and cannot be seen or accessed by users.

Como eu vejo o valor do UNIQUIFIER?
Resposta: "This column and its values are used internally and cannot be seen or accessed by users."







Obs: Maaaaaais ou menos!!!!!

DBCC PAGE
*/

/*
Vamos analisar as páginas de alocação dessa tabela para a filial 1
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos 
where IdFilial = 1 
ORDER BY Id DESC
GO
/*
Trace flag 3604 para habilitar a leitura de uma página via DBCC PAGE

DBCC PAGE
(
['database name'|database id], -- can be the actual name or id of the database
file number, -- the file number where the page is found
page number, -- the page number within the file
print option = [0|1|2|3] -- display option; each option provides differing levels of information
)
*/
DBCC TRACEON(3604)
DBCC PAGE('Faturamento',1,99971,3)
/*
Conseguimos essa informação do UNIQUIFIER via dm_db_page_info?
dm_db_page_info está disponível a partir do SQL Server 2019
Resposta: Não!!!
*/
select * from sys.dm_db_page_info(db_id(),1,99971,'DETAILED')

/*
Porque o erro não ocorreu com as demais filiais?
Vamos inserir 1 registro para uma NOVA FILIAL e observar o DBCC PAGEs
*/

exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 5, @NumPedidos = 1

/*
Capturando a página de alocação dos registros da filial 5
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos 
where IdFilial = 5
ORDER BY Id DESC
GO

/*Por dentro da página*/
DBCC PAGE('Faturamento',1,505,3)

/*
Vamos inserir mais 9 registros para a filial 5
*/
exec Faturamento.dbo.sp_fatura_pedido @IdFilial = 5, @NumPedidos = 9

/*
Capturando a página de alocação dos registros da filial 5
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos 
where IdFilial = 5
ORDER BY Id DESC
GO

/*Por dentro da página*/
DBCC PAGE('Faturamento',1,505,3)

/*
Observamos que para um novo valor de registro para a coluna IdFilial que é o índice clustered a
propriedade UNIQUIFIER começar no valor 0

Devido esse comportamento, então chegamos a conclusão que para a FILIAL 1, foi inserido mais de
2 bilhões de registros ao longo de todo o tempo...

Obs: Isso pode ocorrer para as demais filiais também!
*/

/*
Como resolver?
Até o momento as únicas formas de resolução para efeturar o "reset" do UNIQUIFIER são:
	1. DROP / CREATE INDEX CLUSTERED  --Mais complexo se houver particionamento/relacionamento;
	2. APAGAR TODOS OS REGISTROS DE UM DETERMINADO CONJUNTO DE VALORES REPETIDOS
	3. ALTER INDEX ALL ON <Tabela> REBUILD WITH(ONLINE=ON)--Mais simples porém Enterprise only;
*/

/*
********************************************************************************************
**************************SOLUÇÃO 1: DROP/CREATE CLUSTERED**********************************
********************************************************************************************
*/
--VALIDANDO O ERRO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 10
GO
--RECRIANDO CLUSTERED INDEX
DROP INDEX IDX_Pedidos ON Pedidos
GO
CREATE CLUSTERED INDEX IDX_Pedidos ON Pedidos(IdFilial)
GO
/*
Testando....
*/
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 10
/*
Capturando a página de alocação dos registros da filial 1
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos 
where IdFilial = 1
ORDER BY Id DESC
GO
/*Por dentro da página*/
DBCC PAGE('Faturamento',1,16692,3)

/*
********************************************************************************************
****************************SOLUÇÃO 2: APAGAR REGISTROS*************************************
********************************************************************************************
*/
--RESTAURA BASE NOVAMENTE....
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
Use Faturamento
GO
--VALIDANDO O ERRO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
GO

--DELETA TODOS OS REGISTROS
DELETE FROM Pedidos WHERE IdFilial = 1
CHECKPOINT
GO
/*
Testando....
*/
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
/*
Capturando a página de alocação dos registros da filial 1
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos 
where IdFilial = 1
ORDER BY Id DESC
GO
/*Por dentro da página*/
DBCC PAGE('Faturamento',1,772,3)--ID 4000
DBCC PAGE('Faturamento',1,3581,3)--ID 3501
/*
********************************************************************************************
***************************SOLUÇÃO 3: REBUILD ALL ONLINE************************************
********************************************************************************************
*/
--RESTAURA BASE NOVAMENTE....
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
Use Faturamento
GO
--VALIDANDO O ERRO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
GO

--REBUILD ALL COM ONLINE :)
ALTER INDEX ALL ON Pedidos REBUILD WITH(ONLINE=ON)
GO
/*
Testando....
*/
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
/*
Capturando a página de alocação dos registros da filial 1
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos 
where IdFilial = 1
ORDER BY Id DESC
GO
/*Por dentro da página*/
DBCC PAGE('Faturamento',1,16212,3)--ID 4000
DBCC PAGE('Faturamento',1,16216,3)--ID 1

/*
********************************************************************************************
*****************************VALIDANDO OUTROS REBUILDS**************************************
********************************************************************************************
*/
--RESTAURA BASE NOVAMENTE....
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
Use Faturamento
GO
--Testando demais formas de REBUILD
ALTER INDEX IDX_Pedidos ON Pedidos REBUILD
GO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
GO
ALTER INDEX IDX_Pedidos ON Pedidos REBUILD WITH(ONLINE=ON)
GO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
GO
ALTER INDEX ALL ON Pedidos REBUILD 
GO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
GO
ALTER INDEX ALL ON Pedidos REBUILD WITH(ONLINE=ON)
GO
EXEC Faturamento.dbo.sp_fatura_pedido @idFilial = 1,@NumPedidos = 500
GO
/*
**************************************************************************
***************Identificando tabelas candidatas ao problema***************
**************************************************************************
*/
SELECT OBJECT_NAME(I.object_id) AS ObjectName
, I.object_id
, I.name AS IndexName
, I.is_unique
, C.name AS ColumnName
, T.name AS TypeName
, C.max_length
, C.precision
, C.scale
, P.partition_id
, P.partition_number
, P.rows
FROM sys.indexes AS I
INNER JOIN sys.index_columns AS IC
ON I.index_id = IC.index_id
AND I.object_id = IC.object_id
INNER JOIN sys.columns AS C
ON IC.column_id = C.column_id
AND IC.object_id = C.object_id
INNER JOIN sys.types AS T
ON C.system_type_id = T.system_type_id
INNER JOIN sys.partitions AS P
ON P.object_id = I.object_id
AND P.index_id = I.index_id
WHERE I.is_unique = 0 AND I.index_id = 1
ORDER BY I.object_id, C.column_id DESC
/*
O que acontece dentro da página de uma tabela cujo índice cluster é único?
Vamos fazer um pequeno teste...
*/
CREATE TABLE dbo.Pedidos2(
 Id INT IDENTITY NOT NULL PRIMARY KEY
,IdFilial TINYINT
,IdCliente INT
,DtPedido DATE
,Valor DECIMAL(10,2)
)
GO
/*Inserindo alguns registros na tabela Pedidos2*/
INSERT INTO dbo.Pedidos2(IdFilial,IdCliente,DtPedido,Valor) 
SELECT 1, CAST(RAND()*500+500 AS INT), GETDATE(), CAST(RAND()*500+1000 AS DECIMAL(10,2)) 
FROM dbo.GetNums(10) 

/*
Capturando a página de alocação da tabela Pedidos2
*/
SELECT *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.Pedidos2 
ORDER BY Id DESC
GO
/*Por dentro da página*/
DBCC PAGE('Faturamento',1,32456,3)

/*
Referências:

https://docs.microsoft.com/en-us/archive/blogs/luti/uniqueifier-details-in-sql-server
https://techcommunity.microsoft.com/t5/sql-server-support/uniqueifier-considerations-and-error-666/ba-p/319096
*/
```
<a id="empdb-problem"></a>
## CASE 09 - TempDB Problem
### Preparação
1. Desatachar disco de TEMPLOG01 na AWS (No caso de um outro ambiente, retire o disco onde esta o arquivo de log da TEMPDB)
### Simulação
1. Reiniciar a instancia
### Solução
1. Abrir o SQL Server Configuration Manager
2. Inserir no Startup Parameters a trace flag -T3608 e o parametro -m ou -f para inicializacao em minima\single user
3. Abrir o CMD
4. Digitar sqlcmd e logar na instancia
5. Alterar o caminho do aquivo de log:

	C:\Users\Administrator> sqlcmd<br/>
	1> alter database tempdb modify file (NAME = templog, FILENAME = N'F:\TEMPDADOS01\tempdb_log.ldf')
	<br/>
	2> GO
	<br/>

6. Retire os parametros de inicialização inseridos anteriormente
7. Reiniciar a instancia

<a id="trigger-logon"></a>
## CASE 10 - Trigger Logon
### Preparação
Execute o script abaixo.
```tsql
use master
go
EXEC sp_configure 'remote admin connections', '1'
go
reconfigure
go

use master
go
-- DROP TABLE dbo.UserWhiteList
CREATE TABLE dbo.UserWhiteList (
    IdUser       int not null identity(1,1) primary key
,   Usuario      varchar(256) not null
,   DtCadastro	 datetime not null default getdate()
)
go


-- COLOCAR USUÁRIOS CONFORME A SUA INSTÂNCIA. ESSES USUÁRIOS SÃO DE EXEMPLOS.
insert into dbo.UserWhiteList (Usuario) values ('EC2AMAZ-N9T8T09\Administrator')
insert into dbo.UserWhiteList (Usuario) values ('EC2AMAZ-N9T8T09\admin_marcel')
insert into dbo.UserWhiteList (Usuario) values ('EC2AMAZ-N9T8T09\admin_william')
insert into dbo.UserWhiteList (Usuario) values ('EC2AMAZ-N9T8T09\admin_guilherme')
insert into dbo.UserWhiteList (Usuario) values ('dtsa')
insert into dbo.UserWhiteList (Usuario) values ('app1')
insert into dbo.UserWhiteList (Usuario) values ('app2')
insert into dbo.UserWhiteList (Usuario) values ('app3')

USE [master]
GO
 
grant SELECT on dbo.UserWhiteList TO [public]
GO

USE [master]
GO
 
CREATE TRIGGER [trServerLogin] ON ALL SERVER 
FOR LOGON 
AS
BEGIN
  
    SET NOCOUNT ON
    
    -- Não loga conexões de usuários de sistema
    IF ORIGINAL_LOGIN() NOT IN (select Usuario from dbo.UserWhiteList)
	BEGIN
		RAISERROR('ACESSO NÃO PERMITIDO AO SEU USUÁRIO EM PRODUÇÃO',16,1)
        rollback
	END
        
END
GO
 
ENABLE TRIGGER [trServerLogin] ON ALL SERVER  
GO
```
### Simulação
Execute o script abaixo.
```tsql
use master
GO
DELETE dbo.UserWhiteList
GO
```
### Solução
Acessar instância via SQLCMD com DAC.

--======== Conectar via DAC
<br/>
-- > sqlcmd -S localhost -A -d master -E

-- Verifica usuário que está conectado
<br/>
select original_login()

-- Identifica as triggers habilitadas
<br/>
select name, is_disabled from sys.server_triggers;

-- Desabilita trigger
<br/>
disable TRIGGER [trServerLogin] ON ALL SERVER  

[LAST PAGE INSERT]:https://support.microsoft.com/pt-br/help/4460004/how-to-resolve-last-page-insert-pagelatch-ex-contention-in-sql-server
[STACKOVERFLOW]:https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/
[STACKOVERFLOW 2010]:https://drive.google.com/drive/folders/1-G8hP7liB0jAiHmKSoQWqIZodfqKZJqY?usp=sharing
