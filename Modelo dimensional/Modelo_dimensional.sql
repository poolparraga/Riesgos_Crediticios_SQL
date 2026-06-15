USE bd_riesgo_crediticio;
GO

/* ============================================================
   MODELO DIMENSIONAL TIPO ESTRELLA
   Este modelo permite analizar solicitudes, créditos, cuotas,
   pagos y alertas de mora desde una perspectiva analítica.
   ============================================================ */


/* ============================================================
   DIMENSION: dim_cliente
   Consolida clientes naturales y jurídicos en una sola dimensión.
   ============================================================ */
CREATE TABLE dim_cliente (
    cliente_key INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente_origen INT NOT NULL,
    tipo_cliente VARCHAR(1) NOT NULL,
    nombre_cliente VARCHAR(255) NOT NULL,
    documento VARCHAR(20) NULL,
    estado_cliente VARCHAR(20) NOT NULL,
    genero VARCHAR(1) NULL,
    estado_civil VARCHAR(10) NULL,
    situacion_laboral VARCHAR(20) NULL,
    ocupacion VARCHAR(100) NULL,
    tipo_empresa VARCHAR(10) NULL,
    sector_economico VARCHAR(100) NULL,
    ingresos DECIMAL(15,2) NULL,
    ubigeo CHAR(6) NULL
);


/* ============================================================
   DIMENSION: dim_producto_crediticio
   Describe los productos financieros ofrecidos por la entidad.
   ============================================================ */
CREATE TABLE dim_producto_crediticio (
    producto_key INT IDENTITY(1,1) PRIMARY KEY,
    id_producto_origen INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    moneda VARCHAR(5) NOT NULL,
    tasa_interes_min DECIMAL(6,4) NOT NULL,
    tasa_interes_max DECIMAL(6,4) NOT NULL,
    monto_min DECIMAL(12,2) NOT NULL,
    monto_max DECIMAL(12,2) NOT NULL,
    plazo_minimo_meses INT NOT NULL,
    plazo_maximo_meses INT NOT NULL,
    requiere_garantia BIT NOT NULL,
    estado VARCHAR(20) NOT NULL
);


/* ============================================================
   DIMENSION: dim_tiempo
   Permite analizar la información por fecha, mes, trimestre y año.
   ============================================================ */
CREATE TABLE dim_tiempo (
    fecha_key INT PRIMARY KEY,
    fecha DATE NOT NULL,
    anio INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INT NOT NULL,
    dia INT NOT NULL,
    dia_semana INT NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL
);


/* ============================================================
   DIMENSION: dim_cuenta
   Describe las cuentas bancarias usadas por los clientes o para
   desembolsar créditos.
   ============================================================ */
CREATE TABLE dim_cuenta (
    cuenta_key INT IDENTITY(1,1) PRIMARY KEY,
    id_cuenta_origen INT NOT NULL,
    tipo_cuenta VARCHAR(50) NOT NULL,
    moneda VARCHAR(5) NOT NULL,
    estado VARCHAR(15) NOT NULL,
    fecha_apertura DATE NOT NULL
);


/* ============================================================
   DIMENSION: dim_medio_pago
   Describe los canales utilizados para registrar pagos.
   ============================================================ */
CREATE TABLE dim_medio_pago (
    medio_pago_key INT IDENTITY(1,1) PRIMARY KEY,
    id_medio_pago_origen INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL
);


/* ============================================================
   DIMENSION: dim_riesgo
   Agrupa las evaluaciones en rangos de score y endeudamiento.
   ============================================================ */
CREATE TABLE dim_riesgo (
    riesgo_key INT IDENTITY(1,1) PRIMARY KEY,
    historial_crediticio VARCHAR(20) NOT NULL,
    nivel_riesgo VARCHAR(10) NOT NULL,
    rango_score VARCHAR(30) NOT NULL,
    rango_endeudamiento VARCHAR(30) NOT NULL
);


/* ============================================================
   FACT: fact_solicitudes_credito
   ============================================================ */
CREATE TABLE fact_solicitudes_credito (
    solicitud_key INT IDENTITY(1,1) PRIMARY KEY,
    id_solicitud_origen INT NOT NULL,
    cliente_key INT NOT NULL,
    producto_key INT NOT NULL,
    riesgo_key INT NULL,
    fecha_solicitud_key INT NOT NULL,
    fecha_resolucion_key INT NULL,
    monto_solicitado DECIMAL(12,2) NOT NULL,
    plazo_solicitado_meses INT NOT NULL,
    estado VARCHAR(20) NOT NULL
);


