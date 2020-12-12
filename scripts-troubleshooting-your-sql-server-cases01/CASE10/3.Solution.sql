
--======== Conectar via DAC
-- > sqlcmd -S localhost -A -d master -E

-- Verifica usuário que está conectado
select original_login()

-- Identifica as triggers habilitadas
select name, is_disabled from sys.server_triggers;

-- Desabilita trigger
disable TRIGGER [trServerLogin] ON ALL SERVER  

 
