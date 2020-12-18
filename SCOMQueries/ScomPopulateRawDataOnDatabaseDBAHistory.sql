

--select max(DateTime) from dba.dbo.tb_performance_raw_scom

-- Inicio do processo para coletar as tabelas que possuem dados de linha a linha

IF OBJECT_ID('tempdb..#Tabelas') IS NOT NULL DROP TABLE #Tabelas

-- criar tabela temporária com id incremental para ajudar na questão do loop

CREATE TABLE #Tabelas
(
id int identity primary key,
comando varchar(max)
)

DECLARE @DATAINI VARCHAR(30) = '2020-12-08 00:00:00.000'
DECLARE @DATAFIM VARCHAR(30) = '2020-12-08 23:59:59.000'
DECLARE @rows int
DECLARE @texto VARCHAR(500)

INSERT INTO #Tabelas (comando)

select
  '
  INSERT INTO dba.dbo.tb_performance_raw_scom
  select distinct A.DateTime,
				a.SampleValue,
				cast (c.ManagedEntityTypeSystemName as varchar(256)) as ManagedEntityTypeSystemName ,
				cast (c.ManagedEntityTypeDefaultName as varchar(256)) as ManagedEntityTypeDefaultName ,
				c.ManagedEntityTypeDefaultDescription,
				cast ( b.FullName as varchar(512)) as FullName ,
				cast ( B.Path as varchar(512)) as Path  ,
				cast ( B.DisplayName as varchar(512)) as DisplayName,
				B.DwCreatedDatetime
			from [OperationsManagerDW].Perf.' +
		name +
  ' a inner join [OperationsManagerDW].dbo.ManagedEntity b
												on a.ManagedEntityRowId = b.ManagedEntityRowId
											 inner join [OperationsManagerDW].dbo.ManagedEntityType c
												 on b.ManagedEntityTypeRowId = c.ManagedEntityTypeRowId


												 CROSS APPLY(

select [Path] as Path from OperationsManager.dbo.BaseManagedEntity crs
where FullName like ''%SQL%''
and crs.Path = b.Path

)

D


				where 1 = 1
				AND A.DateTime between ''' + @DataIni +
				' '' and ''' + @DataFim + ''''

  as comando
  from
  sys.objects
  where name like '%PerfRaw%'
  and type = 'U'
  order by create_date asc



-- Fazer a declaração do valor de loop para iniciar com o ID = 1

Use
OperationsManagerDW


declare @Loop int,@dscomando nvarchar(MAX)

set @Loop = 1

while exists (select top 1 null from #Tabelas)

BEGIN

	-- Primeiro Loop Obter o nome da primeira tabela por meio do ID = 1, que foi declarado inicialmente acima.
	-- Segundo Loop em diante, teremos o valor de @loop para o ultimo incremento do @@rowcount retornado no final do loop

		SELECT @dscomando = comando
     		from #Tabelas
     	where id = @Loop

		exec sp_executesql @dscomando

		set @rows = @@ROWCOUNT

		delete from #Tabelas where id = @Loop
        -- Aqui a fazemos o incremento para voltar ao Loop e fazer o seguinte comando

		SELECT @texto = 'Tabela de número ' + cast(@Loop as varchar(5)) + ' consulta realizada com sucesso! Total de linhas executadas: ' +  cast (@rows  as varchar(20))

		RAISERROR (@texto,0,1) WITH NOWAIT;

		set @loop = @loop + 1

END