/* ============================================================
   FACT: fact_creditos
   ============================================================ */
CREATE TABLE fact_creditos (
    credito_key INT IDENTITY(1,1) PRIMARY KEY,
    id_credito_origen INT NOT NULL,
    cliente_key INT NOT NULL,
    producto_key INT NOT NULL,
    cuenta_key INT NULL,
    riesgo_key INT NULL,
    fecha_inicio_key INT NOT NULL,
    fecha_vencimiento_key INT NOT NULL,
    monto_aprobado DECIMAL(12,2) NOT NULL,
    plazo_meses INT NOT NULL,
    tea DECIMAL(6,4) NOT NULL,
    tcea DECIMAL(6,4) NOT NULL,
    valor_cuota DECIMAL(12,2) NOT NULL,
    estado VARCHAR(20) NOT NULL
);


/* ============================================================
   FACT: fact_cuotas
   ============================================================ */
CREATE TABLE fact_cuotas (
    cuota_key INT IDENTITY(1,1) PRIMARY KEY,
    id_cuota_origen INT NOT NULL,
    credito_key INT NOT NULL,
    fecha_vencimiento_key INT NOT NULL,
    num_cuota INT NOT NULL,
    capital DECIMAL(12,2) NOT NULL,
    intereses DECIMAL(12,2) NOT NULL,
    seguros DECIMAL(12,2) NOT NULL,
    total_cuota DECIMAL(12,2) NOT NULL,
    saldo_pendiente DECIMAL(12,2) NOT NULL,
    dias_atraso INT NOT NULL,
    estado VARCHAR(25) NOT NULL
);


/* ============================================================
   FACT: fact_pagos

   Esta fact usa detalle_cuotas_pagos porque un pago puede cubrir
   varias cuotas y una cuota puede recibir varios pagos.
   ============================================================ */
CREATE TABLE fact_pagos (
    pago_key INT IDENTITY(1,1) PRIMARY KEY,
    id_pago_origen INT NOT NULL,
    id_detalle_pago_origen INT NOT NULL,
    cuota_key INT NOT NULL,
    credito_key INT NOT NULL,
    medio_pago_key INT NOT NULL,
    fecha_pago_key INT NOT NULL,
    monto_pagado DECIMAL(12,2) NOT NULL,
    estado_pago VARCHAR(15) NOT NULL
);


/* ============================================================
   FACT: fact_alertas_mora
   ============================================================ */
CREATE TABLE fact_alertas_mora (
    alerta_key INT IDENTITY(1,1) PRIMARY KEY,
    id_alerta_origen INT NOT NULL,
    cliente_key INT NOT NULL,
    credito_key INT NOT NULL,
    cuota_key INT NULL,
    fecha_alerta_key INT NOT NULL,
    fecha_cierre_key INT NULL,
    tipo_alerta VARCHAR(30) NOT NULL,
    dias_atraso INT NOT NULL,
    nivel_severidad VARCHAR(10) NOT NULL,
    estado VARCHAR(15) NOT NULL
);


/* ============================================================
   CARGA: dim_cliente
   Extrae clientes naturales y jurídicos desde el modelo relacional
   y los consolida en una sola dimensión.
   ============================================================ */
INSERT INTO dim_cliente (
    id_cliente_origen,
    tipo_cliente,
    nombre_cliente,
    documento,
    estado_cliente,
    genero,
    estado_civil,
    situacion_laboral,
    ocupacion,
    tipo_empresa,
    sector_economico,
    ingresos,
    ubigeo
)
SELECT
    c.id,
    c.tipo_cliente,
    COALESCE(
        pn.nombres + ' ' + pn.apellido_paterno + ' ' + pn.apellido_materno,
        pj.razon_social
    ) AS nombre_cliente,
    COALESCE(pn.dni, pj.ruc) AS documento,
    c.estado_cliente,
    pn.genero,
    pn.estado_civil,
    pn.situacion_laboral,
    pn.ocupacion,
    pj.tipo_empresa,
    pj.sector_economico,
    COALESCE(pn.ingresos_mensuales, pj.ingresos_anuales) AS ingresos,
    COALESCE(pn.ubigeo, pj.ubigeo_fiscal) AS ubigeo
FROM clientes c
LEFT JOIN personas_naturales pn
    ON pn.id_cliente = c.id
