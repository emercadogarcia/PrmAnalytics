CREATE OR REPLACE VIEW BOL_TI_RPT_MEGAREPORTE_STOCK AS SELECT   stocks_detallado.CODIGO_ALMACEN, (SELECT NOMBRE
FROM ALMACENES
WHERE CODIGO_EMPRESA = '999' AND ALMACEN = stocks_detallado.CODIGO_ALMACEN) NOMBRE_ALMACEN, articulos.CODIGO_ESTAD6 TIPO_ARTICULO, articulos.d_codigo_estad5 UEN, articulos.CODIGO_SITUACION
	   , stocks_detallado.codigo_articulo CODIGO_ARTICULO
       , articulos.descrip_comercial DESCRIPCION_ARTICULO                                                                                          
	   ,(
	    SELECT sum(r.TOTAL_CANTIDAD) tot_cant FROM (select
       sum(dd.CANTIDAD) TOTAL_CANTIDAD,(
                            SELECT
                                    CASE WHEN C.NOMBRE LIKE '%SCZ%' THEN '04010'
									WHEN C.NOMBRE LIKE '%SANTA%' THEN '04010'
									WHEN C.NOMBRE LIKE '%ALTO%' THEN '04014'
									WHEN C.NOMBRE LIKE '%CBBA%' THEN '04011'
									WHEN C.NOMBRE LIKE '%COCHA%' THEN '04011'
									WHEN C.NOMBRE LIKE '%POT%' THEN '04011'
									WHEN C.NOMBRE LIKE '%LPZ%' THEN '04014'
									WHEN C.NOMBRE LIKE '%PAZ%' THEN '04014'
									WHEN C.NOMBRE LIKE '%ORU%' THEN '04014'
									WHEN C.NOMBRE LIKE '%TJA%' THEN '04010'
									WHEN C.NOMBRE LIKE '%TARIJ%' THEN '04010'
									WHEN C.NOMBRE LIKE '%TAR%' THEN '04010'
									WHEN C.NOMBRE LIKE '%SCR%' THEN '04011'
									WHEN C.NOMBRE LIKE '%SUCR%' THEN '04011'
									WHEN C.NOMBRE LIKE '%BEN%' THEN '04010'
									WHEN C.NOMBRE LIKE '%PAN%' THEN '04010'
									ELSE '-' END ALMAC
                            FROM
                                   clientes c
                            WHERE
                                   c.codigo_empresa    = d.empresa
                                   and c.codigo_rapido = d.cliente
                     ) COD_ALMACEN, d.articulo
from
       PLANES_VENTAS_LIN     D
     , PLANES_VENTAS         M
     , PLANES_VENTAS_LIN_DET DD
where
       d.codigo                    = m.codigo
       and d.empresa               = m.empresa
       and DD.CODIGO               = m.codigo
       and dd.empresa              = m.empresa
       and d.linea                 = dd.linea
       and m.empresa               = '004'
       and dd.PERIODO              = to_char(sysdate,'MM')
       and UPPER(m.descripcion) like '%UNIDADES%'
       and dd.EJERCICIO            = to_char(sysdate,'YYYY')
	   GROUP BY d.empresa, D.CLIENTE, d.articulo)
	   r where r.articulo = stocks_detallado.codigo_articulo
	   and r.cod_almacen = stocks_detallado.codigo_almacen
	   group by r.articulo, r.cod_almacen
	   /*UNION ALL
	   select  SUM(PPTO_UND) tot_cant
from BOL_BI_VTAS_PPTO
where ejercicio   = to_char(sysdate,'YYYY')
         and V_MES       = to_char(sysdate,'MM')
		 and codigo_articulo = stocks_detallado.codigo_articulo
		 and decode(reg, 'SCZ','04010', 'LPZ','04014','CBBA', '04011','TJA', '04012','ALTO','04014','SCR','04013', '') = stocks_detallado.CODIGO_ALMACEN*/
	   ) VENTAS_OBJETIVO_UNIDAD
	   ,(
	    SELECT SUM(BOL_BI_VTAS_PPTO.CANTIDAD) CANTIDAD_VENTAS
		FROM BOL_BI_VTAS_PPTO
		WHERE    BOL_BI_VTAS_PPTO.UEN  = articulos.d_codigo_estad5
				 AND bol_bi_vtas_ppto.codigo_articulo = stocks_detallado.codigo_articulo
				 AND bol_bi_vtas_ppto.tipo_pedido BETWEEN '10' AND '50'
				 AND bol_bi_vtas_ppto.ejercicio = TO_CHAR(sysdate, 'YYYY')
				 AND bol_bi_vtas_ppto.v_mes = TO_CHAR(sysdate, 'MM')
				 AND bol_bi_vtas_ppto.COD_ALMAC = stocks_detallado.CODIGO_ALMACEN
	   ) VENTA_FACTURADA
	   ,(
	   
	   SELECT
         sum(V_FACTURAS_VENTAS_LIN.UNIDADES_SERVIDAS) CANT_ANULADAS
FROM
         (
                SELECT
                       FACTURAS_VENTAS.*
                     , (
                              SELECT
                                     c.nombre
                              FROM
                                     clientes c
                              WHERE
                                     c.codigo_rapido      = facturas_ventas.cliente
                                     AND c.codigo_empresa = facturas_ventas.empresa
                       )
                       D_CLIENTE
                FROM
                       FACTURAS_VENTAS
         )
         FACTURAS_VENTAS
       , FACTURAS_SUSTITUCIONES
       , CLIENTES
       , V_FACTURAS_VENTAS_LIN
       , (
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
                     , DECODE(articulos.codigo_estad2,NULL,NULL, (
                              SELECT
                                     lvfm.descripcion
                              FROM
                                     familias lvfm
                              WHERE
                                     lvfm.codigo_familia     = articulos.codigo_estad2
                                     AND lvfm.numero_tabla   = 2
                                     AND lvfm.codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD2
                     , DECODE(articulos.codigo_estad4,NULL,NULL, (
                              SELECT
                                     lvfm.descripcion
                              FROM
                                     familias lvfm
                              WHERE
                                     lvfm.codigo_familia     = articulos.codigo_estad4
                                     AND lvfm.numero_tabla   = 4
                                     AND lvfm.codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD4
                FROM
                       ARTICULOS
         )
         ARTICULOS_ANULADOS
WHERE
         (
                  (
                           FACTURAS_VENTAS.EMPRESA                    =FACTURAS_SUSTITUCIONES.EMPRESA(+)
                           and FACTURAS_VENTAS.EJERCICIO              =FACTURAS_SUSTITUCIONES.EJERCICIO(+)
                           and FACTURAS_VENTAS.NUMERO_SERIE           =FACTURAS_SUSTITUCIONES.NUMERO_SERIE(+)
                           and FACTURAS_VENTAS.NUMERO_FACTURA         = FACTURAS_SUSTITUCIONES.NUMERO_FACTURA(+)
                           AND FACTURAS_VENTAS.EMPRESA                = CLIENTES.CODIGO_EMPRESA
                           AND FACTURAS_VENTAS.CLIENTE                = CLIENTES.CODIGO_RAPIDO
                           AND FACTURAS_VENTAS.NUMERO_FACTURA         = V_FACTURAS_VENTAS_LIN.NUMERO_FACTURA
                           AND FACTURAS_VENTAS.NUMERO_SERIE           = V_FACTURAS_VENTAS_LIN.NUMERO_SERIE_FRA
                           AND FACTURAS_VENTAS.ORGANIZACION_COMERCIAL = V_FACTURAS_VENTAS_LIN.ORGANIZACION_COMERCIAL
                           AND FACTURAS_VENTAS.EJERCICIO              = V_FACTURAS_VENTAS_LIN.EJERCICIO_FACTURA
                           and V_FACTURAS_VENTAS_LIN.EMPRESA          =ARTICULOS_ANULADOS.CODIGO_EMPRESA
                           and V_FACTURAS_VENTAS_LIN.ARTICULO         =ARTICULOS_ANULADOS.CODIGO_ARTICULO
                           AND FACTURAS_VENTAS.EMPRESA                = STOCKS_DETALLADO.CODIGO_EMPRESA
                  )
                  AND
                  (
                           FACTURAS_SUSTITUCIONES.USUARIO_GRABACION IS NOT NULL
                  )
         )
         AND
         (
                  facturas_ventas.empresa = STOCKS_DETALLADO.CODIGO_EMPRESA
         )
         AND
         (
                  clientes.codigo_empresa = STOCKS_DETALLADO.CODIGO_EMPRESA
         )
         AND
         (
                  ARTICULOS_ANULADOS.codigo_empresa = STOCKS_DETALLADO.CODIGO_EMPRESA
         )
         AND facturas_ventas.fecha_factura BETWEEN  '01/'||to_char(last_day(sysdate),'MM/YYYY') and TO_CHAR(TO_DATE(last_day(sysdate),'DD/MM/YYYY'))
         AND v_facturas_ventas_lin.tipo_pedido BETWEEN '11' AND '45'
		 AND ARTICULOS_ANULADOS.codigo_articulo = stocks_detallado.codigo_articulo
		 AND V_FACTURAS_VENTAS_LIN.ALMACEN = STOCKS_DETALLADO.codigo_almacen
	   ) CANTIDAD_ANULADAS
	   , SUM(STOCKS_DETALLADO.CANTIDAD_UNIDAD1) CANTIDAD_STOCK
	   ,(
	    SELECT decode(SUM(BOL_BI_VTAS_PPTO.PPTO_VLR),null,null,0,0,(SUM(BOL_BI_VTAS_PPTO.IMP_NETO)/SUM(BOL_BI_VTAS_PPTO.PPTO_VLR))*100) CANT_CUMPLIMIENTO
		FROM BOL_BI_VTAS_PPTO
		WHERE    BOL_BI_VTAS_PPTO.UEN  = articulos.d_codigo_estad5
				 AND bol_bi_vtas_ppto.codigo_articulo = stocks_detallado.codigo_articulo
				 AND bol_bi_vtas_ppto.tipo_pedido BETWEEN '10' AND '50'
				 AND bol_bi_vtas_ppto.ejercicio = TO_CHAR(sysdate, 'YYYY')
				 AND bol_bi_vtas_ppto.v_mes = TO_CHAR(sysdate, 'MM')
	   ) CANTIDAD_CUMPLIMIENTO
	   ,(
	   SELECT  SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona = 460
	   ) PROXIMO_A_VENCER_460
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona = 111
	   ) ZONA_MALTRATADOS_111
	   /*,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona = 462
	   ) ZONA_CALIDAD_462*/
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona = 480
	   ) ZONA_RESERVA_INSTITUCIONES_480
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (400)
		and sd.TIPO_SITUACION = 'RESER'
	   ) ZONA_ALISTAMIENTO_400_RESER
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (400)
		and sd.TIPO_SITUACION = 'DISPO'
	   ) ZONA_DISPONIBLE_400_DISPO
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (800)
	   ) TRANSITO_REGIONALES_800
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (100)
		and sd.TIPO_SITUACION in ('CALID')
	   ) CALIDAD_100
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (112)
	   ) REPROCESO_112
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (461)
	   ) CORTO_VENCIMIENTO_UBICADO_461
	   ,(
	   SELECT SUM(sd.CANTIDAD_UNIDAD1)
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona IN (120)
	   ) DEVOLUCIONES_CLIENTES_120
	   , (SELECT SUM(SUBTOTAL) SUB_OTRAS_AREAS FROM (
	   SELECT  SUM(sd.CANTIDAD_UNIDAD1) SUBTOTAL
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona NOT IN (460, 111, 480, 400, 800, 112, 461,120, 100)
		UNION ALL
		SELECT SUM(sd.CANTIDAD_UNIDAD1) SUBTOTAL
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona  = '400' and sd.TIPO_SITUACION not in ('RESER', 'DISPO')
		UNION ALL
		SELECT SUM(sd.CANTIDAD_UNIDAD1) SUBTOTAL
		FROM almacenes_zonas az, STOCKS_DETALLADO sd WHERE az.codigo_zona = sd.codigo_zona
		AND az.codigo_almacen = sd.codigo_almacen
		AND az.codigo_empresa = sd.codigo_empresa
		AND sd.codigo_articulo = STOCKS_DETALLADO.CODIGO_ARTICULO 	
		AND sd.codigo_empresa  = STOCKS_DETALLADO.CODIGO_EMPRESA 
		AND sd.codigo_almacen = STOCKS_DETALLADO.codigo_almacen
		AND az.codigo_zona  = '100' and sd.TIPO_SITUACION not in ('CALID')
	   )) ZONA_OTRAS_AREAS
	   ,(
	   SELECT  LISTAGG('PEDIDO: '|| NUMERO_PEDIDO || ' - FECHA ENTREGA: ' || FECHA_ENTREGA || ' - UNIDADES: ' || UNIDADES_PEDIDAS, ',') WITHIN GROUP (ORDER BY UNIDADES_PEDIDAS) AS DETALLE_IMPORTACIONES
		 FROM  PEDIDOS_COMPRAS_LIN
		 WHERE CODIGO_EMPRESA   = STOCKS_DETALLADO.CODIGO_EMPRESA
         AND STATUS_CIERRE    = 'E'
         AND CODIGO_ARTICULO = STOCKS_DETALLADO.CODIGO_ARTICULO 
         AND FECHA_ENTREGA > sysdate
	   ) DATOS_IMPORTACIONES
	   , 0 COBERTURA
	   , 0 ABASTECIMIENTO
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
                     , DECODE(articulos.codigo_estad2,NULL,NULL, (
                              SELECT
                                     lvfm.descripcion
                              FROM
                                     familias lvfm
                              WHERE
                                     lvfm.codigo_familia     = articulos.codigo_estad2
                                     AND lvfm.numero_tabla   = 2
                                     AND lvfm.codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD2
                     , DECODE(articulos.codigo_estad4,NULL,NULL, (
                              SELECT
                                     lvfm.descripcion
                              FROM
                                     familias lvfm
                              WHERE
                                     lvfm.codigo_familia     = articulos.codigo_estad4
                                     AND lvfm.numero_tabla   = 4
                                     AND lvfm.codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD4
                FROM
                       ARTICULOS
         )
         ARTICULOS
       , STOCKS_DETALLADO
       , ALMACENES
       , ALMACENES_ZONAS
WHERE STOCKS_DETALLADO.CODIGO_EMPRESA        = '004'
                  AND STOCKS_DETALLADO.CODIGO_EMPRESA    = ARTICULOS.CODIGO_EMPRESA
                  AND STOCKS_DETALLADO.CODIGO_ARTICULO   = ARTICULOS.CODIGO_ARTICULO
                  /*AND STOCKS_DETALLADO.CANTIDAD_UNIDAD1 <> 0*/
                  AND STOCKS_DETALLADO.CODIGO_EMPRESA    = ALMACENES.CODIGO_EMPRESA
                  AND STOCKS_DETALLADO.CODIGO_ALMACEN    = ALMACENES.ALMACEN
                  AND ALMACENES_ZONAS.CODIGO_ALMACEN     = STOCKS_DETALLADO.CODIGO_ALMACEN
                  AND STOCKS_DETALLADO.CODIGO_ZONA       = ALMACENES_ZONAS.CODIGO_ZONA
                  AND STOCKS_DETALLADO.CODIGO_EMPRESA    = ALMACENES_ZONAS.CODIGO_EMPRESA
				  AND articulos.CODIGO_ESTAD6 IN ('PT','MM')
				  --AND STOCKS_DETALLADO.CODIGO_ARTICULO = '00030339'
				  AND STOCKS_DETALLADO.CODIGO_ALMACEN IN ('04010','04011','04014')
GROUP BY articulos.d_codigo_estad5
	   , stocks_detallado.codigo_articulo, STOCKS_DETALLADO.CODIGO_EMPRESA
       , articulos.descrip_comercial,stocks_detallado.CODIGO_ALMACEN, articulos.CODIGO_ESTAD6, CODIGO_SITUACION
ORDER BY articulos.d_codigo_estad5, stocks_detallado.codigo_articulo