USE bd_riesgo_crediticio;
GO
--Obtener el total de deuda aprobada por tipo de producto crediticio, considerando solo créditos vigentes.--
SELECT
    pc.tipo AS tipo_producto,
    COUNT(cr.id) AS cantidad_creditos,
    SUM(cr.monto_aprobado) AS total_monto_aprobado
FROM creditos cr
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN productos_crediticios pc
    ON pc.id = s.id_producto
WHERE cr.estado = 'vigente'
GROUP BY pc.tipo
ORDER BY total_monto_aprobado DESC;

--Calcular el saldo pendiente total por crédito según el cronograma de cuotas.--
SELECT
    cr.nro_credito,
    cr.monto_aprobado,
    cr.estado,
    SUM(cc.saldo_pendiente) AS saldo_pendiente_total
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
GROUP BY
    cr.nro_credito,
    cr.monto_aprobado,
    cr.estado
ORDER BY saldo_pendiente_total DESC;

--Identificar los clientes que han presentado eventos de mora registrados en alertas_mora, mostrando el crédito asociado, cuota vinculada si existe,--
--tipo de alerta, días de atraso, severidad, estado de la alerta y estado actual de la cuota. Ordenar por mayor atraso y severidad.--
SELECT
    c.id AS id_cliente,
    c.tipo_cliente,
    cr.nro_credito,
    cc.num_cuota,
    cc.estado AS estado_actual_cuota,
    am.tipo_alerta,
    am.dias_atraso,
    am.nivel_severidad,
    am.estado AS estado_alerta,
    am.fecha_alerta,
    am.fecha_cierre
FROM alertas_mora am
INNER JOIN creditos cr
    ON cr.id = am.id_credito
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
LEFT JOIN cronograma_cuotas cc
    ON cc.id = am.id_cuota
ORDER BY
    am.dias_atraso DESC,
    CASE am.nivel_severidad
        WHEN 'critica' THEN 1
        WHEN 'alta' THEN 2
        WHEN 'media' THEN 3
        WHEN 'baja' THEN 4
    END,
    am.fecha_alerta DESC;

--Mostrar el porcentaje de cuotas pagadas, pendientes, vencidas y pagadas parcialmente por cada crédito.--
SELECT
    cr.nro_credito,
    cc.estado,
    COUNT(*) AS cantidad_cuotas,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY cr.id)
        AS DECIMAL(10,2)
    ) AS porcentaje
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
GROUP BY
    cr.id,
    cr.nro_credito,
    cc.estado
ORDER BY cr.nro_credito, cc.estado;

--Identificar solicitudes aprobadas que, pese a haber sido aceptadas, presentan señales de riesgo en su evaluación: nivel de riesgo medio o alto,-- 
--historial crediticio distinto de normal, score menor a 700 o nivel de endeudamiento mayor a 35%.--
SELECT
    s.nro_solicitud,
    c.id AS id_cliente,
    c.tipo_cliente,
    pc.nombre AS producto,
    s.monto_solicitado,
    s.plazo_solicitado_meses,
    er.historial_crediticio,
    er.score_crediticio,
    er.nivel_riesgo,
    er.nivel_endeudamiento,
    er.observaciones
FROM solicitudes s
INNER JOIN evaluaciones_riesgo er
    ON er.id_solicitud = s.id
INNER JOIN clientes c
    ON c.id = s.id_cliente
INNER JOIN productos_crediticios pc
    ON pc.id = s.id_producto
WHERE s.estado = 'aprobada'
  AND (
      er.nivel_riesgo IN ('medio', 'alto')
      OR er.historial_crediticio <> 'normal'
      OR er.score_crediticio < 700
      OR er.nivel_endeudamiento > 35
  )
ORDER BY
    er.nivel_riesgo DESC,
    er.score_crediticio ASC,
    er.nivel_endeudamiento DESC;

--Calcular el ratio de endeudamiento promedio por tipo de cliente: natural y jurídico.--
SELECT
    c.tipo_cliente,
    AVG(er.nivel_endeudamiento) AS promedio_endeudamiento
FROM evaluaciones_riesgo er
INNER JOIN solicitudes s
    ON s.id = er.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
GROUP BY c.tipo_cliente;

--Detectar créditos que tienen más de una cuota vencida o parcialmente pagada.--
SELECT
    cr.nro_credito,
    c.id AS id_cliente,
    c.tipo_cliente,
    COUNT(cc.id) AS cuotas_con_problema,
    SUM(cc.saldo_pendiente) AS saldo_pendiente_total,
    MAX(cc.dias_atraso) AS max_dias_atraso
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
WHERE cc.estado IN ('vencida', 'pagada parcialmente')
GROUP BY
    cr.nro_credito,
    c.id,
    c.tipo_cliente
