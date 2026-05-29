USE bd_riesgo_crediticio;
GO

/* ============================================================
   7. SOLICITUDES

   Requiere:
   - clientes cargados
   - productos_crediticios cargados

   No se insertan ids manuales porque la tabla usa IDENTITY.
   ============================================================ */

;WITH data_solicitudes AS (
    SELECT *
    FROM (VALUES
        (1,  'Prestamo Personal Libre Disponibilidad', 'SOL-2024-0001', '2024-01-12', 12000.00,  'PEN', 24,  'aprobada',      '2024-01-15', NULL),
        (2,  'Credito Vehicular Nuevo',                'SOL-2024-0002', '2024-01-18', 68000.00,  'PEN', 48,  'aprobada',      '2024-01-23', NULL),
        (3,  'Consumo Digital',                        'SOL-2024-0003', '2024-01-25', 4500.00,   'PEN', 12,  'aprobada',      '2024-01-26', NULL),
        (4,  'Credito Hipotecario Vivienda',           'SOL-2024-0004', '2024-02-02', 320000.00, 'PEN', 180, 'aprobada',      '2024-02-12', NULL),
        (5,  'Prestamo Personal Preferente',           'SOL-2024-0005', '2024-02-08', 25000.00,  'PEN', 36,  'en evaluacion', NULL,         NULL),
        (6,  'Prestamo Personal Convenio',             'SOL-2024-0006', '2024-02-14', 18000.00,  'PEN', 24,  'aprobada',      '2024-02-17', NULL),
        (7,  'Compra de Electrodomesticos',            'SOL-2024-0007', '2024-02-21', 6500.00,   'PEN', 18,  'desestimado',   '2024-02-23', 'Score crediticio por debajo del minimo requerido.'),
        (8,  'Credito Educativo',                      'SOL-2024-0008', '2024-03-01', 22000.00,  'PEN', 48,  'aprobada',      '2024-03-05', NULL),
        (9,  'Prestamo Personal Libre Disponibilidad', 'SOL-2024-0009', '2024-03-05', 15000.00,  'PEN', 30,  'aprobada',      '2024-03-08', NULL),
        (10, 'Consumo Digital',                        'SOL-2024-0010', '2024-03-10', 8000.00,   'PEN', 24,  'ingresado',     NULL,         NULL),
        (11, 'Credito Vehicular Seminuevo',            'SOL-2024-0011', '2024-03-16', 54000.00,  'PEN', 36,  'aprobada',      '2024-03-20', NULL),
        (12, 'Prestamo Personal Preferente',           'SOL-2024-0012', '2024-03-22', 30000.00,  'PEN', 36,  'desistida',     NULL,         NULL),
        (13, 'Compra de Electrodomesticos',            'SOL-2024-0013', '2024-03-28', 3500.00,   'PEN', 12,  'aprobada',      '2024-03-29', NULL),
        (14, 'Consumo Digital',                        'SOL-2024-0014', '2024-04-03', 6000.00,   'PEN', 18,  'aprobada',      '2024-04-04', NULL),
        (15, 'Prestamo Personal Libre Disponibilidad', 'SOL-2024-0015', '2024-04-09', 20000.00,  'PEN', 36,  'desestimado',   '2024-04-12', 'Nivel de endeudamiento superior a politica vigente.'),
        (16, 'Prestamo Personal Convenio',             'SOL-2024-0016', '2024-04-15', 40000.00,  'PEN', 48,  'aprobada',      '2024-04-18', NULL),
        (17, 'Consumo Digital',                        'SOL-2024-0017', '2024-04-20', 2500.00,   'PEN', 6,   'aprobada',      '2024-04-21', NULL),
        (18, 'Prestamo Personal Preferente',           'SOL-2024-0018', '2024-04-25', 45000.00,  'PEN', 48,  'en evaluacion', NULL,         NULL),
        (19, 'Credito Educativo',                      'SOL-2024-0019', '2024-05-02', 18000.00,  'PEN', 36,  'aprobada',      '2024-05-06', NULL),
        (20, 'Consumo Digital',                        'SOL-2024-0020', '2024-05-07', 7000.00,   'PEN', 24,  'desestimado',   '2024-05-09', 'Ingresos no sustentados para el monto solicitado.'),
        (21, 'Capital de Trabajo Pyme',                'SOL-2024-0021', '2024-01-20', 50000.00,  'PEN', 24,  'aprobada',      '2024-01-25', NULL),
        (22, 'Activo Fijo Pyme',                       'SOL-2024-0022', '2024-01-27', 180000.00, 'PEN', 48,  'aprobada',      '2024-02-03', NULL),
        (23, 'Credito Agropecuario',                   'SOL-2024-0023', '2024-02-06', 90000.00,  'PEN', 36,  'aprobada',      '2024-02-12', NULL),
        (24, 'Linea Revolvente Negocio',               'SOL-2024-0024', '2024-02-13', 35000.00,  'PEN', 12,  'aprobada',      '2024-02-16', NULL),
        (25, 'Activo Fijo Pyme',                       'SOL-2024-0025', '2024-02-20', 260000.00, 'PEN', 60,  'en evaluacion', NULL,         NULL),
        (26, 'Capital de Trabajo Pyme',                'SOL-2024-0026', '2024-03-02', 75000.00,  'PEN', 24,  'aprobada',      '2024-03-07', NULL),
        (27, 'Credito Campana Comercial',              'SOL-2024-0027', '2024-03-09', 22000.00,  'PEN', 9,   'aprobada',      '2024-03-11', NULL),
        (28, 'Credito Empresarial USD',                'SOL-2024-0028', '2024-03-15', 60000.00,  'USD', 36,  'aprobada',      '2024-03-22', NULL),
        (29, 'Capital de Trabajo Pyme',                'SOL-2024-0029', '2024-03-21', 42000.00,  'PEN', 18,  'desestimado',   '2024-03-25', 'Flujo de caja insuficiente para la cuota proyectada.'),
        (30, 'Linea Revolvente Negocio',               'SOL-2024-0030', '2024-03-28', 25000.00,  'PEN', 12,  'ingresado',     NULL,         NULL),
        (31, 'Activo Fijo Pyme',                       'SOL-2024-0031', '2024-04-04', 120000.00, 'PEN', 48,  'aprobada',      '2024-04-10', NULL),
        (32, 'Capital de Trabajo Pyme',                'SOL-2024-0032', '2024-04-12', 95000.00,  'PEN', 30,  'aprobada',      '2024-04-17', NULL),
        (33, 'Credito Campana Comercial',              'SOL-2024-0033', '2024-04-18', 30000.00,  'PEN', 12,  'desestimado',   '2024-04-22', 'Empresa con estado suspendido en validacion interna.'),
        (34, 'Capital de Trabajo Pyme',                'SOL-2024-0034', '2024-04-25', 38000.00,  'PEN', 18,  'aprobada',      '2024-04-29', NULL),
        (35, 'Credito Empresarial USD',                'SOL-2024-0035', '2024-05-02', 85000.00,  'USD', 36,  'desistida',     NULL,         NULL),
        (1,  'Prestamo Personal USD',                  'SOL-2024-0036', '2024-05-08', 12000.00,  'USD', 24,  'en evaluacion', NULL,         NULL),
        (2,  'Consumo Digital',                        'SOL-2024-0037', '2024-05-10', 3000.00,   'PEN', 6,   'aprobada',      '2024-05-11', NULL),
        (3,  'Prestamo Personal Libre Disponibilidad', 'SOL-2024-0038', '2024-05-12', 10000.00,  'PEN', 24,  'desestimado',   '2024-05-15', 'Cliente registra atrasos recientes en otra entidad.'),
        (4,  'Compra de Terreno',                      'SOL-2024-0039', '2024-05-14', 180000.00, 'PEN', 120, 'ingresado',     NULL,         NULL),
        (5,  'Credito Educativo',                      'SOL-2024-0040', '2024-05-16', 12000.00,  'PEN', 24,  'aprobada',      '2024-05-19', NULL),
        (6,  'Credito Vehicular Seminuevo',            'SOL-2024-0041', '2024-05-18', 48000.00,  'PEN', 36,  'aprobada',      '2024-05-23', NULL),
        (7,  'Consumo Digital',                        'SOL-2024-0042', '2024-05-20', 5500.00,   'PEN', 18,  'en evaluacion', NULL,         NULL),
        (8,  'Prestamo Personal Preferente',           'SOL-2024-0043', '2024-05-22', 35000.00,  'PEN', 36,  'aprobada',      '2024-05-26', NULL),
        (9,  'Credito Taxi',                           'SOL-2024-0044', '2024-05-24', 62000.00,  'PEN', 48,  'aprobada',      '2024-05-29', NULL),
        (10, 'Compra de Electrodomesticos',            'SOL-2024-0045', '2024-05-26', 4200.00,   'PEN', 12,  'desistida',     NULL,         NULL),
        (11, 'Prestamo Personal Convenio',             'SOL-2024-0046', '2024-05-28', 28000.00,  'PEN', 36,  'aprobada',      '2024-05-31', NULL),
        (12, 'Consumo Digital',                        'SOL-2024-0047', '2024-06-01', 9500.00,   'PEN', 24,  'ingresado',     NULL,         NULL),
        (13, 'Prestamo Personal Libre Disponibilidad', 'SOL-2024-0048', '2024-06-03', 17000.00,  'PEN', 30,  'aprobada',      '2024-06-06', NULL),
        (14, 'Credito Educativo',                      'SOL-2024-0049', '2024-06-05', 26000.00,  'PEN', 48,  'aprobada',      '2024-06-10', NULL),
        (15, 'Consumo Digital',                        'SOL-2024-0050', '2024-06-07', 11000.00,  'PEN', 30,  'desestimado',   '2024-06-09', 'Capacidad de pago insuficiente.'),
        (16, 'Prestamo Personal Preferente',           'SOL-2024-0051', '2024-06-09', 60000.00,  'PEN', 60,  'aprobada',      '2024-06-14', NULL),
        (17, 'Compra de Electrodomesticos',            'SOL-2024-0052', '2024-06-11', 1800.00,   'PEN', 6,   'aprobada',      '2024-06-12', NULL),
        (18, 'Credito Vehicular Nuevo',                'SOL-2024-0053', '2024-06-13', 95000.00,  'PEN', 60,  'en evaluacion', NULL,         NULL),
        (19, 'Prestamo Personal Libre Disponibilidad', 'SOL-2024-0054', '2024-06-15', 14000.00,  'PEN', 24,  'aprobada',      '2024-06-18', NULL),
        (20, 'Consumo Digital',                        'SOL-2024-0055', '2024-06-17', 4000.00,   'PEN', 12,  'desistida',     NULL,         NULL),
        (21, 'Credito Campana Comercial',              'SOL-2024-0056', '2024-06-19', 45000.00,  'PEN', 12,  'aprobada',      '2024-06-24', NULL),
        (22, 'Credito Empresarial USD',                'SOL-2024-0057', '2024-06-21', 150000.00, 'USD', 48,  'en evaluacion', NULL,         NULL),
        (23, 'Capital de Trabajo Pyme',                'SOL-2024-0058', '2024-06-23', 65000.00,  'PEN', 24,  'aprobada',      '2024-06-28', NULL),
        (24, 'Linea Revolvente Negocio',               'SOL-2024-0059', '2024-06-25', 50000.00,  'PEN', 18,  'aprobada',      '2024-06-29', NULL),
        (25, 'Activo Fijo Pyme',                       'SOL-2024-0060', '2024-06-27', 320000.00, 'PEN', 72,  'desestimado',   '2024-07-02', 'Garantia propuesta no cubre politica minima.'),
        (26, 'Capital de Trabajo Pyme',                'SOL-2024-0061', '2024-06-29', 110000.00, 'PEN', 36,  'aprobada',      '2024-07-04', NULL),
        (27, 'Credito Campana Comercial',              'SOL-2024-0062', '2024-07-01', 18000.00,  'PEN', 6,   'ingresado',     NULL,         NULL),
        (28, 'Activo Fijo Pyme',                       'SOL-2024-0063', '2024-07-03', 210000.00, 'PEN', 60,  'aprobada',      '2024-07-09', NULL),
        (29, 'Capital de Trabajo Pyme',                'SOL-2024-0064', '2024-07-05', 55000.00,  'PEN', 24,  'aprobada',      '2024-07-10', NULL),
        (30, 'Linea Revolvente Negocio',               'SOL-2024-0065', '2024-07-07', 40000.00,  'PEN', 12,  'desistida',     NULL,         NULL)
    ) AS s (
        id_cliente,
        nombre_producto,
        nro_solicitud,
        fecha_solicitud,
        monto_solicitado,
        moneda_solicitada,
        plazo_solicitado_meses,
        estado,
        fecha_resolucion,
        motivo_rechazo
    )
)
INSERT INTO solicitudes
    (id_cliente, id_producto, nro_solicitud, fecha_solicitud, monto_solicitado,
     moneda_solicitada, plazo_solicitado_meses, estado, fecha_resolucion, motivo_rechazo)
SELECT
    ds.id_cliente,
    pc.id AS id_producto,
    ds.nro_solicitud,
    ds.fecha_solicitud,
    ds.monto_solicitado,
    ds.moneda_solicitada,
    ds.plazo_solicitado_meses,
    ds.estado,
    ds.fecha_resolucion,
    ds.motivo_rechazo
FROM data_solicitudes ds
INNER JOIN productos_crediticios pc
    ON pc.nombre = ds.nombre_producto
WHERE NOT EXISTS (
    SELECT 1
    FROM solicitudes s
    WHERE s.nro_solicitud = ds.nro_solicitud
);
GO

SELECT
    estado,
    COUNT(*) AS cantidad
FROM solicitudes
GROUP BY estado
ORDER BY estado;

SELECT
    COUNT(*) AS total_solicitudes
FROM solicitudes;
GO