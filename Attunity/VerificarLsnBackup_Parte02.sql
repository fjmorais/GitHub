select
   bmf.physical_device_name,
   bs.position,
   [dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn),
   [dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn),
   bs.backup_set_id
 from  msdb.dbo.backupmediafamily bmf, msdb.dbo.backupset bs
 where bmf.media_set_id = bs.media_set_id
 and bs.backup_set_id > 0
 and bs.database_name=db_name() and bs.type='L'
 and
 (
  cast('003c3f66:000086b0:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar(24)) >= cast([dbo].[attrep_fn_NumericLsnToHexa](bs.first_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar(24))
  and
  cast('003c3f66:000086b0:0001' collate SQL_Latin1_General_CP1_CI_AS as varchar(24)) <  cast([dbo].[attrep_fn_NumericLsnToHexa](bs.last_lsn) collate SQL_Latin1_General_CP1_CI_AS as varchar(24))
  )
 and bmf.device_type in(2, 102, 0)
