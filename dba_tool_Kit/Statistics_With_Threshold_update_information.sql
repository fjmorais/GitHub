SELECT OBJECT_NAME(st.OBJECT_ID) AS 'TableName'
				                                               ,sch.name as schema_table
															   --, sp.stats_id
                                                               , st.name AS 'StatisticsName'
                                                               --, ob.type
                                                               --, sc.column_id
                                                               , co.name AS 'ColumnName'
                                                               , sp.last_updated
                                                               , sp.rows
                                                               , sp.rows_sampled
                                                               , CONVERT(DECIMAL(32,2),sp.rows_sampled)/CONVERT(DECIMAL(32,2),rows) * 100 AS 'SampleRate'
															   ,([sp].[rows]*.20) + 500 [OldThreshold] -- Antes do SQL Server 2012
															   ,SQRT([sp].[rows]*1000) [NewThreshold] -- Depois do SQL Server 2012 +
                                                               , sp.steps
                                                               , sp.unfiltered_rows
                                                               , sp.modification_counter
															   , 'UPDATE STATISTICS  ' + sch.name + '.' + OBJECT_NAME(st.OBJECT_ID) + ' (' + st.name + ' )' + ' WITH FULLSCAN ,MAXDOP=2' as Script


FROM sys.stats AS st
                INNER JOIN sys.stats_columns sc
                               ON st.object_id = sc.object_id
                                               AND st.stats_id = sc.stats_id
                INNER JOIN sys.columns co
                               ON sc.column_id = co.column_id
                                               AND sc.object_id = co.object_id
                INNER JOIN sysobjects ob
                               ON sc.object_id = ob.id
                INNER JOIN sys.objects obj
						       ON obj.object_id = ob.id
			    INNER JOIN sys.schemas sch
						       ON sch.schema_id = obj.schema_id
                CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
WHERE ob.type = 'u'
and sch.name = 'PREMIO' -- Informar o schema da tabela
and OBJECT_NAME(st.OBJECT_ID) = 'BASE_CONSOLIDADA_ICATU' -- Informar o nome da tabela
AND rows <> rows_sampled -- Isso filtro somente apresenta as estatísticas que precisam ser atualizadas.
ORDER BY 1
