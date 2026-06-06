USE bd_riesgo_crediticio;
GO

--Listar todos los clientes con su id, tipo_cliente, estado_cliente y fecha de creación.--
SELECT
    id,
    tipo_cliente,
    estado_cliente,
    created_at
FROM clientes
ORDER BY id;

--Mostrar todas las personas naturales con nombres completos, DNI, situación laboral e ingresos mensuales.--
SELECT
    id,
    dni,
    nombres + ' ' + apellido_paterno + ' ' + apellido_materno AS nombre_completo,
    situacion_laboral,
    ingresos_mensuales
FROM personas_naturales
ORDER BY apellido_paterno, apellido_materno, nombres;

--Listar las personas jurídicas con RUC, razón social, tipo de empresa, sector económico e ingresos anuales.--
SELECT
    id,
    ruc,
    razon_social,
    tipo_empresa,
    sector_economico,
    ingresos_anuales
FROM personas_juridicas
ORDER BY razon_social;

--Mostrar todas las cuentas bancarias activas, indicando número de cuenta, moneda, saldo actual y estado.--
SELECT
    nro_cuenta,
    moneda,
    saldo_actual,
    estado
FROM cuentas_bancarias
WHERE estado = 'activa'
ORDER BY saldo_actual DESC;

--Contar cuántos clientes existen por tipo de cliente: natural N y jurídico J.--
SELECT
    tipo_cliente,
    COUNT(*) AS cantidad_clientes
FROM clientes
GROUP BY tipo_cliente
ORDER BY tipo_cliente;

--Listar los clientes naturales junto con sus cuentas bancarias, mostrando nombre completo, DNI, número de cuenta, tipo de cuenta, moneda y saldo.--
SELECT
    c.id,
    pn.dni,
    pn.nombres + ' ' + pn.apellido_paterno + ' ' + pn.apellido_materno AS nombre_completo,
    tc.nombre AS tipo_cuenta,
    cb.nro_cuenta,
    cb.moneda,
    cb.saldo_actual,
    cb.estado
FROM clientes c
INNER JOIN personas_naturales pn
    ON pn.id_cliente = c.id
INNER JOIN cuentas_bancarias cb
    ON cb.id_cliente = c.id
INNER JOIN tipos_cuenta tc
    ON tc.id = cb.tipo_cuenta_id
ORDER BY nombre_completo, cb.nro_cuenta;

--Mostrar las solicitudes de crédito con el nombre del producto, monto solicitado, plazo, estado y fecha de solicitud.--
SELECT
    s.nro_solicitud,
    pc.nombre AS producto,
    pc.tipo AS tipo_producto,
    s.monto_solicitado,
    s.moneda_solicitada,
    s.plazo_solicitado_meses,
    s.estado,
    s.fecha_solicitud
FROM solicitudes s
INNER JOIN productos_crediticios pc
    ON pc.id = s.id_producto
ORDER BY s.fecha_solicitud DESC;

--Contar cuántas solicitudes existen por estado: aprobada, desestimado, ingresado, en evaluacion, desistida.--
SELECT
    estado,
    COUNT(*) AS cantidad_solicitudes
FROM solicitudes
GROUP BY estado
ORDER BY cantidad_solicitudes DESC;

--Listar los créditos vigentes con su número de crédito, numero de solicitud, cliente, monto aprobado, moneda, plazo, TEA, TCEA y valor de cuota.--
SELECT
    cr.nro_credito,
    s.nro_solicitud,
    c.id AS id_cliente,
    c.tipo_cliente,
    cr.monto_aprobado,
    cr.moneda,
    cr.plazo_meses,
    cr.tea,
    cr.tcea,
    cr.valor_cuota,
    cr.fecha_inicio,
    cr.fecha_vencimiento,
    cr.estado
FROM creditos cr
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
WHERE cr.estado = 'vigente'
ORDER BY cr.fecha_inicio DESC;

--Mostrar las evaluaciones de riesgo con score menor a 600, incluyendo solicitud, cliente, historial crediticio, nivel de riesgo y observaciones.--
SELECT
    s.nro_solicitud,
    c.id AS id_cliente,
    c.tipo_cliente,
    er.historial_crediticio,
    er.score_crediticio,
    er.nivel_riesgo,
    er.nivel_endeudamiento,
    er.observaciones
FROM evaluaciones_riesgo er
INNER JOIN solicitudes s
    ON s.id = er.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
WHERE er.score_crediticio < 600
ORDER BY er.score_crediticio ASC;