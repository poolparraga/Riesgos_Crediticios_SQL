# Riesgos_Crediticios_SQL
# Sistema de Análisis de Riesgo Crediticio para una Entidad Bancaria
1. Contexto del negocio

El banco FinanRisk Perú es una entidad financiera que ofrece productos crediticios a personas naturales y pequeñas empresas. Entre sus principales productos se encuentran los préstamos personales, créditos vehiculares, créditos hipotecarios y líneas de crédito para negocios.

En los últimos años, el banco ha incrementado la cantidad de créditos otorgados. Sin embargo, también ha detectado un aumento en la cantidad de clientes que pagan fuera de fecha o que dejan de pagar sus cuotas.

Actualmente, la información de los clientes, solicitudes, créditos y pagos se encuentra registrada en diferentes archivos y sistemas. Esto dificulta que el área de riesgos pueda analizar correctamente el comportamiento de pago de los clientes y detectar posibles casos de morosidad.

Por este motivo, el banco necesita diseñar una base de datos que permita organizar la información del proceso crediticio y apoyar la toma de decisiones.

2. Objetivo del sistema

Diseñar una base de datos relacional que permita registrar y analizar la información de clientes, productos crediticios, solicitudes de crédito, evaluaciones de riesgo, créditos otorgados, cuotas, pagos y alertas de mora.

El sistema deberá ayudar al banco a conocer qué clientes tienen mayor riesgo de incumplimiento y qué créditos presentan problemas de pago.

3. Alcance funcional del sistema

El sistema debe contemplar las siguientes áreas principales:

A. Gestión de clientes

El banco registra información de sus clientes. Los clientes pueden ser:

Personas naturales.
Personas jurídicas.

Para una persona natural, se desea registrar:

DNI.
Nombres.
Apellidos.
Fecha de nacimiento.
Estado civil.
Situación laboral.
Ingresos mensuales.
Teléfono.
Correo electrónico.
Dirección.

Para una persona jurídica, se desea registrar:

RUC.
Razón social.
Sector económico.
Fecha de constitución.
Ingresos anuales.
Teléfono.
Correo electrónico.
Dirección fiscal.

Cada cliente puede realizar varias solicitudes de crédito y puede tener uno o más créditos activos.

B. Productos crediticios

El banco ofrece diferentes productos de crédito, tales como:

Préstamo personal.
Crédito vehicular.
Crédito hipotecario.
Línea de crédito para negocios.

Para cada producto crediticio se debe registrar:

Nombre del producto.
Descripción.
Tasa de interés.
Monto mínimo.
Monto máximo.
Plazo máximo.
Estado del producto.
C. Solicitudes de crédito

Antes de recibir un crédito, el cliente debe presentar una solicitud.

Cada solicitud debe registrar:

Fecha de solicitud.
Cliente solicitante.
Producto solicitado.
Monto solicitado.
Plazo solicitado.
Finalidad del crédito.
Estado de la solicitud.

Los estados posibles de una solicitud son:

En evaluación.
Aprobada.
Rechazada.

Una solicitud pertenece a un solo cliente, pero un cliente puede realizar varias solicitudes.

D. Evaluación de riesgo

Cada solicitud de crédito debe ser evaluada por el banco antes de ser aprobada o rechazada.

La evaluación considera información como:

Ingresos del cliente.
Nivel de endeudamiento.
Historial de pagos.
Cantidad de créditos activos.
Score crediticio.
Nivel de riesgo.

El nivel de riesgo puede ser:

Bajo.
Medio.
Alto.

El score crediticio se calcula para cada solicitud. Esto significa que un mismo cliente puede tener diferentes evaluaciones de riesgo en distintos momentos.

E. Créditos otorgados

Cuando una solicitud es aprobada, se genera un crédito.

Para cada crédito se debe registrar:

Cliente.
Solicitud aprobada.
Producto crediticio.
Fecha de aprobación.
Fecha de desembolso.
Monto aprobado.
Tasa de interés aplicada.
Número de cuotas.
Saldo pendiente.
Estado del crédito.

Los estados posibles de un crédito son:

Vigente.
Cancelado.
Vencido.

Cada crédito pertenece a un solo cliente, pero un cliente puede tener varios créditos.

F. Cronograma de cuotas

Cada crédito otorgado genera un cronograma de pagos.

Para cada cuota se debe registrar:

Número de cuota.
Fecha de vencimiento.
Monto de la cuota.
Monto pagado.
Estado de la cuota.
Días de atraso.

Los estados posibles de una cuota son:

Pendiente.
Pagada.
Vencida.
Pagada parcialmente.

Una cuota pertenece a un solo crédito, pero un crédito tiene muchas cuotas.

G. Pagos

El cliente puede realizar pagos para cancelar sus cuotas.

Para cada pago se debe registrar:

Fecha de pago.
Monto pagado.
Medio de pago.
Cuota asociada.
Estado del pago.

Los medios de pago pueden ser:

Ventanilla.
Transferencia.
Aplicativo móvil.
Agente bancario.

Una cuota puede pagarse en una sola operación o mediante varios pagos parciales.

