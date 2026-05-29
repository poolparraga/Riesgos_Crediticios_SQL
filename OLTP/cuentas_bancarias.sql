USE bd_riesgo_crediticio;
GO

/* ============================================================
   4. TIPOS DE CUENTA
   ============================================================ */


INSERT INTO tipos_cuenta
(nombre,descripcion)
VALUES
('Ahorros','Cuenta de ahorro para personas naturales'),
('Corriente','Cuenta para operaciones frecuentes'),
('Sueldo','Cuenta para depósitos de planilla'),
('Cuenta CTS','Cuenta de compensación por tiempo de servicio'),
('Cuenta Empresarial','Cuenta para empresas'),
('Cuenta Premium','Cuenta para clientes preferentes');
GO

/* ============================================================
   5. CUENTAS BANCARIAS
   100 cuentas distribuidas entre los 35 clientes

   Regla usada:
   - Clientes 1 al 20: personas naturales
   - Clientes 21 al 35: personas juridicas
   - Cada cliente tiene entre 2 y 3 cuentas aproximadamente
   ============================================================ */
     
;WITH numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numeros
    WHERE n < 100
),
datos AS (
    SELECT
        n,
        ((n - 1) % 35) + 1 AS id_cliente,
        CASE
            WHEN ((n - 1) % 35) + 1 <= 20 AND n % 17 = 0 THEN 'Cuenta Premium'
            WHEN ((n - 1) % 35) + 1 <= 20 AND n % 11 = 0 THEN 'Cuenta CTS'
            WHEN ((n - 1) % 35) + 1 <= 20 AND n % 5 = 0 THEN 'Sueldo'
            WHEN ((n - 1) % 35) + 1 <= 20 THEN 'Ahorros'
            WHEN n % 19 = 0 THEN 'Cuenta Premium'
            WHEN n % 4 = 0 THEN 'Corriente'
            ELSE 'Cuenta Empresarial'
        END AS tipo_cuenta,
        CASE
            WHEN n % 13 = 0 THEN 'USD'
            WHEN n % 29 = 0 THEN 'EUR'
            ELSE 'PEN'
        END AS moneda,
        CASE
            WHEN n % 31 = 0 THEN 'bloqueada'
            WHEN n % 47 = 0 THEN 'cerrada'
            WHEN n % 53 = 0 THEN 'embargada'
            ELSE 'activa'
        END AS estado,
        DATEADD(DAY, n * 3, CONVERT(DATE, '2023-01-01')) AS fecha_apertura,
        RIGHT('00000000000000000000' + CAST(100000000000000000 + n AS VARCHAR(20)), 18) AS nro_cuenta,
        RIGHT('00000000000000000000' + CAST(200000000000000000 + n AS VARCHAR(20)), 20) AS cci
    FROM numeros
)
INSERT INTO cuentas_bancarias
    (tipo_cuenta_id, id_cliente, nro_cuenta, cci, moneda, saldo_actual,
     fecha_apertura, fecha_vencimiento, estado)
SELECT
    tc.id AS tipo_cuenta_id,
    d.id_cliente,
    d.nro_cuenta,
    d.cci,
    d.moneda,
    CASE
        WHEN d.estado = 'cerrada' THEN 0.00
        WHEN d.id_cliente <= 20 THEN
            CAST(250.00 + (d.n * 137.65) % 28500 AS DECIMAL(14,2))
        ELSE
            CAST(5000.00 + (d.n * 2847.35) % 480000 AS DECIMAL(14,2))
    END AS saldo_actual,
    d.fecha_apertura,
    NULL AS fecha_vencimiento,
    d.estado
FROM datos d
INNER JOIN tipos_cuenta tc
    ON tc.nombre = d.tipo_cuenta
WHERE NOT EXISTS (
    SELECT 1
    FROM cuentas_bancarias cb
    WHERE cb.nro_cuenta = d.nro_cuenta
)
OPTION (MAXRECURSION 100);
GO

SELECT
    tc.nombre AS tipo_cuenta,
    COUNT(*) AS cantidad
FROM cuentas_bancarias cb
INNER JOIN tipos_cuenta tc
    ON tc.id = cb.tipo_cuenta_id
GROUP BY tc.nombre
ORDER BY tc.nombre;

SELECT
    COUNT(*) AS total_cuentas,
    COUNT(DISTINCT id_cliente) AS clientes_con_cuenta
FROM cuentas_bancarias;
GO
