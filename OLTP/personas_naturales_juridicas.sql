USE bd_riesgo_crediticio;
GO

/* ============================================================
   2. PERSONAS NATURALES
   Requiere clientes con id 1 al 20 y tipo_cliente = 'N'
   ============================================================ */

INSERT INTO personas_naturales
    (id_cliente, dni, nombres, apellido_paterno, apellido_materno,
     fecha_nacimiento, genero, estado_civil, situacion_laboral, ocupacion,
     ingresos_mensuales, telefono, email, direccion, ubigeo)
VALUES
(1, '45871236', 'Ana Lucia', 'Torres', 'Vargas', '1988-04-18', 'F', 'C',
 'empleado', 'Analista contable', 6200.00, '987654321', 'ana.torres@example.com',
 'Av. Javier Prado 2450, San Borja', '150130'),
(2, '40125874', 'Luis Alberto', 'Quispe', 'Huaman', '1982-11-02', 'M', 'C',
 'independiente', 'Tecnico electricista', 4800.00, '996320145', 'luis.quispe@example.com',
 'Jr. Los Sauces 334, Ate', '150103'),
(3, '47223319', 'Maria Fernanda', 'Salazar', 'Rojas', '1991-08-27', 'F', 'S',
 'empleado', 'Ejecutiva comercial', 3900.00, '981112233', 'maria.salazar@example.com',
 'Calle Los Laureles 120, Miraflores', '150122'),
(4, '32987451', 'Carlos Miguel', 'Ramirez', 'Castillo', '1976-02-14', 'M', 'D',
 'empleado', 'Supervisor de operaciones', 8500.00, '999774411', 'carlos.ramirez@example.com',
 'Av. La Marina 1780, Pueblo Libre', '150121'),
(5, '28654190', 'Rosa Elena', 'Medina', 'Paredes', '1968-05-09', 'F', 'V',
 'jubilado', 'Docente jubilada', 2800.00, '945778899', 'rosa.medina@example.com',
 'Urb. Santa Patricia Mz F Lt 12, La Molina', '150114'),
(6, '51240987', 'Jorge Enrique', 'Flores', 'Navarro', '1995-12-30', 'M', 'S',
 'empleado', 'Desarrollador de software', 7200.00, '973410258', 'jorge.flores@example.com',
 'Av. El Sol 550, Santiago de Surco', '150140'),
(7, '60214578', 'Valeria', 'Mendoza', 'Caceres', '1998-07-16', 'F', 'U',
 'independiente', 'Disenadora grafica', 3500.00, '933222111', 'valeria.mendoza@example.com',
 'Calle Berlin 410, Miraflores', '150122'),
(8, '43567821', 'Patricia Isabel', 'Leon', 'Gamarra', '1985-09-05', 'F', 'C',
 'empleado', 'Jefa de recursos humanos', 7800.00, '955123987', 'patricia.leon@example.com',
 'Av. Arequipa 3650, San Isidro', '150131'),
(9, '39874562', 'Miguel Angel', 'Sanchez', 'Morales', '1979-01-23', 'M', 'C',
 'independiente', 'Comerciante minorista', 5600.00, '944556677', 'miguel.sanchez@example.com',
 'Av. Proceres 890, San Juan de Lurigancho', '150132'),
(10, '48751209', 'Claudia Maribel', 'Paredes', 'Lopez', '1990-06-12', 'F', 'S',
 'empleado', 'Enfermera', 4300.00, '966778899', 'claudia.paredes@example.com',
 'Calle Las Gardenias 215, Los Olivos', '150117'),
(11, '36549871', 'Ricardo Antonio', 'Castro', 'Diaz', '1974-10-30', 'M', 'D',
 'empleado', 'Administrador de planta', 9100.00, '977665544', 'ricardo.castro@example.com',
 'Av. Colonial 2210, Bellavista', '070102'),
(12, '52987410', 'Sofia Andrea', 'Rios', 'Alvarez', '1996-03-19', 'F', 'S',
 'empleado', 'Asistente de marketing', 3200.00, '988223344', 'sofia.rios@example.com',
 'Jr. Huallaga 545, Cercado de Lima', '150101'),
