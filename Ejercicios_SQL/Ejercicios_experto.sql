USE pdan_bd_sistema_riesgo_crediticio;
Go
/*
===========================================================
EJERCICIOS NIVEL EXPERTO
BASE DE DATOS: SISTEMA DE RIESGO CREDITICIO
===========================================================

Objetivo:
Aplicar consultas anal�ticas, indicadores financieros,
riesgo crediticio, funciones de agregaci�n, CTE,
subconsultas y funciones ventana.

===========================================================
EJERCICIO 1
===========================================================

Construir un score crediticio simplificado:

score_final =
(score_riesgo * 0.5)
+
((ingresos_mensuales / 1000) * 0.3)
-
(nivel_endeudamiento * 0.2)

Clasificar el resultado en:

- Bajo Riesgo
- Riesgo Medio
- Alto Riesgo
*/

;WITH scores AS
(
SELECT 
id, solicitud_id,score_riesgo, ingresos_mensuales, nivel_endeudamiento,
(score_riesgo * 0.5)+((ingresos_mensuales / 1000) * 0.3)-(nivel_endeudamiento * 0.2) AS 'Score_final'
FROM evaluaciones_crediticias
)
SELECT sc.*,
CASE 
WHEN Score_final<200 THEN 'Alto Riesgo'
WHEN Score_final<400 THEN 'Riesgo Medio'
ELSE 'Riesgo Bajo' END AS 'clasificacion'
FROM solicitudes s
INNER JOIN scores sc ON sc.solicitud_id=s.id;




/*
===========================================================
EJERCICIO 2
===========================================================

Calcular la tasa de aprobaci�n de solicitudes.

Formula:

(Aprobadas / Total Solicitudes) * 100

Mostrar:

- Total solicitudes
- Total aprobadas
- Porcentaje de aprobaci�n

*/

