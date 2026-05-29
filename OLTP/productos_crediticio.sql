USE bd_riesgo_crediticio;
GO

/* ============================================================
   6. PRODUCTOS CREDITICIOS
   Data de prueba para productos personales, consumo, vehiculares,
   hipotecarios y negocio.
   ============================================================ */

INSERT INTO productos_crediticios
    (nombre, descripcion, tipo, tasa_interes_min, tasa_interes_max,
     monto_min, monto_max, plazo_minimo_meses, plazo_maximo_meses,
     moneda, requiere_garantia, estado)
VALUES
('Prestamo Personal Libre Disponibilidad',
 'Credito para gastos personales con evaluacion de ingresos.',
 'personal', 0.1450, 0.2890, 1000.00, 50000.00, 6, 60, 'PEN', 0, 'activo'),
('Prestamo Personal Preferente',
 'Credito personal para clientes con buen historial y abono de sueldo.',
 'personal', 0.1190, 0.2150, 5000.00, 90000.00, 12, 72, 'PEN', 0, 'activo'),
('Prestamo Personal Convenio',
 'Credito para trabajadores de empresas con convenio de planilla.',
 'personal', 0.0990, 0.1890, 3000.00, 80000.00, 6, 60, 'PEN', 0, 'activo'),
('Consumo Digital',
 'Credito de bajo monto aprobado por canal digital.',
 'consumo', 0.1990, 0.3990, 500.00, 15000.00, 3, 36, 'PEN', 0, 'activo'),
('Compra de Electrodomesticos',
 'Financiamiento para consumo en comercios afiliados.',
 'consumo', 0.2490, 0.4490, 300.00, 12000.00, 3, 24, 'PEN', 0, 'activo'),
('Credito Educativo',
 'Financiamiento para estudios tecnicos, universitarios o posgrado.',
 'consumo', 0.1290, 0.2450, 2000.00, 60000.00, 6, 72, 'PEN', 0, 'activo'),
('Credito Vehicular Nuevo',
 'Financiamiento para compra de vehiculo nuevo.',
 'vehicular', 0.0950, 0.1650, 15000.00, 220000.00, 12, 72, 'PEN', 1, 'activo'),
('Credito Vehicular Seminuevo',
 'Financiamiento para compra de vehiculo seminuevo.',
 'vehicular', 0.1150, 0.1890, 10000.00, 150000.00, 12, 60, 'PEN', 1, 'activo'),
('Credito Taxi',
 'Financiamiento vehicular para unidad de trabajo.',
 'vehicular', 0.1350, 0.2250, 12000.00, 90000.00, 12, 60, 'PEN', 1, 'activo'),
('Credito Hipotecario Vivienda',
 'Financiamiento para compra de primera o segunda vivienda.',
 'hipotecario', 0.0790, 0.1290, 50000.00, 900000.00, 60, 300, 'PEN', 1, 'activo'),
('Credito Hipotecario MiVivienda',
 'Financiamiento hipotecario orientado a vivienda familiar.',
 'hipotecario', 0.0690, 0.1150, 60000.00, 650000.00, 60, 300, 'PEN', 1, 'activo'),
('Compra de Terreno',
 'Credito hipotecario para compra de terreno urbano.',
 'hipotecario', 0.0950, 0.1450, 40000.00, 500000.00, 36, 180, 'PEN', 1, 'activo'),
('Capital de Trabajo Pyme',
 'Credito para compra de inventario y liquidez operativa.',
 'negocio', 0.1250, 0.2450, 5000.00, 250000.00, 6, 48, 'PEN', 0, 'activo'),
('Activo Fijo Pyme',
 'Financiamiento para maquinaria, equipos o adecuacion de local.',
 'negocio', 0.1150, 0.2150, 10000.00, 400000.00, 12, 72, 'PEN', 1, 'activo'),
('Linea Revolvente Negocio',
 'Linea de credito para necesidades recurrentes de caja.',
 'negocio', 0.1450, 0.2850, 3000.00, 120000.00, 3, 24, 'PEN', 0, 'activo'),
('Credito Campana Comercial',
 'Credito temporal para campanas de alta demanda.',
 'negocio', 0.1590, 0.2990, 2000.00, 80000.00, 3, 18, 'PEN', 0, 'activo'),
('Credito Agropecuario',
 'Financiamiento para siembra, cosecha, insumos o maquinaria agricola.',
 'negocio', 0.1050, 0.2050, 5000.00, 300000.00, 6, 60, 'PEN', 1, 'activo'),
('Prestamo Personal USD',
 'Credito personal desembolsado en dolares para clientes calificados.',
 'personal', 0.0850, 0.1650, 1000.00, 40000.00, 6, 48, 'USD', 0, 'activo'),
('Credito Empresarial USD',
 'Financiamiento para empresas con ingresos en dolares.',
 'negocio', 0.0750, 0.1550, 5000.00, 200000.00, 6, 48, 'USD', 1, 'activo'),
('Credito Consumo Promocional',
 'Producto de consumo en etapa de implementacion comercial.',
 'consumo', 0.1890, 0.3290, 500.00, 10000.00, 3, 24, 'PEN', 0, 'implementandose');
GO

SELECT
    tipo,
    estado,
    COUNT(*) AS cantidad
FROM productos_crediticios
GROUP BY tipo, estado
ORDER BY tipo, estado;
GO