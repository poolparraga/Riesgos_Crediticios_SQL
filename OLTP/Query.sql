--- ============================================================
---  FINANRISK PERU - Sistema de Analisis de Riesgo Crediticio
---  Base de datos: SQL Server
--- ============================================================

CREATE DATABASE bd_riesgo_crediticio;
GO

USE bd_riesgo_crediticio;
GO

--- ============================================================
---  1. CLIENTES
--- ============================================================

CREATE TABLE clientes (
    id              INT             IDENTITY(1,1) PRIMARY KEY,
    tipo_cliente    VARCHAR(1)      NOT NULL,
    estado_cliente  VARCHAR(20)     NOT NULL,
);

--- ============================================================
---  2. PERSONAS NATURALES
--- ============================================================

CREATE TABLE personas_naturales (
    id                  INT             IDENTITY(1,1) PRIMARY KEY,
    id_cliente          INT             UNIQUE NOT NULL,
    dni                 VARCHAR(8)      UNIQUE NOT NULL,
    nombres             VARCHAR(100)    NOT NULL,
    apellido_paterno    VARCHAR(100)    NOT NULL,
    apellido_materno    VARCHAR(100)    NOT NULL,
    fecha_nacimiento    DATE            NOT NULL,
    genero              VARCHAR(1)      NOT NULL,
    estado_civil        VARCHAR(10)     NOT NULL,
    situacion_laboral   VARCHAR(20)     NOT NULL,
    ocupacion           VARCHAR(100)    NULL,
    ingresos_mensuales  DECIMAL(12,2)   NOT NULL,
    telefono            VARCHAR(15)     NULL,
    email               VARCHAR(100)    NULL,
    direccion           VARCHAR(255)    NULL,
    ubigeo              CHAR(6)         NULL,
    CONSTRAINT fk_pn_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

--- ============================================================
---  3. PERSONAS JURIDICAS
--- ============================================================

CREATE TABLE personas_juridicas (
    id                  INT             IDENTITY(1,1) PRIMARY KEY,
    id_cliente          INT             UNIQUE NOT NULL,
    ruc                 CHAR(11)        UNIQUE NOT NULL,
    razon_social        VARCHAR(255)    NOT NULL,
    nombre_comercial    VARCHAR(255)    NULL,
    representante_legal VARCHAR(200)    NOT NULL,
    tipo_empresa        VARCHAR(10)     NOT NULL,
    sector_economico    VARCHAR(100)    NULL,
    direccion_fiscal    VARCHAR(255)    NOT NULL,
    ubigeo_fiscal       CHAR(6)         NULL,
    telefono            VARCHAR(20)     NULL,
    email               VARCHAR(100)    NULL,
    fecha_constitucion  DATE            NOT NULL,
    inicio_actividades  DATE            NOT NULL,
    estado_empresa      VARCHAR(20)     NOT NULL,
    ingresos_anuales    DECIMAL(15,2)   NOT NULL,
    CONSTRAINT fk_pj_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

--- ============================================================
---  4. TIPOS DE CUENTA
--- ============================================================

CREATE TABLE tipos_cuenta (
    id          INT             IDENTITY(1,1) PRIMARY KEY,
    nombre      VARCHAR(50)     UNIQUE NOT NULL,
    descripcion VARCHAR(255)    NULL
);

--- ============================================================
---  5. CUENTAS BANCARIAS
--- ============================================================

CREATE TABLE cuentas_bancarias (
    id                INT             IDENTITY(1,1) PRIMARY KEY,
    tipo_cuenta_id    INT             NOT NULL,
    id_cliente        INT             NOT NULL,
    nro_cuenta        VARCHAR(20)     UNIQUE NOT NULL,
    cci               VARCHAR(20)     UNIQUE NOT NULL,
    moneda            VARCHAR(5)      NOT NULL,
    saldo_actual      DECIMAL(14,2)   NOT NULL    DEFAULT 0,
    fecha_apertura    DATE            NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    fecha_vencimiento DATE            NULL,
    estado            VARCHAR(15)     NOT NULL    DEFAULT 'activa',
    CONSTRAINT fk_cuentas_tipo    FOREIGN KEY (tipo_cuenta_id) REFERENCES tipos_cuenta(id),
    CONSTRAINT fk_cuentas_cliente FOREIGN KEY (id_cliente)     REFERENCES clientes(id)
);

--- ============================================================
---  6. PRODUCTOS CREDITICIOS
--- ============================================================

CREATE TABLE productos_crediticios (
    id                      INT             IDENTITY(1,1) PRIMARY KEY,
    nombre                  VARCHAR(100)    UNIQUE NOT NULL,
    descripcion             VARCHAR(500)    NULL,
    tipo                    VARCHAR(20)     NOT NULL,
    tasa_interes_min        DECIMAL(6,4)    NOT NULL,
    tasa_interes_max        DECIMAL(6,4)    NOT NULL,
    monto_min               DECIMAL(12,2)   NOT NULL,
    monto_max               DECIMAL(12,2)   NOT NULL,
    plazo_minimo_meses      INT             NOT NULL,
    plazo_maximo_meses      INT             NOT NULL,
    moneda                  VARCHAR(5)      NOT NULL    DEFAULT 'PEN',
    requiere_garantia       BIT             NOT NULL    DEFAULT 0,
    estado                  VARCHAR(20)     NOT NULL    DEFAULT 'activo',
    created_at              DATETIME        NOT NULL    DEFAULT GETDATE(),
    updated_at              DATETIME        NOT NULL    DEFAULT GETDATE(),
    deleted_at              DATETIME        NULL
);

--- ============================================================
---  7. SOLICITUDES
--- ============================================================

CREATE TABLE solicitudes (
    id                      INT             IDENTITY(1,1) PRIMARY KEY,
    id_cliente              INT             NOT NULL,
    id_producto             INT             NOT NULL,
    nro_solicitud           VARCHAR(20)     UNIQUE NOT NULL,
    fecha_solicitud         DATE            NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    monto_solicitado        DECIMAL(12,2)   NOT NULL,
    moneda_solicitada       VARCHAR(5)      NOT NULL    DEFAULT 'PEN',
    plazo_solicitado_meses  INT             NOT NULL,
    estado                  VARCHAR(20)     NOT NULL    DEFAULT 'ingresado',
    fecha_resolucion        DATE            NULL,
    motivo_rechazo          VARCHAR(500)    NULL,
    CONSTRAINT fk_solicitudes_cliente   FOREIGN KEY (id_cliente)  REFERENCES clientes(id),
    CONSTRAINT fk_solicitudes_producto  FOREIGN KEY (id_producto) REFERENCES productos_crediticios(id),
    CONSTRAINT chk_monto_solicitado     CHECK (monto_solicitado > 0),
    CONSTRAINT chk_plazo_solicitado     CHECK (plazo_solicitado_meses > 0)
);

--- ============================================================
---  8. EVALUACIONES DE RIESGO
--- ============================================================

CREATE TABLE evaluaciones_riesgo (
    id                      INT             IDENTITY(1,1) PRIMARY KEY,
    id_solicitud            INT             UNIQUE NOT NULL,
    ingresos_verificados    DECIMAL(12,2)   NOT NULL,
    deuda_activa            DECIMAL(12,2)   NOT NULL    DEFAULT 0,
    nivel_endeudamiento     DECIMAL(5,2)    NOT NULL    DEFAULT 0,
    historial_crediticio    VARCHAR(20)     NOT NULL,
    creditos_activos        INT             NOT NULL    DEFAULT 0,
    score_crediticio        SMALLINT        NOT NULL,
    nivel_riesgo            VARCHAR(10)     NOT NULL,
    fecha_evaluacion        DATE            NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    observaciones           VARCHAR(MAX)    NULL,
    CONSTRAINT fk_evaluaciones_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitudes(id)
);

--- ============================================================
---  9. CREDITOS
--- ============================================================

CREATE TABLE creditos (
    id                      INT             IDENTITY(1,1) PRIMARY KEY,
    id_solicitud            INT             UNIQUE NOT NULL,
    id_producto             INT             NOT NULL,
    id_cuenta_desembolso    INT             NULL,
    nro_credito             VARCHAR(20)     UNIQUE NOT NULL,
    monto_aprobado          DECIMAL(12,2)   NOT NULL,
    moneda                  VARCHAR(5)      NOT NULL    DEFAULT 'PEN',
    plazo_meses             INT             NOT NULL,
    tea                     DECIMAL(6,4)    NOT NULL,
    tcea                    DECIMAL(6,4)    NOT NULL,
    valor_cuota             DECIMAL(12,2)   NOT NULL,
    desgravamen             DECIMAL(12,2)   NOT NULL    DEFAULT 0,
    fecha_inicio            DATE            NOT NULL,
    fecha_vencimiento       DATE            NOT NULL,
    fecha_aprobacion        DATE            NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    fecha_desembolso        DATETIME        NOT NULL,
    nro_cuotas              INT             NOT NULL,
    estado                  VARCHAR(20)     NOT NULL    DEFAULT 'desembolsado',

    CONSTRAINT fk_creditos_solicitud    FOREIGN KEY (id_solicitud)         REFERENCES solicitudes(id),
    CONSTRAINT fk_creditos_producto     FOREIGN KEY (id_producto)          REFERENCES productos_crediticios(id),
    CONSTRAINT fk_creditos_cuenta       FOREIGN KEY (id_cuenta_desembolso) REFERENCES cuentas_bancarias(id),
    CONSTRAINT chk_creditos_monto       CHECK (monto_aprobado > 0),
    CONSTRAINT chk_creditos_plazo       CHECK (plazo_meses > 0),
    CONSTRAINT chk_creditos_fechas      CHECK (fecha_vencimiento > fecha_inicio)
);

--- ============================================================
---  10. CRONOGRAMA DE CUOTAS
--- ============================================================

CREATE TABLE cronograma_cuotas (
    id                  INT             IDENTITY(1,1) PRIMARY KEY,
    id_credito          INT             NOT NULL,
    num_cuota           INT             NOT NULL,
    fecha_vencimiento   DATE            NOT NULL,
    capital             DECIMAL(12,2)   NOT NULL,
    intereses           DECIMAL(12,2)   NOT NULL    DEFAULT 0,
    seguros             DECIMAL(12,2)   NOT NULL    DEFAULT 0,
    total_cuota         DECIMAL(12,2)   NOT NULL,
    saldo_pendiente     DECIMAL(12,2)   NOT NULL,
    tasa_mora           DECIMAL(6,4)    NOT NULL    DEFAULT 0,
    dias_atraso         INT             NOT NULL    DEFAULT 0,
    estado              VARCHAR(25)     NOT NULL    DEFAULT 'pendiente',

    CONSTRAINT fk_cuotas_credito        FOREIGN KEY (id_credito)  REFERENCES creditos(id),
    CONSTRAINT uq_credito_num_cuota     UNIQUE (id_credito, num_cuota),
    CONSTRAINT chk_total_cuota          CHECK (total_cuota = capital + intereses + seguros),
    CONSTRAINT chk_saldo_cuota          CHECK (saldo_pendiente <= total_cuota),
    CONSTRAINT chk_cuotas_monto         CHECK (capital > 0 AND intereses >= 0 AND seguros >= 0)
);

--- ============================================================
---  11. MEDIOS DE PAGO
--- ============================================================

CREATE TABLE medios_pago (
    id          INT             IDENTITY(1,1) PRIMARY KEY,
    nombre      VARCHAR(50)     UNIQUE NOT NULL,
    descripcion VARCHAR(255)    NULL,
);

--- ============================================================
---  12. PAGOS
--- ============================================================

CREATE TABLE pagos (
    id              INT             IDENTITY(1,1) PRIMARY KEY,
    id_medio_pago   INT             NOT NULL,
    nro_operacion   VARCHAR(20)     UNIQUE NOT NULL,
    fecha_pago      DATETIME        NOT NULL    DEFAULT GETDATE(),
    monto    DECIMAL(12,2)   NOT NULL,
    moneda          VARCHAR(5)      NOT NULL    DEFAULT 'PEN',
    observaciones   VARCHAR(200)    NULL,
    estado          VARCHAR(15)     NOT NULL    DEFAULT 'procesado',
    CONSTRAINT fk_pagos_medio   FOREIGN KEY (id_medio_pago) REFERENCES medios_pago(id),
    CONSTRAINT chk_pagos_monto  CHECK (monto > 0)
);

--- ============================================================
---  13. DETALLE CUOTAS PAGOS  (N:M entre cuotas y pagos)
--- ============================================================

CREATE TABLE detalle_cuotas_pagos (
    id              INT             IDENTITY(1,1) PRIMARY KEY,
    id_cuota        INT             NOT NULL,
    id_pago         INT             NOT NULL,
    monto_pagado    DECIMAL(12,2)   NOT NULL    DEFAULT 0,
    CONSTRAINT fk_detalle_cuota         FOREIGN KEY (id_cuota) REFERENCES cronograma_cuotas(id),   -- [CORREGIDO] cuotas → cronograma_cuotas
    CONSTRAINT fk_detalle_pago          FOREIGN KEY (id_pago)  REFERENCES pagos(id),
    CONSTRAINT uq_detalle_cuota_pago    UNIQUE (id_cuota, id_pago),
    CONSTRAINT chk_detalle_monto        CHECK (monto_pagado > 0)
);

--- ============================================================
---  14. ALERTAS MORA
--- ============================================================

CREATE TABLE alertas_mora (
    id              INT             IDENTITY(1,1) PRIMARY KEY,
    id_cliente      INT             NOT NULL,
    id_credito      INT             NOT NULL,
    id_cuota        INT             NULL,
    tipo_alerta     VARCHAR(30)     NOT NULL,
    fecha_alerta    DATE            NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    dias_atraso     INT             NOT NULL    DEFAULT 0,
    descripcion     VARCHAR(500)    NULL,
    nivel_severidad VARCHAR(10)     NOT NULL,
    estado          VARCHAR(15)     NOT NULL    DEFAULT 'activa',
    CONSTRAINT fk_alertas_cliente   FOREIGN KEY (id_cliente) REFERENCES clientes(id),
    CONSTRAINT fk_alertas_credito   FOREIGN KEY (id_credito) REFERENCES creditos(id),
    CONSTRAINT fk_alertas_cuota     FOREIGN KEY (id_cuota)   REFERENCES cronograma_cuotas(id)      -- [CORREGIDO] cuotas → cronograma_cuotas
);

--- ============================================================
---  CHECK CONSTRAINTS (ALTER TABLE)
--- ============================================================

--- clientes
ALTER TABLE clientes
ADD CHECK (tipo_cliente IN ('N', 'J'));

ALTER TABLE clientes
ADD CHECK (estado_cliente IN ('activo', 'inactivo', 'bloqueado', 'baja'));

--- personas_naturales
ALTER TABLE personas_naturales
ADD CHECK (genero IN ('M', 'F'));

ALTER TABLE personas_naturales
ADD CHECK (estado_civil IN ('S', 'C', 'D', 'V'));

ALTER TABLE personas_naturales
ADD CHECK (situacion_laboral IN ('empleado', 'independiente', 'desempleado', 'jubilado'));

ALTER TABLE personas_naturales
ADD CHECK (ingresos_mensuales >= 0);

--- personas_juridicas
ALTER TABLE personas_juridicas
ADD CHECK (tipo_empresa IN ('SA', 'SAC', 'SRL', 'EIRL', 'SAA'));

ALTER TABLE personas_juridicas
ADD CHECK (estado_empresa IN ('activo', 'inactivo', 'suspendido', 'en liquidacion'));

ALTER TABLE personas_juridicas
ADD CHECK (ingresos_anuales >= 0);

--- cuentas
ALTER TABLE cuentas_bancarias
ADD CHECK (moneda IN ('PEN', 'USD', 'EUR'));

ALTER TABLE cuentas_bancarias
ADD CHECK (saldo_actual >= 0);

ALTER TABLE cuentas_bancarias
ADD CHECK (estado IN ('activa', 'bloqueada', 'cerrada', 'embargada'));

--- productos_crediticios
ALTER TABLE productos_crediticios
ADD CHECK (estado IN ('activo', 'inactivo', 'implementandose'));

ALTER TABLE productos_crediticios
ADD CHECK (tipo IN ('personal', 'vehicular', 'hipotecario', 'negocio', 'consumo'));

ALTER TABLE productos_crediticios
ADD CHECK (tasa_interes_min > 0 AND tasa_interes_max >= tasa_interes_min);

ALTER TABLE productos_crediticios
ADD CHECK (monto_min > 0 AND monto_max >= monto_min);

ALTER TABLE productos_crediticios
ADD CHECK (plazo_minimo_meses > 0 AND plazo_maximo_meses >= plazo_minimo_meses);

--- solicitudes
ALTER TABLE solicitudes
ADD CHECK (estado IN ('ingresado', 'en evaluacion', 'aprobada', 'desestimado', 'desistida'));

ALTER TABLE solicitudes
ADD CHECK (moneda_solicitada IN ('PEN', 'USD', 'EUR'));

--- evaluaciones_riesgo
ALTER TABLE evaluaciones_riesgo
ADD CHECK (historial_crediticio IN ('normal', 'cpp', 'deficiente', 'dudoso', 'perdida'));

ALTER TABLE evaluaciones_riesgo
ADD CHECK (nivel_riesgo IN ('bajo', 'medio', 'alto'));

ALTER TABLE evaluaciones_riesgo
ADD CHECK (score_crediticio BETWEEN 0 AND 999);

ALTER TABLE evaluaciones_riesgo
ADD CHECK (nivel_endeudamiento BETWEEN 0 AND 100);

--- creditos
ALTER TABLE creditos
ADD CHECK (estado IN ('desembolsado', 'vigente', 'cancelado', 'refinanciado', 'judicial', 'castigado'));

ALTER TABLE creditos
ADD CHECK (moneda IN ('PEN', 'USD'));

ALTER TABLE creditos
ADD CHECK (tea > 0 AND tcea >= tea);

--- cronograma_cuotas
ALTER TABLE cronograma_cuotas
ADD CHECK (estado IN ('pendiente', 'pagada', 'pagada parcialmente', 'vencida', 'refinanciada', 'condonada'));

ALTER TABLE cronograma_cuotas
ADD CHECK (dias_atraso >= 0);

--- pagos
ALTER TABLE pagos
ADD CHECK (moneda IN ('PEN', 'USD', 'EUR'));

ALTER TABLE pagos
ADD CHECK (estado IN ('procesado', 'anulado', 'reversado', 'pendiente'));

--- alertas_mora
ALTER TABLE alertas_mora
ADD CHECK (tipo_alerta IN ('cuota_vencida', 'mora_30d', 'mora_60d', 'mora_90d', 'credito_vencido', 'alto_riesgo', 'multiples_cuotas'));

ALTER TABLE alertas_mora
ADD CHECK (nivel_severidad IN ('baja', 'media', 'alta', 'critica'));

ALTER TABLE alertas_mora
ADD CHECK (estado IN ('activa', 'gestionada', 'cerrada'));

ALTER TABLE alertas_mora
ADD CHECK (dias_atraso >= 0);
