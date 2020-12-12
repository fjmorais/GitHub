
-- 
-- Troubleshooting your SQL Server - Cases #01
-- @datatuning
-- https://blog.datatuning.com.br/
-- 

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


-- Teste proc
-- exec dbo.spInserePedido
-- select * from dbo.Pedidos



