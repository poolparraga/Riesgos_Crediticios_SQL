USE bd_riesgo_crediticio;
GO

/* ============================================================
   8. EVALUACIONES DE RIESGO

   Requiere:
   - solicitudes cargadas

   Se relaciona por nro_solicitud para no depender del id generado.
   No se insertan ids manuales porque la tabla usa IDENTITY.
   ============================================================ */

;WITH data_evaluaciones AS (
    SELECT *
    FROM (VALUES
        ('SOL-2024-0001', 6200.00,   850.00,   13.71, 'normal',     1, 812, 'bajo',  '2024-01-14', 'Cliente con ingresos estables y buen comportamiento historico.'),
        ('SOL-2024-0002', 4800.00,   1200.00,  25.00, 'normal',     1, 735, 'medio', '2024-01-22', 'Actividad independiente verificada con movimientos bancarios.'),
        ('SOL-2024-0003', 3900.00,   600.00,   15.38, 'normal',     0, 760, 'bajo',  '2024-01-26', 'Credito digital aprobado por score y capacidad de pago.'),
        ('SOL-2024-0004', 8500.00,   1850.00,  21.76, 'normal',     1, 798, 'bajo',  '2024-02-09', 'Garantia hipotecaria y documentacion completa.'),
        ('SOL-2024-0005', 2800.00,   900.00,   32.14, 'cpp',        2, 640, 'medio', '2024-02-10', 'Pendiente validacion laboral y sustento adicional de ingresos.'),
        ('SOL-2024-0006', 7200.00,   1600.00,  22.22, 'normal',     1, 790, 'bajo',  '2024-02-16', 'Cliente con planilla recurrente y buena experiencia crediticia.'),
        ('SOL-2024-0007', 3500.00,   2100.00,  60.00, 'deficiente', 3, 410, 'alto',  '2024-02-22', 'Endeudamiento alto y atrasos recientes en otra entidad.'),
        ('SOL-2024-0008', 7800.00,   1400.00,  17.95, 'normal',     1, 805, 'bajo',  '2024-03-04', 'Capacidad suficiente para cuota educativa.'),
        ('SOL-2024-0009', 5600.00,   1550.00,  27.68, 'normal',     2, 710, 'medio', '2024-03-07', 'Ingresos variables sustentados con ventas mensuales.'),
        ('SOL-2024-0011', 9100.00,   2600.00,  28.57, 'normal',     2, 748, 'medio', '2024-03-19', 'Vehiculo con cuota dentro del rango permitido.'),
        ('SOL-2024-0013', 2600.00,   500.00,   19.23, 'normal',     0, 700, 'medio', '2024-03-29', 'Monto bajo con riesgo controlado.'),
        ('SOL-2024-0014', 4100.00,   900.00,   21.95, 'normal',     1, 755, 'bajo',  '2024-04-04', 'Buen score digital y estabilidad laboral.'),
        ('SOL-2024-0015', 6700.00,   4100.00,  61.19, 'cpp',        4, 455, 'alto',  '2024-04-11', 'Nivel de endeudamiento superior a politica vigente.'),
        ('SOL-2024-0016', 9800.00,   1900.00,  19.39, 'normal',     1, 830, 'bajo',  '2024-04-17', 'Cliente preferente con ingresos verificados.'),
        ('SOL-2024-0017', 2800.00,   350.00,   12.50, 'normal',     0, 720, 'medio', '2024-04-21', 'Credito de bajo monto aprobado por canal digital.'),
        ('SOL-2024-0018', 11500.00,  3800.00,  33.04, 'cpp',        3, 660, 'medio', '2024-04-26', 'Evaluacion pendiente por deuda reportada en central externa.'),
        ('SOL-2024-0019', 5200.00,   1000.00,  19.23, 'normal',     1, 770, 'bajo',  '2024-05-05', 'Capacidad de pago adecuada para financiamiento educativo.'),
        ('SOL-2024-0020', 3100.00,   1800.00,  58.06, 'deficiente', 2, 430, 'alto',  '2024-05-08', 'Ingresos insuficientes frente a obligaciones actuales.'),
        ('SOL-2024-0021', 154166.67, 22000.00, 14.27, 'normal',     2, 780, 'bajo',  '2024-01-24', 'Ventas constantes y buena rotacion de inventario.'),
        ('SOL-2024-0022', 285000.00, 98000.00, 34.39, 'cpp',        4, 675, 'medio', '2024-02-02', 'Cuenta con contratos vigentes y deuda de flota controlada.'),
        ('SOL-2024-0023', 106666.67, 18000.00, 16.88, 'normal',     1, 760, 'bajo',  '2024-02-11', 'Campana agricola sustentada con contratos de venta.'),
        ('SOL-2024-0024', 180000.00, 42000.00, 23.33, 'normal',     2, 745, 'medio', '2024-02-15', 'Flujo operativo suficiente para linea revolvente.'),
        ('SOL-2024-0025', 498333.33, 210000.00,42.14, 'cpp',        5, 620, 'medio', '2024-02-24', 'Evaluacion pendiente por tasacion de garantia.'),
        ('SOL-2024-0026', 204166.67, 36000.00, 17.63, 'normal',     2, 790, 'bajo',  '2024-03-06', 'Buen movimiento de cuenta empresarial.'),
        ('SOL-2024-0027', 80000.00,  9500.00,  11.88, 'normal',     1, 805, 'bajo',  '2024-03-10', 'Campana comercial con historial de ventas favorable.'),
        ('SOL-2024-0028', 143333.33, 38000.00, 26.51, 'normal',     2, 755, 'medio', '2024-03-21', 'Empresa con ingresos en dolares y contratos activos.'),
        ('SOL-2024-0029', 111666.67, 72000.00, 64.48, 'deficiente', 4, 440, 'alto',  '2024-03-24', 'Flujo de caja insuficiente para la cuota proyectada.'),
        ('SOL-2024-0031', 98333.33,  24000.00, 24.41, 'normal',     2, 735, 'medio', '2024-04-09', 'Compra de activo fijo sustentada con cotizacion.'),
        ('SOL-2024-0032', 354166.67, 128000.00,36.14, 'cpp',        4, 665, 'medio', '2024-04-16', 'Deuda relevante, pero con contratos de transporte vigentes.'),
        ('SOL-2024-0033', 57500.00,  39000.00, 67.83, 'dudoso',     5, 380, 'alto',  '2024-04-21', 'Empresa suspendida en validacion interna.'),
        ('SOL-2024-0034', 71666.67,  12000.00, 16.74, 'normal',     1, 750, 'medio', '2024-04-28', 'Negocio educativo con ingresos recurrentes.'),
        ('SOL-2024-0036', 6200.00,   900.00,   14.52, 'normal',     1, 785, 'bajo',  '2024-05-09', 'Evaluacion en moneda extranjera pendiente de validacion de ingresos USD.'),
        ('SOL-2024-0037', 4800.00,   1000.00,  20.83, 'normal',     1, 725, 'medio', '2024-05-11', 'Solicitud de bajo monto con comportamiento aceptable.'),
        ('SOL-2024-0038', 3900.00,   2400.00,  61.54, 'deficiente', 3, 405, 'alto',  '2024-05-14', 'Atrasos recientes en otra entidad.'),
        ('SOL-2024-0040', 2800.00,   650.00,   23.21, 'normal',     1, 710, 'medio', '2024-05-18', 'Financiamiento educativo viable por monto moderado.'),
        ('SOL-2024-0041', 7200.00,   1800.00,  25.00, 'normal',     1, 765, 'bajo',  '2024-05-22', 'Unidad vehicular dentro de capacidad de pago.'),
        ('SOL-2024-0042', 3500.00,   1500.00,  42.86, 'cpp',        2, 610, 'medio', '2024-05-21', 'Requiere validacion adicional de ingresos independientes.'),
        ('SOL-2024-0043', 7800.00,   1700.00,  21.79, 'normal',     1, 800, 'bajo',  '2024-05-25', 'Cliente con perfil preferente.'),
        ('SOL-2024-0044', 5600.00,   1900.00,  33.93, 'cpp',        2, 655, 'medio', '2024-05-28', 'Ingreso independiente validado parcialmente.'),
        ('SOL-2024-0046', 9100.00,   2500.00,  27.47, 'normal',     2, 760, 'medio', '2024-05-30', 'Capacidad de pago aceptable para convenio.'),
        ('SOL-2024-0048', 2600.00,   700.00,   26.92, 'normal',     1, 690, 'medio', '2024-06-05', 'Monto moderado aprobado con seguimiento.'),
        ('SOL-2024-0049', 4100.00,   950.00,   23.17, 'normal',     1, 740, 'medio', '2024-06-09', 'Credito educativo sustentado con constancia.'),
        ('SOL-2024-0050', 6700.00,   3900.00,  58.21, 'deficiente', 3, 430, 'alto',  '2024-06-08', 'Capacidad de pago insuficiente.'),
        ('SOL-2024-0051', 9800.00,   2200.00,  22.45, 'normal',     1, 835, 'bajo',  '2024-06-13', 'Cliente con ingresos altos y buen historial.'),
        ('SOL-2024-0052', 2800.00,   300.00,   10.71, 'normal',     0, 705, 'medio', '2024-06-12', 'Solicitud de consumo de bajo importe.'),
        ('SOL-2024-0053', 11500.00,  3600.00,  31.30, 'cpp',        2, 670, 'medio', '2024-06-14', 'Pendiente validacion de inicial y documentacion vehicular.'),
        ('SOL-2024-0054', 5200.00,   950.00,   18.27, 'normal',     1, 775, 'bajo',  '2024-06-17', 'Buen comportamiento crediticio.'),
        ('SOL-2024-0056', 154166.67, 24000.00, 15.57, 'normal',     2, 795, 'bajo',  '2024-06-23', 'Campana comercial con flujo historico favorable.'),
        ('SOL-2024-0057', 285000.00, 112000.00,39.30, 'cpp',        4, 650, 'medio', '2024-06-22', 'Evaluacion en curso por exposicion en moneda extranjera.'),
        ('SOL-2024-0058', 106666.67, 25000.00, 23.44, 'normal',     2, 755, 'medio', '2024-06-27', 'Capital de trabajo sustentado con ventas.'),
        ('SOL-2024-0059', 180000.00, 39000.00, 21.67, 'normal',     2, 770, 'bajo',  '2024-06-28', 'Linea revolvente aprobable por rotacion de caja.'),
        ('SOL-2024-0060', 498333.33, 250000.00,50.17, 'cpp',        5, 520, 'alto',  '2024-07-01', 'Garantia propuesta no cubre politica minima.'),
        ('SOL-2024-0061', 204166.67, 42000.00, 20.57, 'normal',     2, 785, 'bajo',  '2024-07-03', 'Empresa con flujo operativo saludable.'),
        ('SOL-2024-0063', 143333.33, 44000.00, 30.70, 'normal',     2, 735, 'medio', '2024-07-08', 'Activo fijo respaldado por garantia.'),
        ('SOL-2024-0064', 111666.67, 26000.00, 23.28, 'normal',     2, 748, 'medio', '2024-07-09', 'Solicitud aprobable con monitoreo de ventas.')
    ) AS e (
        nro_solicitud,
        ingresos_verificados,
        deuda_activa,
        nivel_endeudamiento,
        historial_crediticio,
        creditos_activos,
        score_crediticio,
        nivel_riesgo,
        fecha_evaluacion,
        observaciones
    )
)
INSERT INTO evaluaciones_riesgo
    (id_solicitud, ingresos_verificados, deuda_activa, nivel_endeudamiento,
     historial_crediticio, creditos_activos, score_crediticio, nivel_riesgo,
     fecha_evaluacion, observaciones)
SELECT
    s.id AS id_solicitud,
    de.ingresos_verificados,
    de.deuda_activa,
    de.nivel_endeudamiento,
    de.historial_crediticio,
    de.creditos_activos,
    de.score_crediticio,
    de.nivel_riesgo,
    de.fecha_evaluacion,
    de.observaciones
FROM data_evaluaciones de
INNER JOIN solicitudes s
    ON s.nro_solicitud = de.nro_solicitud
WHERE NOT EXISTS (
    SELECT 1
    FROM evaluaciones_riesgo er
    WHERE er.id_solicitud = s.id
);
GO

SELECT
    nivel_riesgo,
    historial_crediticio,
    COUNT(*) AS cantidad
FROM evaluaciones_riesgo
GROUP BY nivel_riesgo, historial_crediticio
ORDER BY nivel_riesgo, historial_crediticio;

SELECT COUNT(*) AS total_evaluaciones
FROM evaluaciones_riesgo;
GO