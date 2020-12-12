

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
'tb_sinistros',
'tb_sinistrosCobBeneficiarios',
'tb_sinistrosCoberturas',
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

	print @@tabela + ' tabela incluída com sucesso no CDC!'

	set @@count = @@count+1


END
