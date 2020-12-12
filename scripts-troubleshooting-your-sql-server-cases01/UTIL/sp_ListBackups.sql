
use DBA
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_WARNINGS ON;
SET NUMERIC_ROUNDABORT OFF;
SET ARITHABORT ON;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'sp_ListBackups')
	EXEC ('CREATE PROC dbo.sp_ListBackups AS SELECT ''stub version, to be replaced''')
GO

alter procedure dbo.sp_ListBackups (
	@Database		sysname = null
,	@Tipo			sysname = null /* FULL | DIFF | LOG */
,	@LikeDir		sysname = null /*EX: E: | E:\Backup | .bak */
) as 
begin

	/* Lista histórico de Backup da instância.
	
	exec DBA.dbo.sp_ListBackups
	exec DBA.dbo.sp_ListBackups @Database = 'DBA'
	exec DBA.dbo.sp_ListBackups @Tipo = 'DIFF'
	exec DBA.dbo.sp_ListBackups @LikeDir = 'F:\'
	
	*/

	select @Tipo = case @Tipo
						when 'FULL' then 'D'
						when 'DIFF' then 'I'
						when 'LOG'  then 'L'
					end

	SELECT
		 bs.backup_set_id 
	   , bs.database_name 
	   , bs.backup_start_date 
	   , bs.backup_finish_date 
	   , bs.backup_size / 1024 / 1024 / 1024.0 as BackupSize_GB 
	   , bs.recovery_model 
	   , bs.is_copy_only
	   , case bs.[type]
		   when 'D' then 'Database Backup - Full'
		   when 'L' then 'Log Backup'
		   when 'I' then 'Diff Backup'
		 end as TypeBackup
	   , bs.[user_name]
	   , mf.physical_device_name
	   , mf.device_type
	FROM 
	   MSDB.dbo.backupset bs
	 inner join 
	   msdb.dbo.backupmediafamily mf
		on bs.media_set_id = mf.media_set_id
	WHERE 
		    bs.database_name = isnull(@Database, bs.database_name)
		and bs.[type] = isnull(@Tipo, bs.[type])
		and mf.physical_device_name like isnull('%' + @LikeDir + '%', mf.physical_device_name)
	order by bs.backup_start_date DESC, bs.backup_finish_date desc


end
go

