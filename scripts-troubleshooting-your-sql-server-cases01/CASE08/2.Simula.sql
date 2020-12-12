USE Faturamento
GO
/*
Simiulação de 500 pedidos para cada Filial
*/
exec sp_fatura_pedido @IdFilial = 1--Aqui deve dar errro
exec sp_fatura_pedido @IdFilial = 2
exec sp_fatura_pedido @IdFilial = 3
exec sp_fatura_pedido @IdFilial = 4
GO
