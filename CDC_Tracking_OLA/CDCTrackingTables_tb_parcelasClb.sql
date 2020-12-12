--id_coberturacertificado
--num_certificado_coberturacertificado
--cod_cobertura_coberturacertificado
--vl_capital_coberturacertificado
--data_carga


-- 1 Delete
-- 2 Insert
-- 3 Updated row before the change
-- 4 Updated row after the change

-- dlkmumps.tb_parcelasClb

Use
DLKMUMPS
go

SET QUOTED_IDENTIFIER ON
GO

DECLARE @max_lsn binary(10);
DECLARE @from_lsn binary (10) ,@to_lsn binary (10)


DECLARE @id_parcela int
DECLARE @num_certificado_parcela int
DECLARE @num_parcela int
DECLARE @competencia_parcela int
DECLARE @data_vencimento_parcela int
DECLARE @vl_premio_parcela int
DECLARE @status_Endosso_parcela int
DECLARE @data_vencimento_ultima_parcela int
DECLARE @data_pagamento_parcela int
DECLARE @data_carga int


SET @from_lsn = sys.fn_cdc_get_min_lsn('dlkmumps_tb_parcelasClb')
SET @to_lsn = sys.fn_cdc_get_max_lsn()

SET @id_parcela =					  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'id_parcela')
SET @num_certificado_parcela =		  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'num_certificado_parcela')
SET @num_parcela =					  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'num_parcela')
SET @competencia_parcela =			  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'competencia_parcela')
SET @data_vencimento_parcela =		  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'data_vencimento_parcela')
SET @vl_premio_parcela =			  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'vl_premio_parcela')
SET @status_Endosso_parcela =		  sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'status_Endosso_parcela')
SET @data_vencimento_ultima_parcela = sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'data_vencimento_ultima_parcela')
SET @data_pagamento_parcela =         sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'data_pagamento_parcela')
SET @data_carga =                     sys.fn_cdc_get_column_ordinal('dlkmumps_tb_parcelasClb', 'data_carga')


INSERT INTO dba.dbo.cdc_tracking_tb_parcelasClb WITH (TABLOCKX)

SELECT
'tb_parcelasClb' as TableName
,sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$start_lsn) as ChangedDate
	,		   fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$start_lsn
	,		   fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$seqval
	,case when fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$operation = 1 THEN 'Delete'
		  when fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$operation = 2 THEN 'Insert'
		  when fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$operation = 3 THEN 'Updated row before the change'
		  when fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$operation = 4 THEN 'Updated row after the change' ELSE 'Não encontrado ' END as [Status]
	,		   fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$update_mask
	,      sys.fn_cdc_is_bit_set(@id_parcela, __$update_mask) as 'Updatednum_id_parcela'
	,      sys.fn_cdc_is_bit_set(@num_certificado_parcela, __$update_mask) as 'Updatednum_certificado_parcela'
	,      sys.fn_cdc_is_bit_set(@num_parcela, __$update_mask) as 'Updatednum_parcela'
	,      sys.fn_cdc_is_bit_set(@competencia_parcela, __$update_mask) as 'Updatedcompetencia_parcela'
	,      sys.fn_cdc_is_bit_set(@data_vencimento_parcela, __$update_mask) as 'Updateddata_vencimento_parcela'
	,      sys.fn_cdc_is_bit_set(@vl_premio_parcela, __$update_mask) as 'Updatedvl_premio_parcela'
	,      sys.fn_cdc_is_bit_set(@status_Endosso_parcela, __$update_mask) as 'Updatedstatus_Endosso_parcela'
	,      sys.fn_cdc_is_bit_set(@data_vencimento_ultima_parcela, __$update_mask) as 'Updateddata_vencimento_ultima_parcela'
	,      sys.fn_cdc_is_bit_set(@data_pagamento_parcela, __$update_mask) as 'Updateddata_pagamento_parcela'
	,      sys.fn_cdc_is_bit_set(@data_carga, __$update_mask) as 'Updateddata_carga'


	FROM cdc.fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb(@from_lsn, @to_lsn, 'all')

WHERE sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dlkmumps_tb_parcelasClb.__$start_lsn) > (select top 1 LastDateInserted from dba.dbo.vw_max_ChangedDate_tb_parcelasClb WITH(NOEXPAND)order by 1 desc   )
ORDER BY __$seqval
GO


-- Criação da View para realizar a restrição e usar uma carga incremental
use
dba
go


CREATE view [vw_max_ChangedDate_tb_parcelasClb]

WITH SCHEMABINDING

as

select id,ChangedDate as LastDateInserted from [dbo].[cdc_tracking_tb_parcelasClb]
GO

create unique clustered index idx_LastDateInserted on vw_max_ChangedDate_tb_parcelasClb (id,LastDateInserted)

select top 1 LastDateInserted from vw_max_ChangedDate_tb_parcelasClb WITH(NOEXPAND)
order by 1 desc



CREATE CLUSTERED INDEX IDX_ChangedDate ON dba.dbo.cdc_tracking_tb_parcelasClb (ChangedDate)


----DECLARE @from_lsn binary (10), @to_lsn binary (10)

----SET @from_lsn = sys.fn_cdc_get_min_lsn('dlkmumps_tb_coberturacertificadoClb')
----SET @to_lsn = sys.fn_cdc_get_max_lsn()

----SELECT *
----FROM cdc.fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb(@from_lsn, @to_lsn, 'all')
----ORDER BY __$seqval
