USE bd_riesgo_crediticio;
GO

/* ============================================================
   13. DETALLE CUOTAS PAGOS

   Requiere:
   - cronograma_cuotas cargado
   - pagos cargados con nro_operacion formato OP-000000000001

   Relaciona cada pago con la cuota correspondiente.
   No inserta ids manuales porque la tabla usa IDENTITY.
   ============================================================ */

INSERT INTO detalle_cuotas_pagos
    (id_cuota, id_pago, monto_pagado)
SELECT
    cc.id AS id_cuota,
    p.id AS id_pago,
    p.monto AS monto_pagado
FROM pagos p
INNER JOIN cronograma_cuotas cc
    ON cc.id = CAST(RIGHT(p.nro_operacion, 12) AS INT)
WHERE p.nro_operacion LIKE 'OP-%'
  AND p.estado = 'procesado'
  AND NOT EXISTS (
      SELECT 1
      FROM detalle_cuotas_pagos dcp
      WHERE dcp.id_cuota = cc.id
        AND dcp.id_pago = p.id
  );
GO

SELECT
    cc.estado AS estado_cuota,
    COUNT(*) AS cantidad_detalles,
    SUM(dcp.monto_pagado) AS total_pagado
FROM detalle_cuotas_pagos dcp
INNER JOIN cronograma_cuotas cc
    ON cc.id = dcp.id_cuota
GROUP BY cc.estado
ORDER BY cc.estado;

SELECT COUNT(*) AS total_detalles
FROM detalle_cuotas_pagos;
GO