SELECT
    COUNT(*) AS total_solicitudes,
    SUM(CASE WHEN estado = 'aprobado' THEN 1 ELSE 0 END) AS total_aprobadas,
    ROUND(
        SUM(CASE WHEN estado = 'aprobado' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2
    ) AS porcentaje_aprobacion
FROM solicitudes;

/*
===========================================================
EJERCICIO 3
===========================================================

Calcular el ratio de morosidad.

Formula:

(Cuotas Pendientes / Total Cuotas) * 100

Mostrar:

- Total cuotas
- Cuotas pendientes
- Ratio de morosidad */

SELECT
    COUNT(*) AS total_cuotas,
    SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) AS cuotas_pendientes,
    ROUND(
        SUM(CASE WHEN estado = 'pendiente' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2
    ) AS ratio_morosidad
FROM cuotas;

/*
===========================================================
EJERCICIO 4
===========================================================

Identificar clientes de alto riesgo.

Condiciones:

- Score de riesgo menor a 500
- Nivel de endeudamiento mayor a 70
- Deuda activa en otras entidades mayor a 20,000

Mostrar:

- Cliente
- Score
- Nivel endeudamiento
- Deuda externa

*/
SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    ec.score_riesgo,
    ec.nivel_endeudamiento,
    ec.deuda_activa_otras_entidades AS deuda_externa
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
WHERE ec.score_riesgo < 500
  AND ec.nivel_endeudamiento > 70
  AND ec.deuda_activa_otras_entidades > 20000
ORDER BY ec.score_riesgo ASC;



/*===========================================================
EJERCICIO 5
===========================================================

Construir un ranking de exposici�n crediticia.

Formula:

Exposici�n =
Saldo Cr�dito
+
Deuda Activa
+
Deuda Activa Otras Entidades

Ordenar de mayor a menor.
*/

SELECT
    RANK() OVER (ORDER BY (cr.saldo_credito + ec.deuda_activa + ec.deuda_activa_otras_entidades) DESC) AS ranking,
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    cr.saldo_credito,
    ec.deuda_activa,
    ec.deuda_activa_otras_entidades AS deuda_externa,
    cr.saldo_credito + ec.deuda_activa + ec.deuda_activa_otras_entidades AS exposicion_total
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
ORDER BY exposicion_total DESC;

/*
===========================================================
EJERCICIO 6
===========================================================

Detectar clientes con se�ales tempranas de incumplimiento.

Condiciones:

- M�s de 3 cuotas pendientes
- Score de riesgo menor a 600

Mostrar:

- Cliente
- N�mero de cuotas pendientes
- Score de riesgo
*/
SELECT 
c.id,
c.tipo_cliente,
COUNT(ct.id) AS 'num_cuotas',
ec.score_riesgo
FROM clientes c
	INNER JOIN solicitudes s ON s.cliente_id=c.id
	INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id=s.id
	INNER JOIN creditos cr ON cr.evaluacion_crediticia_id=ec.id
	INNER JOIN cuotas ct ON ct.credito_id=cr.id
WHERE ct.estado='pendiente' AND ec.score_riesgo<600 
GROUP BY c.id, c.tipo_cliente, ec.score_riesgo
HAVING COUNT(ct.id)>3


SELECT DISTINCT estado FROM cuotas

/*
===========================================================
EJERCICIO 7
===========================================================

Calcular el ingreso mensual recomendado.

Formula:

Ingreso Recomendado =
Total Cuotas Activas * 3

Mostrar:

- Cliente
- Cuotas activas
- Ingreso recomendado
*/

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    SUM(cu.total_cuota) AS cuotas_activas_total,
    SUM(cu.total_cuota) * 3 AS ingreso_recomendado
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
INNER JOIN cuotas cu ON cu.credito_id = cr.id
WHERE cu.estado = 'pendiente'
GROUP BY cl.id, pn.nombres, pn.apellido_paterno, pj.razon_social
ORDER BY ingreso_recomendado DESC;

/*===========================================================
EJERCICIO 8
===========================================================

Calcular la concentraci�n de cartera por producto.

Formula:

(Monto Producto / Total Cartera) * 100

Mostrar:

- Producto
- Total desembolsado
- Participaci�n % */

;WITH cartera AS (
    SELECT SUM(cr.monto) AS total_cartera
    FROM creditos cr
)
SELECT
    pc.nombre AS producto,
    SUM(cr.monto) AS total_desembolsado,
    ROUND(SUM(cr.monto) / ca.total_cartera * 100, 2) AS participacion_pct
FROM productos_crediticios pc
INNER JOIN solicitudes s ON s.producto_crediticio_id = pc.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
CROSS JOIN cartera ca
GROUP BY pc.id, pc.nombre, ca.total_cartera
ORDER BY participacion_pct DESC;


/*===========================================================
EJERCICIO 9
===========================================================

Calcular el porcentaje de utilizaci�n de l�nea.

Formula:

(Deuda Activa / L�nea Cr�dito) * 100

Mostrar:

- Cliente
- L�nea de cr�dito
- Deuda activa
- Utilizaci�n % */

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    ec.linea_credito,
    ec.deuda_activa,
    ROUND(ec.deuda_activa / NULLIF(ec.linea_credito, 0) * 100, 2) AS utilizacion_pct
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
ORDER BY utilizacion_pct DESC;


/*===========================================================
EJERCICIO 10
===========================================================

Detectar clientes potencialmente sobreendeudados.

Formula:

(Deuda Total / Ingresos Mensuales)

Considerar:

Deuda Total =
Deuda Activa
+
Deuda Activa Otras Entidades

Mostrar �nicamente clientes cuyo ratio sea mayor a 0.50 */

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    ec.deuda_activa + ec.deuda_activa_otras_entidades AS deuda_total,
    ec.ingresos_mensuales,
    ROUND(
        (ec.deuda_activa + ec.deuda_activa_otras_entidades)
        / NULLIF(ec.ingresos_mensuales, 0), 2
    ) AS ratio_endeudamiento
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
WHERE (ec.deuda_activa + ec.deuda_activa_otras_entidades)
      / NULLIF(ec.ingresos_mensuales, 0) > 0.50
ORDER BY ratio_endeudamiento DESC;

/*===========================================================
EJERCICIO 11
===========================================================

Construir un ranking de empresas por exposici�n financiera.

Considerar solamente personas jur�dicas.

Ordenar por:

- Saldo cr�dito
- Deuda activa
- Deuda externa */

SELECT
    RANK() OVER (ORDER BY (cr.saldo_credito + ec.deuda_activa + ec.deuda_activa_otras_entidades) DESC) AS ranking,
    pj.razon_social,
    pj.tipo_empresa,
    cr.saldo_credito,
    ec.deuda_activa,
    ec.deuda_activa_otras_entidades AS deuda_externa,
    cr.saldo_credito + ec.deuda_activa + ec.deuda_activa_otras_entidades AS exposicion_total
FROM personas_juridicas pj
INNER JOIN clientes cl ON cl.id = pj.cliente_id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
ORDER BY exposicion_total DESC;

/*===========================================================
EJERCICIO 12
===========================================================

Encontrar clientes que tienen cuentas bancarias
pero nunca han solicitado cr�ditos.

Mostrar:

- Cliente
- N�mero de cuentas*/

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    COUNT(cc.cuenta_id) AS numero_cuentas
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN cuentas_clientes cc ON cc.cliente_id = cl.id
WHERE cl.id NOT IN (SELECT DISTINCT cliente_id FROM solicitudes)
GROUP BY cl.id, pn.nombres, pn.apellido_paterno, pj.razon_social
ORDER BY numero_cuentas DESC;

/*===========================================================
EJERCICIO 13
===========================================================

Encontrar clientes que poseen cr�ditos
pero no registran ning�n pago.

Mostrar:

- Cliente
- N�mero de cr�dito
- Monto del cr�dito */

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    cr.numero_credito,
    cr.monto AS monto_credito
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
WHERE cr.id NOT IN (
    SELECT DISTINCT cu.credito_id
    FROM cuotas cu
    INNER JOIN detalle_cuotas_pagos dcp ON dcp.cuota_id = cu.id
)
ORDER BY cr.monto DESC;

/*===========================================================
EJERCICIO 14
===========================================================

Detectar anomal�as crediticias.

Regla:

Monto Cr�dito > Valor Patrimonio

Mostrar:

- Cliente
- Patrimonio
- Monto cr�dito */

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    ec.valor_patrimonio AS patrimonio,
    cr.monto AS monto_credito,
    cr.monto - ec.valor_patrimonio AS anomalias_crediticias
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
INNER JOIN creditos cr ON cr.evaluacion_crediticia_id = ec.id
WHERE cr.monto > ec.valor_patrimonio
ORDER BY anomalias_crediticias DESC;

/*===========================================================
EJERCICIO 15
===========================================================

Identificar clientes con patrimonio comprometido.

Formula:

Patrimonio Neto Simulado =
Valor Patrimonio
-
(Deuda Activa + Deuda Externa)

Mostrar los clientes cuyo patrimonio neto
sea negativo.*/

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    ec.valor_patrimonio,
    ec.deuda_activa + ec.deuda_activa_otras_entidades AS deuda_total,
    ec.valor_patrimonio - (ec.deuda_activa + ec.deuda_activa_otras_entidades) AS patrimonio_neto_simulado
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
WHERE ec.valor_patrimonio - (ec.deuda_activa + ec.deuda_activa_otras_entidades) < 0
ORDER BY patrimonio_neto_simulado ASC;

/*===========================================================
EJERCICIO 16
===========================================================

Construir un Dashboard General utilizando
una �nica consulta.

Indicadores requeridos:

- Total Clientes
- Total Solicitudes
- Total Cr�ditos
- Total Desembolsado
- Total Pagos
- Total Cuotas
- Ratio Morosidad */

SELECT
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(*) FROM solicitudes) AS total_solicitudes,
    (SELECT COUNT(*) FROM creditos) AS total_creditos,
    (SELECT SUM(monto) FROM creditos) AS total_desembolsado,
    (SELECT COUNT(*) FROM pagos) AS total_pagos,
    (SELECT COUNT(*) FROM cuotas) AS total_cuotas,
    ROUND(
        (SELECT COUNT(*) * 1.0 FROM cuotas WHERE estado = 'pendiente')
        / NULLIF((SELECT COUNT(*) FROM cuotas), 0) * 100, 2
    ) AS ratio_morosidad;

