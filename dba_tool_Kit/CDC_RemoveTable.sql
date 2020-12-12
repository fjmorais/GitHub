-- Verificar tabela com  CDC
EXEC sys.sp_cdc_help_change_data_capture
GO
 
SELECT OBJECT_NAME([object_id]), OBJECT_NAME(source_object_id), capture_instance
FROM cdc.change_tables

--Remover tabela com CDC
EXEC sys.sp_cdc_disable_table
    @source_schema = 'dbo', -- sysname
    @source_name = 'T_NEGOCIACAO_CONVENIO', -- sysname
    @capture_instance = 'dbo_T_NEGOCIACAO_CONVENIO' -- sysname
