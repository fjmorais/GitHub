
DECLARE @from_lsn binary (10), @to_lsn binary (10)

SET @from_lsn = sys.fn_cdc_get_min_lsn('dlkmumps_tb_coberturacertificadoClb')
SET @to_lsn = sys.fn_cdc_get_max_lsn()

SELECT *
FROM cdc.fn_cdc_get_all_changes_dlkmumps_tb_coberturacertificadoClb(@from_lsn, @to_lsn, 'all')
ORDER BY __$seqval