
-- Restaurar o banco de dados dt_alunos
RESTORE DATABASE dt_alunos FROM DISK = 'dt_alunos_FULL.bak'
WITH   
    REPLACE,
    STATS = 25