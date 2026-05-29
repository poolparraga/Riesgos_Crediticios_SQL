USE bd_riesgo_crediticio;
GO

/* ============================================================
   DATA INCREMENTAL RELACIONADA

   Para DBeaver:
   - Relaciona datos con subconsultas por valores unicos:
     DNI, RUC, nro_cuenta, nro_solicitud, nro_credito.
   ============================================================ */

/* ============================================================
   CASO 1: PERSONA NATURAL CON CREDITO, CUOTAS Y PAGOS
   ============================================================ */

INSERT INTO clientes (tipo_cliente, estado_cliente, created_at)
SELECT 'N', 'activo', '2026-01-08T09:20:00'
WHERE NOT EXISTS (
    SELECT 1 FROM personas_naturales WHERE dni = '62547819'
);
GO

INSERT INTO personas_naturales
    (id_cliente, dni, nombres, apellido_paterno, apellido_materno,
     fecha_nacimiento, genero, estado_civil, situacion_laboral, ocupacion,
     ingresos_mensuales, telefono, email, direccion, ubigeo)
SELECT
    (SELECT TOP 1 id FROM clientes WHERE tipo_cliente = 'N' AND created_at = '2026-01-08T09:20:00' ORDER BY id DESC),
    '62547819', 'Lucia Andrea', 'Benites', 'Arce',
    '1992-06-15', 'F', 'S', 'empleado', 'Product manager',
    9200.00, '987120345', 'lucia.benites@example.com',
    'Av. El Derby 254, Santiago de Surco', '150140'
WHERE NOT EXISTS (
    SELECT 1 FROM personas_naturales WHERE dni = '62547819'
);
GO

INSERT INTO cuentas_bancarias
    (tipo_cuenta_id, id_cliente, nro_cuenta, cci, moneda, saldo_actual,
     fecha_apertura, fecha_vencimiento, estado)
SELECT
    (SELECT TOP 1 id FROM tipos_cuenta WHERE nombre IN ('Sueldo', 'Cuenta Sueldo') ORDER BY id),
    pn.id_cliente,
    '009900062547819001',
    '00200990006254781901',
    'PEN',
    18500.00,
    '2026-01-09',
    NULL,
    'activa'
FROM personas_naturales pn
WHERE pn.dni = '62547819'
  AND NOT EXISTS (
      SELECT 1 FROM cuentas_bancarias WHERE nro_cuenta = '009900062547819001'
  );
GO

INSERT INTO solicitudes
    (id_cliente, id_producto, nro_solicitud, fecha_solicitud, monto_solicitado,
     moneda_solicitada, plazo_solicitado_meses, estado, fecha_resolucion, motivo_rechazo)
SELECT
    pn.id_cliente,
    pc.id,
    'SOL-2026-0101',
    '2026-01-10',
    28000.00,
    'PEN',
    24,
    'aprobada',
    '2026-01-13',
    NULL
FROM personas_naturales pn
INNER JOIN productos_crediticios pc
    ON pc.nombre = 'Prestamo Personal Libre Disponibilidad'
WHERE pn.dni = '62547819'
  AND NOT EXISTS (
      SELECT 1 FROM solicitudes WHERE nro_solicitud = 'SOL-2026-0101'
  );
GO

INSERT INTO evaluaciones_riesgo
    (id_solicitud, ingresos_verificados, deuda_activa, nivel_endeudamiento,
     historial_crediticio, creditos_activos, score_crediticio, nivel_riesgo,
     fecha_evaluacion, observaciones)
SELECT
    s.id,
    9200.00,
    1800.00,
    19.57,
    'normal',
    1,
    820,
    'bajo',
    '2026-01-12',
    'Cliente con ingreso fijo, score alto y bajo endeudamiento.'
FROM solicitudes s
WHERE s.nro_solicitud = 'SOL-2026-0101'
  AND NOT EXISTS (
      SELECT 1 FROM evaluaciones_riesgo WHERE id_solicitud = s.id
  );
GO

INSERT INTO creditos
    (id_solicitud, id_cuenta_desembolso, nro_credito, monto_aprobado, moneda,
     plazo_meses, tea, tcea, valor_cuota, desgravamen, fecha_inicio,
     fecha_vencimiento, fecha_aprobacion, fecha_desembolso, nro_cuotas, estado)