LEFT JOIN personas_juridicas pj
    ON pj.id_cliente = c.id;


/* ============================================================
   CARGA: dim_producto_crediticio
   Copia los productos crediticios y sus atributos comerciales.
   ============================================================ */
INSERT INTO dim_producto_crediticio (
    id_producto_origen,
    nombre,
    tipo,
    moneda,
    tasa_interes_min,
    tasa_interes_max,
    monto_min,
    monto_max,
    plazo_minimo_meses,
    plazo_maximo_meses,
    requiere_garantia,
    estado
)
SELECT
    id,
    nombre,
    tipo,
    moneda,
    tasa_interes_min,
    tasa_interes_max,
    monto_min,
    monto_max,
    plazo_minimo_meses,
    plazo_maximo_meses,
    requiere_garantia,
    estado
FROM productos_crediticios;


/* ============================================================
   CARGA: dim_cuenta
   Carga las cuentas bancarias con su tipo, moneda y estado.
   ============================================================ */
INSERT INTO dim_cuenta (
    id_cuenta_origen,
    tipo_cuenta,
    moneda,
    estado,
    fecha_apertura
)
SELECT
    cb.id,
    tc.nombre,
    cb.moneda,
    cb.estado,
    cb.fecha_apertura
FROM cuentas_bancarias cb
INNER JOIN tipos_cuenta tc
    ON tc.id = cb.tipo_cuenta_id;


/* ============================================================
   CARGA: dim_medio_pago
   Carga los canales o medios usados para registrar pagos.
   ============================================================ */
INSERT INTO dim_medio_pago (
    id_medio_pago_origen,
    nombre,
    descripcion
)
SELECT
    id,
    nombre,
    descripcion
FROM medios_pago;


/* ============================================================
   CARGA: dim_riesgo
   Crea combinaciones únicas de riesgo a partir de las evaluaciones.
   Agrupa score y endeudamiento en rangos analíticos.
   ============================================================ */
INSERT INTO dim_riesgo (
    historial_crediticio,
    nivel_riesgo,
    rango_score,
    rango_endeudamiento
)
SELECT DISTINCT
    historial_crediticio,
    nivel_riesgo,
    CASE
        WHEN score_crediticio < 500 THEN '0-499'
        WHEN score_crediticio < 650 THEN '500-649'
        WHEN score_crediticio < 750 THEN '650-749'
        WHEN score_crediticio < 850 THEN '750-849'
        ELSE '850-999'
    END AS rango_score,
    CASE
        WHEN nivel_endeudamiento < 20 THEN '0-19'
        WHEN nivel_endeudamiento < 35 THEN '20-34'
        WHEN nivel_endeudamiento < 50 THEN '35-49'
        ELSE '50-100'
    END AS rango_endeudamiento
FROM evaluaciones_riesgo;


/* ============================================================
   CARGA: dim_tiempo
   Genera un calendario diario desde 2023 hasta 2035.
   Esta dimensión se usa para analizar solicitudes, pagos,
   vencimientos y alertas por periodo.
   ============================================================ */
DECLARE @fecha_inicio DATE = '2023-01-01';
DECLARE @fecha_fin DATE = '2035-12-31';

WITH fechas AS (
    SELECT @fecha_inicio AS fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, fecha)
    FROM fechas
    WHERE fecha < @fecha_fin
)
INSERT INTO dim_tiempo (
    fecha_key,
    fecha,
    anio,
    mes,
    nombre_mes,
    trimestre,
    dia,
    dia_semana,
    nombre_dia
)
SELECT
    CONVERT(INT, FORMAT(fecha, 'yyyyMMdd')) AS fecha_key,
    fecha,
    YEAR(fecha),
    MONTH(fecha),
    DATENAME(MONTH, fecha),
    DATEPART(QUARTER, fecha),
    DAY(fecha),
    DATEPART(WEEKDAY, fecha),
    DATENAME(WEEKDAY, fecha)
FROM fechas
OPTION (MAXRECURSION 0);


/* ============================================================
   CARGA: fact_solicitudes_credito
   Carga cada solicitud como un evento medible.
   Relaciona cliente, producto, riesgo y fechas.
   ============================================================ */
