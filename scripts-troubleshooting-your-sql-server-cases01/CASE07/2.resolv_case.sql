USE dt_alunos
GO

-- Ao executar a query do relatório de notas para montar o histórico escolar dos alunos
-- a surpresa:

SELECT 
	idAluno,
	dataProva,
	notaProva
FROM nota_aluno
WHERE
	dataProva >= '1990-01-01 00:00:00';
GO

-- Verificando erros que reportam a corrupção
DBCC CHECKDB (dt_alunos) WITH NO_INFOMSGS;
GO

-- Conectando na base para tentar repurar o maximo de dados possíveis
USE dt_alunos
GO

-- Pegar ultimo ID retornado
SELECT * FROM nota_aluno
GO

-- Pegar primeiro ID retornado
SELECT * FROM nota_aluno
ORDER BY id DESC
GO

-- Declarando variaveis e passando os IDs retirados das querys acima
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX

-- Verificando os indices e se os mesmos possuem colunas incluidas
EXEC sp_helpindex2
GO

-- Podemos utilizar o HINT INDEX(XX) para percorrer pelos dados de um indice 
-- existente dentro da tabela, neste caso, estamos percorrendo pelo indice de ID 2
-- De dentro dele podemos retirar os dados da coluna idAluno
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX
SELECT
	id, idAluno
FROM nota_aluno	WITH (INDEX(2))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

-- Podemos utilizar o HINT INDEX(XX) para percorrer pelos dados de um indice 
-- existente dentro da tabela, neste caso, estamos percorrendo pelo indice de ID 3
-- De dentro dele podemos retirar os dados da coluna idCurso
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX
SELECT
	id, idCurso
FROM nota_aluno	WITH (INDEX(3))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

-- Podemos utilizar o HINT INDEX(XX) para percorrer pelos dados de um indice 
-- existente dentro da tabela, neste caso, estamos percorrendo pelo indice de ID 4
-- De dentro dele podemos retirar os dados das colunas idMateria, dataProva, notaProva
-- Vide que foi possível até retonar os dados das colunas incluidas no indice, desta
-- forma confirmamos que, ao incluir as colunas em um indice não precisamos mais ir no
-- indice clusterizado\head para pegar os dados.
DECLARE @id_inic INT = XXX
		, @id_fim INT = XXX
SELECT
	id, idMateria, dataProva, notaProva
FROM nota_aluno	WITH (INDEX(4))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

-- Crie uma tabela temporaria para armazenar os dados da pagina corrompida e que
-- achamos em nossos indices
CREATE TABLE nota_aluno_temp (
	id INT
	,idAluno INT 
	,idCurso INT 
	,idMateria INT 
	,dataProva DATETIME
	,notaProva DECIMAL(4,2)
);

-- Inserindo os dados do indice 2 na tabela temporaria
INSERT INTO nota_aluno_temp(id, idAluno, idCurso, idMateria, dataProva, notaProva)
SELECT 
	id,	idAluno, NULL, NULL, NULL, NULL
FROM nota_aluno	WITH (INDEX(2))
WHERE id > @id_inic and id < @id_fim
ORDER BY id
GO

SELECT * FROM nota_aluno_temp;
GO

-- Completando a tabela com os demais dados
UPDATE nota_aluno_temp
SET
	idCurso = nota_aluno_idx3.idCurso,
	idMateria = nota_aluno_idx4.idMateria, 
	dataProva = nota_aluno_idx4.dataProva, 
	notaProva = nota_aluno_idx4.notaProva
FROM nota_aluno_temp
INNER JOIN (
		SELECT
			  id
			, idCurso
		FROM nota_aluno	WITH (INDEX(3))
		WHERE id > @id_inic and id < @id_fim
	) AS nota_aluno_idx3 ON nota_aluno_temp.id = nota_aluno_idx3.id
INNER JOIN (
		SELECT
			  id
			, idMateria
			, dataProva
			, notaProva
		FROM nota_aluno	WITH (INDEX(4))
		WHERE id > @id_inic and id < @id_fim
	) AS nota_aluno_idx4 ON nota_aluno_temp.id = nota_aluno_idx4.id
GO

-- Agora vamos reparar a tabela, retirando a pagina corrompida da tabela
ALTER DATABASE dt_alunos SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DBCC CHECKDB('dt_alunos', REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS
GO
ALTER DATABASE dt_alunos SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE
GO

-- Verificando a consistencia da tabela e verificando se não há mais problemas de corrupção
DBCC CHECKDB('dt_alunos') WITH NO_INFOMSGS
GO

-- Verifique a quantidade de dados, verifique que perdemos parte dos registros da tabela.
SELECT * FROM nota_aluno
GO

-- Reinserindo os dados recuperados na tabela original
SET IDENTITY_INSERT nota_aluno ON;
GO
INSERT INTO nota_aluno(id, idAluno,idCurso, idMateria, dataProva, notaProva)
SELECT 
	id
	, idAluno
	, idCurso
	, idMateria
	, dataProva
	, notaProva 
FROM nota_aluno_temp
GO

-- Dados totalmente recuperados
SELECT * FROM nota_aluno
GO
