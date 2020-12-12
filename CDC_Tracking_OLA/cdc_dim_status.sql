use
dba
go

create table dim_status
(pk_id int identity primary key ,
sk_id int,
[status] varchar(120))

INSERT INTO dim_status VALUES (1,'Delete')
INSERT INTO dim_status VALUES (2,'Insert')
INSERT INTO dim_status VALUES (3,'Updated row before the change')
INSERT INTO dim_status VALUES (4,'Updated row after the change')
