
use
DBA
GO

CREATE TABLE dim_table
(
pk_id int identity primary key,
sk_id int,
TableName varchar(120)
)

insert into dim_table values (1,'tb_coberturacertificadoClb')
insert into dim_table values (2,'tb_enderecosClb')
insert into dim_table values (3,'tb_enderecosInd')
insert into dim_table values (4,'tb_tb_parcelasClb')
insert into dim_table values (5,'tb_tb_parcelasInd')
