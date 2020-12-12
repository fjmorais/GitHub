-- Status OK

--id_coberturacertificado
--num_certificado_coberturacertificado
--cod_cobertura_coberturacertificado
--vl_capital_coberturacertificado
--data_carga


-- 1 Delete
-- 2 Insert
-- 3 Updated row before the change
-- 4 Updated row after the change


-- Processo de Leitura das modificações em relação a tabela tb_coberturacertificadoClb


Use
DLKMUMPS
go

SET QUOTED_IDENTIFIER ON
GO

DECLARE @max_lsn binary(10);
DECLARE @from_lsn binary (10) ,@to_lsn binary (10)
DECLARE @id_coberturacertificado INT
DECLARE @num_certificado_coberturacertificado INT
DECLARE @cod_cobertura_coberturacertificado INT
DECLARE @vl_capital_coberturacertificado INT
DECLARE @data_carga INT

SET @from_lsn = sys.fn_cdc_get_min_lsn('dlkmumps_tb_coberturacertificadoClb')
SET @to_lsn = sys.fn_cdc_get_max_lsn()
SET @id_coberturacertificado = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_coberturacertificadoClb', 'id_coberturacertificado')
SET @num_certificado_coberturacertificado = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_coberturacertificadoClb', 'num_certificado_coberturacertificado')
SET @cod_cobertura_coberturacertificado = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_coberturacertificadoClb', 'cod_cobertura_coberturacertificado')
SET @vl_capital_coberturacertificado = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_coberturacertificadoClb', 'vl_capital_coberturacertificado')
SET @data_carga = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_coberturacertificadoClb', 'data_carga')


INSERT INTO dba.dbo.cdc_tracking_tb_coberturacertificadoClb WITH (TABLOCKX)

SELECT
'tb_coberturacertificadoClb' as TableName
,sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$start_lsn) as ChangedDate
	,fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$start_lsn
	,fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$seqval
	,case when fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$operation = 1 THEN 'Delete'
		  when fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$operation = 2 THEN 'Insert'
		  when fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$operation = 3 THEN 'Updated row before the change'
		  when fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$operation = 4 THEN 'Updated row after the change' ELSE 'Não encontrado ' END as [Status]
	,fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb.__$update_mask
	,sys.fn_cdc_is_bit_set(@id_coberturacertificado, __$update_mask) as 'Updatedid_coberturacertificado'
	,sys.fn_cdc_is_bit_set(@num_certificado_coberturacertificado, __$update_mask) as 'Updatednum_certificado_coberturacertificado'
	,sys.fn_cdc_is_bit_set(@cod_cobertura_coberturacertificado, __$update_mask) as 'Updatedcod_cobertura_coberturacertificado'
	,sys.fn_cdc_is_bit_set(@vl_capital_coberturacertificado, __$update_mask) as 'Updatedvl_capital_coberturacertificado'
	,sys.fn_cdc_is_bit_set(@data_carga, __$update_mask) as 'Updateddata_carga'
	FROM cdc.fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb(@from_lsn, @to_lsn, 'all')
	WHERE sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dlkmumps_tb_enderecosClb.__$start_lsn) > (select top 1 LastDateInserted from vw_max_ChangedDate_tb_coberturacertificadoClb WITH(NOEXPAND)order by 1 desc
ORDER BY __$seqval
GO


CREATE CLUSTERED INDEX IDX_ChangedDate ON dba.dbo.cdc_tracking_tb_coberturacertificadoClb (ChangedDate)


-- Criação da View para realizar a restrição e usar uma carga incremental

CREATE view [vw_max_ChangedDate_tb_coberturacertificadoClb]

WITH SCHEMABINDING

as

select id,ChangedDate as LastDateInserted from [dbo].[cdc_tracking_tb_coberturacertificadoClb]
GO

create unique clustered index idx_LastDateInserted on vw_max_ChangedDate_tb_coberturacertificadoClb (id,LastDateInserted)

select top 1 LastDateInserted from vw_max_ChangedDate_tb_coberturacertificadoClb WITH(NOEXPAND)
order by 1 desc
