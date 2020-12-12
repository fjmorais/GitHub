
-- Executar o script 1 e criar o banco Northwind

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

