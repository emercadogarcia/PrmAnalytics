/**** nueva version con grupo y datos adicionales */
SELECT G.*,
(SELECT NOMBRE FROM VALORES_CLAVES WHERE CLAVE = 'CADN' AND VALOR_CLAVE = G.CODIGO_CADENA) D_CODIGO_CADENA,
(SELECT NOMBRE FROM VALORES_CLAVES WHERE CLAVE = 'CANALV' AND VALOR_CLAVE = G.CODIGO_CANAL_VTA) D_CODIGO_CANAL_VTA
FROM
(
    SELECT E.*, F.ALMACEN_PEDIDO, F.IMPORTE_BRUTO, F.CLIENTE,
    (SELECT RAZON_SOCIAL2 FROM VA_CLIENTES WHERE CODIGO_EMPRESA = '004' AND CODIGO_RAPIDO = F.CLIENTE) D_CLIENTE,
    (SELECT VALOR_CLAVE FROM CLIENTES_CLAVES_ESTADISTICAS WHERE CODIGO_EMPRESA = '004' AND CODIGO_CLIENTE = F.CLIENTE AND CLAVE = 'CADN') CODIGO_CADENA,
    (SELECT VALOR_CLAVE FROM CLIENTES_CLAVES_ESTADISTICAS WHERE CODIGO_EMPRESA = '004' AND CODIGO_CLIENTE = F.CLIENTE AND CLAVE = 'CANALV') CODIGO_CANAL_VTA,
    (SELECT NOMBRE FROM ALMACENES WHERE CODIGO_EMPRESA = '004' AND ALMACEN = F.ALMACEN_PEDIDO) D_CODIGO_ALMACEN,
    (CASE E.CODIGO_SECUENCIA
    WHEN '020' THEN 1
    WHEN '032' THEN 2
    WHEN '033' THEN 2
    WHEN '034' THEN 2
    WHEN '030' THEN 4
    WHEN '031' THEN 4
    WHEN '040' THEN 4
    WHEN '050' THEN 4
    WHEN '060' THEN 4
    WHEN '065' THEN 3
    WHEN '070' THEN 5
    WHEN '130' THEN 5
    WHEN '140' THEN 5
    WHEN '075' THEN 6
    WHEN '120' THEN 7
    WHEN '080' THEN 8
    WHEN '150' THEN 9
    WHEN '160' THEN 9
    WHEN '160' THEN 10
    WHEN '190' THEN 11
    WHEN '999' THEN 12
    WHEN '100' THEN 13
    ELSE 0 END) ORDEN,
    (CASE E.CODIGO_SECUENCIA
    WHEN '020' THEN 'Confirmar pedido'
    WHEN '032' THEN 'Validacion Call Center'
    WHEN '033' THEN 'Validacion Call Center'
    WHEN '034' THEN 'Validacion Call Center'
    WHEN '030' THEN 'Validacion Financiera'
    WHEN '031' THEN 'Validacion Financiera'
    WHEN '040' THEN 'Validacion Financiera'
    WHEN '050' THEN 'Validacion Financiera'
    WHEN '060' THEN 'Validacion Financiera'
    WHEN '065' THEN 'Validacion Gestor'
    WHEN '070' THEN 'Emitir pedido'
    WHEN '130' THEN 'Validacion Solicitante'
    WHEN '140' THEN 'Validacion Solicitante'
    WHEN '075' THEN 'Gestionar Hoja de Carga'
    WHEN '120' THEN 'Alistar pedido'
    WHEN '080' THEN 'Realizar Facturacion'
    WHEN '150' THEN 'Despacho-Entregar Ped.'
    WHEN '160' THEN 'Despacho-Entregar Ped.'
    WHEN '160' THEN 'Pedido Entregado'
    WHEN '190' THEN 'Logistica Inversa'
    WHEN '999' THEN 'Pedido Descartado'
    WHEN '100' THEN 'Cerrar/anular pedido'
    ELSE '' END) GRUPO
    FROM
    (
    SELECT A.NUMERO_EXPEDIENTE,
    A.FECHA_INICIO,
    A.ITEMA041 SERIE,
    A.ITEMN002 NRO_PEDIDO,
    A.ITEMN001 PERIODO,
    B.CODIGO_SECUENCIA,
    A.TIPO_EXPEDIENTE,
    A.STATUS_EXPEDIENTE,
    B.STATUS_TAREA,
    C.DESCRIPCION
    FROM
    CRMEXPEDIENTES_CAB A,
    CRMEXPEDIENTES_LIN B,
    CRMSECUENCIA_TAREAS C,
    CRMESTADOS_TAREAS D,
    CRMTIPOS_TAREA E
    WHERE A.EMPRESA=B.EMPRESA
    AND A.NUMERO_EXPEDIENTE=B.NUMERO_EXPEDIENTE
    AND (B.EMPRESA=C.EMPRESA AND B.CODIGO_SECUENCIA = C.CODIGO_SECUENCIA)
    AND A.TIPO_EXPEDIENTE=C.TIPO_EXPEDIENTE
    AND B.STATUS_TAREA = D.ESTADO_TAREA
    AND B.EMPRESA = D.EMPRESA
    AND E.TIPO_TAREA = B.TIPO_TAREA
    AND E.EMPRESA=B.EMPRESA
    AND A.EMPRESA = '004'
    AND A.FECHA_INICIO BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY') AND TO_DATE('02/08/2022', 'DD/MM/YYYY')
    AND A.TIPO_EXPEDIENTE = '04003'
    AND (
        (A.STATUS_EXPEDIENTE = '01' AND B.STATUS_TAREA = '01') OR (A.STATUS_EXPEDIENTE = '99' AND B.CODIGO_SECUENCIA IN ('160','999','100') AND B.STATUS_TAREA IN ('82B','999','99'))
        )
    ) E LEFT JOIN PEDIDOS_VENTAS F
    ON E.PERIODO = F.EJERCICIO
    AND E.SERIE = F.NUMERO_SERIE
    AND E.NRO_PEDIDO = F.NUMERO_PEDIDO and empresa ='004'
) G
ORDER BY 1