/*===========================================================
EJERCICIO 17
===========================================================

Analizar la tendencia mensual de solicitudes.

Mostrar:

- A�o
- Mes
- Cantidad solicitudes

Ordenar cronol�gicamente. */
SELECT
    YEAR(fecha_solicitud) AS year,
    MONTH(fecha_solicitud) AS mes,
    DATENAME(MONTH, fecha_solicitud) AS nombre_mes,
    COUNT(*) AS cantidad_solicitudes
FROM solicitudes
GROUP BY YEAR(fecha_solicitud), MONTH(fecha_solicitud), DATENAME(MONTH, fecha_solicitud)
ORDER BY year ASC, mes ASC;

/*===========================================================
EJERCICIO 18
===========================================================

Determinar el mes con mayor desembolso.

Mostrar:

- A�o
- Mes
- Total desembolsado

Ordenar de mayor a menor.*/

SELECT
    YEAR(fecha_desembolso) AS year,
    MONTH(fecha_desembolso) AS mes,
    SUM(monto) AS total_desembolsado
FROM creditos
GROUP BY YEAR(fecha_desembolso), MONTH(fecha_desembolso), DATENAME(MONTH, fecha_desembolso)
ORDER BY total_desembolsado DESC;

/*===========================================================
EJERCICIO 19
===========================================================

Proyectar ingresos futuros por intereses.

Considerar �nicamente:

- Cuotas pendientes
- Cuotas parcialmente pagadas

Mostrar:

- Cr�dito
- Intereses pendientes
- Total proyectado */

