USE bd_riesgo_crediticio;
GO

/* ============================================================
   CASOS PARA PROBAR RELACION MUCHOS A MUCHOS
   detalle_cuotas_pagos

   Incluye:
   1. Un pago aplicado a varias cuotas.
   2. Una cuota cubierta por varios pagos.

   Sin variables, pensado para DBeaver.
   ============================================================ */

/* ============================================================
   CASO 1:
   Un solo pago paga dos cuotas del credito CRE-2026-0101

   Pago:
   OP-2026-MULTI-01

   Cuotas:
   CRE-2026-0101 cuota 3
   CRE-2026-0101 cuota 4
   ============================================================ */

INSERT INTO cronograma_cuotas
    (id_credito, num_cuota, fecha_vencimiento, capital, intereses, seguros,
     total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
SELECT
    cr.id,
    v.num_cuota,
    v.fecha_vencimiento,
    v.capital,
    v.intereses,
    v.seguros,
    v.total_cuota,
    v.saldo_pendiente,
    v.tasa_mora,
    v.dias_atraso,
    v.estado
FROM creditos cr
CROSS JOIN (VALUES
    (3, CONVERT(DATE, '2026-04-16'), 1058.00, 320.67, 18.00, 1396.67, 1396.67, 0.0000, 0, 'pendiente'),
    (4, CONVERT(DATE, '2026-05-16'), 1072.00, 306.67, 18.00, 1396.67, 1396.67, 0.0000, 0, 'pendiente')
) AS v (num_cuota, fecha_vencimiento, capital, intereses, seguros, total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
WHERE cr.nro_credito = 'CRE-2026-0101'
  AND NOT EXISTS (
      SELECT 1
      FROM cronograma_cuotas cc
      WHERE cc.id_credito = cr.id
        AND cc.num_cuota = v.num_cuota
  );
GO

INSERT INTO pagos
    (id_medio_pago, nro_operacion, fecha_pago, monto, moneda, observaciones, estado)
SELECT
    (SELECT TOP 1 id FROM medios_pago WHERE nombre IN ('Transferencia bancaria', 'Transferencia') ORDER BY id),
    'OP-2026-MULTI-01',
    '2026-05-29T10:30:00',
    2793.34,
    'PEN',
    'Un pago aplicado a dos cuotas del credito CRE-2026-0101',
    'procesado'
WHERE NOT EXISTS (
    SELECT 1
    FROM pagos
    WHERE nro_operacion = 'OP-2026-MULTI-01'
);
GO

INSERT INTO detalle_cuotas_pagos
    (id_cuota, id_pago, monto_pagado)
SELECT
    cc.id,
    p.id,
    cc.total_cuota
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
INNER JOIN pagos p
    ON p.nro_operacion = 'OP-2026-MULTI-01'
WHERE cr.nro_credito = 'CRE-2026-0101'
  AND cc.num_cuota IN (3, 4)
  AND NOT EXISTS (
      SELECT 1
      FROM detalle_cuotas_pagos dcp
      WHERE dcp.id_cuota = cc.id
        AND dcp.id_pago = p.id
  );
GO

UPDATE cc
SET
    estado = 'pagada',
    saldo_pendiente = 0.00,
    tasa_mora = 0.0000,
    dias_atraso = 0
FROM cronograma_cuotas cc