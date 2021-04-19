select
bmf.physical_device_name,
bs.position,
[dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn),
[dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn),
bs.backup_set_id
from msdb.dbo.backupmediafamily bmf, msdb.dbo.backupset bs
where bmf.media_set_id = bs.media_set_id
and bs.backup_set_id > 0
and bs.database_name=db_name() and bs.type='L'




USE PGBL;
select top 1
[Current LSN],
[operation],
[Begin Time] as begin_time,
[End Time] as end_time,
getdate() as curr_time
from sys.fn_dblog ('0x0038c11a:00000c97:00aa', NULL)
where operation in ('LOP_BEGIN_XACT','LOP_COMMIT_XACT')