SELECT
    cr.id AS credito_id,
    cr.numero_credito,
    SUM(cu.intereses) AS intereses_pendientes,
    SUM(cu.saldo_cuota) AS total_proyectado
FROM creditos cr
INNER JOIN cuotas cu ON cu.credito_id = cr.id
WHERE cu.estado IN ('pendiente', 'pagada parcialmente')
GROUP BY cr.id, cr.numero_credito
ORDER BY total_proyectado DESC;

/*===========================================================
EJERCICIO 20
===========================================================

Construir un Sem�foro Crediticio.

Reglas:

Verde:
Score > 700

Amarillo:
Score entre 500 y 700

Rojo:
Score < 500

Mostrar:

- Cliente
- Score
- Sem�foro */

SELECT
    cl.id AS cliente_id,
    COALESCE(pn.nombres + ' ' + pn.apellido_paterno, pj.razon_social) AS cliente,
    ec.score_riesgo,
    CASE
        WHEN ec.score_riesgo > 700 THEN 'Verde'
        WHEN ec.score_riesgo BETWEEN 500 AND 700 THEN 'Amarillo'
        ELSE 'Rojo'
    END AS semaforo
FROM clientes cl
LEFT JOIN personas_naturales pn ON pn.cliente_id = cl.id
LEFT JOIN personas_juridicas pj ON pj.cliente_id = cl.id
INNER JOIN solicitudes s ON s.cliente_id = cl.id
INNER JOIN evaluaciones_crediticias ec ON ec.solicitud_id = s.id
ORDER BY ec.score_riesgo DESC;
