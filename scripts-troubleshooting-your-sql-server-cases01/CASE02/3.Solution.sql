
-- 
-- Troubleshooting your SQL Server - Cases #01
-- @datatuning
-- https://blog.datatuning.com.br/
-- 

use Ecom
GO

--=========== Como resolver?
-- https://support.microsoft.com/pt-br/help/4460004/how-to-resolve-last-page-insert-pagelatch-ex-contention-in-sql-server


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


