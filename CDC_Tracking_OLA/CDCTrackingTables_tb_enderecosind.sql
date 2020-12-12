--id_coberturacertificado
--num_certificado_coberturacertificado
--cod_cobertura_coberturacertificado
--vl_capital_coberturacertificado
--data_carga


-- 1 Delete
-- 2 Insert
-- 3 Updated row before the change
-- 4 Updated row after the change

-- dlkmumps.tb_enderecosInd


Use
DLKMUMPS
go

SET QUOTED_IDENTIFIER ON
GO

DECLARE @max_lsn binary(10);
DECLARE @from_lsn binary (10) ,@to_lsn binary (10)


DECLARE @id_enderecos int
DECLARE @num_matricula_cliente int
DECLARE @tipo_endereco int
DECLARE @dsc_endereco_cliente int
DECLARE @dsc_complemento_cliente int
DECLARE @dsc_bairro_cliente int
DECLARE @dsc_cidade_cliente int
DECLARE @dsc_uf_cliente int
DECLARE @num_cep_cliente int
DECLARE @num_ddd_cliente int
DECLARE @num_telefone_cliente int
DECLARE @data_ultima_atualizacao int
DECLARE @flg_endereco_correspondencia int
DECLARE @data_carga int



SET @from_lsn = sys.fn_cdc_get_min_lsn('dlkmumps_tb_enderecosInd')
SET @to_lsn = sys.fn_cdc_get_max_lsn()
SET @id_enderecos = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'id_enderecos')
SET @num_matricula_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'num_matricula_cliente')
SET @tipo_endereco = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'tipo_endereco')
SET @dsc_endereco_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'dsc_endereco_cliente')
SET @dsc_complemento_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'dsc_complemento_cliente')
SET @dsc_bairro_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'dsc_bairro_cliente')
SET @dsc_cidade_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'dsc_cidade_cliente')
SET @dsc_uf_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'dsc_uf_cliente')
SET @num_cep_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'num_cep_cliente')
SET @num_ddd_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'num_ddd_cliente')
SET @num_telefone_cliente = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'num_telefone_cliente')
SET @data_ultima_atualizacao = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'data_ultima_atualizacao')
SET @flg_endereco_correspondencia = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'flg_endereco_correspondencia')
SET @data_carga = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_enderecosInd', 'data_carga')



INSERT INTO dba.dbo.cdc_tracking_tb_enderecosInd WITH (TABLOCKX)

SELECT
'tb_enderecosInd' as TableName
,sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$start_lsn) as ChangedDate
	,fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$start_lsn
	,fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$seqval
	,case when fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$operation = 1 THEN 'Delete'
		  when fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$operation = 2 THEN 'Insert'
		  when fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$operation = 3 THEN 'Updated row before the change'
		  when fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$operation = 4 THEN 'Updated row after the change' ELSE 'Não encontrado ' END as [Status]
	,fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$update_mask
	,sys.fn_cdc_is_bit_set(@id_enderecos, __$update_mask) as 'Updatednum_id_enderecos'
	,sys.fn_cdc_is_bit_set(@num_matricula_cliente, __$update_mask) as 'Updatednum_matricula_cliente'
	,sys.fn_cdc_is_bit_set(@tipo_endereco, __$update_mask) as 'Updatedtipo_endereco'
	,sys.fn_cdc_is_bit_set(@dsc_endereco_cliente, __$update_mask) as 'Updateddsc_endereco_cliente'
	,sys.fn_cdc_is_bit_set(@dsc_complemento_cliente, __$update_mask) as 'Updateddsc_complemento_cliente'
	,sys.fn_cdc_is_bit_set(@dsc_bairro_cliente, __$update_mask) as 'Updateddsc_bairro_cliente'
	,sys.fn_cdc_is_bit_set(@dsc_cidade_cliente, __$update_mask) as 'Updateddsc_cidade_cliente'
	,sys.fn_cdc_is_bit_set(@dsc_uf_cliente, __$update_mask) as 'Updateddsc_uf_cliente'
	,sys.fn_cdc_is_bit_set(@num_cep_cliente, __$update_mask) as 'Updatednum_cep_cliente'
	,sys.fn_cdc_is_bit_set(@num_ddd_cliente, __$update_mask) as 'Updatednum_ddd_cliente'
	,sys.fn_cdc_is_bit_set(@num_telefone_cliente, __$update_mask) as 'Updatednum_telefone_cliente'
	,sys.fn_cdc_is_bit_set(@data_ultima_atualizacao, __$update_mask) as 'Updateddata_ultima_atualizacao'
	,sys.fn_cdc_is_bit_set(@flg_endereco_correspondencia, __$update_mask) as 'Updatedflg_endereco_correspondencia'
	,sys.fn_cdc_is_bit_set(@data_carga, __$update_mask) as 'Updateddata_carga'

	FROM cdc.fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd(@from_lsn, @to_lsn, 'all')

	WHERE sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dlkmumps_tb_enderecosInd.__$start_lsn) > (select top 1 LastDateInserted from dba.dbo.vw_max_ChangedDate_tb_enderecosInd WITH(NOEXPAND)order by 1 desc   )
ORDER BY __$seqval
GO


-- Criação da View para realizar a restrição e usar uma carga incremental
use
dba
go

CREATE view [vw_max_ChangedDate_tb_enderecosInd]

WITH SCHEMABINDING

as

select id,ChangedDate as LastDateInserted from [dbo].[cdc_tracking_tb_enderecosInd]
GO

create unique clustered index idx_LastDateInserted on vw_max_ChangedDate_tb_enderecosInd (id,LastDateInserted)

select top 1 LastDateInserted from vw_max_ChangedDate_tb_enderecosInd WITH(NOEXPAND)
order by 1 desc



CREATE CLUSTERED INDEX IDX_ChangedDate ON dba.dbo.cdc_tracking_tb_enderecosInd (ChangedDate)


--DECLARE @from_lsn binary (10), @to_lsn binary (10)

--SET @from_lsn = sys.fn_cdc_get_min_lsn('dlkmumps_tb_coberturacertificadoClb')
--SET @to_lsn = sys.fn_cdc_get_max_lsn()

--SELECT *
--FROM cdc.fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb(@from_lsn, @to_lsn, 'all')
--ORDER BY __$seqval
