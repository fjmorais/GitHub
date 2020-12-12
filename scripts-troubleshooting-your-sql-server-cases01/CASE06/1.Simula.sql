use StackOverflow50
go
/*
Procedure:
	sp_get_posts_report
Parametros:
	@TypePost......: Tipo da postagem podendo ser Question, Answer, Wiki, TagWikiExerpt, TagWiki, ModeratorNomination, 
	                 WikiPlaceholder, PrivilegeWiki
	@OwnerUserName.: Matt Mitchell, Nick Berardi, Ryan Eastabrook, etc...
	@ViewCounts....: Quantidade de views de uma determinada postagem...
	@CreationDate..: Data de criação no formado YYYMMDD, podendo ser apenas o ano no formato YYYY ou ano e mês no formato YYYYMM
	@ClosedDate....: Data de encerramento para alguns tipos de postagem no formato YYYYMMDD, podendo ser apenas o ano no formato YYYY 
	                 ou ano e mês no formato YYYYMM
*/

/*
90% das execuções da procedure são passando @TypePost, @CreationDate e @ViewCounts
*/
EXEC dbo.sp_get_posts_report @TypePost = 'Question', @CreationDate = '20130505', @ViewCounts = 10000

/***********************************************************************************************
***********Demais formas de execução da procedure por outros departamentos da empresa***********
************************************************************************************************/

--Todas as perguntas com mais de 80 mil visualizacoes, criadas em 2008 por um determinado usuario.
EXEC dbo.sp_get_posts_report @TypePost = 'Question',@ViewCounts = 80000, @OwnerUserName = 'Matt Mitchell', @CreationDate = '2008'

--Todos as respostas, perguntas, wiki, etc... criados em um determinado dia
EXEC dbo.sp_get_posts_report @CreationDate = '20130704'

--Todas as respostas de um determinado dia
EXEC dbo.sp_get_posts_report @TypePost = 'Answer', @CreationDate = '20130505'

--Todas as postagens encerradas em 20131231
EXEC dbo.sp_get_posts_report @ClosedDate = '20131231'

--Todas as postagens criadas em 201201 e fechadas em 201301
EXEC dbo.sp_get_posts_report @CreationDate = '201201', @ClosedDate = '201301'

--Todas as postagens com mais de 1.000.000 de visualizações
EXEC dbo.sp_get_posts_report @ViewCounts = 1000000