
SELECT a.*
FROM sys.dm_exec_connections a
WHERE EXISTS
      (
          SELECT *
          FROM sys.dm_exec_connections b
          WHERE b.net_transport = 'Session' -- Se tiver alguma conexão com MARS, net_transport vai ser = "Session"
          AND a.session_id = b.session_id
      )
ORDER BY a.session_id;
GO