SELECT
    s.id,
    cb.id,
    'CRE-2026-0101',
    28000.00,
    'PEN',
    24,
    0.1650,
    0.1840,
    1396.67,
    18.00,
    '2026-01-16',
    '2028-01-16',
    '2026-01-13',
    '2026-01-14T11:30:00',
    24,
    'vigente'
FROM solicitudes s
INNER JOIN cuentas_bancarias cb
    ON cb.nro_cuenta = '009900062547819001'
WHERE s.nro_solicitud = 'SOL-2026-0101'
  AND NOT EXISTS (
      SELECT 1 FROM creditos WHERE nro_credito = 'CRE-2026-0101'
  );
GO

INSERT INTO cronograma_cuotas
    (id_credito, num_cuota, fecha_vencimiento, capital, intereses, seguros,
     total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
SELECT cr.id, v.num_cuota, v.fecha_vencimiento, v.capital, v.intereses, v.seguros,
       v.total_cuota, v.saldo_pendiente, v.tasa_mora, v.dias_atraso, v.estado
FROM creditos cr
CROSS JOIN (VALUES
    (1, CONVERT(DATE, '2026-02-16'), 1030.00, 348.67, 18.00, 1396.67, 0.00,   0.0000, 0, 'pagada'),
    (2, CONVERT(DATE, '2026-03-16'), 1044.00, 334.67, 18.00, 1396.67, 558.67, 0.0000, 0, 'pagada parcialmente')
) AS v (num_cuota, fecha_vencimiento, capital, intereses, seguros, total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
WHERE cr.nro_credito = 'CRE-2026-0101'
  AND NOT EXISTS (
      SELECT 1
      FROM cronograma_cuotas cc
      WHERE cc.id_credito = cr.id
        AND cc.num_cuota = v.num_cuota
  );
GO

INSERT INTO pagos
    (id_medio_pago, nro_operacion, fecha_pago, monto, moneda, observaciones, estado)
SELECT
    (SELECT TOP 1 id FROM medios_pago WHERE nombre IN ('Transferencia bancaria', 'Transferencia') ORDER BY id),
    'OP-2026-010101',
    '2026-02-15T18:20:00',
    1396.67,
    'PEN',
    'Pago completo cuota 1 credito CRE-2026-0101',
    'procesado'
WHERE NOT EXISTS (
    SELECT 1 FROM pagos WHERE nro_operacion = 'OP-2026-010101'
);
GO

INSERT INTO pagos
    (id_medio_pago, nro_operacion, fecha_pago, monto, moneda, observaciones, estado)
SELECT
    (SELECT TOP 1 id FROM medios_pago WHERE nombre IN ('Banca movil', 'Transferencia bancaria', 'Transferencia') ORDER BY id),
    'OP-2026-010102',
    '2026-03-18T09:15:00',
    838.00,
    'PEN',
    'Pago parcial cuota 2 credito CRE-2026-0101',
    'procesado'
WHERE NOT EXISTS (
    SELECT 1 FROM pagos WHERE nro_operacion = 'OP-2026-010102'
);
GO

INSERT INTO detalle_cuotas_pagos (id_cuota, id_pago, monto_pagado)
SELECT cc.id, p.id, p.monto
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
INNER JOIN pagos p
    ON p.nro_operacion = CASE
        WHEN cc.num_cuota = 1 THEN 'OP-2026-010101'
        WHEN cc.num_cuota = 2 THEN 'OP-2026-010102'
    END
WHERE cr.nro_credito = 'CRE-2026-0101'
  AND cc.num_cuota IN (1, 2)
  AND NOT EXISTS (
      SELECT 1
      FROM detalle_cuotas_pagos dcp
      WHERE dcp.id_cuota = cc.id
        AND dcp.id_pago = p.id
  );
GO

/* ============================================================
   CASO 2: PERSONA NATURAL CON SOLICITUD DESESTIMADA
   ============================================================ */

INSERT INTO clientes (tipo_cliente, estado_cliente, created_at)
SELECT 'N', 'activo', '2026-02-04T14:10:00'
WHERE NOT EXISTS (
    SELECT 1 FROM personas_naturales WHERE dni = '63987124'
);
GO

INSERT INTO personas_naturales
    (id_cliente, dni, nombres, apellido_paterno, apellido_materno,
     fecha_nacimiento, genero, estado_civil, situacion_laboral, ocupacion,
     ingresos_mensuales, telefono, email, direccion, ubigeo)
SELECT
    (SELECT TOP 1 id FROM clientes WHERE tipo_cliente = 'N' AND created_at = '2026-02-04T14:10:00' ORDER BY id DESC),
    '63987124', 'Marco Antonio', 'Delgado', 'Pena',
    '1997-10-03', 'M', 'S', 'independiente', 'Repartidor independiente',
    2600.00, '934120987', 'marco.delgado@example.com',
    'Jr. Los Olmos 512, San Juan de Miraflores', '150133'
WHERE NOT EXISTS (
    SELECT 1 FROM personas_naturales WHERE dni = '63987124'
);
GO

INSERT INTO cuentas_bancarias
    (tipo_cuenta_id, id_cliente, nro_cuenta, cci, moneda, saldo_actual,
     fecha_apertura, fecha_vencimiento, estado)
SELECT
    (SELECT TOP 1 id FROM tipos_cuenta WHERE nombre IN ('Ahorros', 'Cuenta Ahorro') ORDER BY id),
    pn.id_cliente,
    '009900063987124001',
    '00200990006398712401',
    'PEN',
    740.00,
    '2026-02-05',
    NULL,
    'activa'
FROM personas_naturales pn
WHERE pn.dni = '63987124'
  AND NOT EXISTS (
      SELECT 1 FROM cuentas_bancarias WHERE nro_cuenta = '009900063987124001'
  );
GO

INSERT INTO solicitudes
    (id_cliente, id_producto, nro_solicitud, fecha_solicitud, monto_solicitado,
     moneda_solicitada, plazo_solicitado_meses, estado, fecha_resolucion, motivo_rechazo)
SELECT
    pn.id_cliente,
    pc.id,
    'SOL-2026-0102',
    '2026-02-06',
    9000.00,
    'PEN',
    24,
    'desestimado',
    '2026-02-09',
    'Endeudamiento alto para ingresos variables no sustentados.'
FROM personas_naturales pn
INNER JOIN productos_crediticios pc
    ON pc.nombre = 'Consumo Digital'
WHERE pn.dni = '63987124'
  AND NOT EXISTS (
      SELECT 1 FROM solicitudes WHERE nro_solicitud = 'SOL-2026-0102'
  );
GO

INSERT INTO evaluaciones_riesgo
    (id_solicitud, ingresos_verificados, deuda_activa, nivel_endeudamiento,
     historial_crediticio, creditos_activos, score_crediticio, nivel_riesgo,
     fecha_evaluacion, observaciones)
SELECT
    s.id,
    2600.00,
    1850.00,
    71.15,
    'deficiente',
    3,
    390,
    'alto',
    '2026-02-08',
    'Cliente con deuda activa alta y atrasos recientes.'
FROM solicitudes s
WHERE s.nro_solicitud = 'SOL-2026-0102'
  AND NOT EXISTS (
      SELECT 1 FROM evaluaciones_riesgo WHERE id_solicitud = s.id
  );
GO

/* ============================================================
   CASO 3: PERSONA JURIDICA CON CREDITO Y ALERTA DE MORA
   ============================================================ */

INSERT INTO clientes (tipo_cliente, estado_cliente, created_at)
SELECT 'J', 'activo', '2026-03-03T10:05:00'
WHERE NOT EXISTS (
    SELECT 1 FROM personas_juridicas WHERE ruc = '20699011223'
);
GO

INSERT INTO personas_juridicas
    (id_cliente, ruc, razon_social, nombre_comercial, representante_legal,
     tipo_empresa, sector_economico, direccion_fiscal, ubigeo_fiscal,
     telefono, email, fecha_constitucion, inicio_actividades,
     estado_empresa, ingresos_anuales)
SELECT
    (SELECT TOP 1 id FROM clientes WHERE tipo_cliente = 'J' AND created_at = '2026-03-03T10:05:00' ORDER BY id DESC),
    '20699011223',
    'Servicios Integrales Killa SAC',
    'Killa Servicios',
    'Natalia Chavez Rios',
    'SAC',
    'Servicios generales',
    'Av. La Encalada 840, Santiago de Surco',
    '150140',
    '014589632',
    'finanzas@killaservicios.example.com',
    '2021-05-12',
    '2021-06-01',
    'activo',
    1450000.00
WHERE NOT EXISTS (
    SELECT 1 FROM personas_juridicas WHERE ruc = '20699011223'
);
GO

INSERT INTO cuentas_bancarias
    (tipo_cuenta_id, id_cliente, nro_cuenta, cci, moneda, saldo_actual,
     fecha_apertura, fecha_vencimiento, estado)
SELECT
    (SELECT TOP 1 id FROM tipos_cuenta WHERE nombre IN ('Cuenta Empresarial', 'Corriente', 'Cuenta Corriente') ORDER BY id),
    pj.id_cliente,
    '009900206990112001',
    '00200990020699011201',
    'PEN',
    96500.00,
    '2026-03-04',
    NULL,
    'activa'
FROM personas_juridicas pj
WHERE pj.ruc = '20699011223'
  AND NOT EXISTS (
      SELECT 1 FROM cuentas_bancarias WHERE nro_cuenta = '009900206990112001'
  );
GO

INSERT INTO solicitudes
    (id_cliente, id_producto, nro_solicitud, fecha_solicitud, monto_solicitado,
     moneda_solicitada, plazo_solicitado_meses, estado, fecha_resolucion, motivo_rechazo)
SELECT
    pj.id_cliente,
    pc.id,
    'SOL-2026-0103',
    '2026-03-05',
    65000.00,
    'PEN',
    18,
    'aprobada',
    '2026-03-10',
    NULL
FROM personas_juridicas pj
INNER JOIN productos_crediticios pc
    ON pc.nombre = 'Capital de Trabajo Pyme'
WHERE pj.ruc = '20699011223'
  AND NOT EXISTS (
      SELECT 1 FROM solicitudes WHERE nro_solicitud = 'SOL-2026-0103'
  );
GO

INSERT INTO evaluaciones_riesgo
    (id_solicitud, ingresos_verificados, deuda_activa, nivel_endeudamiento,
     historial_crediticio, creditos_activos, score_crediticio, nivel_riesgo,
     fecha_evaluacion, observaciones)
SELECT
    s.id,
    120833.33,
    42000.00,
    34.75,
    'cpp',
    3,
    655,
    'medio',
    '2026-03-08',
    'Empresa con flujo positivo, pero deuda relevante en sistema.'
FROM solicitudes s
WHERE s.nro_solicitud = 'SOL-2026-0103'
  AND NOT EXISTS (
      SELECT 1 FROM evaluaciones_riesgo WHERE id_solicitud = s.id
  );
GO

INSERT INTO creditos
    (id_solicitud, id_cuenta_desembolso, nro_credito, monto_aprobado, moneda,
     plazo_meses, tea, tcea, valor_cuota, desgravamen, fecha_inicio,
     fecha_vencimiento, fecha_aprobacion, fecha_desembolso, nro_cuotas, estado)
SELECT
    s.id,
    cb.id,
    'CRE-2026-0103',
    65000.00,
    'PEN',
    18,
    0.1850,
    0.2040,
    4358.89,
    30.00,
    '2026-03-13',
    '2027-09-13',
    '2026-03-10',
    '2026-03-11T15:40:00',
    18,
    'vigente'
FROM solicitudes s
INNER JOIN cuentas_bancarias cb
    ON cb.nro_cuenta = '009900206990112001'
WHERE s.nro_solicitud = 'SOL-2026-0103'
  AND NOT EXISTS (
      SELECT 1 FROM creditos WHERE nro_credito = 'CRE-2026-0103'
  );
GO

INSERT INTO cronograma_cuotas
    (id_credito, num_cuota, fecha_vencimiento, capital, intereses, seguros,
     total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
SELECT cr.id, v.num_cuota, v.fecha_vencimiento, v.capital, v.intereses, v.seguros,
       v.total_cuota, v.saldo_pendiente, v.tasa_mora, v.dias_atraso, v.estado
FROM creditos cr
CROSS JOIN (VALUES
    (1, CONVERT(DATE, '2026-04-13'), 3000.00, 1328.89, 30.00, 4358.89, 0.00,    0.0000, 0,  'pagada'),
    (2, CONVERT(DATE, '2026-05-13'), 3046.00, 1282.89, 30.00, 4358.89, 4358.89, 0.0250, 16, 'vencida')
) AS v (num_cuota, fecha_vencimiento, capital, intereses, seguros, total_cuota, saldo_pendiente, tasa_mora, dias_atraso, estado)
WHERE cr.nro_credito = 'CRE-2026-0103'
  AND NOT EXISTS (
      SELECT 1
      FROM cronograma_cuotas cc
      WHERE cc.id_credito = cr.id
        AND cc.num_cuota = v.num_cuota
  );
GO

INSERT INTO pagos
    (id_medio_pago, nro_operacion, fecha_pago, monto, moneda, observaciones, estado)
SELECT
    (SELECT TOP 1 id FROM medios_pago WHERE nombre IN ('Transferencia bancaria', 'Transferencia') ORDER BY id),
    'OP-2026-010301',
    '2026-04-12T16:05:00',
    4358.89,
    'PEN',
    'Pago completo cuota 1 credito CRE-2026-0103',
    'procesado'
WHERE NOT EXISTS (
    SELECT 1 FROM pagos WHERE nro_operacion = 'OP-2026-010301'
);
GO

INSERT INTO detalle_cuotas_pagos (id_cuota, id_pago, monto_pagado)
SELECT cc.id, p.id, p.monto
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
INNER JOIN pagos p
    ON p.nro_operacion = 'OP-2026-010301'
WHERE cr.nro_credito = 'CRE-2026-0103'
  AND cc.num_cuota = 1
  AND NOT EXISTS (
      SELECT 1
      FROM detalle_cuotas_pagos dcp
      WHERE dcp.id_cuota = cc.id
        AND dcp.id_pago = p.id
  );
GO

INSERT INTO alertas_mora
    (id_credito, id_cuota, tipo_alerta, fecha_alerta, dias_atraso,
     descripcion, nivel_severidad, estado, fecha_cierre)
SELECT
    cr.id,
    cc.id,
    'cuota_vencida',
    '2026-05-14',
    16,
    'Cuota 2 vencida del credito CRE-2026-0103. Gestion preventiva requerida.',
    'baja',
    'activa',
    NULL
FROM creditos cr
INNER JOIN cronograma_cuotas cc
    ON cc.id_credito = cr.id
WHERE cr.nro_credito = 'CRE-2026-0103'
  AND cc.num_cuota = 2
  AND NOT EXISTS (
      SELECT 1
      FROM alertas_mora am
      WHERE am.id_credito = cr.id
        AND am.id_cuota = cc.id
        AND am.tipo_alerta = 'cuota_vencida'
  );
GO

SELECT 'clientes' AS tabla, COUNT(*) AS total FROM clientes
UNION ALL SELECT 'personas_naturales', COUNT(*) FROM personas_naturales
UNION ALL SELECT 'personas_juridicas', COUNT(*) FROM personas_juridicas
UNION ALL SELECT 'cuentas_bancarias', COUNT(*) FROM cuentas_bancarias
UNION ALL SELECT 'solicitudes', COUNT(*) FROM solicitudes
UNION ALL SELECT 'evaluaciones_riesgo', COUNT(*) FROM evaluaciones_riesgo
UNION ALL SELECT 'creditos', COUNT(*) FROM creditos
UNION ALL SELECT 'cronograma_cuotas', COUNT(*) FROM cronograma_cuotas
UNION ALL SELECT 'pagos', COUNT(*) FROM pagos
UNION ALL SELECT 'detalle_cuotas_pagos', COUNT(*) FROM detalle_cuotas_pagos
UNION ALL SELECT 'alertas_mora', COUNT(*) FROM alertas_mora;
GO
