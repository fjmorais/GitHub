use
DLKMUMPS
GO


USE DLKMUMPS
GO

DECLARE @tablesCDCExclude TABLE
(
CodTabelas INT IDENTITY(1,1) PRIMARY KEY,
Table_ChangeTracking varchar(250),
capture_instance varchar(250),
[schema_name] varchar (20)
)

INSERT INTO @tablesCDCExclude

SELECT OBJECT_NAME(b.[object_id])Table_ChangeTracking, capture_instance , sc.name as [schema_name]
FROM cdc.change_tables a inner join (select [name],schema_id,object_id
										from
									  sys.objects
										        where type = 'U'
											and name not like '%_CT') b
	on OBJECT_NAME(source_object_id) = b.name
		inner join sys.schemas sc
	on b.schema_id = sc.schema_id
	where OBJECT_NAME(b.[object_id]) in (
'tb_apolices',
'tb_beneficiariosClb',
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
'tb_enderecosClb',
'tb_enderecosInd',
'tb_enderecosVg',
'tb_estipulantes',
'tb_filiais',
'tb_formacobrancas',
'tb_historicomovimentacaoClb',
'tb_historicomovimentacaoInd',
'tb_historicomovimentacaoVg',
'tb_parceiros',
'tb_parcelasClb',
'tb_parcelasInd',
'tb_periodicidades',
'tb_produtos',
'tb_produtosClb',
'tb_profissoes',
'tb_subestipulantes')


declare @QtdTabelas AS INT
SET @QtdTabelas = (select COUNT(*) from @tablesCDCExclude)

declare @count AS INT = 1
declare @tabela AS varchar (250)
declare @schema as varchar (20)
declare @capture_instance as varchar (250)

WHILE @count <= @QtdTabelas

BEGIN

	set @tabela = (select Table_ChangeTracking from @tablesCDCExclude where CodTabelas = @count);
	set @schema = (select [schema_name] from @tablesCDCExclude where CodTabelas = @count);
	set @capture_instance = (select capture_instance from @tablesCDCExclude where CodTabelas = @count);

	EXEC sys.sp_cdc_disable_table
    @source_schema = @schema , -- sysname
    @source_name = @tabela, -- sysname
    @capture_instance = @capture_instance -- sysname

	set @count = @count+1

	print @tabela + ' tabela removida do CDC com sucesso!'


END


GO