/*******/
SELECT DISTINCT G.*,
(SELECT NOMBRE FROM VALORES_CLAVES WHERE CLAVE = 'CADN' AND VALOR_CLAVE = G.CODIGO_CADENA) D_CODIGO_CADENA,
(SELECT NOMBRE FROM VALORES_CLAVES WHERE CLAVE = 'CANALV' AND VALOR_CLAVE = G.CODIGO_CANAL_VTA) D_CODIGO_CANAL_VTA
FROM
(
SELECT E.*, F.ALMACEN_PEDIDO, F.IMPORTE_BRUTO, F.CLIENTE,
(SELECT RAZON_SOCIAL2 FROM VA_CLIENTES WHERE CODIGO_EMPRESA = '004' AND CODIGO_RAPIDO = F.CLIENTE) D_CLIENTE,
(SELECT VALOR_CLAVE FROM CLIENTES_CLAVES_ESTADISTICAS WHERE CODIGO_EMPRESA = '004' AND CODIGO_CLIENTE = F.CLIENTE AND CLAVE = 'CADN') CODIGO_CADENA,
(SELECT VALOR_CLAVE FROM CLIENTES_CLAVES_ESTADISTICAS WHERE CODIGO_EMPRESA = '004' AND CODIGO_CLIENTE = F.CLIENTE AND CLAVE = 'CANALV') CODIGO_CANAL_VTA,
(SELECT NOMBRE FROM ALMACENES WHERE CODIGO_EMPRESA = '004' AND ALMACEN = F.ALMACEN_PEDIDO) D_CODIGO_ALMACEN,
(CASE E.CODIGO_SECUENCIA
WHEN '020' THEN 1
WHEN '032' THEN 2
WHEN '033' THEN 2
WHEN '034' THEN 2
WHEN '030' THEN 4
WHEN '031' THEN 4
WHEN '040' THEN 4
WHEN '050' THEN 4
WHEN '060' THEN 4
WHEN '065' THEN 3
WHEN '070' THEN 5
WHEN '130' THEN 5
WHEN '140' THEN 5
WHEN '075' THEN 6
WHEN '120' THEN 7
WHEN '080' THEN 8
WHEN '150' THEN 9
WHEN '160' THEN 9
WHEN '160' THEN 10
WHEN '190' THEN 11
WHEN '999' THEN 12
WHEN '100' THEN 13
ELSE 0 END) ORDEN,
(CASE E.CODIGO_SECUENCIA
WHEN '020' THEN 'Confirmar pedido'
WHEN '032' THEN 'Validacion Call Center'
WHEN '033' THEN 'Validacion Call Center'
WHEN '034' THEN 'Validacion Call Center'
WHEN '030' THEN 'Validacion Financiera'
WHEN '031' THEN 'Validacion Financiera'
WHEN '040' THEN 'Validacion Financiera'
WHEN '050' THEN 'Validacion Financiera'
WHEN '060' THEN 'Validacion Financiera'
WHEN '065' THEN 'Validacion Gestor'
WHEN '070' THEN 'Emitir pedido'
WHEN '130' THEN 'Validacion Solicitante'
WHEN '140' THEN 'Validacion Solicitante'
WHEN '075' THEN 'Gestionar Hoja de Carga'
WHEN '120' THEN 'Alistar pedido'
WHEN '080' THEN 'Realizar Facturacion'
WHEN '150' THEN 'Despacho-Entregar Ped.'
WHEN '160' THEN 'Despacho-Entregar Ped.'
WHEN '160' THEN 'Pedido Entregado'
WHEN '190' THEN 'Logistica Inversa'
WHEN '999' THEN 'Pedido Descartado'
WHEN '100' THEN 'Cerrar/anular pedido'
ELSE '' END) GRUPO
FROM
(
SELECT A.NUMERO_EXPEDIENTE,
A.FECHA_INICIO,
A.ITEMA041 SERIE,
A.ITEMN002 NRO_PEDIDO,
A.ITEMN001 PERIODO,
B.CODIGO_SECUENCIA,
A.TIPO_EXPEDIENTE,
A.STATUS_EXPEDIENTE,
B.STATUS_TAREA,
C.DESCRIPCION,
A.EMPRESA
FROM
CRMEXPEDIENTES_CAB A,
CRMEXPEDIENTES_LIN B,
CRMSECUENCIA_TAREAS C,
CRMESTADOS_TAREAS D,
CRMTIPOS_TAREA E
WHERE A.EMPRESA=B.EMPRESA
AND A.NUMERO_EXPEDIENTE=B.NUMERO_EXPEDIENTE
AND (B.EMPRESA=C.EMPRESA AND B.CODIGO_SECUENCIA = C.CODIGO_SECUENCIA)
AND A.TIPO_EXPEDIENTE=C.TIPO_EXPEDIENTE
AND B.STATUS_TAREA = D.ESTADO_TAREA
AND B.EMPRESA = D.EMPRESA
AND E.TIPO_TAREA = B.TIPO_TAREA
AND E.EMPRESA=B.EMPRESA
AND A.EMPRESA = '004'
AND A.FECHA_INICIO BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY') AND TO_DATE('02/08/2022', 'DD/MM/YYYY')
AND A.TIPO_EXPEDIENTE = '04003'
AND
((A.STATUS_EXPEDIENTE = '01' AND B.STATUS_TAREA = '01') OR (A.STATUS_EXPEDIENTE = '99' AND B.CODIGO_SECUENCIA IN ('999','100') AND B.STATUS_TAREA IN ('01','999','99')) OR (A.STATUS_EXPEDIENTE = '99' AND B.CODIGO_SECUENCIA = '160' AND B.STATUS_TAREA = '82B'))
) E LEFT JOIN PEDIDOS_VENTAS F
ON E.EMPRESA = F.EMPRESA
AND E.PERIODO = F.EJERCICIO
AND E.SERIE = F.NUMERO_SERIE
AND E.NRO_PEDIDO = F.NUMERO_PEDIDO
) G
ORDER BY 1