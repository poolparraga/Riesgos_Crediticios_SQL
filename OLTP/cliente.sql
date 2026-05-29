USE bd_riesgo_crediticio;
GO

/* ============================================================
   1. CLIENTES
   Version para DBeaver sin ids explicitos.

   Si la tabla clientes esta vacia, SQL Server generara ids 1 al 35.
   ============================================================ */

INSERT INTO clientes (tipo_cliente, estado_cliente, created_at) VALUES
('N', 'activo', '2023-01-10T09:15:00'),
('N', 'activo', '2023-01-18T10:20:00'),
('N', 'activo', '2023-02-03T08:45:00'),
('N', 'activo', '2023-02-21T12:30:00'),
('N', 'activo', '2023-03-08T15:10:00'),
('N', 'activo', '2023-03-25T11:05:00'),
('N', 'activo', '2023-04-14T16:40:00'),
('N', 'activo', '2023-05-02T09:55:00'),
('N', 'activo', '2023-05-19T13:25:00'),
('N', 'activo', '2023-06-07T10:35:00'),
('N', 'activo', '2023-06-28T17:00:00'),
('N', 'activo', '2023-07-13T08:20:00'),
('N', 'activo', '2023-08-01T14:15:00'),
('N', 'activo', '2023-08-22T09:40:00'),
('N', 'activo', '2023-09-11T11:50:00'),
('N', 'inactivo', '2023-10-04T16:05:00'),
('N', 'activo', '2023-10-26T10:10:00'),
('N', 'bloqueado', '2023-11-15T12:00:00'),
('N', 'activo', '2023-12-06T15:35:00'),
('N', 'baja', '2023-12-21T09:25:00'),
('J', 'activo', '2023-01-16T10:00:00'),
('J', 'activo', '2023-02-09T11:30:00'),
('J', 'activo', '2023-03-03T14:20:00'),
('J', 'activo', '2023-03-27T09:10:00'),
('J', 'activo', '2023-04-18T16:45:00'),
('J', 'activo', '2023-05-12T08:50:00'),
('J', 'activo', '2023-06-05T13:15:00'),
('J', 'activo', '2023-07-20T10:25:00'),
('J', 'activo', '2023-08-16T12:40:00'),
('J', 'inactivo', '2023-09-06T15:55:00'),
('J', 'activo', '2023-10-02T09:35:00'),
('J', 'activo', '2023-10-24T11:45:00'),
('J', 'bloqueado', '2023-11-13T14:05:00'),
('J', 'activo', '2023-12-04T10:15:00'),
('J', 'baja', '2023-12-19T16:30:00');
GO

SELECT id, tipo_cliente, estado_cliente, created_at
FROM clientes
ORDER BY id;
GO