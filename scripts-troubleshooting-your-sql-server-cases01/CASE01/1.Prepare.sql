USE [StackOverflow50]
GO
/*
	1. Baixem o banco StackOverflow de 50GB: https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/
	2. Edite o arquivo Start.ps1 da seguinte maneira:
	   "-SEC2AMAZ-N9T8T09" --Colocar o nome da sua instância SQL Server 2019 após o -S;
	   "-dStackOverflow50" --Colocar o nome do banco de dados do StackOverflow que você criou, após o -d;
	3. Execute o script abaixo para criar alguns objetos necessários para o case.
*/
DROP INDEX IF EXISTS IDX_Posts_CreationDate ON dbo.Posts
GO
CREATE INDEX IDX_Posts_CreationDate ON dbo.Posts(CreationDate) INCLUDE(Title)
GO
DROP INDEX IF EXISTS IDX_Comments_PostId ON dbo.Comments
GO
CREATE INDEX IDX_Comments_PostId ON dbo.Comments(PostId)
GO
CREATE OR ALTER PROCEDURE dbo.sp_get_latest_questions
AS
BEGIN
	SELECT TOP 100 p.Id, p.PostTypeId, p.CreationDate, p.Title 
	FROM Posts p
	WHERE
	p.PostTypeId=1 and 
	CAST(p.CreationDate AS DATE) = (SELECT CAST(MAX(CreationDate) AS DATE) FROM Posts)
	ORDER BY CommentCount DESC
END
GO
CREATE OR ALTER PROCEDURE dbo.sp_posts_stats
@tipo varchar(20) = 'Comentario'/*1 - Posts mais comentados | 2 - Posts mais votados*/,
@dataInicio datetime = null,
@dataTermino datetime = null
AS 
BEGIN
	IF @tipo = 'Comentario'
	BEGIN
		SELECT p.Title,COUNT(0) AS totalComentarios
		FROM Posts p
		JOIN Comments c ON c.PostId = p.Id
		WHERE p.CreationDate BETWEEN @dataInicio AND @dataTermino AND p.Title IS NOT NULL
		GROUP BY p.Title
		ORDER BY count(0) DESC
	END
	ELSE IF @tipo = 'Voto'
	BEGIN
		SELECT p.Title,COUNT(0) AS totalVotos 
		FROM Posts p
		JOIN Votes v ON v.PostId = p.Id
		GROUP BY p.Title
		ORDER BY count(0) DESC
	END
END
GO