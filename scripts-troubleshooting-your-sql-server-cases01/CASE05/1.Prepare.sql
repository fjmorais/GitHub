
/*

REALIZAR O RESTORE DO ARQUIVO StackOverflow2010_case05.bak DISPONÍVEL NO LINK ABAIXO:

https://drive.google.com/drive/folders/1-G8hP7liB0jAiHmKSoQWqIZodfqKZJqY?usp=sharing

*/

-- ALTERAR OS DIRETÓRIOS
RESTORE FILELISTONLY FROM DISK = 'C:\temp\bkp\StackOverflow2010_case05.bak'

RESTORE DATABASE StackOverflow2010
WITH MOVE 'StackOverflow2010'     TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\StackOverflow2010.mdf'
   , MOVE 'StackOverflow2010_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\StackOverflow2010_log.ldf'
   , RECOVERY



use StackOverflow2010
go

alter database StackOverflow2010 set recovery simple
-- Estamos usando o SQL 2019, mas pode ser qualquer compatibilidade
alter database StackOverflow2010 set compatibility_level = 150
-- Ativar TraceFlag para esconder possíveis dicas de Missing Index
dbcc traceon(2392)



go

create or alter procedure dbo.spGetNotablePosts (
	@DtInicio	datetime
,	@DtFim		datetime
)
as
begin

	set nocount on
	
	-- Regras minimas para definir que é um Post notavel.
	-- Esses numeros foram definidos pelo negocio e nao podem ser alterados
	declare @minViewCount  int = 500
		,	@CommentCount  int = 3
		,	@AnswerCount   int = 3
		,	@AnswerQuality int = 10
		,	@UserViews     int = 1500

	-- Busca Posts de acordo com regras acima
	select  
			p.Id
		,	p.Title
		,	p.CreationDate
		,	u.DisplayName
		,	p.ViewCount
		,	p.Score
		,	p.AnswerQuality
		,	p.AnswerCount
		,	p.CommentCount
	from
				dbo.Posts p 
	inner join	dbo.Users u on p.OwnerUserId = u.Id
	where
			p.CreationDate between @DtInicio and @DtFim
		and p.ViewCount     >= @minViewCount
		and p.CommentCount  >= @CommentCount
		and p.AnswerCount   >= @AnswerCount
		and p.AnswerQuality =  @AnswerQuality
		and u.Views         >= @UserViews
	order by
			p.ViewCount desc

end
GO

create nonclustered index ix_posts_report on dbo.Posts (CommentCount, AnswerCount, ViewCount) 
include (AnswerQuality, CreationDate, Title, Score)