HAVING COUNT(cc.id) > 1
ORDER BY cuotas_con_problema DESC, max_dias_atraso DESC;

--Detectar créditos que tienen más de una alerta de mora registrada, calculando cantidad total de alertas, cantidad de alertas activas,--
--máximo de días de atraso, última fecha de alerta y saldo pendiente actual según su cronograma de cuotas.--
SELECT
    cr.nro_credito,
    c.id AS id_cliente,
    c.tipo_cliente,
    COUNT(am.id) AS cantidad_alertas,
    SUM(CASE WHEN am.estado = 'activa' THEN 1 ELSE 0 END) AS alertas_activas,
    MAX(am.dias_atraso) AS max_dias_atraso,
    MAX(am.fecha_alerta) AS ultima_fecha_alerta,
    SUM(cc.saldo_pendiente) AS saldo_pendiente_actual
FROM alertas_mora am
INNER JOIN creditos cr
    ON cr.id = am.id_credito
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
LEFT JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
GROUP BY
    cr.nro_credito,
    c.id,
    c.tipo_cliente
HAVING COUNT(am.id) > 1
ORDER BY
    cantidad_alertas DESC,
    max_dias_atraso DESC;


--Reporte resumen de riesgo por cliente--
--Construir una consulta que muestre por cada cliente: nombre o razón social, tipo de cliente, cantidad de solicitudes, cantidad de créditos, score crediticio más bajo, nivel de riesgo más alto registrado y cantidad de alertas de mora.--
SELECT
    c.id AS id_cliente,
    c.tipo_cliente,
    COALESCE(
        pn.nombres + ' ' + pn.apellido_paterno + ' ' + pn.apellido_materno,
        pj.razon_social
    ) AS cliente,
    COUNT(DISTINCT s.id) AS cantidad_solicitudes,
    COUNT(DISTINCT cr.id) AS cantidad_creditos,
    MIN(er.score_crediticio) AS score_mas_bajo,
    CASE
        WHEN SUM(CASE WHEN er.nivel_riesgo = 'alto' THEN 1 ELSE 0 END) > 0
            THEN 'alto'
        WHEN SUM(CASE WHEN er.nivel_riesgo = 'medio' THEN 1 ELSE 0 END) > 0
            THEN 'medio'
        WHEN SUM(CASE WHEN er.nivel_riesgo = 'bajo' THEN 1 ELSE 0 END) > 0
            THEN 'bajo'
        ELSE 'sin evaluacion'
    END AS nivel_riesgo_mas_alto,
    COUNT(DISTINCT am.id) AS cantidad_alertas_mora
FROM clientes c
LEFT JOIN personas_naturales pn
    ON pn.id_cliente = c.id
LEFT JOIN personas_juridicas pj
    ON pj.id_cliente = c.id
LEFT JOIN solicitudes s
    ON s.id_cliente = c.id
LEFT JOIN evaluaciones_riesgo er
    ON er.id_solicitud = s.id
LEFT JOIN creditos cr
    ON cr.id_solicitud = s.id
LEFT JOIN alertas_mora am
    ON am.id_credito = cr.id
GROUP BY
    c.id,
    c.tipo_cliente,
    pn.nombres,
    pn.apellido_paterno,
    pn.apellido_materno,
    pj.razon_social
ORDER BY cantidad_alertas_mora DESC, score_mas_bajo ASC;

--Análisis de recuperación de pagos por crédito--
--Construir una consulta que muestre por cada crédito: número de crédito, monto aprobado, total programado en cuotas, total pagado, saldo pendiente, porcentaje recuperado y estado del crédito.--
SELECT
    cr.nro_credito,
    cr.monto_aprobado,
    cr.estado,
    COALESCE(SUM(DISTINCT cc.total_cuota), 0) AS total_programado,
    COALESCE(SUM(dcp.monto_pagado), 0) AS total_pagado,
    COALESCE(SUM(DISTINCT cc.saldo_pendiente), 0) AS saldo_pendiente,
    CAST(
        COALESCE(SUM(dcp.monto_pagado), 0) * 100.0 /
        NULLIF(COALESCE(SUM(DISTINCT cc.total_cuota), 0), 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_recuperado
FROM creditos cr
LEFT JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
LEFT JOIN detalle_cuotas_pagos dcp
    ON dcp.id_cuota = cc.id
GROUP BY
    cr.nro_credito,
    cr.monto_aprobado,
    cr.estado
ORDER BY porcentaje_recuperado DESC;
