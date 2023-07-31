
*****************************************************************
*****************************************************************
/******* consultas para revisar datos de manera rapida   ******/
*****************************************************************
*****************************************************************

/***  EMERCADO: expedientes CERRADO con tareas abiertas *****/
select empresa,numero_expediente, TIPO_EXPEDIENTE 
from crmexpedientes_cab where empresa = '004' and TIPO_EXPEDIENTE='04003' AND FECHA_ALTA >TO_DATE('01/01/2021', 'DD/MM/YYYY') AND STATUS_EXPEDIENTE='99'

select NUMERO_EXPEDIENTE,CODIGO_SECUENCIA, count(numero_expediente) nro_tareas
  from crmexpedientes_lin where empresa='004' AND STATUS_TAREA='01' AND NUMERO_EXPEDIENTE IN (select numero_expediente 
from crmexpedientes_cab where empresa = '004' AND FECHA_ALTA >TO_DATE('01/01/2021', 'DD/MM/YYYY') AND STATUS_EXPEDIENTE='99')
  group by NUMERO_EXPEDIENTE, CODIGO_SECUENCIA
  /***************/


Azure DevOps Services: https://azure.microsoft.com

/* MUESTRA TAREAS REPETIDAS ABIERTA*/
select numero_expediente, CODIGO_SECUENCIA, count(numero_expediente) nro_tareas
  from crmexpedientes_lin where empresa='004' AND STATUS_TAREA='01'
  group by numero_expediente, CODIGO_SECUENCIA
  HAVING count(numero_expediente)>=2


/*** REVISAR FACTURA */
SELECT fecha_factura, CLIENTE, IMP_FAC_BRUTO,IMPORTE_FAC_NETO, DTOS_GLOBAL,IMP_DTO_GLOBAL,LIQUIDO_FACTURA,IMPORTE_FAC_NETO_div
FROM FACTURAS_VENTAS
WHERE EMPRESA='004' AND EJERCICIO=2020 AND NUMERO_SERIE='111' AND NUMERO_FACTURA=2095


/**** query para revision de bpm 04003 */
SELECT distinct cod_empresa, NUMERO_EXPEDIENTE, NUMERO_LINEA, CODIGO_SECUENCIA, EQUIPO_A_REALIZARLO, usuario_a_realizarlo FROM (select crmexpedientes_lin.*, (select c.codigo_empresa from crmexpedientes_cab c where c.empresa= crmexpedientes_lin.empresa and crmexpedientes_lin.numero_expediente=c.numero_expediente) cod_empresa from crmexpedientes_lin) crmexpedientes_lin
WHERE EMPRESA='004' AND STATUS_TAREA='01' and codigo_secuencia in ('030','031','040','050','060','070','075') and numero_expediente in (Select numero_expediente from crmexpedientes_cab 	where FECHA_INICIO >=trunc(current_date,'MONTH') and empresa='004' and tipo_expediente='04003' and status_expediente='01') GROUP BY cod_empresa, NUMERO_EXPEDIENTE, NUMERO_LINEA, CODIGO_SECUENCIA,EQUIPO_A_REALIZARLO, usuario_a_realizarlo

SELECT CODIGO_SECUENCIA, EQUIPO_A_REALIZARLO, usuario_a_realizarlo, COUNT(NUMERO_EXPEDIENTE) TTL FROM crmexpedientes_lin
WHERE EMPRESA='004' AND STATUS_TAREA='01' and codigo_secuencia in ('030','031','040','050','060','070','075') and numero_expediente in (Select numero_expediente from crmexpedientes_cab 	where FECHA_INICIO >=trunc(current_date,'MONTH') and empresa='004' and tipo_expediente='04003' and status_expediente='01') GROUP BY  CODIGO_SECUENCIA,EQUIPO_A_REALIZARLO, usuario_a_realizarlo

/**** *****/

SELECT CODIGO_SECUENCIA,NUMERO_EXPEDIENTE, EQUIPO_A_REALIZARLO, usuario_a_realizarlo, COUNT(NUMERO_EXPEDIENTE) TTL FROM crmexpedientes_lin
WHERE EMPRESA='004' AND STATUS_TAREA='01' and codigo_secuencia in ('065') and numero_expediente in (Select numero_expediente from crmexpedientes_cab 	where FECHA_INICIO >=trunc(current_date,'MONTH') and empresa='004' and tipo_expediente='04003' and status_expediente='01') GROUP BY  CODIGO_SECUENCIA,EQUIPO_A_REALIZARLO, usuario_a_realizarlo
