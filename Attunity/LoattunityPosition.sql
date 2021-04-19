use
PGBL

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
and cast([dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
<=cast( '0038c11a:00000c97:00aa' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and cast( '0038c11a:00000c97:00aa' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
< cast( [dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and bmf.device_type in (2,102,7)

R:\PGBL\PGBL_backup_2021_03_01_233004_9370363.trn
