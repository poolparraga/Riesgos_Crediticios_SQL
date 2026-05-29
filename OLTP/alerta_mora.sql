USE bd_riesgo_crediticio;
GO

/* ============================================================
   14. ALERTAS MORA

   Requiere:
   - creditos cargados
   - cronograma_cuotas cargado

   Genera alertas para:
   - cuotas vencidas
   - cuotas pagadas parcialmente con atraso
   - creditos con multiples cuotas atrasadas
   - creditos de alto riesgo

   No inserta ids manuales porque la tabla usa IDENTITY.
   ============================================================ */

/* Alertas por cuotas vencidas o con pago parcial atrasado */
INSERT INTO alertas_mora
    (id_credito, id_cuota, tipo_alerta, fecha_alerta, dias_atraso,
     descripcion, nivel_severidad, estado, fecha_cierre)
SELECT
    cr.id AS id_credito,
    cc.id AS id_cuota,
    CASE
        WHEN cc.dias_atraso >= 90 THEN 'mora_90d'
        WHEN cc.dias_atraso >= 60 THEN 'mora_60d'
        WHEN cc.dias_atraso >= 30 THEN 'mora_30d'
        ELSE 'cuota_vencida'
    END AS tipo_alerta,
    DATEADD(DAY, 1, cc.fecha_vencimiento) AS fecha_alerta,
    cc.dias_atraso,
    'Alerta generada por cuota ' + CAST(cc.num_cuota AS VARCHAR(10)) +
        ' del credito ' + cr.nro_credito +
        ' con ' + CAST(cc.dias_atraso AS VARCHAR(10)) + ' dias de atraso.' AS descripcion,
    CASE
        WHEN cc.dias_atraso >= 90 THEN 'critica'
        WHEN cc.dias_atraso >= 60 THEN 'alta'
        WHEN cc.dias_atraso >= 30 THEN 'media'
        ELSE 'baja'
    END AS nivel_severidad,
    CASE
        WHEN cc.estado = 'pagada parcialmente' THEN 'gestionada'
        ELSE 'activa'
    END AS estado,
    CASE
        WHEN cc.estado = 'pagada parcialmente' THEN DATEADD(DAY, 5, cc.fecha_vencimiento)
        ELSE NULL
    END AS fecha_cierre
FROM cronograma_cuotas cc
INNER JOIN creditos cr
    ON cr.id = cc.id_credito
WHERE cc.estado IN ('vencida', 'pagada parcialmente')
  AND cc.dias_atraso > 0
  AND NOT EXISTS (
      SELECT 1
      FROM alertas_mora am
      WHERE am.id_cuota = cc.id
        AND am.tipo_alerta IN ('cuota_vencida', 'mora_30d', 'mora_60d', 'mora_90d')
  );
GO

/* Alertas por multiples cuotas vencidas en un mismo credito */
;WITH creditos_con_multiples_cuotas AS (
    SELECT
        cr.id AS id_credito,
        cr.nro_credito,
        COUNT(*) AS cuotas_atrasadas,
        MAX(cc.dias_atraso) AS max_dias_atraso,
        MIN(cc.fecha_vencimiento) AS primera_cuota_atrasada
    FROM creditos cr
    INNER JOIN cronograma_cuotas cc
        ON cc.id_credito = cr.id
    WHERE cc.estado IN ('vencida', 'pagada parcialmente')
      AND cc.dias_atraso > 0
    GROUP BY cr.id, cr.nro_credito
    HAVING COUNT(*) >= 2
)
INSERT INTO alertas_mora
    (id_credito, id_cuota, tipo_alerta, fecha_alerta, dias_atraso,
     descripcion, nivel_severidad, estado, fecha_cierre)
SELECT
    cmc.id_credito,
    NULL AS id_cuota,
    'multiples_cuotas' AS tipo_alerta,
    DATEADD(DAY, 1, cmc.primera_cuota_atrasada) AS fecha_alerta,
    cmc.max_dias_atraso AS dias_atraso,
    'Credito ' + cmc.nro_credito + ' registra ' +
        CAST(cmc.cuotas_atrasadas AS VARCHAR(10)) +
        ' cuotas atrasadas o con pago parcial.' AS descripcion,
    CASE
        WHEN cmc.max_dias_atraso >= 90 THEN 'critica'
        WHEN cmc.max_dias_atraso >= 60 THEN 'alta'
        WHEN cmc.max_dias_atraso >= 30 THEN 'media'
        ELSE 'baja'
    END AS nivel_severidad,
    'activa' AS estado,
    NULL AS fecha_cierre
FROM creditos_con_multiples_cuotas cmc
WHERE NOT EXISTS (
    SELECT 1
    FROM alertas_mora am
    WHERE am.id_credito = cmc.id_credito
      AND am.tipo_alerta = 'multiples_cuotas'
);
GO

/* Alertas de alto riesgo por evaluacion asociada al credito */
INSERT INTO alertas_mora
    (id_credito, id_cuota, tipo_alerta, fecha_alerta, dias_atraso,
     descripcion, nivel_severidad, estado, fecha_cierre)
SELECT
    cr.id AS id_credito,
    NULL AS id_cuota,
    'alto_riesgo' AS tipo_alerta,
    DATEADD(DAY, 1, er.fecha_evaluacion) AS fecha_alerta,
    0 AS dias_atraso,
    'Credito ' + cr.nro_credito +
        ' asociado a evaluacion de riesgo alto o score bajo.' AS descripcion,
    CASE
        WHEN er.score_crediticio < 450 THEN 'alta'
        ELSE 'media'
    END AS nivel_severidad,
    'gestionada' AS estado,
    NULL AS fecha_cierre
FROM creditos cr
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN evaluaciones_riesgo er
    ON er.id_solicitud = s.id
WHERE (er.nivel_riesgo = 'alto' OR er.score_crediticio < 600)
  AND NOT EXISTS (
      SELECT 1
      FROM alertas_mora am
      WHERE am.id_credito = cr.id
        AND am.tipo_alerta = 'alto_riesgo'
  );
GO

SELECT
    tipo_alerta,
    nivel_severidad,
    estado,
    COUNT(*) AS cantidad
FROM alertas_mora
GROUP BY tipo_alerta, nivel_severidad, estado
ORDER BY tipo_alerta, nivel_severidad, estado;

SELECT COUNT(*) AS total_alertas
FROM alertas_mora;
GO