USE bd_riesgo_crediticio;
GO

/* ============================================================
   ACTUALIZAR FECHAS A 2025-2026

   Este script hace mas actuales las fechas de:
   - solicitudes
   - evaluaciones_riesgo
   - creditos

   Mantiene una secuencia realista:
   solicitud -> evaluacion -> resolucion/aprobacion -> desembolso -> inicio
   ============================================================ */

;WITH fechas AS (
    SELECT
        s.id AS id_solicitud,
        s.nro_solicitud,
        ROW_NUMBER() OVER (ORDER BY s.nro_solicitud) AS rn,
        DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY s.nro_solicitud) - 1) * 3, CONVERT(DATE, '2025-08-04')) AS nueva_fecha_solicitud
    FROM solicitudes s
)
UPDATE s
SET
    fecha_solicitud = f.nueva_fecha_solicitud,
    fecha_resolucion = CASE
        WHEN s.estado IN ('aprobada', 'desestimado')
            THEN DATEADD(DAY, 3, f.nueva_fecha_solicitud)
        ELSE NULL
    END
FROM solicitudes s
INNER JOIN fechas f
    ON f.id_solicitud = s.id;
GO

UPDATE er
SET fecha_evaluacion = DATEADD(DAY, 2, s.fecha_solicitud)
FROM evaluaciones_riesgo er
INNER JOIN solicitudes s
    ON s.id = er.id_solicitud;
GO

UPDATE cr
SET
    fecha_aprobacion = s.fecha_resolucion,
    fecha_desembolso = DATEADD(HOUR, 10, CAST(DATEADD(DAY, 1, s.fecha_resolucion) AS DATETIME)),
    fecha_inicio = DATEADD(DAY, 3, s.fecha_resolucion),
    fecha_vencimiento = DATEADD(MONTH, cr.plazo_meses, DATEADD(DAY, 3, s.fecha_resolucion))
FROM creditos cr
INNER JOIN solicitudes s
    ON s.id = cr.id_solicitud
WHERE s.estado = 'aprobada'
  AND s.fecha_resolucion IS NOT NULL;
GO

SELECT
    MIN(fecha_solicitud) AS primera_solicitud,
    MAX(fecha_solicitud) AS ultima_solicitud
FROM solicitudes;

SELECT
    MIN(fecha_inicio) AS primer_credito,
    MAX(fecha_inicio) AS ultimo_credito,
    MIN(fecha_vencimiento) AS primer_vencimiento,
    MAX(fecha_vencimiento) AS ultimo_vencimiento
FROM creditos;
GO