USE [DBA]
GO

/****** Object:  Table [dbo].[tb_performance_raw_scom]    Script Date: 27/11/2020 14:24:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tb_performance_raw_scom]') AND type in (N'U'))
DROP TABLE [dbo].[tb_performance_raw_scom]
GO

/****** Object:  Table [dbo].[tb_performance_raw_scom]    Script Date: 27/11/2020 14:24:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tb_performance_raw_scom](
	[DateTime] [datetime] NOT NULL,
	[SampleValue] [float] NULL,
	[ManagedEntityTypeSystemName] [varchar](256) NOT NULL,
	[ManagedEntityTypeDefaultName] [varchar](256) NOT NULL,
	[ManagedEntityTypeDefaultDescription] [varchar](max) NULL,
	[FullName] [varchar](512) NULL,
	[Path] [varchar](512) NULL,
	[DisplayName] [varchar](512) NULL,
	[DwCreatedDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO


USE [DBA]
GO

/****** Object:  Index [idx_clr_DateTime]    Script Date: 27/11/2020 14:24:33 ******/
CREATE CLUSTERED INDEX [idx_clr_DateTime] ON [dbo].[tb_performance_raw_scom]
(
	[DateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

USE [DBA]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [idx_nclr_path]    Script Date: 27/11/2020 14:24:41 ******/
CREATE NONCLUSTERED INDEX [idx_nclr_path] ON [dbo].[tb_performance_raw_scom]
(
	[Path] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
