USE bd_riesgo_crediticio;
GO

/* ============================================================
   EJERCICIO 1 - VIEW
   Crear una vista llamada vw_resumen_riesgo_cliente que muestre
   el perfil consolidado de cada cliente, incluyendo su nombre
   o razón social, cantidad de solicitudes, créditos aprobados,
   monto total aprobado, score crediticio mínimo, nivel máximo
   de endeudamiento, evaluaciones en riesgo alto, y cantidad
   de alertas de mora activas.
   ============================================================ */
CREATE OR ALTER VIEW dbo.vw_resumen_riesgo_cliente AS
WITH solicitudes_resumen AS (
    SELECT
        id_cliente,
        COUNT(*) AS cantidad_solicitudes
    FROM solicitudes
    GROUP BY id_cliente
),
creditos_resumen AS (
    SELECT
        s.id_cliente,
        COUNT(cr.id) AS cantidad_creditos,
        SUM(cr.monto_aprobado) AS monto_total_aprobado
    FROM creditos cr
    INNER JOIN solicitudes s
        ON s.id = cr.id_solicitud
    GROUP BY s.id_cliente
),
riesgo_resumen AS (
    SELECT
        s.id_cliente,
        MIN(er.score_crediticio) AS score_minimo,
        MAX(er.nivel_endeudamiento) AS max_endeudamiento,
        SUM(CASE WHEN er.nivel_riesgo = 'alto' THEN 1 ELSE 0 END) AS evaluaciones_alto_riesgo
    FROM evaluaciones_riesgo er
    INNER JOIN solicitudes s
        ON s.id = er.id_solicitud
    GROUP BY s.id_cliente
),
alertas_resumen AS (
    SELECT
        s.id_cliente,
        COUNT(am.id) AS cantidad_alertas,
        SUM(CASE WHEN am.estado = 'activa' THEN 1 ELSE 0 END) AS alertas_activas
    FROM alertas_mora am
    INNER JOIN creditos cr
        ON cr.id = am.id_credito
    INNER JOIN solicitudes s
        ON s.id = cr.id_solicitud
    GROUP BY s.id_cliente
)
SELECT
    c.id AS id_cliente,
    c.tipo_cliente,
    c.estado_cliente,
    COALESCE(
        pn.nombres + ' ' + pn.apellido_paterno + ' ' + pn.apellido_materno,
        pj.razon_social
    ) AS cliente,
    COALESCE(sr.cantidad_solicitudes, 0) AS cantidad_solicitudes,
    COALESCE(crs.cantidad_creditos, 0) AS cantidad_creditos,
    COALESCE(crs.monto_total_aprobado, 0) AS monto_total_aprobado,
    rr.score_minimo,
    rr.max_endeudamiento,
    COALESCE(rr.evaluaciones_alto_riesgo, 0) AS evaluaciones_alto_riesgo,
    COALESCE(ar.cantidad_alertas, 0) AS cantidad_alertas,
    COALESCE(ar.alertas_activas, 0) AS alertas_activas
FROM clientes c
LEFT JOIN personas_naturales pn
    ON pn.id_cliente = c.id
LEFT JOIN personas_juridicas pj
    ON pj.id_cliente = c.id
LEFT JOIN solicitudes_resumen sr
    ON sr.id_cliente = c.id
LEFT JOIN creditos_resumen crs
    ON crs.id_cliente = c.id
LEFT JOIN riesgo_resumen rr
    ON rr.id_cliente = c.id
LEFT JOIN alertas_resumen ar
    ON ar.id_cliente = c.id;
GO


/* ============================================================
   EJERCICIO 2 - VIEW
   Crear una vista llamada vw_estado_financiero_credito que
   muestre por cada crédito el total programado a cobrar,
   el total efectivamente pagado, el saldo pendiente, la
   cantidad de cuotas pagadas y vencidas, y el porcentaje
   de recuperación de la deuda.
   ============================================================ */
