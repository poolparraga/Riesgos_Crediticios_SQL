USE bd_riesgo_crediticio;
GO

/* ============================================================
   12. PAGOS

   Requiere:
   - medios_pago cargados
   - cronograma_cuotas cargado
   - creditos cargados

   Genera pagos para cuotas:
   - pagada
   - pagada parcialmente

   No inserta ids manuales porque la tabla usa IDENTITY.
   El nro_operacion se genera con el id de la cuota para poder
   relacionarlo luego en detalle_cuotas_pagos.
   ============================================================ */

;WITH pagos_base AS (
    SELECT
        cc.id AS id_cuota,
        cr.id AS id_credito,
        cr.nro_credito,
        cc.num_cuota,
        cc.fecha_vencimiento,
        cc.total_cuota,
        cc.saldo_pendiente,
        cc.estado AS estado_cuota,
        cr.moneda,
        CASE
            WHEN cc.estado = 'pagada' THEN cc.total_cuota
            WHEN cc.estado = 'pagada parcialmente' THEN cc.total_cuota - cc.saldo_pendiente
        END AS monto_pago,
        CASE
            WHEN cc.estado = 'pagada' THEN DATEADD(HOUR, 10 + (cc.id % 8), CAST(DATEADD(DAY, -1 * (cc.id % 3), cc.fecha_vencimiento) AS DATETIME))
            WHEN cc.estado = 'pagada parcialmente' THEN DATEADD(HOUR, 9 + (cc.id % 7), CAST(DATEADD(DAY, 2 + (cc.id % 5), cc.fecha_vencimiento) AS DATETIME))
        END AS fecha_pago,
        'OP-' + RIGHT('000000000000' + CAST(cc.id AS VARCHAR(12)), 12) AS nro_operacion,
        CASE
            WHEN cc.estado = 'pagada' THEN 'Pago completo de cuota ' + CAST(cc.num_cuota AS VARCHAR(10)) + ' del credito ' + cr.nro_credito
            WHEN cc.estado = 'pagada parcialmente' THEN 'Pago parcial de cuota ' + CAST(cc.num_cuota AS VARCHAR(10)) + ' del credito ' + cr.nro_credito
        END AS observaciones
    FROM cronograma_cuotas cc
    INNER JOIN creditos cr
        ON cr.id = cc.id_credito
    WHERE cc.estado IN ('pagada', 'pagada parcialmente')
),
pagos_con_medio AS (
    SELECT
        pb.*,
        mp.id AS id_medio_pago
    FROM pagos_base pb
    INNER JOIN medios_pago mp
        ON mp.nombre = CASE
            WHEN pb.id_cuota % 6 = 0 THEN 'Transferencia bancaria'
            WHEN pb.id_cuota % 6 = 1 THEN 'Debito automatico'
            WHEN pb.id_cuota % 6 = 2 THEN 'Pago en ventanilla'
            WHEN pb.id_cuota % 6 = 3 THEN 'Banca movil'
            WHEN pb.id_cuota % 6 = 4 THEN 'Banca por internet'
            ELSE 'Agente bancario'
        END
)
INSERT INTO pagos
    (id_medio_pago, nro_operacion, fecha_pago, monto, moneda, observaciones, estado)
SELECT
    id_medio_pago,
    nro_operacion,
    fecha_pago,
    CAST(monto_pago AS DECIMAL(12,2)) AS monto,
    moneda,
    observaciones,
    'procesado' AS estado
FROM pagos_con_medio pcm
WHERE monto_pago > 0
  AND NOT EXISTS (
      SELECT 1
      FROM pagos p
      WHERE p.nro_operacion = pcm.nro_operacion
  );
GO

SELECT
    mp.nombre AS medio_pago,
    p.estado,
    COUNT(*) AS cantidad,
    SUM(p.monto) AS total_pagado
FROM pagos p
INNER JOIN medios_pago mp
    ON mp.id = p.id_medio_pago
GROUP BY mp.nombre, p.estado
ORDER BY mp.nombre, p.estado;

SELECT COUNT(*) AS total_pagos
FROM pagos;
GO