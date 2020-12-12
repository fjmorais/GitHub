use
I4Pro_ERP_Icatu
go

DECLARE @from_lsn binary (50), @to_lsn binary (50)

SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_corp_item_vida')
SET @to_lsn = sys.fn_cdc_get_max_lsn()

SELECT TOP 100
sys.fn_cdc_map_lsn_to_time(fn_cdc_get_all_changes_dbo_corp_item_vida.__$start_lsn) as ChangedData,*
FROM cdc.fn_cdc_get_all_changes_dbo_corp_item_vida(@from_lsn, @to_lsn, 'all')
ORDER BY __$seqval
