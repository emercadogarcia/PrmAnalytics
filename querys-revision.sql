
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

