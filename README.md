# Riesgos_Crediticios_SQL
# Sistema de Análisis de Riesgo Crediticio para una Entidad Bancaria

## 1. Contexto del negocio

El banco **FinanRisk Perú** es una entidad financiera que ofrece productos crediticios a personas naturales y pequeñas empresas. Entre sus principales productos se encuentran préstamos personales, créditos vehiculares, créditos hipotecarios y líneas de crédito para negocios.

En los últimos años, el banco ha incrementado la cantidad de créditos otorgados. Sin embargo, también ha detectado un aumento en los clientes que pagan fuera de fecha o que presentan cuotas vencidas. Esta situación afecta la rentabilidad del banco y aumenta el riesgo de pérdida por incumplimiento de pago.

Actualmente, la información de los clientes, solicitudes, créditos, cuotas y pagos se encuentra distribuida en diferentes archivos y sistemas internos. Esto dificulta conocer el comportamiento real de pago de los clientes y detectar oportunamente a aquellos que podrían representar un mayor riesgo crediticio.

Por ello, el banco necesita diseñar una base de datos que permita centralizar la información del proceso crediticio y apoyar el análisis de riesgo.

---

## 2. Objetivo del sistema

Diseñar una base de datos relacional que permita registrar, organizar y analizar la información relacionada con clientes, productos crediticios, solicitudes de crédito, evaluaciones de riesgo, créditos otorgados, cuotas, pagos y alertas de mora.

El sistema deberá permitir identificar clientes con alto riesgo, controlar créditos vencidos y generar información útil para la toma de decisiones del área de riesgos.

---

## 3. Alcance funcional

El sistema deberá contemplar las siguientes áreas:

---

## A. Gestión de clientes

El banco registra información de sus clientes, quienes pueden ser:

- Personas naturales.
- Personas jurídicas.

Para las **personas naturales**, se debe registrar:

- DNI.
- Nombres.
- Apellidos.
- Fecha de nacimiento.
- Estado civil.
- Situación laboral.
- Ingresos mensuales.
- Teléfono.
- Correo electrónico.
- Dirección.

Para las **personas jurídicas**, se debe registrar:

- RUC.
- Razón social.
- Sector económico.
- Fecha de constitución.
- Ingresos anuales.
- Teléfono.
- Correo electrónico.
- Dirección fiscal.

Un cliente puede realizar varias solicitudes de crédito y puede tener uno o más créditos activos.
El banco registra las cuentas bancarias asociadas a sus clientes, las cuales pueden ser utilizadas para el desembolso de créditos y el pago de cuotas.

Un cliente puede tener una o varias cuentas bancarias activas dentro del banco.

Para cada cuenta bancaria se debe registrar:

Número de cuenta.
Tipo de cuenta.
Moneda.
Fecha de apertura.
Saldo actual.
Estado de la cuenta.

---

## B. Productos crediticios

El banco ofrece diferentes productos financieros, tales como:

- Préstamo personal.
- Crédito vehicular.
- Crédito hipotecario.
- Línea de crédito para negocios.

Para cada producto crediticio se debe registrar:

- Nombre del producto.
- Descripción.
- Tasa de interés.
- Monto mínimo.
- Monto máximo.
- Plazo máximo.
- Estado del producto.

---

## C. Solicitudes de crédito

Antes de recibir un crédito, el cliente debe presentar una solicitud.

Cada solicitud debe registrar:

- Fecha de solicitud.
- Cliente solicitante.
- Producto solicitado.
- Monto solicitado.
- Plazo solicitado.
- Finalidad del crédito.
- Estado de la solicitud.

Los estados posibles de una solicitud son:

- En evaluación.
- Aprobada.
- Rechazada.

Una solicitud pertenece a un solo cliente, pero un cliente puede realizar varias solicitudes.

---

## D. Evaluación de riesgo

Cada solicitud de crédito debe ser evaluada antes de ser aprobada o rechazada.

La evaluación considera información como:

- Ingresos del cliente.
- Nivel de endeudamiento.
- Historial crediticio.
- Comportamiento de pagos anteriores.
- Cantidad de créditos activos.
- Score crediticio.
- Nivel de riesgo.

El nivel de riesgo puede clasificarse como:

- Bajo.
- Medio.
- Alto.

El score crediticio se calcula para cada solicitud. Esto significa que un mismo cliente puede tener diferentes evaluaciones de riesgo en distintos momentos.

---

## E. Créditos otorgados

Cuando una solicitud es aprobada, se genera un crédito.

Para cada crédito se debe registrar:

- Cliente.
- Solicitud aprobada.
- Producto crediticio.
- Fecha de aprobación.
- Fecha de desembolso.
- Monto aprobado.
- Tasa de interés aplicada.
- Número de cuotas.
- Saldo pendiente.
- Estado del crédito.

Los estados posibles de un crédito son:

- Vigente.
- Cancelado.
- Vencido.

Cada crédito pertenece a un solo cliente, pero un cliente puede tener varios créditos.

---

## F. Cronograma de cuotas

Cada crédito otorgado genera un cronograma de pagos.

Para cada cuota se debe registrar:

- Número de cuota.
- Fecha de vencimiento.
- Monto de la cuota.
- Monto pagado.
- Estado de la cuota.
- Días de atraso.

Los estados posibles de una cuota son:

- Pendiente.
- Pagada.
- Vencida.
- Pagada parcialmente.

Una cuota pertenece a un solo crédito, pero un crédito tiene muchas cuotas.

---

## G. Pagos

Los clientes realizan pagos para cancelar sus cuotas.

Para cada pago se debe registrar:

