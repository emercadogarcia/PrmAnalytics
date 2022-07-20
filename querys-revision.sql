
*****************************************************************
*****************************************************************
/******* consultas para revisar datos de manera rapida   ******/
*****************************************************************
*****************************************************************

/***  EMERCADO: expedientes CERRADO con tareas abiertas *****/
elect empresa,numero_expediente, TIPO_EXPEDIENTE 
from crmexpedientes_cab where empresa = '004' and TIPO_EXPEDIENTE='04003' AND FECHA_ALTA >TO_DATE('01/01/2021', 'DD/MM/YYYY') AND STATUS_EXPEDIENTE='99'

select NUMERO_EXPEDIENTE,CODIGO_SECUENCIA, count(numero_expediente) nro_tareas
  from crmexpedientes_lin where empresa='004' AND STATUS_TAREA='01' AND NUMERO_EXPEDIENTE IN (select numero_expediente 
from crmexpedientes_cab where empresa = '004' AND FECHA_ALTA >TO_DATE('01/01/2021', 'DD/MM/YYYY') AND STATUS_EXPEDIENTE='99')
  group by NUMERO_EXPEDIENTE, CODIGO_SECUENCIA
  /***************/