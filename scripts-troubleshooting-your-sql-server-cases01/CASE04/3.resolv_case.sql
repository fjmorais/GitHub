
--###################################################################
			-- SOLU��O PARA O CASO
--###################################################################

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

-- EXTRA - TENTATIVA DE SOLU��O - Attach File

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
-- 5. Iniciar o servi�o da instancia


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




