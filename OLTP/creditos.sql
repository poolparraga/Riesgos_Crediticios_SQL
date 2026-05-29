USE bd_riesgo_crediticio;
GO

/* ============================================================
   9. CREDITOS

   Requiere:
   - solicitudes cargadas
   - cuentas_bancarias cargadas

   Se crean creditos solo para solicitudes con estado = 'aprobada'.
   Se relaciona por nro_solicitud para no depender del id generado.
   No se insertan ids manuales porque la tabla usa IDENTITY.
   ============================================================ */

;WITH data_creditos AS (
    SELECT *
    FROM (VALUES
        ('SOL-2024-0001', 'CRE-2024-0001', 12000.00,  0.1850, 0.2050, 15.00, '2024-01-18', '2024-01-15', '2024-01-16T10:15:00', 'vigente'),
        ('SOL-2024-0002', 'CRE-2024-0002', 65000.00,  0.1390, 0.1540, 35.00, '2024-01-25', '2024-01-23', '2024-01-24T12:30:00', 'vigente'),
        ('SOL-2024-0003', 'CRE-2024-0003', 4500.00,   0.2990, 0.3290, 8.00,  '2024-01-28', '2024-01-26', '2024-01-26T16:45:00', 'vigente'),
        ('SOL-2024-0004', 'CRE-2024-0004', 310000.00, 0.0920, 0.1040, 80.00, '2024-02-15', '2024-02-12', '2024-02-13T09:00:00', 'vigente'),
        ('SOL-2024-0006', 'CRE-2024-0005', 18000.00,  0.1490, 0.1680, 18.00, '2024-02-20', '2024-02-17', '2024-02-19T11:20:00', 'vigente'),
        ('SOL-2024-0008', 'CRE-2024-0006', 22000.00,  0.1590, 0.1790, 12.00, '2024-03-08', '2024-03-05', '2024-03-06T13:05:00', 'vigente'),
        ('SOL-2024-0009', 'CRE-2024-0007', 15000.00,  0.2150, 0.2380, 16.00, '2024-03-11', '2024-03-08', '2024-03-09T10:40:00', 'vigente'),
        ('SOL-2024-0011', 'CRE-2024-0008', 54000.00,  0.1550, 0.1740, 30.00, '2024-03-22', '2024-03-20', '2024-03-21T15:10:00', 'vigente'),
        ('SOL-2024-0013', 'CRE-2024-0009', 3500.00,   0.3450, 0.3790, 6.00,  '2024-04-01', '2024-03-29', '2024-03-30T12:25:00', 'vigente'),
        ('SOL-2024-0014', 'CRE-2024-0010', 6000.00,   0.2850, 0.3150, 8.00,  '2024-04-06', '2024-04-04', '2024-04-05T17:45:00', 'vigente'),
        ('SOL-2024-0016', 'CRE-2024-0011', 40000.00,  0.1320, 0.1490, 22.00, '2024-04-21', '2024-04-18', '2024-04-19T10:30:00', 'vigente'),
        ('SOL-2024-0017', 'CRE-2024-0012', 2500.00,   0.3250, 0.3590, 5.00,  '2024-04-23', '2024-04-21', '2024-04-22T08:50:00', 'cancelado'),
        ('SOL-2024-0019', 'CRE-2024-0013', 18000.00,  0.1650, 0.1840, 12.00, '2024-05-08', '2024-05-06', '2024-05-07T14:20:00', 'vigente'),
        ('SOL-2024-0021', 'CRE-2024-0014', 50000.00,  0.1690, 0.1860, 25.00, '2024-01-28', '2024-01-25', '2024-01-26T11:15:00', 'vigente'),
        ('SOL-2024-0022', 'CRE-2024-0015', 175000.00, 0.1420, 0.1580, 55.00, '2024-02-06', '2024-02-03', '2024-02-05T09:35:00', 'vigente'),
        ('SOL-2024-0023', 'CRE-2024-0016', 90000.00,  0.1360, 0.1520, 40.00, '2024-02-15', '2024-02-12', '2024-02-14T13:40:00', 'vigente'),
        ('SOL-2024-0024', 'CRE-2024-0017', 35000.00,  0.1980, 0.2190, 18.00, '2024-02-19', '2024-02-16', '2024-02-17T10:05:00', 'vigente'),
        ('SOL-2024-0026', 'CRE-2024-0018', 75000.00,  0.1750, 0.1930, 30.00, '2024-03-10', '2024-03-07', '2024-03-08T16:15:00', 'vigente'),
        ('SOL-2024-0027', 'CRE-2024-0019', 22000.00,  0.2050, 0.2260, 12.00, '2024-03-13', '2024-03-11', '2024-03-12T09:10:00', 'cancelado'),
        ('SOL-2024-0028', 'CRE-2024-0020', 60000.00,  0.1090, 0.1240, 45.00, '2024-03-25', '2024-03-22', '2024-03-23T12:50:00', 'vigente'),
        ('SOL-2024-0031', 'CRE-2024-0021', 120000.00, 0.1580, 0.1760, 45.00, '2024-04-13', '2024-04-10', '2024-04-11T15:30:00', 'vigente'),
        ('SOL-2024-0032', 'CRE-2024-0022', 95000.00,  0.1820, 0.2010, 35.00, '2024-04-20', '2024-04-17', '2024-04-18T10:10:00', 'vigente'),
        ('SOL-2024-0034', 'CRE-2024-0023', 38000.00,  0.1920, 0.2110, 20.00, '2024-05-02', '2024-04-29', '2024-04-30T11:25:00', 'vigente'),
        ('SOL-2024-0037', 'CRE-2024-0024', 3000.00,   0.3150, 0.3490, 5.00,  '2024-05-13', '2024-05-11', '2024-05-12T09:00:00', 'vigente'),
        ('SOL-2024-0040', 'CRE-2024-0025', 12000.00,  0.1720, 0.1920, 10.00, '2024-05-21', '2024-05-19', '2024-05-20T10:45:00', 'vigente'),
        ('SOL-2024-0041', 'CRE-2024-0026', 48000.00,  0.1620, 0.1810, 28.00, '2024-05-25', '2024-05-23', '2024-05-24T14:15:00', 'vigente'),
        ('SOL-2024-0043', 'CRE-2024-0027', 35000.00,  0.1450, 0.1620, 18.00, '2024-05-28', '2024-05-26', '2024-05-27T12:35:00', 'vigente'),
        ('SOL-2024-0044', 'CRE-2024-0028', 62000.00,  0.1850, 0.2050, 32.00, '2024-06-01', '2024-05-29', '2024-05-30T15:05:00', 'vigente'),
        ('SOL-2024-0046', 'CRE-2024-0029', 28000.00,  0.1390, 0.1560, 16.00, '2024-06-03', '2024-05-31', '2024-06-01T09:20:00', 'vigente'),
        ('SOL-2024-0048', 'CRE-2024-0030', 17000.00,  0.2250, 0.2490, 15.00, '2024-06-09', '2024-06-06', '2024-06-07T16:10:00', 'vigente'),
        ('SOL-2024-0049', 'CRE-2024-0031', 26000.00,  0.1550, 0.1740, 12.00, '2024-06-13', '2024-06-10', '2024-06-11T13:50:00', 'vigente'),
        ('SOL-2024-0051', 'CRE-2024-0032', 60000.00,  0.1280, 0.1450, 24.00, '2024-06-17', '2024-06-14', '2024-06-15T10:30:00', 'vigente'),
        ('SOL-2024-0052', 'CRE-2024-0033', 1800.00,   0.3650, 0.3990, 4.00,  '2024-06-14', '2024-06-12', '2024-06-13T09:05:00', 'cancelado'),
        ('SOL-2024-0054', 'CRE-2024-0034', 14000.00,  0.1980, 0.2190, 14.00, '2024-06-21', '2024-06-18', '2024-06-19T11:40:00', 'vigente'),
        ('SOL-2024-0056', 'CRE-2024-0035', 45000.00,  0.1890, 0.2080, 20.00, '2024-06-27', '2024-06-24', '2024-06-25T15:35:00', 'vigente'),
        ('SOL-2024-0058', 'CRE-2024-0036', 65000.00,  0.1760, 0.1940, 28.00, '2024-07-01', '2024-06-28', '2024-06-29T10:05:00', 'vigente'),
        ('SOL-2024-0059', 'CRE-2024-0037', 50000.00,  0.2050, 0.2260, 22.00, '2024-07-02', '2024-06-29', '2024-06-30T12:45:00', 'vigente'),
        ('SOL-2024-0061', 'CRE-2024-0038', 110000.00, 0.1640, 0.1830, 45.00, '2024-07-07', '2024-07-04', '2024-07-05T09:25:00', 'vigente'),
        ('SOL-2024-0063', 'CRE-2024-0039', 210000.00, 0.1510, 0.1690, 60.00, '2024-07-12', '2024-07-09', '2024-07-10T13:15:00', 'vigente'),
        ('SOL-2024-0064', 'CRE-2024-0040', 55000.00,  0.1780, 0.1970, 26.00, '2024-07-13', '2024-07-10', '2024-07-11T16:30:00', 'vigente')
    ) AS c (
        nro_solicitud,
        nro_credito,
        monto_aprobado,
        tea,
        tcea,
        desgravamen,
        fecha_inicio,
        fecha_aprobacion,
        fecha_desembolso,
        estado
    )
)
INSERT INTO creditos
    (id_solicitud, id_cuenta_desembolso, nro_credito, monto_aprobado, moneda,
     plazo_meses, tea, tcea, valor_cuota, desgravamen, fecha_inicio,
     fecha_vencimiento, fecha_aprobacion, fecha_desembolso, nro_cuotas, estado)
