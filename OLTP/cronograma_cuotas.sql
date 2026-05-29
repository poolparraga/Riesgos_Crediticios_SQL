USE bd_riesgo_crediticio;
GO

/* ============================================================
   10. CRONOGRAMA DE CUOTAS
   Version para DBeaver sin variables.

   Fecha de referencia usada para estados de prueba: 2026-05-29.
   ============================================================ */

;WITH numeros AS (
    SELECT 1 AS num_cuota
    UNION ALL
    SELECT num_cuota + 1
    FROM numeros
    WHERE num_cuota < 300
),
base AS (
    SELECT
        cr.id AS id_credito,
        cr.nro_credito,
        cr.monto_aprobado,
        cr.nro_cuotas,
        cr.fecha_inicio,
        cr.tea,
        cr.desgravamen,
        n.num_cuota,
        DATEADD(MONTH, n.num_cuota, cr.fecha_inicio) AS fecha_vencimiento,
        CAST(ROUND(cr.monto_aprobado / cr.nro_cuotas, 2) AS DECIMAL(12,2)) AS capital_base,
        CAST(ROUND(
            (cr.monto_aprobado - ((n.num_cuota - 1) * (cr.monto_aprobado / cr.nro_cuotas)))
            * (cr.tea / 12), 2
        ) AS DECIMAL(12,2)) AS intereses_base,
        CAST(cr.desgravamen AS DECIMAL(12,2)) AS seguros_base
    FROM creditos cr
    INNER JOIN numeros n
        ON n.num_cuota <= cr.nro_cuotas
    WHERE NOT EXISTS (
        SELECT 1
        FROM cronograma_cuotas cc
        WHERE cc.id_credito = cr.id
    )
),
montos AS (
    SELECT
        id_credito,
        nro_credito,
        num_cuota,
        fecha_vencimiento,
        CASE
            WHEN num_cuota = nro_cuotas THEN
                CAST(ROUND(monto_aprobado - (capital_base * (nro_cuotas - 1)), 2) AS DECIMAL(12,2))
            ELSE capital_base
        END AS capital,
        CASE
            WHEN intereses_base < 0 THEN 0.00
            ELSE intereses_base
        END AS intereses,
        seguros_base AS seguros
    FROM base
),
estados AS (
    SELECT
        id_credito,
        nro_credito,
        num_cuota,
        fecha_vencimiento,
        capital,
        intereses,
        seguros,
        CAST(capital + intereses + seguros AS DECIMAL(12,2)) AS total_cuota,
        CASE
            WHEN fecha_vencimiento < CONVERT(DATE, '2026-05-29') AND num_cuota % 11 = 0 THEN 'vencida'
            WHEN fecha_vencimiento < CONVERT(DATE, '2026-05-29') AND num_cuota % 7 = 0 THEN 'pagada parcialmente'
            WHEN fecha_vencimiento < CONVERT(DATE, '2026-05-29') THEN 'pagada'
            ELSE 'pendiente'
        END AS estado
    FROM montos
)
INSERT INTO cronograma_cuotas
    (id_credito, num_cuota, fecha_vencimiento, capital, intereses, seguros,
     total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
SELECT
    id_credito,
    num_cuota,
    fecha_vencimiento,
    capital,
    intereses,
    seguros,
    total_cuota,
    CASE
        WHEN estado = 'pagada' THEN 0.00
        WHEN estado = 'pagada parcialmente' THEN CAST(ROUND(total_cuota * 0.40, 2) AS DECIMAL(12,2))
        WHEN estado = 'vencida' THEN total_cuota
        ELSE total_cuota
    END AS saldo_pendiente,
    CASE
        WHEN estado IN ('vencida', 'pagada parcialmente') THEN 0.0250
        ELSE 0.0000
    END AS tasa_mora,
    CASE
        WHEN estado IN ('vencida', 'pagada parcialmente') AND fecha_vencimiento < CONVERT(DATE, '2026-05-29')
            THEN DATEDIFF(DAY, fecha_vencimiento, CONVERT(DATE, '2026-05-29'))
        ELSE 0
    END AS dias_atraso,
    estado
FROM estados
OPTION (MAXRECURSION 300);
GO

SELECT
    estado,
    COUNT(*) AS cantidad,
    SUM(total_cuota) AS total_programado,
    SUM(saldo_pendiente) AS saldo_pendiente
FROM cronograma_cuotas
GROUP BY estado
ORDER BY estado;

SELECT
    cr.nro_credito,
    COUNT(cc.id) AS cuotas_generadas,
    cr.nro_cuotas AS cuotas_esperadas
FROM creditos cr
LEFT JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
GROUP BY cr.nro_credito, cr.nro_cuotas
ORDER BY cr.nro_credito;
GO