(13, '31098745', 'Hector Manuel', 'Gutierrez', 'Campos', '1965-07-08', 'M', 'C',
 'jubilado', 'Tecnico mecanico jubilado', 2600.00, '933887766', 'hector.gutierrez@example.com',
 'Av. Universitaria 1800, Comas', '150110'),
(14, '57412098', 'Daniela', 'Cruz', 'Espinoza', '1999-12-01', 'F', 'S',
 'empleado', 'Analista de datos junior', 4100.00, '922334455', 'daniela.cruz@example.com',
 'Calle Los Pinos 330, Surquillo', '150141'),
(15, '42310987', 'Oscar Javier', 'Vega', 'Salinas', '1986-05-26', 'M', 'U',
 'independiente', 'Chef propietario', 6700.00, '911223344', 'oscar.vega@example.com',
 'Av. Angamos 1540, Surquillo', '150141'),
(16, '33781254', 'Carmen Rosa', 'Navarro', 'Reyes', '1972-08-14', 'F', 'C',
 'empleado', 'Contadora senior', 9800.00, '999112233', 'carmen.navarro@example.com',
 'Av. San Luis 2010, San Borja', '150130'),
(17, '60123984', 'Bruno Sebastian', 'Herrera', 'Mori', '2000-02-17', 'M', 'S',
 'empleado', 'Soporte tecnico', 2800.00, '900123456', 'bruno.herrera@example.com',
 'Jr. Paruro 780, Cercado de Lima', '150101'),
(18, '38901276', 'Gabriela', 'Aguilar', 'Soto', '1981-04-22', 'F', 'C',
 'independiente', 'Odontologa', 11500.00, '956789012', 'gabriela.aguilar@example.com',
 'Av. Primavera 1205, Santiago de Surco', '150140'),
(19, '45609832', 'Fernando Jose', 'Luna', 'Villanueva', '1993-11-09', 'M', 'S',
 'empleado', 'Ejecutivo de ventas', 5200.00, '945678123', 'fernando.luna@example.com',
 'Av. Brasil 990, Jesus Maria', '150113'),
(20, '29876543', 'Elena Beatriz', 'Marquez', 'Chavez', '1969-09-28', 'F', 'V',
 'jubilado', 'Administradora jubilada', 3100.00, '934567890', 'elena.marquez@example.com',
 'Calle Los Cedros 145, Lince', '150116');
GO

/* ============================================================
   3. PERSONAS JURIDICAS
   Requiere clientes con id 21 al 35 y tipo_cliente = 'J'
   ============================================================ */

INSERT INTO personas_juridicas
    (id_cliente, ruc, razon_social, nombre_comercial, representante_legal,
     tipo_empresa, sector_economico, direccion_fiscal, ubigeo_fiscal, telefono,
     email, fecha_constitucion, inicio_actividades, estado_empresa, ingresos_anuales)
VALUES
(21, '20604578123', 'Inversiones Andes SAC', 'Andes Market', 'Patricia Leon Vargas',
 'SAC', 'Comercio mayorista', 'Av. Argentina 3250, Callao', '070101', '014455667',
 'contacto@andesmarket.example.com', '2016-03-11', '2016-04-01', 'activo', 1850000.00),
(22, '20599874156', 'Servicios Logisticos Pacifico SRL', 'Logipacifico', 'Rafael Benavides Soto',
 'SRL', 'Transporte y logistica', 'Av. Faucett 1400, Callao', '070101', '014201900',
 'administracion@logipacifico.example.com', '2012-09-20', '2012-10-05', 'activo', 3420000.00),
(23, '20456789012', 'Agroexportadora Norte EIRL', 'AgroNorte', 'Elmer Carranza Diaz',
 'EIRL', 'Agroindustria', 'Carretera Panamericana Norte Km 780, Chiclayo', '140101', '074612345',
 'finanzas@agronorte.example.com', '2018-01-15', '2018-02-01', 'activo', 1280000.00),
(24, '20611223344', 'Textiles Santa Rosa SAC', 'Santa Rosa Textiles', 'Mariela Campos Arias',
 'SAC', 'Manufactura textil', 'Av. Industrial 440, Ate', '150103', '013456789',
 'ventas@santarosatextiles.example.com', '2014-06-10', '2014-07-01', 'activo', 2160000.00),