SELECT
    s.id AS id_solicitud,
    cuenta.id AS id_cuenta_desembolso,
    dc.nro_credito,
    dc.monto_aprobado,
    s.moneda_solicitada AS moneda,
    s.plazo_solicitado_meses AS plazo_meses,
    dc.tea,
    dc.tcea,
    CAST((dc.monto_aprobado * (1 + dc.tcea) / s.plazo_solicitado_meses) + dc.desgravamen AS DECIMAL(12,2)) AS valor_cuota,
    dc.desgravamen,
    dc.fecha_inicio,
    DATEADD(MONTH, s.plazo_solicitado_meses, CONVERT(DATE, dc.fecha_inicio)) AS fecha_vencimiento,
    dc.fecha_aprobacion,
    dc.fecha_desembolso,
    s.plazo_solicitado_meses AS nro_cuotas,
    dc.estado
FROM data_creditos dc
INNER JOIN solicitudes s
    ON s.nro_solicitud = dc.nro_solicitud
OUTER APPLY (
    SELECT TOP 1 cb.id
    FROM cuentas_bancarias cb
    WHERE cb.id_cliente = s.id_cliente
      AND cb.estado = 'activa'
    ORDER BY
        CASE WHEN cb.moneda = s.moneda_solicitada THEN 0 ELSE 1 END,
        cb.saldo_actual DESC,
        cb.id
) cuenta
WHERE s.estado = 'aprobada'
  AND NOT EXISTS (
      SELECT 1
      FROM creditos cr
      WHERE cr.nro_credito = dc.nro_credito
         OR cr.id_solicitud = s.id
  );
GO

SELECT
    estado,
    moneda,
    COUNT(*) AS cantidad,
    SUM(monto_aprobado) AS total_monto_aprobado
FROM creditos
GROUP BY estado, moneda
ORDER BY estado, moneda;

SELECT COUNT(*) AS total_creditos
FROM creditos;
GO