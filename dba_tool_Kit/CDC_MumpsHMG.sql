
--**********Configuração do CDC**********
--Habilita CDC

USE DLKMUMPS
GO
EXEC sys.sp_cdc_enable_db 
GO

--Em caso de erro:
--Msg 22830, Level 16, State 1, Procedure sp_cdc_enable_db_internal, Line 193 [Batch Start Line 4]
--Could not update the metadata that indicates database PGBL is enabled for Change Data Capture. 
--The failure occurred when executing the command 'SetCDCTracked(Value = 1)'. 
--The error returned was 15517: 'Cannot execute as the database principal because the principal "dbo"
--does not exist, this type of principal cannot be impersonated, or you do not have permission.'. 
--Use the action and error to determine the cause of the failure and resubmit the request.

--USE [DLKMUMPS]
--GO
--ALTER AUTHORIZATION ON DATABASE::[PGBL] TO [sa]
--GO


--**********Configuração do CDC**********
--Desabilita CDC

--USE DLKMUMPS
--GO 
--EXEC sys.sp_cdc_disable_db
--GO

--**********Verificar qual base tem o CDC ativo**********
USE DLKMUMPS
GO
SELECT [name], is_cdc_enabled 
FROM sys.databases

--**********Verificar quais tabelas estão com o CDC ativo**********
SELECT [name], is_tracked_by_cdc
FROM sys.tables where is_tracked_by_cdc = 1


--**********Ativar as tabelas necessárias**********
-- Criar o FILEGROUP CDC, com arquivos em uma unidade apartada.
-- Substituir o nome da base e as tabelas necessárias
USE DLKMUMPS
GO

DECLARE @tabelasCDC TABLE
(
CodTabelas INT IDENTITY(1,1) PRIMARY KEY,
NomeSchema varchar (20),
NomeTabelas varchar (128)
)

INSERT INTO @tabelasCDC
select sc.name, o.name from sys.objects o 
JOIN SYS.schemas sc
ON sc.schema_id = o.schema_id
where o.type = 'U' AND o.name IN
(


'tb_apolicestb_beneficiariosClb',
'tb_beneficiariosInd',
'tb_beneficiariosVg',
'tb_canais',
'tb_certificadoassistenciasClb',
'tb_certificadoassistenciasInd',
'tb_certificadoassistenciasVg',
'tb_certificadosClb',
'tb_certificadosInd',
'tb_certificadosVg',
'tb_clientesClb',
'tb_clientesInd',
'tb_clientesVg',
'tb_coberturacertificadoClb',
'tb_coberturacertificadoInd',
'tb_coberturacertificadoVg',
'tb_coberturas',
'tb_corretores',
'tb_estipulantes',
'tb_filiais',
'tb_formacobrancas',
'tb_historicomovimentacaoClb',
'tb_historicomovimentacaoInd',
'tb_historicomovimentacaoVg',
'tb_parceiros',
'tb_periodicidades',
'tb_produtos',
'tb_produtosClb',
'tb_profissoes',
'tb_sinistrosaviso',
'tb_subestipulantes'
)
ORDER BY CONCAT (sc.name,'.',o.name)



declare @@QtdTabelas AS INT
SET @@QtdTabelas = (select COUNT(*) from @tabelasCDC)

declare @@count AS INT = 1
declare @@tabela AS varchar (128)
declare @@schema as varchar (20)

WHILE @@count <= @@QtdTabelas
BEGIN

	set @@tabela = (select NomeTabelas from @tabelasCDC where CodTabelas = @@count);
	set @@schema = (select NomeSchema from @tabelasCDC where CodTabelas = @@count);

	EXECUTE sys.sp_cdc_enable_table @source_schema = @@schema, 
	@source_name = @@tabela, @filegroup_name = 'CDC', @role_name = NULL;



	set @@count = @@count+1


END