CREATE OR REPLACE VIEW BOL_INFORME_SEDES AS SELECT m.codigo_zona, f.FECHA_FACTURA, f.region, s.codigo_articulo articulo, s.CANTIDAD_STOCK, m.movimiento, m.desc_movimiento, m.CANTIDAD_MOVIDA, m.cliente_movimiento, f.NUMERO_FACTURA, f.cliente CLIENTE_FACTURA, F.CLIENTE22 FROM (SELECT s.CODIGO_ARTICULO, SUM(s.CANTIDAD) CANTIDAD_STOCK FROM (SELECT
         stocks_detallado.codigo_almacen  
       , almacenes.nombre                 
       , articulos.codigo_estad3          
       , articulos.codigo_sinonimo        
       , stocks_detallado.codigo_articulo 
       , articulos.descrip_comercial      
       , articulos.codigo_estad6          
       , stocks_detallado.codigo_zona     
       , almacenes_zonas.descripcion      
       , stocks_detallado.tipo_situacion  
       , stocks_detallado.numero_lote_int 
       , MAX(
              (
                     SELECT
                            h.fecha_caducidad
                     FROM
                            historico_lotes h
                     WHERE
                            h.codigo_articulo     = stocks_detallado.codigo_articulo
                            AND h.numero_lote_int = stocks_detallado.numero_lote_int
                            AND h.codigo_empresa  = stocks_detallado.codigo_empresa
             )
             )                                  FECHA
       , SUM(STOCKS_DETALLADO.CANTIDAD_UNIDAD1) CANTIDAD
       , articulos.d_codigo_estad5              ESTADO_ARTICULO_DESCRIPCION
       , articulos.codigo_estad5                ESTADO_ARTICULO
       , MAX(DECODE(STOCKS_DETALLADO.NUMERO_LOTE_INT, NULL, NULL, (
                SELECT
                       h.descripcion_lote2
                FROM
                       historico_lotes h
                WHERE
                       h.numero_lote_int     = STOCKS_DETALLADO.NUMERO_LOTE_INT
                       AND h.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO
                       AND h.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA
         )
         )) c15
       , MAX(DECODE(STOCKS_DETALLADO.NUMERO_LOTE_INT, NULL, NULL, (
                SELECT
                       c.valor_alfa_2
                FROM
                       CARACTERISTICAS_LOTES c
                WHERE
                       c.numero_lote_int     = STOCKS_DETALLADO.NUMERO_LOTE_INT
                       AND c.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO
                       AND c.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA
         )
         )) c16
       , MAX(
              (
                     select
                            PRECIO_STANDARD
                     from
                            ARTICULOS_VALORACION
                     where
                            codigo_empresa     =almacenes.codigo_empresa
                            and codigo_articulo=STOCKS_DETALLADO.CODIGO_ARTICULO
                            and codigo_divisa  ='BOB'
                            and ejercicio      =
                            (
                                   SELECT
                                          MAX(av.ejercicio)
                                   FROM
                                          articulos_valoracion av
                                   WHERE
                                          av.codigo_articulo    = articulos_valoracion.codigo_articulo
                                          AND av.codigo_divisa  = articulos_valoracion.codigo_divisa
                                          AND av.codigo_almacen = articulos_valoracion.codigo_almacen
                                          AND av.codigo_empresa = articulos_valoracion.CODIGO_EMPRESA
                            )
             )
             ) n2
       , MAX(
              (
                     select
                            ULTIMO_PRECIO_COMPRA
                     from
                            ARTICULOS_VALORACION
                     where
                            codigo_empresa     =almacenes.codigo_empresa
                            and codigo_articulo=STOCKS_DETALLADO.CODIGO_ARTICULO
                            and codigo_divisa  ='BOB'
                            and ejercicio      =
                            (
                                   SELECT
                                          MAX(av.ejercicio)
                                   FROM
                                          articulos_valoracion av
                                   WHERE
                                          av.codigo_articulo    = articulos_valoracion.codigo_articulo
                                          AND av.codigo_divisa  = articulos_valoracion.codigo_divisa
                                          AND av.codigo_almacen = articulos_valoracion.codigo_almacen
                                          AND av.codigo_empresa = articulos_valoracion.CODIGO_EMPRESA
                            )
             )
             ) n3
       , MAX(
              (
                     select
                            PRECIO_MEDIO_PONDERADO
                     from
                            ARTICULOS_VALORACION
                     where
                            codigo_empresa     =almacenes.codigo_empresa
                            and codigo_articulo=STOCKS_DETALLADO.CODIGO_ARTICULO
                            and codigo_divisa  ='BOB'
                            and ejercicio      =
                            (
                                   SELECT
                                          MAX(av.ejercicio)
                                   FROM
                                          articulos_valoracion av
                                   WHERE
                                          av.codigo_articulo    = articulos_valoracion.codigo_articulo
                                          AND av.codigo_divisa  = articulos_valoracion.codigo_divisa
                                          AND av.codigo_almacen = articulos_valoracion.codigo_almacen
                                          AND av.codigo_empresa = articulos_valoracion.CODIGO_EMPRESA
                            )
             )
             ) n4
       , MAX(
              (
                     select
                            PRECIO_MEDIO_PONDERADO
                     from
                            ARTICULOS_VALORACION
                     where
                            codigo_empresa     =almacenes.codigo_empresa
                            and codigo_articulo=STOCKS_DETALLADO.CODIGO_ARTICULO
                            and codigo_divisa  ='BOB'
                            and ejercicio      =
                            (
                                   SELECT
                                          MAX(av.ejercicio)
                                   FROM
                                          articulos_valoracion av
                                   WHERE
                                          av.codigo_articulo    = articulos_valoracion.codigo_articulo
                                          AND av.codigo_divisa  = articulos_valoracion.codigo_divisa
                                          AND av.codigo_almacen = articulos_valoracion.codigo_almacen
                                          AND av.codigo_empresa = articulos_valoracion.CODIGO_EMPRESA
                            )
             )
             )*SUM(STOCKS_DETALLADO.CANTIDAD_UNIDAD1) n5
       , stocks_detallado.presentacion                c17
       , articulos.dias_caducidad                     n6
       , TO_DATE(TRUNC(SYSDATE),'DD-MM-YYYY')-TO_DATE(MAX(
                                                           (
                                                                  SELECT
                                                                         h.fecha_caducidad
                                                                  FROM
                                                                         historico_lotes h
                                                                  WHERE
                                                                         h.codigo_articulo     = stocks_detallado.codigo_articulo
                                                                         AND h.numero_lote_int = stocks_detallado.numero_lote_int
                                                                         AND h.codigo_empresa  = stocks_detallado.codigo_empresa
                                                          )
                                                          )) n7
       , NULL                                                gi$color
FROM
         (
                SELECT
                       ARTICULOS.*
                     , DECODE(articulos.codigo_estad5,NULL,NULL, (
                              SELECT
                                     lvfm.descripcion
                              FROM
                                     familias lvfm
                              WHERE
                                     lvfm.codigo_familia     = articulos.codigo_estad5
                                     AND lvfm.numero_tabla   = 5
                                     AND lvfm.codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD5
                FROM
                       ARTICULOS
         )
         ARTICULOS
       , STOCKS_DETALLADO
       , ALMACENES
       , ALMACENES_ZONAS
WHERE
         (
                  STOCKS_DETALLADO.CODIGO_EMPRESA        = '004'
                  AND STOCKS_DETALLADO.CODIGO_EMPRESA    = ARTICULOS.CODIGO_EMPRESA
                  AND STOCKS_DETALLADO.CODIGO_ARTICULO   = ARTICULOS.CODIGO_ARTICULO
                  AND STOCKS_DETALLADO.CANTIDAD_UNIDAD1 <> 0
                  AND STOCKS_DETALLADO.CODIGO_EMPRESA    = ALMACENES.CODIGO_EMPRESA
                  AND STOCKS_DETALLADO.CODIGO_ALMACEN    = ALMACENES.ALMACEN
                  AND ALMACENES_ZONAS.CODIGO_ALMACEN     =STOCKS_DETALLADO.CODIGO_ALMACEN
                  AND STOCKS_DETALLADO.CODIGO_ZONA       =ALMACENES_ZONAS.CODIGO_ZONA
                  AND STOCKS_DETALLADO.CODIGO_EMPRESA    = ALMACENES_ZONAS.CODIGO_EMPRESA
         )
         AND
         (
                  almacenes_zonas.codigo_empresa = '004'
         )
GROUP BY
         stocks_detallado.codigo_almacen
       , almacenes.nombre
       , articulos.codigo_estad3
       , articulos.codigo_sinonimo
       , stocks_detallado.codigo_articulo
       , articulos.descrip_comercial
       , articulos.codigo_estad6
       , stocks_detallado.codigo_zona
       , almacenes_zonas.descripcion
       , stocks_detallado.tipo_situacion
       , stocks_detallado.numero_lote_int
       , articulos.d_codigo_estad5
       , articulos.codigo_estad5
       , stocks_detallado.presentacion
       , articulos.dias_caducidad
	   ) s
	   WHERE s.tipo_situacion IN ('DISPO', 'NDISC')
		 AND s.codigo_almacen  = '04010'
		 AND s.CODIGO_ARTICULO IN ('00036845', '00034089')
		 AND s.CODIGO_ESTAD6 = 'PT'
		 GROUP BY s.CODIGO_ARTICULO) s LEFT JOIN ( SELECT h.codigo_zona,   h.codigo_movimiento movimiento, (select c.descripcion from codigos_movimiento c where c.codigo_empresa = h.codigo_empresa and h.codigo_movimiento = c.codigo_movimiento) desc_movimiento,h.codigo_articulo, h.CANTIDAD_UNIDAD1 CANTIDAD_MOVIDA, fecha_valor, (SELECT NOMBRE FROM CLIENTES WHERE CODIGO_EMPRESA = h.CODIGO_EMPRESA AND CODIGO_RAPIDO = SUCO_LLAMA_CTE_VTA(h.CODIGO_ARTICULO,h.NUMERO_DOC_INTERNO,h.TIPO_MOVIMIENTO , h.CODIGO_EMPRESA, h.NUMERO_LINEA, h.FECHA_MOVIM )) cliente_movimiento, SUCO_LLAMA_CTE_VTA(h.CODIGO_ARTICULO,h.NUMERO_DOC_INTERNO,h.TIPO_MOVIMIENTO , h.CODIGO_EMPRESA, h.NUMERO_LINEA, h.FECHA_MOVIM ) cliente23
FROM HISTORICO_MOVIM_ALMACEN h, ARTICULOS a WHERE( h.CODIGO_EMPRESA = a.CODIGO_EMPRESA and h.CODIGO_ARTICULO=a.CODIGO_ARTICULO) AND h.codigo_empresa  = '004' AND h.codigo_articulo IN ('00036845','00034089')
and to_char(h.fecha_valor,'ddMMyyyy') = to_char(sysdate-1,'ddMMyyyy') 
AND h.codigo_zona IN ('100','400')
and (h.codigo_movimiento in ('VTAS','IP611','DNEG','DVMPR','SACOC') or SUBSTR(h.codigo_movimiento,0,2)='TR')
and h.CODIGO_ZONA<>'900' ) m ON s.codigo_articulo = m.codigo_articulo LEFT JOIN ( SELECT C16 REGION, C12 COD_ARTICULO, C21 FECHA_FACTURA, N1 UNIDADES, N10 NUMERO_FACTURA, C13 CLIENTE, CLIENTE22  FROM (SELECT  SUBSTR(articulos.d_codigo_estad5,1,30) c1,SUBSTR(v_facturas_ventas_lin.tipo_pedido,1,3) c2,SUBSTR(v_facturas_ventas_lin.almacen,1,5) c3,SUBSTR(domicilios_envio.comarca,1,50) c4,SUBSTR(facturas_ventas.cadena,1,25) c5,DECODE(facturas_ventas.CANALV,'DISTRIBUIDORES','DISTRIBUIDORES','ACCESO','ACCESO','INDEPENDIENTE','INDEPENDIENTE',FACTURAS_VENTAS.CADENA) c6,SUBSTR(facturas_ventas.canalv,1,25) c7,SUBSTR(domicilios_envio.provincia,1,10) c8,SUBSTR(v_facturas_ventas_lin.cliente,1,15) c9,SUBSTR(agentes_clientes.agente,1,15) c10,SUBSTR(agentes.nif,1,15) c11,SUBSTR(articulos.codigo_articulo,1,20) c12,SUM(V_FACTURAS_VENTAS_LIN.UNIDADES_SERVIDAS) n1,SUBSTR(facturas_ventas.d_cliente,1,30) c13,SUBSTR(articulos.descrip_comercial,1,30) c14,SUBSTR(domicilios_envio.direccion,1,10) c15,decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ORU','0460','SCR','0461','POT','0470','BENI','0471','PAN','SIN REG') c16,facturas_ventas.dto_pronto_pago n2,facturas_ventas.dtos_global n3,MAX((SELECT NOMBRE FROM PROVINCIAS P WHERE P.PROVINCIA = DOMICILIOS_ENVIO.PROVINCIA AND P.ESTADO = DOMICILIOS_ENVIO.ESTADO)) c17,MAX((SELECT p.nombre FROM comunidades_autonomas p WHERE p.comunidad_autonoma = domicilios_envio.cadena and p.estado=domicilios_envio.estado)) c18,MAX((SELECT p.nombre FROM formas_cobro_pago p WHERE p.codigo = FACTURAS_VENTAS.FORMA_COBRO)) c19,MAX((SELECT DESCRIPCION FROM ZONAS Z WHERE Z.CODIGO = DOMICILIOS_ENVIO.ZONA AND Z.EMPRESA = DOMICILIOS_ENVIO.EMPRESA)) c20,facturas_ventas.ejercicio n4,facturas_ventas.fecha_factura c21,SUBSTR(facturas_ventas.forma_cobro,1,10) c22,max((SELECT h.fecha_caducidad FROM historico_lotes h WHERE h.numero_lote_int=pkconsgen.get_numero_lote_int_albvta(FACTURAS_VENTAS.empresa,V_FACTURAS_VENTAS_LIN.articulo,V_FACTURAS_VENTAS_LIN.numero_albaran,V_FACTURAS_VENTAS_LIN.numero_serie,V_FACTURAS_VENTAS_LIN.ejercicio,V_FACTURAS_VENTAS_LIN.sub_albaran,V_FACTURAS_VENTAS_LIN.organizacion_comercial,V_FACTURAS_VENTAS_LIN.numero_linea_albaran) AND h.codigo_articulo=V_FACTURAS_VENTAS_LIN.articulo AND h.codigo_empresa=FACTURAS_VENTAS.empresa)) c23,MAX((SELECT h.descripcion_lote2 FROM historico_lotes h WHERE h.numero_lote_int=pkconsgen.get_numero_lote_int_albvta(FACTURAS_VENTAS.empresa,V_FACTURAS_VENTAS_LIN.articulo,V_FACTURAS_VENTAS_LIN.numero_albaran,V_FACTURAS_VENTAS_LIN.numero_serie,V_FACTURAS_VENTAS_LIN.ejercicio,V_FACTURAS_VENTAS_LIN.sub_albaran,V_FACTURAS_VENTAS_LIN.organizacion_comercial,V_FACTURAS_VENTAS_LIN.numero_linea_albaran) AND h.codigo_articulo=V_FACTURAS_VENTAS_LIN.articulo AND h.codigo_empresa=FACTURAS_VENTAS.empresa)) c24,facturas_ventas.imp_dto_global n5,facturas_ventas.imp_dto_pronto_pago n6,SUBSTR(articulos.d_codigo_estad2,1,25) c25,SUBSTR(articulos.codigo_estad2,1,15) c26,facturas_ventas.liquido_factura n7,MAX((SELECT VALOR_ALFA_2 FROM CARACTERISTICAS_LOTES C WHERE C.CODIGO_EMPRESA=FACTURAS_VENTAS.EMPRESA AND V_FACTURAS_VENTAS_LIN.ARTICULO=C.CODIGO_ARTICULO AND C.NUMERO_LOTE_INT=pkconsgen.get_numero_lote_int_albvta(V_FACTURAS_VENTAS_LIN.empresa,V_FACTURAS_VENTAS_LIN.articulo,V_FACTURAS_VENTAS_LIN.numero_albaran,V_FACTURAS_VENTAS_LIN.numero_serie,V_FACTURAS_VENTAS_LIN.ejercicio,V_FACTURAS_VENTAS_LIN.sub_albaran,V_FACTURAS_VENTAS_LIN.organizacion_comercial,V_FACTURAS_VENTAS_LIN.numero_linea_albaran))) c27,pkconsgen.get_numero_lote_int_albvta(V_FACTURAS_VENTAS_LIN.empresa,
V_FACTURAS_VENTAS_LIN.articulo,
V_FACTURAS_VENTAS_LIN.numero_albaran,
V_FACTURAS_VENTAS_LIN.numero_serie,
V_FACTURAS_VENTAS_LIN.ejercicio,
V_FACTURAS_VENTAS_LIN.sub_albaran,
V_FACTURAS_VENTAS_LIN.organizacion_comercial,
V_FACTURAS_VENTAS_LIN.numero_linea_albaran) c28,SUBSTR(agentes.nombre,1,40) c29,SUBSTR(domicilios_envio.nombre,1,20) c30,domicilios_envio.numero_direccion n8,v_facturas_ventas_lin.numero_albaran n9,facturas_ventas.numero_factura n10,v_facturas_ventas_lin.numero_linea_albaran n11,SUBSTR(v_facturas_ventas_lin.numero_serie,1,3) c31,SUBSTR(v_facturas_ventas_lin.numero_serie_fra,1,3) c32,SUBSTR(facturas_ventas.organizacion_comercial,1,5) c33,decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ALTO','0460','SCR','0461','SCR','0470','BENI','0471','BENI','SIN REG') c34,SUBSTR(clientes.reservadoa01,1,10) c35,SUBSTR(articulos.d_codigo_estad4,1,25) c36,SUBSTR(articulos.codigo_estad4,1,15) c37,v_facturas_ventas_lin.sub_albaran n12,SUBSTR(domicilios_envio.municipio,1,30) c38,SUBSTR(clientes.tipo_cliente,1,3) c39,SUBSTR(articulos.codigo_estad3,1,15) c40,sum((V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN-(V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN*FACTURAS_VENTAS.DTOS_GLOBAL)/100)*0.87) n13,sum(V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN-(V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN*FACTURAS_VENTAS.DTOS_GLOBAL)/100) n14,NULL gi$color, FACTURAS_VENTAS.CLIENTE CLIENTE22   FROM (SELECT FACTURAS_VENTAS.*,(SELECT NOMBRE FROM VALORES_CLAVES V WHERE V.CLAVE ='CADN' AND V.VALOR_CLAVE=(SELECT VALOR_CLAVE FROM  CLIENTES_CLAVES_ESTADISTICAS c WHERE c.CLAVE='CADN' AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE AND c.CODIGO_EMPRESA=facturas_ventas.empresa)) CADENA,(SELECT NOMBRE FROM VALORES_CLAVES V WHERE V.CLAVE ='CANALV' AND V.VALOR_CLAVE=(SELECT VALOR_CLAVE FROM  CLIENTES_CLAVES_ESTADISTICAS c WHERE c.CLAVE='CANALV' AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE AND c.CODIGO_EMPRESA=facturas_ventas.empresa)) CANALV,(SELECT c.nombre FROM clientes c WHERE c.codigo_rapido = facturas_ventas.cliente AND c.codigo_empresa = facturas_ventas.empresa) D_CLIENTE,TO_CHAR(FACTURAS_VENTAS.FECHA_FACTURA,'MM') V_MES FROM FACTURAS_VENTAS) FACTURAS_VENTAS,CLIENTES,V_FACTURAS_VENTAS_LIN,(SELECT ARTICULOS.*,DECODE(articulos.codigo_estad5,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad5 AND lvfm.numero_tabla = 5 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD5,DECODE(articulos.codigo_estad2,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad2 AND lvfm.numero_tabla = 2 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD2,DECODE(articulos.codigo_estad4,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad4 AND lvfm.numero_tabla = 4 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD4 FROM ARTICULOS) ARTICULOS,DOMICILIOS_ENVIO,AGENTES_CLIENTES,AGENTES WHERE (not exists (select 1 from FACTURAS_SUSTITUCIONES where FACTURAS_VENTAS.EMPRESA=FACTURAS_SUSTITUCIONES.EMPRESA and FACTURAS_VENTAS.EJERCICIO=FACTURAS_SUSTITUCIONES.EJERCICIO and FACTURAS_VENTAS.NUMERO_SERIE=FACTURAS_SUSTITUCIONES.NUMERO_SERIE and FACTURAS_VENTAS.NUMERO_FACTURA = FACTURAS_SUSTITUCIONES.NUMERO_FACTURA) AND (FACTURAS_VENTAS.EMPRESA = CLIENTES.CODIGO_EMPRESA AND FACTURAS_VENTAS.CLIENTE = CLIENTES.CODIGO_RAPIDO AND FACTURAS_VENTAS.NUMERO_FACTURA= V_FACTURAS_VENTAS_LIN.NUMERO_FACTURA AND  FACTURAS_VENTAS.NUMERO_SERIE = V_FACTURAS_VENTAS_LIN.NUMERO_SERIE_FRA AND FACTURAS_VENTAS.ORGANIZACION_COMERCIAL = V_FACTURAS_VENTAS_LIN.ORGANIZACION_COMERCIAL AND  FACTURAS_VENTAS.EJERCICIO = V_FACTURAS_VENTAS_LIN.EJERCICIO_FACTURA and V_FACTURAS_VENTAS_LIN.EMPRESA=ARTICULOS.CODIGO_EMPRESA and V_FACTURAS_VENTAS_LIN.ARTICULO=ARTICULOS.CODIGO_ARTICULO AND FACTURAS_VENTAS.EMPRESA='004') AND (FACTURAS_VENTAS.NUMERO_SERIE <> 'CAN')  AND EXISTS (SELECT 1 FROM almacenes_usuarios au WHERE au.codigo_empresa='004' AND au.usuario='JMENACHO' AND au.codigo_almacen = V_FACTURAS_VENTAS_LIN.almacen) and V_FACTURAS_VENTAS_LIN.EMPRESA=DOMICILIOS_ENVIO.EMPRESA and V_FACTURAS_VENTAS_LIN.CLIENTE=DOMICILIOS_ENVIO.CODIGO_CLIENTE and V_FACTURAS_VENTAS_LIN.DOMICILIO_ENVIO=DOMICILIOS_ENVIO.NUMERO_DIRECCION and FACTURAS_VENTAS.CLIENTE=AGENTES_CLIENTES.CODIGO_CLIENTE and FACTURAS_VENTAS.EMPRESA=AGENTES_CLIENTES.EMPRESA and (agentes.empresa=clientes.codigo_empresa and agentes.codigo=AGENTES_CLIENTES.AGENTE)) AND (facturas_ventas.empresa = '004') AND (clientes.codigo_empresa = '004' 
 AND ((clientes.grupo_balance IS NULL AND clientes.centro_contable IS NULL) OR (clientes.grupo_balance IS NOT NULL AND EXISTS (SELECT 1 FROM usuarios_gb ug WHERE ug.codigo_empresa = '004' AND ug.usuario = 'JMENACHO' AND ug.grupo_balance = clientes.grupo_balance)) OR (clientes.centro_contable IS NOT NULL AND EXISTS (SELECT 1 FROM centros_grupo_ccont cgc, usuarios_gb ug WHERE ug.codigo_empresa = '004' AND ug.usuario = 'JMENACHO' AND ug.grupo_balance = cgc.codigo_grupo AND cgc.codigo_centro = clientes.centro_contable AND cgc.empresa = '004')))
 AND (clientes.centro_contable IS NULL OR EXISTS (SELECT 1 FROM centros_grupo_ccont cgc, usuarios_gb ug WHERE ug.codigo_empresa = '004' AND ug.usuario = 'JMENACHO' AND ug.grupo_balance = cgc.codigo_grupo AND cgc.codigo_centro = clientes.centro_contable AND cgc.empresa = '004'))) AND (articulos.codigo_empresa = '004'
 AND (articulos.centro_contable IS NULL OR EXISTS (SELECT 1 FROM centros_grupo_ccont cgc, usuarios_gb ug WHERE ug.codigo_empresa = '004' AND ug.usuario = 'JMENACHO' AND ug.grupo_balance = cgc.codigo_grupo AND cgc.codigo_centro = articulos.centro_contable AND cgc.empresa = '004'))
) AND (domicilios_envio.empresa = '004') AND (agentes_clientes.empresa = '004') AND (agentes.empresa = '004') AND v_facturas_ventas_lin.tipo_pedido BETWEEN '10' AND '50'  GROUP BY  SUBSTR(articulos.d_codigo_estad5,1,30),SUBSTR(v_facturas_ventas_lin.tipo_pedido,1,3),SUBSTR(v_facturas_ventas_lin.almacen,1,5),SUBSTR(domicilios_envio.comarca,1,50),SUBSTR(facturas_ventas.cadena,1,25),DECODE(facturas_ventas.CANALV,'DISTRIBUIDORES','DISTRIBUIDORES','ACCESO','ACCESO','INDEPENDIENTE','INDEPENDIENTE',FACTURAS_VENTAS.CADENA),SUBSTR(facturas_ventas.canalv,1,25),SUBSTR(domicilios_envio.provincia,1,10),SUBSTR(v_facturas_ventas_lin.cliente,1,15),SUBSTR(agentes_clientes.agente,1,15),SUBSTR(agentes.nif,1,15),SUBSTR(articulos.codigo_articulo,1,20),SUBSTR(facturas_ventas.d_cliente,1,30),SUBSTR(articulos.descrip_comercial,1,30),SUBSTR(domicilios_envio.direccion,1,10),decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ORU','0460','SCR','0461','POT','0470','BENI','0471','PAN','SIN REG'),facturas_ventas.dto_pronto_pago,facturas_ventas.dtos_global,facturas_ventas.ejercicio,facturas_ventas.fecha_factura,SUBSTR(facturas_ventas.forma_cobro,1,10),facturas_ventas.imp_dto_global,facturas_ventas.imp_dto_pronto_pago,SUBSTR(articulos.d_codigo_estad2,1,25),SUBSTR(articulos.codigo_estad2,1,15),facturas_ventas.liquido_factura,pkconsgen.get_numero_lote_int_albvta(V_FACTURAS_VENTAS_LIN.empresa,
V_FACTURAS_VENTAS_LIN.articulo,
V_FACTURAS_VENTAS_LIN.numero_albaran,
V_FACTURAS_VENTAS_LIN.numero_serie,
V_FACTURAS_VENTAS_LIN.ejercicio,
V_FACTURAS_VENTAS_LIN.sub_albaran,
V_FACTURAS_VENTAS_LIN.organizacion_comercial,
V_FACTURAS_VENTAS_LIN.numero_linea_albaran),SUBSTR(agentes.nombre,1,40),SUBSTR(domicilios_envio.nombre,1,20),domicilios_envio.numero_direccion,v_facturas_ventas_lin.numero_albaran,facturas_ventas.numero_factura,v_facturas_ventas_lin.numero_linea_albaran,SUBSTR(v_facturas_ventas_lin.numero_serie,1,3),SUBSTR(v_facturas_ventas_lin.numero_serie_fra,1,3),SUBSTR(facturas_ventas.organizacion_comercial,1,5),decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ALTO','0460','SCR','0461','SCR','0470','BENI','0471','BENI','SIN REG'),SUBSTR(clientes.reservadoa01,1,10),SUBSTR(articulos.d_codigo_estad4,1,25),SUBSTR(articulos.codigo_estad4,1,15),v_facturas_ventas_lin.sub_albaran,SUBSTR(domicilios_envio.municipio,1,30),SUBSTR(clientes.tipo_cliente,1,3),SUBSTR(articulos.codigo_estad3,1,15), FACTURAS_VENTAS.CLIENTE ORDER BY  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,54 DESC) WHERE c12 IN ('00036845', '00034089') AND C16 IN ('SCZ', 'TJA', 'BENI') AND TO_CHAR(C21,'ddMMyyyy') = TO_CHAR(trunc(sysdate)-1,'ddMMyyyy')) f ON m.codigo_articulo = f.cod_articulo and m.movimiento = 'VTAS' and f.FECHA_FACTURA = m.fecha_valor and m.cliente23 = f.cliente22