- Fecha de pago.
- Monto pagado.
- Medio de pago.
- Cuota asociada.
- Estado del pago.

Los medios de pago pueden ser:

- Ventanilla.
- Transferencia bancaria.
- Aplicativo móvil.
- Agente bancario.

Una cuota puede pagarse en una sola operación o mediante varios pagos parciales.

---

## H. Seguimiento de mora y alertas

El sistema debe permitir identificar clientes con retrasos en sus pagos.

Se deben generar alertas cuando ocurra alguna de las siguientes situaciones:

- El cliente tiene una cuota vencida.
- El cliente tiene más de 30 días de atraso.
- El cliente tiene varias cuotas pendientes.
- El cliente tiene un crédito vencido.
- El cliente fue clasificado como alto riesgo.

Para cada alerta se debe registrar:

- Cliente asociado.
- Crédito asociado.
- Fecha de alerta.
- Tipo de alerta.
- Descripción.
- Nivel de severidad.
- Estado de la alerta.

Los niveles de severidad pueden ser:

- Baja.
- Media.
- Alta.

---

## 4. Reglas de negocio

1. Un cliente puede ser persona natural o persona jurídica.
2. Un cliente puede realizar muchas solicitudes de crédito.
3. Una solicitud pertenece a un solo cliente.
4. Una solicitud está asociada a un solo producto crediticio.
5. Cada solicitud debe tener una evaluación de riesgo.
6. Una solicitud aprobada puede generar un crédito.
7. Una solicitud rechazada no genera crédito.
8. Un crédito pertenece a un solo cliente.
9. Un cliente puede tener varios créditos.
10. Un crédito proviene de una sola solicitud aprobada.
11. Cada crédito genera varias cuotas.
12. Cada cuota pertenece a un solo crédito.
13. Una cuota puede ser pagada total o parcialmente.
14. Un pago pertenece a una/mas cuotas.
15. Una cuota puede tener varios pagos.
16. Una cuota se considera vencida si no fue pagada hasta su fecha de vencimiento.
17. Los días de atraso se calculan comparando la fecha de vencimiento con la fecha de pago o con la fecha actual si aún no ha sido pagada.
18. El score de riesgo se calcula en cada solicitud.

---

## 5. Entidades candidatas

A partir del caso, se pueden identificar las siguientes entidades principales:

| Entidad | Descripción |
|---|---|
| Cliente | Registra la información general del cliente. |
| PersonaNatural | Registra datos específicos de clientes naturales. |
| PersonaJuridica | Registra datos específicos de empresas. |
| ProductoCrediticio | Registra los productos de crédito ofrecidos por el banco. |
| SolicitudCredito | Registra las solicitudes de crédito realizadas por los clientes. |
| EvaluacionRiesgo | Registra el score y nivel de riesgo de cada solicitud. |
| Credito | Registra los créditos aprobados y desembolsados. |
| Cuota | Registra el cronograma de pagos de cada crédito. |
| Pago | Registra los pagos realizados por los clientes. |
| AlertaRiesgo | Registra alertas por mora o riesgo crediticio. |
| MedioPago | Catálogo de medios de pago. |
| EstadoSolicitud | Catálogo de estados de solicitud. |
| EstadoCredito | Catálogo de estados del crédito. |
| EstadoCuota | Catálogo de estados de la cuota. |
| NivelRiesgo | Catálogo de niveles de riesgo. |

---

## 6. Preguntas de negocio

La base de datos debe permitir responder preguntas como:

1. ¿Cuántos clientes tiene el banco?
2. ¿Cuántos clientes son personas naturales y cuántos son personas jurídicas?
3. ¿Cuántas solicitudes de crédito se registraron por mes?
4. ¿Cuántas solicitudes fueron aprobadas?
5. ¿Cuántas solicitudes fueron rechazadas?
6. ¿Qué producto crediticio es el más solicitado?
7. ¿Qué clientes tienen créditos vigentes?
8. ¿Qué clientes tienen créditos vencidos?
9. ¿Qué clientes tienen cuotas vencidas?
10. ¿Cuánto debe actualmente cada cliente?
11. ¿Qué clientes tienen mayor número de días de atraso?
12. ¿Qué créditos presentan más cuotas vencidas?
13. ¿Cuál es el monto total pendiente de pago?
14. ¿Cuál es el monto total pagado por los clientes?
15. ¿Qué clientes fueron clasificados como alto riesgo?
16. ¿Qué productos tienen mayor cantidad de créditos vencidos?
17. ¿Cuántas alertas de riesgo se generaron por mes?
18. ¿Qué clientes tienen alertas activas?
19. ¿Cuál es el porcentaje de créditos vencidos?
20. ¿Cuál es la evolución mensual de la morosidad?

---

## 7. Indicadores sugeridos

| Indicador | Descripción |
|---|---|
| Total de clientes | Cantidad de clientes registrados. |
| Total de solicitudes | Cantidad total de solicitudes de crédito. |
| Tasa de aprobación | Solicitudes aprobadas / total de solicitudes. |
| Tasa de rechazo | Solicitudes rechazadas / total de solicitudes. |
| Total de créditos otorgados | Cantidad de créditos generados. |
| Monto total aprobado | Suma de montos aprobados. |
| Saldo pendiente total | Monto que aún falta pagar. |
| Total de cuotas vencidas | Cantidad de cuotas no pagadas a tiempo. |
| Días promedio de atraso | Promedio de días de mora. |
| Clientes de alto riesgo | Clientes clasificados con nivel de riesgo alto. |
| Créditos vencidos | Créditos con problemas de pago. |
| Alertas activas | Alertas pendientes de atención. |
| Tasa de morosidad | Créditos vencidos / total de créditos. |

