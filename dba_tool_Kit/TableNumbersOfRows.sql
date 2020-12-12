Select
S.name + '.' + T.name As TableName ,
SUM( P.rows ) As RowCont

From sys.tables As T
Inner Join sys.partitions As P On ( P.OBJECT_ID = T.OBJECT_ID )
Inner Join sys.schemas As S On ( T.schema_id = S.schema_id )
Where
( T.is_ms_shipped = 0 )
AND
( P.index_id IN (1,0) )
And
( T.type = 'U' )
and T.name = 'abt_mkt_ecm_performance'
and S.name = 'ecommerce'
Group By S.name , T.name

Order By SUM( P.rows ) Desc
