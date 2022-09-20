/***view para cartera detalle para el equipo de CARTERA **/
CREATE OR REPLACE FORCE VIEW BOL_INFORME_CARTERA_DETALLE(FECHA_VENCIMIENTO, DOCUMENTO, FECHA_FACTURA, TIPO_TRANSACCION, CONCEPTO, P_IMPORTE, P_IMPORTE_DIV, DIVISA_ORIGEN, AGENTE, CODIGO_CUENTA, CARACTER_ASIENTO, BANCO_ASEGURADOR, CONTRATO, VALOR_CAMBIO, TIPO_REMESA_FINANCIACION, 
NUM_CHEQUE, FECHA_VALOR, ESTADO, EMPRESA, FECHA_ASIENTO, DIARIO, NUMERO_ASIENTO_BORRADOR, IMPORTE, IMPORTE_ENDOSADO, IMPORTE_COBRADO, IMPORTE_SUSTITUIDO, IMPORTE_DIVISA, IMPORTE_COBRADO_DIVISA, STATUS_FINANCIADO, 
STATUS_IMPAGADO, STATUS_RETENIDO, STATUS_IMPRESION, STATUS_ACEPTADO, STATUS_RECLAMACION, CODIGO_CLIENTE, DOMICILIACION_MANUAL, SERIE_JUSTIFICANTE, JUSTIFICANTE, IMPORTE_DIV_NO_ASEGURADO, VALOR_CAMBIO_NO_ASEG, 
IMPORTE_DIVISA_ASEGURADO, IMPORTE_PDTE_DIVISA, ORIGEN, UUID, FECHA_TIMBRADO, NUMERO_EXPEDIENTE, D_NUMERO_EXPEDIENTE, D_CARACTER_ASIENTO, D_BANCO, D_BANCO_ASEGURADOR, DET_CAR_REG, DET_CAR_NOMBRE_CADENA, 
DET_CAR_CANAL_VENTA, DET_CAR_MONTO_ORIGINAL, DET_CAR_COBROS_PREVIOS, DET_CAR_NDC_APLICADAS, DET_CAR_SALDO, COBRO_IMPORTE_COBRADO, COBRO_IMPORTE_IMPAGADO, PPTO_CORRIENTE, PPTO_COBRO_CORRIENTE, PPTO_MOROSA, 
PPTO_COBRO_MOROSO, RAZON_SOCIAL) AS
SELECT his.FECHA_VENCIMIENTO,his.DOCUMENTO,his.FECHA_FACTURA,his.TIPO_TRANSACCION,his.CONCEPTO,his.P_IMPORTE,his.P_IMPORTE_DIV,his.DIVISA_ORIGEN,his.AGENTE,his.CODIGO_CUENTA,his.CARACTER_ASIENTO,his.BANCO_ASEGURADOR,his.CONTRATO,his.VALOR_CAMBIO,his.TIPO_REMESA_FINANCIACION,his.NUM_CHEQUE,his.FECHA_VALOR,his.ESTADO,his.EMPRESA,his.FECHA_ASIENTO,his.DIARIO,his.NUMERO_ASIENTO_BORRADOR,his.IMPORTE,his.IMPORTE_ENDOSADO,his.IMPORTE_COBRADO,his.IMPORTE_SUSTITUIDO,his.IMPORTE_DIVISA,his.IMPORTE_COBRADO_DIVISA,his.STATUS_FINANCIADO,his.STATUS_IMPAGADO,his.STATUS_RETENIDO,his.STATUS_IMPRESION,his.STATUS_ACEPTADO,his.STATUS_RECLAMACION,his.CODIGO_CLIENTE,his.DOMICILIACION_MANUAL,his.SERIE_JUSTIFICANTE,his.JUSTIFICANTE,his.IMPORTE_DIV_NO_ASEGURADO,his.VALOR_CAMBIO_NO_ASEG,his.IMPORTE_DIVISA_ASEGURADO,his.IMPORTE_PDTE_DIVISA,his.ORIGEN,his.UUID,his.FECHA_TIMBRADO,his.NUMERO_EXPEDIENTE,his.D_NUMERO_EXPEDIENTE,his.D_CARACTER_ASIENTO,his.D_BANCO,his.D_BANCO_ASEGURADOR, dc.reg det_car_reg, dc.nombre_cadena det_car_nombre_cadena, dc.canal_venta det_car_canal_venta, dc.monto_original det_car_monto_original, dc.cobros_previos det_car_cobros_previos, dc.ndc_aplicadas det_car_ndc_aplicadas, dc.saldo det_car_saldo, cob.importe_cobrado cobro_importe_cobrado, cob.m_importe_impagado cobro_importe_impagado, 'PPTO COBRANZA CORRIENTE' PPTO_CORRIENTE,
(SELECT V.IMPORTE
FROM V_XLS_PLANES_VENTAS V, PLANES_VENTAS pv
WHERE V.EMPRESA  ='004'
	   AND pv.CODIGO = v.codigo
	   AND pv.empresa = v.empresa
       AND pv.DESCRIPCION LIKE '%COB%'
	   AND V.ARTICULO = '00036637'
	   AND V.CLIENTE = his.CODIGO_CLIENTE
	   AND V.EJERCICIO = to_char(his.FECHA_FACTURA,'YYYY')
	   AND V.PERIODO = to_number(to_char(his.FECHA_FACTURA,'MM'),'99')) PPTO_COBRO_CORRIENTE, 'PPTO COBRANZA MOROSA' PPTO_MOROSA,
