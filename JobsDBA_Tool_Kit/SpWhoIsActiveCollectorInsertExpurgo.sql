DECLARE @Rows INT
SET @Rows = 1

WHILE (@Rows > 0)
BEGIN
    DELETE TOP (1000) FROM [DBA].[dbo].[WhoIsActive]
    WHERE [collection_time] < GETDATE() - 30

    SET @Rows = @@ROWCOUNT
END
