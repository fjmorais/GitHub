
DECLARE @newDriveAndFolder VARCHAR(8000);

SET @newDriveAndFolder = 'Z:\YourTempDBfolder';

SELECT [name] AS [Logical Name]
    ,physical_name AS [Current Location]
    ,state_desc AS [Status]
    ,size*8/1024 AS [Size(MB)] --Number of 8KB pages dived by 1024
    ,'ALTER DATABASE tempdb MODIFY FILE (NAME = ' + QUOTENAME(f.[name])
    + CHAR(9) /* Tab */
    + ',FILENAME = ''' + @newDriveAndFolder + CHAR(92) /* Backslash */ + f.[name]
    + CASE WHEN f.[type] = 1 /* Log */ THEN '.ldf' ELSE '.mdf' END  + ''''
    + ');'
    AS [Create new TempDB files]
FROM sys.master_files f
WHERE f.database_id = DB_ID(N'tempdb')
ORDER BY f.[type];



SELECT 'ALTER DATABASE tempdb MODIFY FILE (NAME = [' + f.name + '],'
	+ ' FILENAME = ''Z:\MSSQL\DATA\' + f.name
	+ CASE WHEN f.type = 1 THEN '.ldf' ELSE '.mdf' END
	+ ''');'
FROM sys.master_files f
WHERE f.database_id = DB_ID(N'tempdb');

-- Every time I have to do this, I Google for a script. I might as well write my own and put it here so at least I find myself
-- in the Google results:


-- I can then copy/paste the results into SSMS, edit them, and run ’em.
--I like generating scripts like this rather than flat-out executing it automatically because
--sometimes I need to tweak specific file locations.

--I’m not bothering with detecting what the file names were before, and I’m just generating new file names to match
--the database object’s name instead.

-- Erik says: See that path? Make sure you change that path to the right one. Preferably one that exists,
--and that SQL Server has permissions to. If you don’t, your server won’t start up unless you Google “how to start SQL Server without tempdb” and spend the next morning explaining to your boss why you should keep your job. I mean, I’ve heard stories…