(25, '20566778899', 'Constructora Horizonte SA', 'Horizonte Constructora', 'Alonso Vega Morales',
 'SA', 'Construccion', 'Av. Republica de Panama 3650, San Isidro', '150131', '014789123',
 'contacto@horizonteconstructora.example.com', '2009-02-18', '2009-03-02', 'activo', 5980000.00),
(26, '20622334455', 'Distribuidora Los Olivos SRL', 'Dilo', 'Nadia Fernandez Rojas',
 'SRL', 'Distribucion de alimentos', 'Av. Tomas Valle 910, Los Olivos', '150117', '015556677',
 'administracion@dilo.example.com', '2017-08-23', '2017-09-10', 'activo', 2450000.00),
(27, '20499887766', 'Clinica Dental Sonrisas EIRL', 'Sonrisas Dental', 'Gabriela Aguilar Soto',
 'EIRL', 'Salud', 'Av. Primavera 1210, Santiago de Surco', '150140', '016667788',
 'citas@sonrisasdental.example.com', '2015-04-12', '2015-05-01', 'activo', 960000.00),
(28, '20633445566', 'Tecnologia Aplicada del Sur SAC', 'TAS Solutions', 'Rodrigo Salazar Pinto',
 'SAC', 'Tecnologia', 'Calle Schell 350, Miraflores', '150122', '017778899',
 'comercial@tassolutions.example.com', '2019-10-05', '2019-11-01', 'activo', 1720000.00),
(29, '20544332211', 'Restaurante Sabores del Peru SAC', 'Sabores del Peru', 'Oscar Vega Salinas',
 'SAC', 'Restaurantes', 'Av. Angamos 1550, Surquillo', '150141', '018889900',
 'reservas@saboresperu.example.com', '2013-05-30', '2013-06-15', 'activo', 1340000.00),
(30, '20655667788', 'Muebles Roble Norte SRL', 'Roble Norte', 'Hector Gutierrez Campos',
 'SRL', 'Fabricacion de muebles', 'Av. Tupac Amaru 3400, Comas', '150110', '019991122',
 'ventas@roblenorte.example.com', '2011-11-18', '2011-12-05', 'inactivo', 780000.00),
(31, '20511224488', 'Consultora Financiera Prisma SAC', 'Prisma Consultores', 'Carmen Navarro Reyes',
 'SAC', 'Servicios profesionales', 'Av. Canaval y Moreyra 480, San Isidro', '150131', '014112233',
 'contacto@prismaconsultores.example.com', '2020-01-22', '2020-02-03', 'activo', 1180000.00),
(32, '20677889900', 'Transportes Virgen del Carmen SA', 'TVC Transportes', 'Miguel Sanchez Morales',
 'SA', 'Transporte terrestre', 'Av. Nicolas Ayllon 2850, Ate', '150103', '015223344',
 'operaciones@tvctransportes.example.com', '2007-07-14', '2007-08-01', 'activo', 4250000.00),
(33, '20422113344', 'Comercializadora La Union SAC', 'La Union Comercial', 'Fernando Luna Villanueva',
 'SAC', 'Comercio minorista', 'Jr. Ayacucho 620, Cercado de Lima', '150101', '016334455',
 'administracion@launioncomercial.example.com', '2016-09-09', '2016-10-01', 'suspendido', 690000.00),
(34, '20688990011', 'Servicios Educativos Horizonte EIRL', 'Academia Horizonte', 'Elena Marquez Chavez',
 'EIRL', 'Educacion', 'Av. Brasil 1120, Jesus Maria', '150113', '017445566',
 'informes@academiahorizonte.example.com', '2018-03-26', '2018-04-10', 'activo', 860000.00),
(35, '20533445577', 'Importadora Costa Azul SAA', 'Costa Azul Import', 'Ricardo Castro Diaz',
 'SAA', 'Importaciones', 'Av. Elmer Faucett 2100, Callao', '070101', '018556677',
 'gerencia@costaazulimport.example.com', '2005-12-12', '2006-01-03', 'en liquidacion', 3120000.00);
GO

SELECT COUNT(*) AS total_personas_naturales
FROM personas_naturales;

SELECT COUNT(*) AS total_personas_juridicas
FROM personas_juridicas;
GO