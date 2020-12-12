--|Pessoal,

--Atenção ao usar o template do SQL 2017 que criamos. Ver o collation, trocar o usuário de serviço para admsql
--e adicionar nossos usuários e os padrões como admbkp, admbd, como SYSADMIN.

--Caso seja necessário trocar o collation, segue os comandos:

--Pare TODOS os serviços do SQL Server!

--Abrir a pasta abaixo, no cmd como administrador :
B:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Binn\

--Executar o comando com o collation correto via CMD como Administrador:
sqlservr -m -T4022 -T3659 -q"SQL_Latin1_General_CP1_CI_AI"
