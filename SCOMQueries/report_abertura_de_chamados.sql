select ars.AlertGuid, me.FullName, 
isnull(me.[Path],'') as [path], 
me.Name, me.DisplayName, 
AlertName, AlertDescription, Severity, 
Priority, ResolutionState, 
ResolutionStateName,TimeInStateSeconds,
TimeFromRaisedSeconds, StateSetDateTime, 
DBLastModifiedDateTime, DBCreatedDateTime,StateSetByUserId, 
dateadd(hh, -3, StateSetDateTime) as datatimestamp 
from Alert.vAlertResolutionState ars inner join Alert.vAlertDetail adt 
on ars.alertguid = adt.alertguid inner join Alert.vAlert alt on ars.alertguid = 
alt.alertguid inner join ResolutionState rs on rs.ResolutionStateId = ars.ResolutionState 
inner join ManagedEntity me on alt.ManagedEntityRowId = me.ManagedEntityRowId 
where dateadd(hh, -3, StateSetDateTime) >= '2020-11-05 14:30:00:000' and severity = '2' 
Order by StateSetDateTime ASC