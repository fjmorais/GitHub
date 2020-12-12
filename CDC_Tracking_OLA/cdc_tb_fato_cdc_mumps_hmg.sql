
use
dba
go

CREATE TABLE [dbo].[tb_fato_cdc_mumps_hmg](
     id_pk_fato bigint identity primary key nonclustered,
	[sk_id_tablename] [int] NULL,
	[data] [datetime] NULL,
	[sk_id_status] [int] NULL,
	[qtd] [int] NULL
) ON [PRIMARY]
GO
