--Mostrar el crédito con la mayor cantidad de cuotas pendientes.
SELECT TOP 1
    cr.id AS credito_id,
    cr.numero_credito,
    COUNT(cu.id) AS cuotas_pendientes
FROM creditos cr
INNER JOIN cuotas cu ON cu.credito_id = cr.id
WHERE cu.estado = 'PENDIENTE'
GROUP BY cr.id, cr.numero_credito
ORDER BY cuotas_pendientes DESC;

--Obtener el ranking de clientes según monto total desembolsado.
SELECT
    RANK() OVER (ORDER BY SUM(cr.monto) DESC) AS ranking,
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS nombre_cliente,
    SUM(cr.monto) AS total_desembolsado
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
GROUP BY cl.id, pn.nombres, pn.apellido_paterno, pj.razon_social
ORDER BY ranking;

--Mostrar el porcentaje de endeudamiento promedio por producto crediticio.
SELECT
    pc.nombre AS producto,
    ROUND(AVG(ec.nivel_endeudamiento), 2) AS endeudamiento_promedio
FROM productos_crediticios pc
INNER JOIN solicitudes s ON s.producto_crediticio_id = pc.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
GROUP BY pc.id, pc.nombre
ORDER BY endeudamiento_promedio DESC;

--Encontrar clientes que nunca solicitaron un crédito.
SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS nombre_cliente,
    cl.tipo_cliente
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
WHERE cl.id NOT IN (SELECT DISTINCT cliente_id FROM solicitudes);

--Mostrar los clientes cuyo patrimonio supere tres veces sus ingresos anuales.
SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS nombre_cliente,
    ec.valor_patrimonio,
    ec.ingresos_mensuales * 12 AS ingresos_anuales
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
WHERE ec.valor_patrimonio > (ec.ingresos_mensuales * 12 * 3)
ORDER BY valor_patrimonio DESC;

--Calcular la mora potencial por crédito:
----Saldo pendiente + intereses
SELECT
    cr.id AS credito_id,
    cr.numero_credito,
    cr.saldo_credito AS saldo_pendiente,
    SUM(cu.intereses) AS intereses_pendientes,
    cr.saldo_credito + SUM(cu.intereses) AS mora_potencial
FROM creditos cr
INNER JOIN cuotas cu ON cu.credito_id = cr.id
WHERE cu.estado = 'PENDIENTE'
GROUP BY cr.id, cr.numero_credito, cr.saldo_credito
ORDER BY mora_potencial DESC;

--Mostrar los créditos cuyo saldo actual represente más del 50% del monto inicial.
SELECT
    cr.id AS credito_id,
    cr.numero_credito,
    cr.monto AS monto_inicial,
    cr.saldo_credito AS saldo_actual,
    ROUND((cr.saldo_credito / cr.monto) * 100, 2) AS porcentaje_saldo
FROM creditos cr
WHERE (cr.saldo_credito / cr.monto) > 0.50
ORDER BY porcentaje_saldo DESC;


--Mostrar las cuotas pagadas fuera de su fecha de vencimiento.
SELECT
    cu.id AS cuota_id,
    cr.numero_credito,
    cu.num_cuota,
    CAST(cu.fecha_vencimiento AS DATE) AS fecha_vencimiento,
    CAST(p.fecha_pago AS DATE) AS fecha_pago,
    DATEDIFF(DAY, cu.fecha_vencimiento, p.fecha_pago) AS dias_de_retraso,
    dcp.monto_pagado
FROM cuotas cu
INNER JOIN detalle_cuotas_pagos dcp ON dcp.cuota_id = cu.id
INNER JOIN pagos p ON p.id = dcp.pago_id
INNER JOIN creditos cr ON cr.id = cu.credito_id
WHERE p.fecha_pago > cu.fecha_vencimiento
ORDER BY dias_de_retraso DESC;


