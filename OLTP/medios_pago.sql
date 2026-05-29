USE bd_riesgo_crediticio;
GO

/* ============================================================
   11. MEDIOS DE PAGO
   ============================================================ */

INSERT INTO medios_pago (nombre, descripcion)
VALUES
('Transferencia bancaria', 'Pago realizado mediante transferencia desde una cuenta bancaria'),
('Debito automatico', 'Cargo automatico programado desde la cuenta del cliente'),
('Pago en ventanilla', 'Pago realizado presencialmente en agencia bancaria'),
('Agente bancario', 'Pago realizado mediante agente autorizado'),
('Banca movil', 'Pago realizado desde aplicacion movil del banco'),
('Banca por internet', 'Pago realizado desde plataforma web del banco'),
('Yape', 'Pago realizado mediante billetera digital Yape'),
('Plin', 'Pago realizado mediante billetera digital Plin'),
('Tarjeta de debito', 'Pago realizado con tarjeta de debito'),
('Tarjeta de credito', 'Pago realizado con tarjeta de credito'),
('Deposito en cuenta', 'Deposito directo a una cuenta recaudadora'),
('Pago empresarial', 'Pago realizado desde cuenta empresarial');
GO

SELECT *
FROM medios_pago
ORDER BY id;
GO