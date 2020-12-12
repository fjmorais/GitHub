USE StackOverflow50
GO
CREATE OR ALTER PROCEDURE dbo.sp_get_posts_report
 @TypePost VARCHAR(100) = NULL
,@OwnerUserName VARCHAR(80) = NULL
,@ViewCounts INT = NULL
,@CreationDate VARCHAR(8) = NULL
,@ClosedDate VARCHAR(8) = NULL
AS
BEGIN
	DECLARE @PostTypeId INT
	SELECT @PostTypeId = Id from PostTypes WHERE Type = @TypePost

	SELECT P.Id, P.CreationDate, P.ClosedDate, PT.Type, P.Title, UO.DisplayName, ViewCount
	FROM Posts P
	JOIN PostTypes PT ON PT.Id = P.PostTypeId
	JOIN Users UO ON UO.Id = P.OwnerUserId
	WHERE
	    (@PostTypeId IS NULL OR PostTypeId = @PostTypeId )
	AND (@ViewCounts IS NULL OR ViewCount >= @ViewCounts )
	AND (@OwnerUserName IS NULL OR UO.DisplayName LIKE @OwnerUserName)
	AND (ISNULL(@CreationDate,'') = '' 
	     OR (LEN(@CreationDate) = 4 AND YEAR(P.CreationDate) = CAST(SUBSTRING(@CreationDate,1,4) AS INT)) 
		 OR (LEN(@CreationDate) = 6 AND LEFT(CONVERT(VARCHAR(8),P.CreationDate,112),6) = @CreationDate) 
		 OR (LEN(@CreationDate) = 8 AND LEFT(CONVERT(VARCHAR(8),P.CreationDate,112),8) = @CreationDate))
	AND (ISNULL(@ClosedDate,'') = '' 
	     OR (LEN(@ClosedDate) = 4 AND YEAR(P.ClosedDate) = SUBSTRING(@ClosedDate,1,4)) 
		 OR (LEN(@ClosedDate) = 6 AND YEAR(P.ClosedDate) = SUBSTRING(@ClosedDate,1,4) AND MONTH(P.ClosedDate) = SUBSTRING(@ClosedDate,5,2)) 
		 OR (LEN(@ClosedDate) = 8 AND YEAR(P.ClosedDate) = SUBSTRING(@ClosedDate,1,4) AND MONTH(P.ClosedDate) = SUBSTRING(@ClosedDate,5,2) AND DAY(P.ClosedDate) = SUBSTRING(@ClosedDate,7,2)) 
		 )
END
GO
