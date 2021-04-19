select top 1
	[Current LSN],
	[operation],
	[Begin Time] as begin_time,
	[End Time]   as end_time,
	getdate()    as curr_time
from sys.fn_dblog ('0038c11a:00000c97:00aa', NULL)
where operation in ('LOP_BEGIN_XACT','LOP_COMMIT_XACT')
