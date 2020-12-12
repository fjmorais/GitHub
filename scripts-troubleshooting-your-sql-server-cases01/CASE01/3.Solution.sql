USE StackOverflow50
GO
/*
 Refatoração do código da procedure para ser SARGABLE
*/
CREATE OR ALTER PROCEDURE dbo.sp_get_latest_questions
AS
BEGIN
DECLARE @DATA DATE = (SELECT CAST(MAX(CreationDate) AS DATE) FROM Posts)
SELECT TOP 100 p.Id, p.PostTypeId, p.CreationDate, p.Title 
FROM Posts p
WHERE
p.PostTypeId=1 and 
p.CreationDate  BETWEEN CAST(CAST(@DATA AS VARCHAR(10)) + ' 00:00:00.000' AS DATETIME) AND CAST(CAST(@DATA AS VARCHAR(10)) + ' 23:59:59.997' AS DATETIME)
ORDER BY CommentCount DESC
END
GO
/*
Criação de índice que atende melhor as necessidades da query
*/
DROP INDEX IF EXISTS IDX_Posts_PostTypeId_CreationDate_CommentCount ON dbo.Posts
CREATE NONCLUSTERED INDEX IDX_Posts_PostTypeId_CreationDate_CommentCount ON dbo.Posts(PostTypeId,CreationDate,CommentCount) 
INCLUDE(Title) 
