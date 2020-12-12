use StackOverflow50
go
/*
Solução:
Reescrita da procedure de forma dinâmica executando via sp_executesql
*/
USE StackOverflow50
GO
CREATE OR ALTER PROCEDURE dbo.sp_get_posts_report_new
 @TypePost VARCHAR(100) = NULL
,@OwnerUserName VARCHAR(80) = NULL
,@ViewCounts INT = NULL
,@CreationDate VARCHAR(8) = NULL
,@ClosedDate VARCHAR(8) = NULL
AS
BEGIN
    DECLARE @SQL NVARCHAR(4000) = ''

	DECLARE @PostTypeId INT
	SELECT @PostTypeId = Id from PostTypes WHERE Type = @TypePost

	SET @SQL = 
	'
	SELECT P.Id, P.CreationDate, P.ClosedDate, PT.Type, P.Title, UO.DisplayName, ViewCount
	FROM Posts P
	JOIN PostTypes PT ON PT.Id = P.PostTypeId
	JOIN Users UO ON UO.Id = P.OwnerUserId
	WHERE 1=1'
	+ CASE WHEN @PostTypeId IS NOT NULL    THEN ' AND PostTypeId = @PostTypeId'              ELSE '' END
	+ CASE WHEN @ViewCounts IS NOT NULL    THEN ' AND ViewCount >= @ViewCounts'              ELSE '' END
	+ CASE WHEN @OwnerUserName IS NOT NULL THEN ' AND UO.DisplayName LIKE @OwnerUserName'    ELSE '' END
    + CASE WHEN @CreationDate IS NOT NULL THEN 
	      CASE LEN(@CreationDate) 
	      WHEN 4 THEN ' AND P.CreationDate BETWEEN CAST(@CreationDate +''0101 00:00:00.000'' AS DATETIME) AND CAST(@CreationDate +''1231 23:59:59.997'' AS DATETIME)'  
	      WHEN 6 THEN ' AND P.CreationDate BETWEEN CAST(@CreationDate +''01 00:00:00.000'' AS DATETIME) AND DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@CreationDate +''01 23:59:59.997'' AS DATETIME)))'  
	      WHEN 8 THEN ' AND P.CreationDate BETWEEN CAST(@CreationDate +'' 00:00:00.000'' AS DATETIME) AND CAST(@CreationDate +'' 23:59:59.997'' AS DATETIME)'  
		  ELSE ''
	      END
	  ELSE ''
      END
    + CASE WHEN @ClosedDate IS NOT NULL THEN 
	      CASE LEN(@ClosedDate) 
	      WHEN 4 THEN ' AND P.ClosedDate BETWEEN CAST(@ClosedDate +''0101 00:00:00.000'' AS DATETIME) AND CAST(@ClosedDate +''1231 23:59:59.997'' AS DATETIME)'  
	      WHEN 6 THEN ' AND P.ClosedDate BETWEEN CAST(@ClosedDate +''01 00:00:00.000'' AS DATETIME) AND DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@ClosedDate +''01 23:59:59.997'' AS DATETIME)))'  
	      WHEN 8 THEN ' AND P.ClosedDate BETWEEN CAST(@ClosedDate +'' 00:00:00.000'' AS DATETIME) AND CAST(@ClosedDate +'' 23:59:59.997'' AS DATETIME)'  
		  ELSE ''
	      END
      ELSE ''
	  END
	  print @SQL
	  exec sp_executesql @SQL,N'@PostTypeId INT,@ViewCounts INT,@OwnerUserName VARCHAR(80),@CreationDate VARCHAR(8), @ClosedDate VARCHAR(8)',@PostTypeId = @PostTypeId,@ViewCounts = @ViewCounts,@OwnerUserName = @OwnerUserName,@CreationDate = @CreationDate,@ClosedDate = @ClosedDate
END
/*
EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @CreationDate = '20130101',@ClosedDate = '201301'
EXEC dbo.sp_get_posts_report_new @CreationDate = '20130101',@ClosedDate = '201301'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @TypePost = 'Question',@ViewCounts = 82308, @OwnerUserName = 'Matt Mitchell', @CreationDate = '2008'
EXEC dbo.sp_get_posts_report_new @TypePost = 'Question',@ViewCounts = 82308, @OwnerUserName = 'Matt Mitchell', @CreationDate = '2008'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @TypePost = 'Question',@ViewCounts = 82308, @OwnerUserName = 'Matt Mitchell', @CreationDate = '200808'
EXEC dbo.sp_get_posts_report_new @TypePost = 'Question',@ViewCounts = 82308, @OwnerUserName = 'Matt Mitchell', @CreationDate = '200808'
dbcc traceon(2392,-1)
EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @TypePost = 'Question',@ViewCounts = 82308, @OwnerUserName = 'Matt Mitchell', @CreationDate = '20080805'
EXEC dbo.sp_get_posts_report_new @TypePost = 'Question',@ViewCounts = 82308, @OwnerUserName = 'Matt Mitchell', @CreationDate = '20080805'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @TypePost = 'Question', @CreationDate = '20130505', @ViewCounts = 10000
EXEC dbo.sp_get_posts_report_new @TypePost = 'Question', @CreationDate = '20130505', @ViewCounts = 10000

CREATE NONCLUSTERED INDEX [IDX_Posts_CreationDate] ON [dbo].[Posts](CreationDate ASC)
INCLUDE(Title,ClosedDate,OwnerUserId,ViewCount,PostTypeId) WITH (DROP_EXISTING = ON) 
ON [PRIMARY]
GO
EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @TypePost = 'Question', @CreationDate = '201305', @ViewCounts = 10000
EXEC dbo.sp_get_posts_report_new @TypePost = 'Question', @CreationDate = '201305', @ViewCounts = 10000

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @TypePost = 'Answer',@CreationDate = '2008'
EXEC dbo.sp_get_posts_report_new @TypePost = 'Answer',@CreationDate = '2008'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @CreationDate = '2008'
EXEC dbo.sp_get_posts_report_new @CreationDate = '2008'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @CreationDate = '200808'
EXEC dbo.sp_get_posts_report_new @CreationDate = '200808'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @CreationDate = '2008', @ViewCounts = 100000, @ClosedDate = '200812'
EXEC dbo.sp_get_posts_report_new @CreationDate = '2008', @ViewCounts = 100000, @ClosedDate = '200812'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @CreationDate = '2008', @ClosedDate = '200812'
EXEC dbo.sp_get_posts_report_new @CreationDate = '2008', @ClosedDate = '200812'

EXEC sp_recompile sp_get_posts_report
EXEC dbo.sp_get_posts_report     @ViewCounts = 1000000
EXEC dbo.sp_get_posts_report_new @ViewCounts = 1000000
*/

/*
Análise de estatística de execução dos planos
*/
exec DBA..sp_GetProcStats
go
exec DBA..sp_GetQueryStats @sqltext = 'posts'
go