INSERT INTO fact_solicitudes_credito (
    id_solicitud_origen,
    cliente_key,
    producto_key,
    riesgo_key,
    fecha_solicitud_key,
    fecha_resolucion_key,
    monto_solicitado,
    plazo_solicitado_meses,
    estado
)
SELECT
    s.id,
    dc.cliente_key,
    dp.producto_key,
    dr.riesgo_key,
    CONVERT(INT, FORMAT(s.fecha_solicitud, 'yyyyMMdd')),
    CASE
        WHEN s.fecha_resolucion IS NULL THEN NULL
        ELSE CONVERT(INT, FORMAT(s.fecha_resolucion, 'yyyyMMdd'))
    END,
    s.monto_solicitado,
    s.plazo_solicitado_meses,
    s.estado
FROM solicitudes s
INNER JOIN dim_cliente dc
    ON dc.id_cliente_origen = s.id_cliente
INNER JOIN dim_producto_crediticio dp
    ON dp.id_producto_origen = s.id_producto
LEFT JOIN evaluaciones_riesgo er
    ON er.id_solicitud = s.id
LEFT JOIN dim_riesgo dr
    ON dr.historial_crediticio = er.historial_crediticio
   AND dr.nivel_riesgo = er.nivel_riesgo
   AND dr.rango_score = CASE
        WHEN er.score_crediticio < 500 THEN '0-499'
        WHEN er.score_crediticio < 650 THEN '500-649'
        WHEN er.score_crediticio < 750 THEN '650-749'
        WHEN er.score_crediticio < 850 THEN '750-849'
        ELSE '850-999'
   END
   AND dr.rango_endeudamiento = CASE
        WHEN er.nivel_endeudamiento < 20 THEN '0-19'
        WHEN er.nivel_endeudamiento < 35 THEN '20-34'
        WHEN er.nivel_endeudamiento < 50 THEN '35-49'
        ELSE '50-100'
   END;


/* ============================================================
   CARGA: fact_creditos
   Carga créditos aprobados/desembolsados y los relaciona con
   cliente, producto, cuenta, riesgo y fechas.
   ============================================================ */