(SELECT V.IMPORTE
FROM V_XLS_PLANES_VENTAS V, PLANES_VENTAS pv
WHERE V.EMPRESA  ='004'
       AND pv.CODIGO = v.codigo
	   AND pv.empresa = v.empresa
       AND pv.DESCRIPCION LIKE '%COB%'
	   AND V.ARTICULO = '00036636'
	   AND V.CLIENTE = his.CODIGO_CLIENTE
	   AND V.EJERCICIO = to_char(his.FECHA_FACTURA,'YYYY')
	   AND V.PERIODO = to_number(to_char(his.FECHA_FACTURA,'MM'),'99')) PPTO_COBRO_MOROSO, cli.RAZON_SOCIAL    FROM (SELECT
         TIPO_C
       , FECHA_VENCIMIENTO
       , DOCUMENTO
       , FECHA_FACTURA
       , TIPO_TRANSACCION
       , CONCEPTO
       , P_IMPORTE
       , P_IMPORTE_DIV
       , DIVISA_ORIGEN
       , AGENTE
       , CODIGO_CUENTA
       , CARACTER_ASIENTO
       , TIPO_REMESA
       , D_TIPO_REMESA
       , NUMERO_REMESA
       , FECHA_REMESA
       , BANCO
       , CODIGO_SWIFT
       , BANCO_ASEGURADOR
       , CONTRATO
       , VALOR_CAMBIO
       , TIPO_REMESA_FINANCIACION
       , NUM_CHEQUE
       , NUMERO_REMESA_FINANCIACION
       , FECHA_REMESA_FINANCIACION
       , BANCO_REMESA_FINANCIACION
       , FECHA_VALOR
       , ESTADO
       , EMPRESA
       , FECHA_ASIENTO
       , DIARIO
       , NUMERO_ASIENTO_BORRADOR
       , NUMERO_LINEA_BORRADOR
       , IMPORTE
       , IMPORTE_ENDOSADO
       , IMPORTE_COBRADO
       , IMPORTE_SUSTITUIDO
       , IMPORTE_DIVISA
       , IMPORTE_COBRADO_DIVISA
       , IMPORTE_SUSTITUIDO_DIVISA
       , FECHA_VALOR_DIVISA
       , STATUS_REMESADO
       , STATUS_FINANCIADO
       , STATUS_IMPAGADO
       , STATUS_RETENIDO
       , STATUS_IMPRESION
       , STATUS_ACEPTADO
       , DOCUMENTO_VIVO
       , DOCUMENTO_AGRUPADO
       , STATUS_RECLAMACION
       , CODIGO_CLIENTE
       , DOMICILIACION_MANUAL
       , DOMICILIACION_IBAN
       , SERIE_JUSTIFICANTE
       , JUSTIFICANTE
       , IMPORTE_DIV_NO_ASEGURADO
       , VALOR_CAMBIO_NO_ASEG
       , IMPORTE_DIVISA_ASEGURADO
       , IMPORTE_PDTE_DIVISA
       , ORIGEN
       , UUID
       , FECHA_TIMBRADO
       , NUMERO_EXPEDIENTE
       , D_NUMERO_EXPEDIENTE
       , D_CARACTER_ASIENTO
       , D_BANCO
       , D_BANCO_ASEGURADOR
       , D_TIPO_REMESA_FINANCIACION
       , D_BANCO_REMESA_FINANCIACION
       , FACTORING
       , FACTOR
FROM
         (
                SELECT
                       historico_cobros.*
                     , (
                              SELECT
                                     b.nombre
                              FROM
                                     bancos b
                              WHERE
                                     b.empresa           = historico_cobros.empresa
                                     AND b.codigo_rapido = historico_cobros.banco
                       )
                       D_BANCO
                     , (
                              SELECT
                                     b.nombre
                              FROM
                                     bancos b
                              WHERE
                                     b.empresa           = historico_cobros.empresa
                                     AND b.codigo_rapido = historico_cobros.banco_asegurador
                       )
                       D_BANCO_ASEGURADOR
                     , (
                              SELECT
                                     c.nombre
                              FROM
                                     caracteres_asiento c
                              WHERE
                                     c.codigo      = historico_cobros.caracter_asiento
                                     AND c.empresa = historico_cobros.empresa
                       )
                       D_CARACTER_ASIENTO
                     , (
                              SELECT
                                     ec.descripcion
                              FROM
                                     expedientes_cab ec
                              WHERE
                                     ec.empresa    = historico_cobros.empresa
                                     and ec.codigo = historico_cobros.numero_expediente
                       )
                       D_NUMERO_EXPEDIENTE
                     , DECODE(
                               (
                                      SELECT
                                             hi.uuid
                                      FROM
                                             historico_impuestos hi
                                      WHERE
                                             hi.numero_asiento_borrador   = historico_cobros.numero_asiento_borrador
                                             AND hi.fecha_asiento         = historico_cobros.fecha_asiento
                                             AND hi.diario                = historico_cobros.diario
                                             AND hi.empresa               = historico_cobros.empresa
                                             AND hi.numero_linea_borrador = historico_cobros.numero_linea_borrador
                                             AND rownum                   = 1
                              )
                              , NULL, NULL, (
                                     SELECT
                                            TO_CHAR(d.fecha_certificado, pkpantallas.get_nls_date_format()
                                                   || ' HH24:MI:SS')
                                     FROM
                                            facturas_ventas_doc d
                                     WHERE
                                            d.uuid =
                                            (
                                                   SELECT
                                                          hi.uuid
                                                   FROM
                                                          historico_impuestos hi
                                                   WHERE
                                                          hi.numero_asiento_borrador   = historico_cobros.numero_asiento_borrador
                                                          AND hi.fecha_asiento         = historico_cobros.fecha_asiento
                                                          AND hi.diario                = historico_cobros.diario
                                                          AND hi.empresa               = historico_cobros.empresa
                                                          AND hi.numero_linea_borrador = historico_cobros.numero_linea_borrador
                                                          AND rownum                   = 1
                                            )
                              )
                              )                                                                                                                                                                                                                                                                                                                                                                                                                FECHA_TIMBRADO
                     , f_cobros_cambios (pkpantallas.get_variable_env_varchar2('CAMBIO_ACTUAL'), pkpantallas.get_variable_env_varchar2('CAMBIO_ASEGURADO'), pkpantallas.get_variable_env_varchar2('DIVISA_PRESENTACION'), pkpantallas.get_variable_env_varchar2('CODIGO_DIVISA_PRESENTACION'), pkpantallas.get_variable_env_number('CAMBIO_DIVISA_PRESEN'), pkpantallas.get_variable_env_date('FECHA_VALOR'), pkpantallas.get_variable_env_varchar2('DIVISA_EMPRESA'), pkpantallas.get_variable_env_number('DECIMALES_EMPRESA'), divisa_origen, importe_divisa, importe_cobrado_divisa,valor_cambio, documento_vivo, importe_div_no_asegurado, valor_cambio_no_aseg, importe_divisa_asegurado, importe_pdte_divisa, importe, importe_endosado, importe_sustituido, importe_cobrado, importe_sustituido_divisa) P_IMPORTE
                     , v_importe_divisa                                                                                                                                                                                                                                                                                                                                                                                                                P_IMPORTE_DIV
                     , (
                              SELECT
                                     hi.uuid
                              FROM
                                     historico_impuestos hi
                              WHERE
                                     hi.numero_asiento_borrador   = historico_cobros.numero_asiento_borrador
                                     AND hi.fecha_asiento         = historico_cobros.fecha_asiento
                                     AND hi.diario                = historico_cobros.diario
                                     AND hi.empresa               = historico_cobros.empresa
                                     AND hi.numero_linea_borrador = historico_cobros.numero_linea_borrador
                                     AND rownum                   = 1
                       )
                       UUID
                     , DECODE(historico_cobros.numero_remesa_financiacion, NULL, NULL, (
                              SELECT
                                     fn.codigo_banco
                              FROM
                                     financiaciones fn
                              WHERE
                                     historico_cobros.empresa                        = fn.empresa
                                     AND historico_cobros.numero_remesa_financiacion = fn.numero
                                     AND historico_cobros.fecha_remesa_financiacion  = fn.fecha_remesa
                       )
                       ) BANCO_REMESA_FINANCIACION
                     , DECODE(historico_cobros.numero_remesa_financiacion, NULL, NULL, (
                              SELECT
                                     b.nombre
                              FROM
                                     bancos b
                              WHERE
                                     b.empresa           = historico_cobros.empresa
                                     AND b.codigo_rapido =
                                     (
                                            SELECT
                                                   fn.codigo_banco
                                            FROM
                                                   financiaciones fn
                                            WHERE
                                                   fn.empresa          = historico_cobros.empresa
                                                   AND fn.numero       = historico_cobros.numero_remesa_financiacion
                                                   AND fn.fecha_remesa = historico_cobros.fecha_remesa_financiacion
                                     )
                       )
                       ) D_BANCO_REMESA_FINANCIACION
                     , DECODE(historico_cobros.numero_remesa, NULL, NULL, (
                              SELECT
                                     tr.descripcion
                              FROM
                                     tipos_remesa tr
                              WHERE
                                     tr.empresa    = historico_cobros.empresa
                                     AND tr.codigo =
                                     (
                                            SELECT
                                                   r.tipo_remesa
                                            FROM
                                                   remesas r
                                            WHERE
                                                   r.empresa          = historico_cobros.empresa
                                                   AND r.numero       = historico_cobros.numero_remesa
                                                   AND r.fecha_remesa = historico_cobros.fecha_remesa
                                     )
                       )
                       ) D_TIPO_REMESA
                     , DECODE(historico_cobros.numero_remesa_financiacion, NULL, NULL, (
                              SELECT
                                     trf.descripcion
                              FROM
                                     tipos_remesa_financiacion trf
                              WHERE
                                     trf.empresa    = historico_cobros.empresa
                                     AND trf.codigo =
                                     (
                                            SELECT
                                                   fn.tipo_remesa
                                            FROM
                                                   financiaciones fn
                                            WHERE
                                                   fn.empresa          = historico_cobros.empresa
                                                   AND fn.numero       = historico_cobros.numero_remesa_financiacion
                                                   AND fn.fecha_remesa = historico_cobros.fecha_remesa_financiacion
                                     )
                       )
                       ) D_TIPO_REMESA_FINANCIACION
                     , DECODE(historico_cobros.numero_remesa, NULL, NULL, (
                              SELECT
                                     r.tipo_remesa
                              FROM
                                     remesas r
                              WHERE
                                     r.empresa          = historico_cobros.empresa
                                     AND r.numero       = historico_cobros.numero_remesa
                                     AND r.fecha_remesa = historico_cobros.fecha_remesa
                       )
                       ) TIPO_REMESA
                     , DECODE(historico_cobros.numero_remesa_financiacion, NULL, NULL, (
                              SELECT
                                     fn.tipo_remesa
                              FROM
                                     financiaciones fn
                              WHERE
                                     fn.empresa          = historico_cobros.empresa
                                     AND fn.numero       = historico_cobros.numero_remesa_financiacion
                                     AND fn.fecha_remesa = historico_cobros.fecha_remesa_financiacion
                       )
                       ) TIPO_REMESA_FINANCIACION
                FROM
                       (
                              SELECT
                                     fecha_vencimiento
                                   , documento
                                   , fecha_factura
                                   , tipo_transaccion
                                   , numero_remesa
                                   , fecha_remesa
                                   , contrato
                                   , numero_remesa_financiacion
                                   , fecha_remesa_financiacion
                                   , codigo_swift
                                   , estado
                                   , empresa
                                   , fecha_asiento
                                   , diario
                                   , numero_asiento_borrador
                                   , numero_linea_borrador
                                   , codigo_cuenta
                                   , importe
                                   , importe_endosado
                                   , importe_cobrado
                                   , importe_sustituido
                                   , importe_divisa
                                   , importe_cobrado_divisa
                                   , importe_sustituido_divisa
                                   , fecha_valor_divisa
                                   , status_remesado
                                   , status_financiado
                                   , status_impagado
                                   , status_retenido
                                   , status_impresion
                                   , status_aceptado
                                   , documento_vivo
                                   , documento_agrupado
                                   , status_reclamacion
                                   , codigo_cliente
                                   , domiciliacion_manual
                                   , domiciliacion_iban
                                   , serie_justificante
                                   , justificante
                                   , concepto
                                   , divisa_origen
                                   , agente
                                   , caracter_asiento
                                   , importe_div_no_asegurado
                                   , valor_cambio
                                   , valor_cambio_no_aseg
                                   , importe_divisa_asegurado
                                   , importe_pdte_divisa
                                   , factoring
                                   , situacion_apunte
                                   , usuario
                                   , 'CO' tipo_c
                                   , 'HC' origen
                                   , endoso
                                   , status_contabilizado
                                   , banco_asegurador
                                   , banco
                                   , v_importe_divisa
                                   , fecha_valor
                                   , num_cheque
                                   , numero_expediente
                                   , factor
                              FROM
                                     v_historico_cobros
                       )
                       historico_cobros
         )
         historico_cobros
WHERE
         historico_cobros.caracter_asiento IN
         (
                SELECT
                       b.codigo_centro
                FROM
                       grupos_ccont        a
                     , centros_grupo_ccont b
                WHERE
                       a.empresa     = '004'
                       AND b.empresa = a.empresa
                       AND a.codigo  = '0401'
                       AND a.codigo  = b.codigo_grupo
         )
         AND NVL(historico_cobros.status_impagado, 'N') IN ('N'
                                                          ,'S'
                                                          ,'D'
                                                          ,'P'
                                                          ,'A'
                                                          ,'F')
         AND
         (
                  historico_cobros.status_remesado          = 'N'
                  OR historico_cobros.status_remesado IS NULL
         )
         AND historico_cobros.tipo_c           = 'CO'
         AND historico_cobros.situacion_apunte = 'D'
         AND NVL(historico_cobros.factoring, 'N') IN ('N'
                                                    , DECODE('S', 'S', 'A', 'N')
                                                    , DECODE('N', 'S', 'F', 'N'))
         AND historico_cobros.empresa = '004') his LEFT JOIN DETALLE_CARTERA_RESUM dc ON dc.codigo_cliente = his.CODIGO_CLIENTE and his.FECHA_FACTURA = dc.FECHA_FACTURA AND his.documento = dc.documento