H. Seguimiento de mora y alertas

El sistema debe permitir identificar clientes que presentan retrasos en sus pagos.

Se debe poder registrar alertas cuando ocurra alguna de estas situaciones:

El cliente tiene una cuota vencida.
El cliente tiene más de 30 días de atraso.
El cliente tiene varias cuotas pendientes.
El cliente tiene un crédito vencido.
El cliente fue clasificado como alto riesgo.

Para cada alerta se debe registrar:

Cliente asociado.
Crédito asociado.
Fecha de alerta.
Tipo de alerta.
Descripción.
Nivel de severidad.
Estado de la alerta.

Los niveles de severidad pueden ser:

Baja.
Media.
Alta.
4. Reglas de negocio clave

Los estudiantes deberán considerar las siguientes reglas de negocio:

Un cliente puede ser persona natural o persona jurídica.
Un cliente puede realizar muchas solicitudes de crédito.
Una solicitud pertenece a un solo cliente.
Una solicitud está asociada a un solo producto crediticio.
Cada solicitud debe tener una evaluación de riesgo.
Una solicitud aprobada puede generar un crédito.
Una solicitud rechazada no genera crédito.
Un crédito pertenece a un solo cliente.
Un cliente puede tener varios créditos.
Un crédito proviene de una sola solicitud aprobada.
Cada crédito genera varias cuotas.
Cada cuota pertenece a un solo crédito.
Una cuota puede ser pagada total o parcialmente.
Un pago pertenece a una cuota.
Una cuota puede tener varios pagos.
Una cuota se considera vencida si no fue pagada hasta su fecha de vencimiento.
El score de riesgo se calcula en cada solicitud.
Un cliente puede tener varias alertas de riesgo.
Una alerta puede estar asociada a un cliente y a un crédito.
Los estados de solicitud, crédito y cuota deben controlarse de forma ordenada.
5. Entidades candidatas del modelo

A partir del caso, los estudiantes podrían identificar las siguientes entidades:

Entidad	Descripción
Cliente	Registra la información general del cliente.
PersonaNatural	Registra datos específicos de clientes naturales.
PersonaJuridica	Registra datos específicos de empresas.
ProductoCrediticio	Registra los productos de crédito del banco.
SolicitudCredito	Registra las solicitudes realizadas por los clientes.
EvaluacionRiesgo	Registra el score y nivel de riesgo de cada solicitud.
Credito	Registra los créditos aprobados y desembolsados.
Cuota	Registra el cronograma de pagos del crédito.
Pago	Registra los pagos realizados por los clientes.
AlertaRiesgo	Registra alertas por mora o riesgo crediticio.
MedioPago	Catálogo de medios de pago.
EstadoSolicitud	Catálogo de estados de solicitud.
EstadoCredito	Catálogo de estados del crédito.
EstadoCuota	Catálogo de estados de la cuota.
NivelRiesgo	Catálogo de niveles de riesgo.
6. Preguntas de negocio que debe responder la base de datos

La base de datos debe permitir responder preguntas como:

¿Cuántos clientes tiene el banco?
¿Cuántos clientes son personas naturales y cuántos son personas jurídicas?
¿Cuántas solicitudes de crédito se registraron por mes?
¿Cuántas solicitudes fueron aprobadas?
¿Cuántas solicitudes fueron rechazadas?
¿Qué producto crediticio es el más solicitado?
¿Qué clientes tienen créditos vigentes?
¿Qué clientes tienen créditos vencidos?
¿Qué clientes tienen cuotas vencidas?
¿Cuánto debe actualmente cada cliente?
¿Qué clientes tienen mayor número de días de atraso?
¿Qué créditos presentan más cuotas vencidas?
¿Cuál es el monto total pendiente de pago?
¿Cuál es el monto total pagado por los clientes?
¿Qué clientes fueron clasificados como alto riesgo?
¿Qué productos tienen mayor cantidad de créditos vencidos?
¿Cuántas alertas de riesgo se generaron por mes?
¿Qué clientes tienen alertas activas?
¿Cuál es el porcentaje de créditos vencidos?
¿Cuál es la evolución mensual de la morosidad?
7. Indicadores sugeridos

Los alumnos podrán construir consultas SQL para calcular indicadores como:

Indicador	Descripción
Total de clientes	Cantidad de clientes registrados.
Total de solicitudes	Cantidad total de solicitudes de crédito.
Tasa de aprobación	Solicitudes aprobadas / total de solicitudes.
Tasa de rechazo	Solicitudes rechazadas / total de solicitudes.
Total de créditos otorgados	Cantidad de créditos generados.
Monto total aprobado	Suma de montos aprobados.
Saldo pendiente total	Monto que aún falta pagar.
Total de cuotas vencidas	Cantidad de cuotas no pagadas a tiempo.
Días promedio de atraso	Promedio de días de mora.
Clientes de alto riesgo	Clientes clasificados con nivel de riesgo alto.
Créditos vencidos	Créditos con pagos atrasados.
Alertas activas	Alertas pendientes de atención.
Tasa de morosidad	Créditos vencidos / total de créditos.