INSERT INTO fact_creditos (
    id_credito_origen,
    cliente_key,
    producto_key,
    cuenta_key,
    riesgo_key,
    fecha_inicio_key,
    fecha_vencimiento_key,
    monto_aprobado,
    plazo_meses,
    tea,
    tcea,
    valor_cuota,
    estado
)
SELECT
    cr.id,
    dc.cliente_key,
    dp.producto_key,
    dcu.cuenta_key,
    dr.riesgo_key,
    CONVERT(INT, FORMAT(cr.fecha_inicio, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(cr.fecha_vencimiento, 'yyyyMMdd')),
    cr.monto_aprobado,
    cr.plazo_meses,
    cr.tea,
    cr.tcea,
    cr.valor_cuota,
    cr.estado
FROM creditos cr
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN dim_cliente dc
    ON dc.id_cliente_origen = s.id_cliente
INNER JOIN dim_producto_crediticio dp
    ON dp.id_producto_origen = s.id_producto
LEFT JOIN dim_cuenta dcu
    ON dcu.id_cuenta_origen = cr.id_cuenta_desembolso
LEFT JOIN evaluaciones_riesgo er
    ON er.id_solicitud = s.id
LEFT JOIN dim_riesgo dr
    ON dr.historial_crediticio = er.historial_crediticio
   AND dr.nivel_riesgo = er.nivel_riesgo
   AND dr.rango_score = CASE
        WHEN er.score_crediticio < 500 THEN '0-499'
        WHEN er.score_crediticio < 650 THEN '500-649'
        WHEN er.score_crediticio < 750 THEN '650-749'
        WHEN er.score_crediticio < 850 THEN '750-849'
        ELSE '850-999'
   END
   AND dr.rango_endeudamiento = CASE
        WHEN er.nivel_endeudamiento < 20 THEN '0-19'
        WHEN er.nivel_endeudamiento < 35 THEN '20-34'
        WHEN er.nivel_endeudamiento < 50 THEN '35-49'
        ELSE '50-100'
   END;


/* ============================================================
   CARGA: fact_cuotas
   Carga cada cuota del cronograma como un hecho financiero.
   ============================================================ */
INSERT INTO fact_cuotas (
    id_cuota_origen,
    credito_key,
    fecha_vencimiento_key,
    num_cuota,
    capital,
    intereses,
    seguros,
    total_cuota,
    saldo_pendiente,
    dias_atraso,
    estado
)
SELECT
    cc.id,
    fc.credito_key,
    CONVERT(INT, FORMAT(cc.fecha_vencimiento, 'yyyyMMdd')),
    cc.num_cuota,
    cc.capital,
    cc.intereses,
    cc.seguros,
    cc.total_cuota,
    cc.saldo_pendiente,
    cc.dias_atraso,
    cc.estado
FROM cronograma_cuotas cc
INNER JOIN fact_creditos fc
    ON fc.id_credito_origen = cc.id_credito;


/* ============================================================
   CARGA: fact_pagos
   Carga pagos aplicados a cuotas.
   Usa detalle_cuotas_pagos como base para respetar la relación
   muchos a muchos entre pagos y cuotas.
   ============================================================ */
INSERT INTO fact_pagos (
    id_pago_origen,
    id_detalle_pago_origen,
    cuota_key,
    credito_key,
    medio_pago_key,
    fecha_pago_key,
    monto_pagado,
    estado_pago
)
SELECT
    p.id,
    dcp.id,
    fcu.cuota_key,
    fcr.credito_key,
    dmp.medio_pago_key,
    CONVERT(INT, FORMAT(p.fecha_pago, 'yyyyMMdd')),
    dcp.monto_pagado,
    p.estado
FROM detalle_cuotas_pagos dcp
INNER JOIN pagos p
    ON p.id = dcp.id_pago
INNER JOIN cronograma_cuotas cc
    ON cc.id = dcp.id_cuota
INNER JOIN fact_cuotas fcu
    ON fcu.id_cuota_origen = cc.id
INNER JOIN fact_creditos fcr
    ON fcr.id_credito_origen = cc.id_credito
INNER JOIN dim_medio_pago dmp
    ON dmp.id_medio_pago_origen = p.id_medio_pago;


/* ============================================================
   CARGA: fact_alertas_mora
   Carga alertas de mora como eventos históricos de gestión.
   Puede estar asociada a una cuota o solo al crédito.
   ============================================================ */
INSERT INTO fact_alertas_mora (
    id_alerta_origen,
    cliente_key,
    credito_key,
    cuota_key,
    fecha_alerta_key,
    fecha_cierre_key,
    tipo_alerta,
    dias_atraso,
    nivel_severidad,
    estado
)
SELECT
    am.id,
    dc.cliente_key,
    fcr.credito_key,
    fcu.cuota_key,
    CONVERT(INT, FORMAT(am.fecha_alerta, 'yyyyMMdd')),
    CASE
        WHEN am.fecha_cierre IS NULL THEN NULL
        ELSE CONVERT(INT, FORMAT(am.fecha_cierre, 'yyyyMMdd'))
    END,
    am.tipo_alerta,
    am.dias_atraso,
    am.nivel_severidad,
    am.estado
FROM alertas_mora am
INNER JOIN creditos cr
    ON cr.id = am.id_credito
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN dim_cliente dc
    ON dc.id_cliente_origen = s.id_cliente
INNER JOIN fact_creditos fcr
    ON fcr.id_credito_origen = cr.id
LEFT JOIN fact_cuotas fcu
    ON fcu.id_cuota_origen = am.id_cuota;


/* ============================================================
   VALIDACION 
   Lista las columnas de las tablas de hechos.
   ============================================================ */
SELECT
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE 'fact_%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


/* ============================================================
   VALIDACION
   Lista las tablas de dimensiones del modelo estrella.
   ============================================================ */
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'dim_%';


/* ============================================================
   VALIDACION
   Reporte agregado de créditos aprobados por año, mes, producto
   y tipo de cliente.
   Responde:
   - ¿Cuántos créditos se aprobaron por periodo?
   - ¿Cuánto monto se aprobó por tipo de producto?
   - ¿Cómo se distribuye la cartera por tipo de cliente?
   ============================================================ */
SELECT
    dt.anio,
    dt.mes,
    dp.tipo AS tipo_producto,
    dc.tipo_cliente,
    COUNT(fc.credito_key) AS cantidad_creditos,
    SUM(fc.monto_aprobado) AS total_aprobado
FROM fact_creditos fc
INNER JOIN dim_tiempo dt
    ON dt.fecha_key = fc.fecha_inicio_key
INNER JOIN dim_producto_crediticio dp
    ON dp.producto_key = fc.producto_key
INNER JOIN dim_cliente dc
    ON dc.cliente_key = fc.cliente_key
GROUP BY
    dt.anio,
    dt.mes,
    dp.tipo,
    dc.tipo_cliente
ORDER BY
    dt.anio,
    dt.mes,
    dp.tipo,
    dc.tipo_cliente;