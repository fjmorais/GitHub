
USE [DBA]
GO

INSERT INTO tb_fato_cdc_mumps_hmg
SELECT
1 sk_id_TableName
      ,ChangedDate
      ,case when [Status] = 'Delete' THEN 1
	  when [Status] = 'Insert' THEN 2
	  when [Status] = 'Updated row before the change' THEN 3
	  when [Status] = 'Updated row after the change' THEN 4 ELSE '5' END sk_Id_status,
	  1 as Qtd
FROM [DBA].[dbo].[cdc_tracking_tb_coberturacertificadoClb]
WHERE ChangedDate > (select top 1 LastDateInserted from [vw_max_fato_data_tb_coberturacertificadoClb] order by LastDateInserted desc)


/*

/****** Object:  View [dbo].[vw_max_ChangedDate_tb_coberturacertificadoClb]    Script Date: 19/10/2020 15:32:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_max_fato_data_tb_coberturacertificadoClb]

WITH SCHEMABINDING

as

select id_pk_fato,sk_id_TableName, [data] as LastDateInserted from [dbo].[tb_fato_cdc_mumps_hmg]
where sk_id_TableName = '1'

GO

create unique clustered index idx_LastDateInserted on vw_max_fato_data_tb_coberturacertificadoClb (id_pk_fato,sk_id_TableName,LastDateInserted)

*/