LEFT JOIN  (SELECT SUBSTR(historico_cobros.concepto,1,20) concepto
       , SUBSTR(historico_detallado_apuntes.concepto,1,20) concepto_apuntes
       , historico_cobros.fecha_factura                    
       , historico_mov_cartera.fecha_movimiento            
       , historico_mov_cartera.fecha_asiento               
       , SUBSTR(clientes.codigo_rapido,1,8) codigo_rapido
       , SUBSTR(clientes.nombre,1,40)    nombre                   
       , SUBSTR(historico_cobros.documento,1,15) documento
	   , historico_cobros.documento documento2
       , historico_mov_cartera.importe_cobrado             
       , SUBSTR(historico_mov_cartera.tipo_movimiento,1,6) tipo_movimiento
       , SUBSTR(historico_detallado_apuntes.entidad,1,2) entidad
       , SUBSTR(historico_cobros.tipo_transaccion,1,4) tipo_transaccion
       , SUBSTR(clientes.zona,1,10) zona                       
       , historico_cobros.importe_compensado_divisa        
       , historico_cobros.importe_impagado                 
       , historico_cobros.importe_sustituido_divisa        
       , historico_cobros.importe_impagado_divisa          
       , historico_detallado_apuntes.importe_divisa        
       , historico_mov_cartera.importe historico_mov_cartera_importe          
       , historico_detallado_apuntes.importe hist_dapuntes_importe
       , historico_cobros.importe historico_cobros_importe                   
       , historico_cobros.importe_cobrado    hisobros_importe_cobrado
       , historico_mov_cartera.importe_cobrado_divisa tera_importe_cobrado_divisa
       , historico_cobros.importe_cobrado_divisa           
       , historico_cobros.importe_cob_div2_empresa         
       , historico_mov_cartera.importe_cob_div2_empresa  imp_div2_emp
       , historico_cobros.importe_compensado
       , historico_mov_cartera.importe_condonado           
       , historico_mov_cartera.importe_condonado_divisa    
       , historico_cobros.importe_descuento_pronto_pago    
       , historico_cobros.importe_div2_empresa    c_importe_div2_empresa         
       , historico_mov_cartera.importe_div2_empresa m_importe_div2_empresa
       , historico_detallado_apuntes.importe_div2_empresa  d_importe_div2_empresa
       , historico_cobros.importe_divisa  c_importe_divisa                 
       , historico_mov_cartera.importe_divisa m_importe_divisa 
       , historico_mov_cartera.importe_div_no_asegurado m_importe_div_no_asegurado 
       , historico_cobros.importe_div_no_asegurado c_importe_div_no_asegurado
       , historico_cobros.importe_endosado  c_importe_endosado               
       , historico_mov_cartera.importe_endosado            
       , historico_mov_cartera.importe_impagado m_importe_impagado         
       , historico_mov_cartera.importe_impagado_divisa m_importe_impagado_divisa    
       , historico_mov_cartera.importe_imp_div2_empresa  mov_div2_emp 
       , historico_cobros.importe_imp_div2_empresa cob_div2_emp
       , clientes.importe_minimo_giro                      
       , historico_mov_cartera.importe_mov                 
       , historico_cobros.importe_recargo_financiero       
       , historico_cobros.importe_sustituido c_importe_sustituido
       , historico_mov_cartera.importe_sustituido          
       , historico_mov_cartera.importe_sustituido_divisa  m_importe_sustituido_divisa 
       , historico_mov_cartera.importe_sust_div2_empresa  m_importe_sust_div2_empresa
       , historico_cobros.importe_sust_div2_empresa  c_importe_sust_div2_empresa   
FROM
         HISTORICO_COBROS
       , HISTORICO_MOV_CARTERA
       , CLIENTES
       , HISTORICO_DETALLADO_APUNTES
WHERE
         (
                  HISTORICO_COBROS.DOCUMENTO                       =HISTORICO_MOV_CARTERA.DOCUMENTO
                  and HISTORICO_COBROS.FECHA_FACTURA               =HISTORICO_MOV_CARTERA.FECHA_FACTURA
                  and HISTORICO_COBROS.FECHA_VENCIMIENTO           =HISTORICO_MOV_CARTERA.FECHA_VENCIMIENTO
                  and HISTORICO_COBROS.TIPO_TRANSACCION            =HISTORICO_MOV_CARTERA.TIPO_TRANSACCION
                  and HISTORICO_COBROS.EMPRESA                     =HISTORICO_MOV_CARTERA.EMPRESA
                  and HISTORICO_COBROS.EMPRESA                     =CLIENTES.CODIGO_EMPRESA
                  and HISTORICO_COBROS.CODIGO_CLIENTE              =CLIENTES.CODIGO_RAPIDO
                  and HISTORICO_MOV_CARTERA.EMPRESA                =HISTORICO_DETALLADO_APUNTES.EMPRESA
                  and HISTORICO_MOV_CARTERA.FECHA_ASIENTO          =HISTORICO_DETALLADO_APUNTES.FECHA_ASIENTO
                  and HISTORICO_MOV_CARTERA.NUMERO_ASIENTO_BORRADOR=HISTORICO_DETALLADO_APUNTES.NUMERO_ASIENTO_BORRADOR
                  and CLIENTES.CODIGO_EMPRESA                      = '004'
         )
         AND
         (
                  historico_cobros.empresa = '004'
         )
         AND
         (
                  historico_mov_cartera.empresa = '004'
                  AND
                  (
                           EXISTS
                           (
                                  SELECT
                                         1
                                  FROM
                                         empresas_conta e
                                  WHERE
                                         e.codigo                        = '004'
                                         AND e.grupo_balance_obligatorio = 'N'
                           )
                           OR historico_mov_cartera.caracter_asiento IS NULL
                           OR EXISTS
                           (
                                  SELECT
                                         1
                                  FROM
                                         usuarios_gb         u
                                       , centros_grupo_ccont cgc
                                  WHERE
                                         cgc.empresa           = '004'
                                         AND cgc.codigo_centro = historico_mov_cartera.caracter_asiento
                                         AND u.grupo_balance   = cgc.codigo_grupo
                                         AND u.usuario         = 'JMENACHO'
                                         AND u.codigo_empresa  ='004'
                           )
                  )
         )
         AND
         (
                  clientes.codigo_empresa = '004'
         )
         AND historico_mov_cartera.tipo_movimiento = 'CONSR'
		 AND SUBSTR(historico_detallado_apuntes.entidad,1,2) = 'BA') cob ON cob.codigo_rapido = his.CODIGO_CLIENTE and cob.FECHA_FACTURA = his.FECHA_FACTURA AND cob.documento2 = his.documento
		 INNER JOIN CLIENTES cli ON his.codigo_cliente = cli.CODIGO_RAPIDO AND his.empresa = cli.CODIGO_EMPRESA
		 WHERE  his.CODIGO_CLIENTE='007178' /*AND hIS.documento = '310/000628'*/
		 AND his.fecha_factura BETWEEN TO_DATE('10/07/2020', 'DD/MM/YYYY') AND TO_DATE('10/07/2021', 'DD/MM/YYYY');
