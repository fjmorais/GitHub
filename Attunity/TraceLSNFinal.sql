use
PGBL

select
bmf.physical_device_name,
bs.position,
[dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn),
[dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn),
bs.backup_set_id,backup_start_date
from msdb.dbo.backupmediafamily bmf, msdb.dbo.backupset bs
where bmf.media_set_id = bs.media_set_id
and bs.backup_set_id > 0
and bs.database_name=db_name() and bs.type='L'
and cast([dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
=cast( '003c406a:0000c00e:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and bmf.device_type in (2,102,7)

UNION ALL

select
bmf.physical_device_name,
bs.position,
[dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn),
[dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn),
bs.backup_set_id,backup_start_date
from msdb.dbo.backupmediafamily bmf, msdb.dbo.backupset bs
where bmf.media_set_id = bs.media_set_id
and bs.backup_set_id > 0
and bs.database_name=db_name() and bs.type='L'
and cast( '003c406a:0000c00e:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
= cast( [dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and bmf.device_type in (2,102,7)

select
bmf.physical_device_name,
bs.position,
[dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn),
[dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn),
bs.backup_set_id,backup_start_date
from msdb.dbo.backupmediafamily bmf, msdb.dbo.backupset bs
where bmf.media_set_id = bs.media_set_id
and bs.backup_set_id > 0
and bs.database_name=db_name() and bs.type='L'
and cast([dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
<=cast( '003c406a:0000c00e:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and cast( '003c406a:0000c00e:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
< cast( [dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and bmf.device_type in (2,102,7)


select
bmf.physical_device_name,
bs.position,
[dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn),
[dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn),
bs.backup_set_id,backup_start_date
from msdb.dbo.backupmediafamily bmf, msdb.dbo.backupset bs
where bmf.media_set_id = bs.media_set_id
and bs.backup_set_id > 0
and bs.database_name=db_name() and bs.type='L'
and backup_start_date >= '2021-03-02 22:00:08.000'
--and cast([dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
--<=cast( '003c4005:0001348d:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
--and cast( '003c4005:0001348d:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
--< cast( [dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar (24) )
and bmf.device_type in (2,102,7)



sp_whoIsActive @get_outer_command=1
