
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
 



