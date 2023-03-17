*
****************************************************************
*****************************************************************
/******* consultas para revisar datos de manera rapida   ******/
*****************************************************************
*****************************************************************

/***  EMERCADO: expedientes CERRADO con tareas abiertas *****/
select empresa, numero_expediente, TIPO_EXPEDIENTE
from crmexpedientes_cab
where empresa = '004'
  and TIPO_EXPEDIENTE = '04003'
  AND FECHA_ALTA > TO_DATE('01/01/2021', 'DD/MM/YYYY')
  AND STATUS_EXPEDIENTE = '99'

select NUMERO_EXPEDIENTE, CODIGO_SECUENCIA, count(numero_expediente) nro_tareas
from crmexpedientes_lin
where empresa = '004'
  AND STATUS_TAREA = '01'
  AND NUMERO_EXPEDIENTE IN (select numero_expediente
                            from crmexpedientes_cab
                            where empresa = '004'
                              AND FECHA_ALTA > TO_DATE('01/01/2021', 'DD/MM/YYYY')
                              AND STATUS_EXPEDIENTE = '99')
group by NUMERO_EXPEDIENTE, CODIGO_SECUENCIA
    /***************/


    Azure DevOps Services: https://azure.microsoft.com

/* MUESTRA TAREAS REPETIDAS ABIERTA*/
select numero_expediente, CODIGO_SECUENCIA, count(numero_expediente) nro_tareas
from crmexpedientes_lin
where empresa = '004'
  AND STATUS_TAREA = '01'
group by numero_expediente, CODIGO_SECUENCIA
HAVING count(numero_expediente) >= 2


/*** REVISAR FACTURA */
SELECT fecha_factura,
       CLIENTE,
       IMP_FAC_BRUTO,
       IMPORTE_FAC_NETO,
       DTOS_GLOBAL,
       IMP_DTO_GLOBAL,
       LIQUIDO_FACTURA,
       IMPORTE_FAC_NETO_div
FROM FACTURAS_VENTAS
WHERE EMPRESA = '004'
  AND EJERCICIO = 2020
  AND NUMERO_SERIE = '111'
  AND NUMERO_FACTURA = 2095



SELECT CODIGO_SECUENCIA, EQUIPO_A_REALIZARLO, usuario_a_realizarlo, COUNT(NUMERO_EXPEDIENTE) TTL
FROM crmexpedientes_lin
WHERE EMPRESA = '004'
  AND STATUS_TAREA = '01'
  and codigo_secuencia in ('030', '031', '040', '050', '060', '070', '075')
  and numero_expediente in (Select numero_expediente
                            from crmexpedientes_cab
                            where FECHA_INICIO >= trunc(current_date, 'MONTH')
                              and empresa = '004'
                              and tipo_expediente = '04003'
                              and status_expediente = '01')
GROUP BY CODIGO_SECUENCIA, EQUIPO_A_REALIZARLO, usuario_a_realizarlo



UPDATE crmexpedientes_lin
SET usuario_a_realizarlo = null,
    equipo_a_realizarlo  = CASE
                               WHEN (SELECT ce.ITEMA041
                                     FROM crmexpedientes_cab ce
                                     WHERE ce.empresa = '004'
                                       AND ce.tipo_expediente = '04003'
                                       AND ce.status_expediente = '01'
                                       AND ce.numero_expediente = numero_expediente
                                       AND ROWNUM <= 1) = '011' THEN '402005'
                               WHEN (SELECT ce.ITEMA041
                                     FROM crmexpedientes_cab ce
                                     WHERE ce.empresa = '004'
                                       AND ce.tipo_expediente = '04003'
                                       AND ce.status_expediente = '01'
                                       AND ce.numero_expediente = numero_expediente
                                       AND ROWNUM <= 1) = '010' THEN '402003'
                               WHEN (SELECT ce.ITEMA041
                                     FROM crmexpedientes_cab ce
                                     WHERE ce.empresa = '004'
                                       AND ce.tipo_expediente = '04003'
                                       AND ce.status_expediente = '01'
                                       AND ce.numero_expediente = numero_expediente
                                       AND ROWNUM <= 1) = '014' THEN '402004'
                               ELSE '402008'
        END
WHERE status_tarea = '01'
  AND codigo_secuencia = '075'
  AND empresa = '004'
  AND numero_expediente
    IN (SELECT numero_expediente
        FROM crmexpedientes_cab
        WHERE FECHA_INICIO >= trunc(current_date, 'MONTH')
          and empresa = '004'
          AND tipo_expediente = '04003'
          AND status_expediente = '01')