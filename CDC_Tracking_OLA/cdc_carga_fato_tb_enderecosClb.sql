
USE [DBA]
GO

INSERT INTO tb_fato_cdc_mumps_hmg
SELECT
2 sk_id_TableName
      ,ChangedDate
      ,case when [Status] = 'Delete' THEN 1
	  when [Status] = 'Insert' THEN 2
	  when [Status] = 'Updated row before the change' THEN 3
	  when [Status] = 'Updated row after the change' THEN 4 ELSE '5' END sk_Id_status,
	  1 as Qtd
FROM [DBA].[dbo].[cdc_tracking_tb_enderecosClb]
WHERE ChangedDate > (select top 1 LastDateInserted from [vw_max_fato_data_tb_enderecosClb] order by LastDateInserted desc)


use
dba
go

create view [dbo].[vw_max_fato_data_tb_enderecosClb]

WITH SCHEMABINDING

as

select id_pk_fato,sk_id_TableName, [data] as LastDateInserted from [dbo].[tb_fato_cdc_mumps_hmg]
where sk_id_TableName = '2'

GO

create unique clustered index idx_LastDateInserted on vw_max_fato_data_tb_enderecosClb (id_pk_fato,sk_id_TableName,LastDateInserted)
