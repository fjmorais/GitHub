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