CREATE OR ALTER VIEW dbo.vw_estado_financiero_credito AS
WITH cuotas AS (
    SELECT
        id_credito,
        COUNT(*) AS cantidad_cuotas,
        SUM(total_cuota) AS total_programado,
        SUM(saldo_pendiente) AS saldo_pendiente,
        SUM(CASE WHEN estado = 'pagada' THEN 1 ELSE 0 END) AS cuotas_pagadas,
        SUM(CASE WHEN estado = 'vencida' THEN 1 ELSE 0 END) AS cuotas_vencidas
    FROM cronograma_cuotas
    GROUP BY id_credito
),
pagos AS (
    SELECT
        cc.id_credito,
        SUM(dcp.monto_pagado) AS total_pagado
    FROM detalle_cuotas_pagos dcp
    INNER JOIN cronograma_cuotas cc
        ON cc.id = dcp.id_cuota
    GROUP BY cc.id_credito
)
SELECT
    cr.id AS id_credito,
    cr.nro_credito,
    cr.monto_aprobado,
    cr.moneda,
    cr.estado,
    COALESCE(cu.cantidad_cuotas, 0) AS cantidad_cuotas,
    COALESCE(cu.total_programado, 0) AS total_programado,
    COALESCE(pa.total_pagado, 0) AS total_pagado,
    COALESCE(cu.saldo_pendiente, 0) AS saldo_pendiente,
    COALESCE(cu.cuotas_pagadas, 0) AS cuotas_pagadas,
    COALESCE(cu.cuotas_vencidas, 0) AS cuotas_vencidas,
    CAST(
        COALESCE(pa.total_pagado, 0) * 100.0 /
        NULLIF(COALESCE(cu.total_programado, 0), 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_recuperado
FROM creditos cr
LEFT JOIN cuotas cu
    ON cu.id_credito = cr.id
LEFT JOIN pagos pa
    ON pa.id_credito = cr.id;
GO


/* ============================================================
   EJERCICIO 3 - VIEW
   Crear una vista llamada vw_alertas_mora_detalle que muestre
   el detalle completo de cada alerta de mora, incluyendo el
   tipo de alerta, nivel de severidad, días de atraso, número
   de crédito, cuota afectada y el nombre del cliente asociado.
   ============================================================ */
CREATE OR ALTER VIEW dbo.vw_alertas_mora_detalle AS
SELECT
    am.id AS id_alerta,
    am.tipo_alerta,
    am.nivel_severidad,
    am.estado AS estado_alerta,
    am.dias_atraso,
    am.fecha_alerta,
    am.fecha_cierre,
    cr.nro_credito,
    cc.num_cuota,
    cc.estado AS estado_actual_cuota,
    s.nro_solicitud,
    c.id AS id_cliente,
    c.tipo_cliente,
    COALESCE(
        pn.nombres + ' ' + pn.apellido_paterno + ' ' + pn.apellido_materno,
        pj.razon_social
    ) AS cliente
FROM alertas_mora am
INNER JOIN creditos cr
    ON cr.id = am.id_credito
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
INNER JOIN clientes c
    ON c.id = s.id_cliente
LEFT JOIN cronograma_cuotas cc
    ON cc.id = am.id_cuota
LEFT JOIN personas_naturales pn
    ON pn.id_cliente = c.id
LEFT JOIN personas_juridicas pj
    ON pj.id_cliente = c.id;
GO


/* ============================================================
   EJERCICIO 4 - FUNCTION ESCALAR
   Crear una función llamada fn_nombre_cliente que reciba el
   ID de un cliente y retorne su nombre completo si es persona
   natural, o su razón social si es persona jurídica.
   ============================================================ */
CREATE OR ALTER FUNCTION fn_nombre_cliente (
    @id_cliente INT
)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @nombre VARCHAR(255);
    SELECT
        @nombre = COALESCE(
            pn.nombres + ' ' + pn.apellido_paterno + ' ' + pn.apellido_materno,
            pj.razon_social
        )
    FROM clientes c
    LEFT JOIN personas_naturales pn
        ON pn.id_cliente = c.id
    LEFT JOIN personas_juridicas pj
        ON pj.id_cliente = c.id
    WHERE c.id = @id_cliente;

    RETURN @nombre;
END;

SELECT dbo.fn_nombre_cliente(2);
GO




/* ============================================================
   EJERCICIO 5 - FUNCTION ESCALAR
   Crear una función llamada fn_segmento_riesgo_cliente que
   reciba el ID de un cliente y lo clasifique en 'Riesgo Alto',
   'Riesgo Medio' o 'Riesgo Bajo' según su score crediticio
   mínimo, nivel de endeudamiento y cantidad de alertas de mora
   registradas. Si no tiene evaluaciones, retornar 'Sin informacion'.
   ============================================================ */
CREATE OR ALTER FUNCTION fn_segmento_riesgo_cliente (
    @id_cliente INT
)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE
        @score_minimo SMALLINT,
        @max_endeudamiento DECIMAL(5,2),
        @alertas INT,
        @max_dias_atraso INT,
        @segmento VARCHAR(30);

    SELECT
        @score_minimo = MIN(er.score_crediticio),
        @max_endeudamiento = MAX(er.nivel_endeudamiento)
    FROM evaluaciones_riesgo er
    INNER JOIN solicitudes s
        ON s.id = er.id_solicitud
    WHERE s.id_cliente = @id_cliente;

    SELECT
        @alertas = COUNT(am.id),
        @max_dias_atraso = MAX(am.dias_atraso)
    FROM alertas_mora am
    INNER JOIN creditos cr
        ON cr.id = am.id_credito
    INNER JOIN solicitudes s
        ON s.id = cr.id_solicitud
    WHERE s.id_cliente = @id_cliente;
    
    SET @segmento =
        CASE
            WHEN @score_minimo IS NULL THEN 'Sin informacion'
            WHEN @score_minimo < 600
              OR COALESCE(@max_dias_atraso, 0) > 30
              OR COALESCE(@alertas, 0) >= 2
                THEN 'Riesgo Alto'
            WHEN @score_minimo < 750
              OR COALESCE(@max_endeudamiento, 0) > 35
              OR COALESCE(@alertas, 0) = 1
                THEN 'Riesgo Medio'
            ELSE 'Riesgo Bajo'
        END
    RETURN @segmento
END;

SELECT dbo.fn_segmento_riesgo_cliente(4);
GO


/* ============================================================
   EJERCICIO 6 - FUNCTION DE TABLA
   Crear una función de tabla llamada fn_cuotas_por_credito que
   reciba el número de crédito y retorne todas las cuotas de su
   cronograma con sus montos, fechas de vencimiento, saldo
   pendiente, días de atraso y estado actual.
   ============================================================ */
CREATE OR ALTER FUNCTION dbo.fn_cuotas_por_credito (
    @nro_credito VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        cr.nro_credito,
        cc.num_cuota,
        cc.fecha_vencimiento,
        cc.capital,
        cc.intereses,
        cc.seguros,
        cc.total_cuota,
        cc.saldo_pendiente,
        cc.dias_atraso,
        cc.estado
    FROM creditos cr
    INNER JOIN cronograma_cuotas cc
        ON cc.id_credito = cr.id
    WHERE cr.nro_credito = @nro_credito
);

SELECT *
FROM dbo.fn_cuotas_por_credito('CRE-2024-0021');
GO


/* ============================================================
   EJERCICIO 7 - PROCEDURE
   Crear un procedimiento llamado sp_resumen_cliente que reciba
   el ID de un cliente y retorne su información completa de la
   vista vw_resumen_riesgo_cliente, incluyendo además el segmento
   de riesgo calculado por la función fn_segmento_riesgo_cliente.

   Uso: EXEC dbo.sp_resumen_cliente @id_cliente = 1;
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_resumen_cliente
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.*,
        dbo.fn_segmento_riesgo_cliente(v.id_cliente) AS segmento_riesgo
    FROM dbo.vw_resumen_riesgo_cliente v
    WHERE v.id_cliente = @id_cliente;
END;

EXEC dbo.sp_resumen_cliente @id_cliente = 1;

GO


/* ============================================================
   EJERCICIO 8 - PROCEDURE
   Crear un procedimiento llamado sp_registrar_alerta_mora que
   permita registrar manualmente una alerta de mora para un
   crédito. Debe validar que el crédito exista y, si se indica
   número de cuota, que dicha cuota pertenezca al crédito.

   Uso: EXEC dbo.sp_registrar_alerta_mora
            @nro_credito     = 'CRE-000001',
            @num_cuota       = 3,
            @tipo_alerta     = 'Pago vencido',
            @dias_atraso     = 15,
            @descripcion     = 'Cliente no realizó el pago de la cuota 3',
            @nivel_severidad = 'leve';
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_registrar_alerta_mora
    @nro_credito VARCHAR(20),
    @num_cuota INT = NULL,
    @tipo_alerta VARCHAR(30),
    @dias_atraso INT,
    @descripcion VARCHAR(500),
    @nivel_severidad VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @id_credito INT,
        @id_cuota INT;

    SELECT @id_credito = id
    FROM creditos
    WHERE nro_credito = @nro_credito;

    IF @id_credito IS NULL
    BEGIN
        THROW 50001, 'No existe el credito indicado.', 1;
    END;

    IF @num_cuota IS NOT NULL
    BEGIN
        SELECT @id_cuota = id
        FROM cronograma_cuotas
        WHERE id_credito = @id_credito
          AND num_cuota = @num_cuota;

        IF @id_cuota IS NULL
        BEGIN
            THROW 50002, 'No existe la cuota indicada para el credito.', 1;
        END;
    END;

    INSERT INTO alertas_mora
        (id_credito, id_cuota, tipo_alerta, fecha_alerta, dias_atraso,
         descripcion, nivel_severidad, estado)
    VALUES
        (@id_credito, @id_cuota, @tipo_alerta, CAST(GETDATE() AS DATE),
         @dias_atraso, @descripcion, @nivel_severidad, 'activa');
END;

SELECT TOP 10
    cr.nro_credito,
    cc.num_cuota,
    cc.fecha_vencimiento,
    cc.estado,
    cc.saldo_pendiente,
    cc.dias_atraso
FROM cronograma_cuotas cc
INNER JOIN creditos cr
    ON cr.id = cc.id_credito
WHERE cc.estado IN ('pendiente', 'vencida', 'pagada parcialmente')
  AND cc.saldo_pendiente > 0
ORDER BY cc.fecha_vencimiento;

EXEC dbo.sp_registrar_alerta_mora
    @nro_credito = 'CRE-2024-0021',
    @num_cuota = 1,
    @tipo_alerta = 'cuota_vencida',
    @dias_atraso = 12,
    @descripcion = 'Alerta manual de prueba por cuota vencida.',
    @nivel_severidad = 'baja';
GO


/* ============================================================
   EJERCICIO 8 - PROCEDURE
   Generar un reporte ejecutivo de exposición crediticia por
   segmento de riesgo, consolidando créditos, montos aprobados,
   saldos pendientes, alertas de mora y porcentaje recuperado.
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.sp_exposicion_crediticia_por_segmento
    @segmento VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id AS id_cliente,
        dbo.fn_nombre_cliente(c.id) AS cliente,
        c.tipo_cliente,
        dbo.fn_segmento_riesgo_cliente(c.id) AS segmento_riesgo,
        cr.nro_credito,
        cr.monto_aprobado,
        cr.moneda,
        cr.estado AS estado_credito,
        COALESCE(SUM(cc.total_cuota), 0) AS total_programado,
        COALESCE(SUM(cc.saldo_pendiente), 0) AS saldo_pendiente,
        COALESCE(SUM(dcp.monto_pagado), 0) AS total_pagado,
        COUNT(DISTINCT am.id) AS cantidad_alertas_mora,
        CAST(
            COALESCE(SUM(dcp.monto_pagado), 0) * 100.0 /
            NULLIF(COALESCE(SUM(cc.total_cuota), 0), 0)
            AS DECIMAL(10,2)
        ) AS porcentaje_recuperado
    FROM clientes c
    INNER JOIN solicitudes s
        ON s.id_cliente = c.id
    INNER JOIN creditos cr
        ON cr.id_solicitud = s.id
    LEFT JOIN cronograma_cuotas cc
        ON cc.id_credito = cr.id
    LEFT JOIN detalle_cuotas_pagos dcp
        ON dcp.id_cuota = cc.id
    LEFT JOIN alertas_mora am
        ON am.id_credito = cr.id
    WHERE dbo.fn_segmento_riesgo_cliente(c.id) = @segmento
    GROUP BY
        c.id,
        c.tipo_cliente,
        cr.nro_credito,
        cr.monto_aprobado,
        cr.moneda,
        cr.estado
    ORDER BY
        saldo_pendiente DESC,
        cantidad_alertas_mora DESC;
END;

EXEC dbo.sp_exposicion_crediticia_por_segmento
    @segmento = 'Riesgo Bajo';

EXEC dbo.sp_exposicion_crediticia_por_segmento
    @segmento = 'Riesgo Medio';

EXEC dbo.sp_exposicion_crediticia_por_segmento
    @segmento = 'Riesgo Alto';
GO

/* ============================================================
   EJERCICIO 10 - PROCEDURE
   Crear un procedimiento llamado sp_reporte_mora_por_fechas que
   reciba un rango de fechas y retorne todas las alertas de mora
   registradas en ese período, mostrando el crédito, la cuota
   afectada, el nombre del cliente y el saldo pendiente,
   ordenado por fecha descendente y mayor días de atraso.

   Uso: EXEC dbo.sp_reporte_mora_por_fechas
            @fecha_inicio = '2026-06-01',
            @fecha_fin    = '2026-06-30';
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_reporte_mora_por_fechas
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        am.fecha_alerta,
        am.tipo_alerta,
        am.nivel_severidad,
        am.estado AS estado_alerta,
        am.dias_atraso,
        cr.nro_credito,
        c.id AS id_cliente,
        dbo.fn_nombre_cliente(c.id) AS cliente,
        cc.num_cuota,
        cc.estado AS estado_cuota,
        cc.saldo_pendiente
    FROM alertas_mora am
    INNER JOIN creditos cr
        ON cr.id = am.id_credito
    INNER JOIN solicitudes s
        ON s.id = cr.id_solicitud
    INNER JOIN clientes c
        ON c.id = s.id_cliente
    LEFT JOIN cronograma_cuotas cc
        ON cc.id = am.id_cuota
    WHERE am.fecha_alerta BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY
        am.fecha_alerta DESC,
        am.dias_atraso DESC;
END;

EXEC dbo.sp_reporte_mora_por_fechas
    @fecha_inicio = '2026-01-01',
    @fecha_fin = '2026-12-31';
GO