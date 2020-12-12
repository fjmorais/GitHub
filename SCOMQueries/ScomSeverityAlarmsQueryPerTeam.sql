WITH CTE as (



SELECT [AlertGuid]
      ,[AlertName]
      ,[AlertDescription]
      ,A.[ResolutionState]
      ,A.[ResolutionStateName]
      ,[TimeInStateSeconds]
      ,[TimeFromRaisedSeconds]
      ,[StateSetDateTime]
      ,d.DataHHMMSS as TimeAlarmActionDuration
      ,e.DataHHMMSS as TimeActionDuration
      ,[DWCreatedDateTime]
      ,cast(convert(varchar(10),[DWCreatedDateTime],121) AS datetime) AS DWCreatedDateTimeFormated
      , UltimoStatus = LEAD (DWCreatedDateTime,1) OVER (PARTITION BY [AlertGuid] ORDER BY [AlertGuid])
      ,[DWLastModifiedDateTime]
      ,[StateSetByUserId]
	  ,c.Description as Severity
        FROM [DBA].[scom].[tb_tracking_resolution_state] A join dba.scom.tb_resolution_state B
        on a.ResolutionState = b.ResolutionState
		inner join dba.scom.tb_severity c on a.Severity = c.id
        CROSS APPLY dbo.InLineFunc_ConvertTimeToHHMMSS([TimeInStateSeconds]) as d
        CROSS APPLY dbo.InLineFunc_ConvertTimeToHHMMSS([TimeFromRaisedSeconds]) as e
        WHERE 1 = 1
        --and AlertGuid = '1D6B3EC6-7583-49A2-A43A-00010A720849'
        --and [DWCreatedDateTime] between '2020-09-01' and '2020-09-30'
      and a.ResolutionState not in (0,255)

     )



SELECT

    [AlertGuid]
      ,[AlertName]
      ,[AlertDescription]
      ,[ResolutionState]
      ,[ResolutionStateName]
      ,[TimeInStateSeconds]
      ,[TimeFromRaisedSeconds]
      ,TimeInStateSeconds
      ,[StateSetDateTime]
      ,TimeAlarmActionDuration
      ,TimeActionDuration
      ,[DWCreatedDateTime]
      , UltimoStatus = LEAD (DWCreatedDateTime,1) OVER (PARTITION BY [AlertGuid] ORDER BY [AlertGuid])
      , DWCreatedDateTimeFormated
      --, LastResolutionState = LEAD (ResolutionStateName,1) OVER (PARTITION BY [AlertGuid] ORDER BY [AlertGuid])
      ,[DWLastModifiedDateTime]
      ,[StateSetByUserId]
	  ,Severity

FROM CTE
WHERE UltimoStatus is null
