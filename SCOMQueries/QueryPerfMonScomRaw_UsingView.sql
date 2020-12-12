USE
  DBA
GO

insert into dba.dbo.tb_performance_raw_scom
  select distinct A.DateTime,
  --a.ManagedEntityRowId,
  --b.ManagedEntityRowId,
  a.SampleValue,
  --b.ManagedEntityGuid,
  --b.ManagedEntityTypeRowId,
  --b.TopLevelHostManagedEntityRowId,
  c.ManagedEntityTypeSystemName,
  c.ManagedEntityTypeDefaultName,
  c.ManagedEntityTypeDefaultDescription,
  b.FullName,B.Path,B.DisplayName,
  --d.PropertySystemName,
  --d.PropertyDefaultName,
  --d.PropertyDefaultDescription,
  --e.AlertName,
  --e.AlertDescription,
  --e.Category,
  --case when e.MonitorAlertInd = 0 then 'Rule' ELSE 'Monitor' END as Tipo,
  --e.WorkflowRowId,
  B.DwCreatedDatetime
  from PerfRaw a inner join [OperationsManagerDW].dbo.ManagedEntity b
	on a.ManagedEntityRowId = b.ManagedEntityRowId
		inner join [OperationsManagerDW].dbo.ManagedEntityType c
		on b.ManagedEntityTypeRowId = c.ManagedEntityTypeRowId
		--inner join [OperationsManagerDW].[dbo].[ManagedEntityTypeProperty] d
		--on b.ManagedEntityTypeRowId = d.ManagedEntityTypeRowId
		 --inner join [OperationsManagerDW].Alert.Alert_20AEE55F7CB3410080E53F779B923AFD e
--			on a.ManagedEntityRowId = e.ManagedEntityRowId
  where a.[Datetime] between '2020-11-13 00:00:00' and '2020-11-13 23:59:59'
  go
