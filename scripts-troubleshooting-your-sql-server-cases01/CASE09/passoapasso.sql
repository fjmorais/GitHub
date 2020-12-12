-- Preparandoo ambiente
-- 1: Desatachar disco de TEMPLOG01 na AWS (No caso de um outro ambiente, retire o disco onde esta o arquivo de log da TEMPDB)
-- 2: Reiniciar a instancia

-- Troubleshooting
-- 1: Abrir o arquivo de ERRORLOG mais recente e identificar a falta do disco de TEMPDB LOG ou Olhar os eventos do Event Viewer do Windows

-- Resolvendo o case
-- 1: Abrir o SQL Server Configuration Manager
-- 2: Inserir no Startup Parameters a trace flag -T3608 e o parametro -m ou -f para inicializacao em minima\single user
-- 3: Abrir o CMD
-- 4: Digitar sqlcmd e logar na instancia
-- 5: Alterar o caminho do aquivo de log:

	C:\Users\Administrator> sqlcmd
	1> alter database tempdb modify file (NAME = templog, FILENAME = N'F:\TEMPDADOS01\tempdb_log.ldf')
	2> GO

-- 6: Retire os parametros de inicialização inseridos anteriormente
-- 7: Reiniciar a instancia