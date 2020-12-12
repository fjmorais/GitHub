USE Faturamento
GO
CREATE OR ALTER PROCEDURE dbo.sp_fatura_pedido
@idFilial INT,
@NumPedidos INT = 500
AS
BEGIN
	INSERT INTO dbo.Pedidos(IdFilial,IdCliente,DtPedido,Valor) 
	SELECT @idFilial, CAST(RAND()*500+500 AS INT), GETDATE(), CAST(RAND()*500+1000 AS DECIMAL(10,2)) 
	FROM dbo.GetNums(@NumPedidos) 
END
GO

