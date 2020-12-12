CREATE VIEW PerfRaw

  as

  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].[PerfRaw_008363E188A64AE4A1BC8110F17E469E]
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].[PerfRaw_1C2A9B040BF242428CF6032F31FB72ED]
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_278E787572E04FD7AD729E9428A90786
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_5BA53EE5CB72435380BCFC22CF9ECA2F
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_6977D507DA294C4784B6CB2D7FEE9771
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_7971853676C14CB7B258436FEC64BA81
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_7F0BEBCC81C64101BF49A0A2B9AC9138
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_7F93D51752134D258D2365ECACA0A989
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_9E59405C03564B3490BA9C59B8FB69F5
  UNION ALL
  SELECT
  [DateTime]
      ,[PerformanceRuleInstanceRowId]
      ,[ManagedEntityRowId]
      ,[SampleValue]
  FROM
  [OperationsManagerDW].[Perf].PerfRaw_BEB90A3AF3574C8A9931ECC37518FDA8
