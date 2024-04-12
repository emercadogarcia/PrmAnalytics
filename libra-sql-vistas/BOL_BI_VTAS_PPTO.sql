CREATE OR REPLACE FORCE VIEW BOL_BI_VTAS_PPTO(FECHA_FACTURA, EJERCICIO, V_MES, REG, SUBREG, CANALV, CADENA, RPN2, RPN3, RPN4, RPN5, RPN6, CADENA_AUX, AGENTE, COD_RPN, NOMBRE_AGENTE, CLIENTE_ID, CLIENTE_NOMBRE, CAT_COD, CAT, UEN, CODIGO_ESTAD5, LAB, 
CODIGO_ARTICULO, ARTICULO_NOMBRE, JP_COD, JP_NOMBRE, ST_COD, ST_NOMBRE, TIPO_PEDIDO, USUARIO_PEDIDO, TIPO, TIPO_VTA, FUENTE, CANTIDAD, IMP_NETO, IMP_FACTURADO, PPTO_UND, PPTO_VLR, GESTOR_VTAS, COD_ALMAC, 
UEN_AUX1) AS
SELECT /*BOL_BI_VTAS_PPTO by Edgar Mercado*/
         FACTURAS_VENTAS.fecha_factura
       , facturas_ventas.ejercicio
       , facturas_ventas.v_mes
       , decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ALTO','0460','SCR','0461','SCR','0470','BENI','0471','BENI','SIN REG') REG
       , decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ORU','0460','SCR','0461','POT','0470','BENI','0471','PAN','SIN REG')   SUBREG
       , facturas_ventas.canalv
       , facturas_ventas.cadena
       , facturas_ventas.RPN2
       , facturas_ventas.RPN3
       , facturas_ventas.RPN4
       , facturas_ventas.RPN5
       , facturas_ventas.RPN6
       , TNEGOCIO /* DECODE(facturas_ventas.CANALV,'DISTRIBUIDORES','DISTRIBUIDORES','ACCESO','ACCESO','INDEPENDIENTE','INDEPENDIENTE',FACTURAS_VENTAS.CADENA) */ CADENA_AUX
       , agentes_clientes.agente
       , agentes.nif                   COD_RPN
       , agentes.nombre                NOMBRE_AGENTE
       , v_facturas_ventas_lin.cliente CLIENTE_ID
       , facturas_ventas.d_cliente     CLIENTE_NOMBRE
       , clientes.tipo_cliente         CAT_COD
       , (
          SELECT
           REPLACE(tipos_cliente.descripcion,'CATEGORÍA ','')
          FROM TIPOS_CLIENTE
          WHERE tipos_cliente.codigo=CLIENTES.TIPO_CLIENTE
         ) CAT
       , articulos.d_codigo_estad5 UEN
	   , articulos.codigo_estad5
       , articulos.codigo_estad3   LAB
       , articulos.codigo_articulo
       , articulos.descrip_comercial ARTICULO_NOMBRE
       , articulos.codigo_estad2     JP_COD
       , articulos.d_codigo_estad2   JP_NOMBRE
       , articulos.codigo_estad4     ST_COD
       , articulos.d_codigo_estad4   ST_NOMBRE
       , v_facturas_ventas_lin.tipo_pedido
       , NVL(v_facturas_ventas_lin.usuario_pedido, FACTURAS_VENTAS.USUARIO) usuario_pedido /*nuevo campo agregado*/
       , DECODE(v_facturas_ventas_lin.tipo_pedido,'10','ENTIDADES','ÉTICO') TIPO
       , DECODE(v_facturas_ventas_lin.tipo_pedido,'10','ENTIDADES','11','ÉTICO','12','ÉTICO','13','ÉTICO','NOTA CREDITO')            TIPO_VTA
       ,'VTAS'  FUENTE
       , SUM(V_FACTURAS_VENTAS_LIN.UNIDADES_SERVIDAS)                                                                                CANTIDAD
       , sum((V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN-(V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN*FACTURAS_VENTAS.DTOS_GLOBAL)/100)*0.87) IMP_NETO
       , sum(V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN-(V_FACTURAS_VENTAS_LIN.IMPORTE_NETO_LIN*FACTURAS_VENTAS.DTOS_GLOBAL)/100)        IMP_FACTURADO
       , 0                                                                                                                           PPTO_UND
       , 0                                                                                                                           PPTO_VLR
       , CASE /*nUEVA CONFGG: 08/09/2023*/
             when articulos.codigo_estad3 in ('GRUNENTHAL')
             THEN trim(subStr(facturas_ventas.RPN2,0,3))
             when articulos.codigo_estad5 in ('040101')
             THEN trim(subStr(facturas_ventas.RPN2,0,3))
             when articulos.codigo_estad3 in ('HERSIL')
             THEN trim(subStr(facturas_ventas.RPN4,0,3))
             when articulos.codigo_estad3 in ('BONAPHARM')
             THEN trim(subStr(facturas_ventas.RPN5,0,3))
             when articulos.codigo_estad3 in ('LAFAGE')
             THEN trim(subStr(facturas_ventas.RPN6,0,3))
             else agentes.nif
          end GESTOR_VTAS /* Fin nueva confgi*/
		 , V_FACTURAS_VENTAS_LIN.ALMACEN COD_ALMAC
         , DECODE(articulos.codigo_estad3,'LAFAGE', articulos.D_CODIGO_ESTAD5||' - '||articulos.codigo_estad3, 'BONAPHARM', articulos.D_CODIGO_ESTAD5||' - '||articulos.codigo_estad3, articulos.D_CODIGO_ESTAD5) UEN_AUX1
FROM
         (
                SELECT
                       FACTURAS_VENTAS.*
                     , TO_CHAR(FACTURAS_VENTAS.FECHA_FACTURA,'MM')-0 V_MES
                     , (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='CANALV'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='CANALV'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       )
                       CANALV
                     , (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='CADN'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='CADN'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       )
                       CADENA
                    , (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='TNEG'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='TNEG'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       ) TNEGOCIO
           			, (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='RPN2'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='RPN2'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       )
                       RPN2
                     , (
                            SELECT NOMBRE
                              FROM VALORES_CLAVES V
                              WHERE V.CLAVE='RPN3' AND V.VALOR_CLAVE= (
                                   SELECT VALOR_CLAVE
                                     FROM CLIENTES_CLAVES_ESTADISTICAS c
                                     WHERE c.CLAVE ='RPN3'  AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                      AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       )
                       RPN3
                     , (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='RPN4'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='RPN4'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       )
                       RPN4
                      , (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='RPN5'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='RPN5'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       ) RPN5
                     , (
                              SELECT
                                     NOMBRE
                              FROM
                                     VALORES_CLAVES V
                              WHERE
                                     V.CLAVE          ='RPN6'
                                     AND V.VALOR_CLAVE=
                                     (
                                            SELECT
                                                   VALOR_CLAVE
                                            FROM
                                                   CLIENTES_CLAVES_ESTADISTICAS c
                                            WHERE
                                                   c.CLAVE             ='RPN6'
                                                   AND c.CODIGO_CLIENTE=FACTURAS_VENTAS.CLIENTE
                                                   AND c.CODIGO_EMPRESA=facturas_ventas.empresa
                                     )
                       ) RPN6
                     , (
                              SELECT
                                     c.razon_social
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
       , CLIENTES
       , V_FACTURAS_VENTAS_LIN
       , (
                SELECT
                       ARTICULOS.*
                     , DECODE(codigo_estad5,NULL,NULL, (
                              SELECT
                                     descripcion
                              FROM
                                     familias
                              WHERE
                                     codigo_familia     = articulos.codigo_estad5
                                     AND numero_tabla   = 5
                                     AND ultimo_nivel   = 'S'
                                     AND codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD5
                     , DECODE(codigo_estad2,NULL,NULL, (
                              SELECT
                                     descripcion
                              FROM
                                     familias
                              WHERE
                                     codigo_familia     = articulos.codigo_estad2
                                     AND numero_tabla   = 2
                                     AND ultimo_nivel   = 'S'
                                     AND codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD2
                     , DECODE(codigo_estad4,NULL,NULL, (
                              SELECT
                                     descripcion
                              FROM
                                     familias
                              WHERE
                                     codigo_familia     = articulos.codigo_estad4
                                     AND numero_tabla   = 4
                                     AND ultimo_nivel   = 'S'
                                     AND codigo_empresa = articulos.codigo_empresa
                       )
                       ) D_CODIGO_ESTAD4
                FROM
                       ARTICULOS
         )
         ARTICULOS
       , DOMICILIOS_ENVIO
       , AGENTES_CLIENTES
       , AGENTES
WHERE
         (
                  not exists
                  (
                         select
                                1
                         from
                                FACTURAS_SUSTITUCIONES
                         where
                                FACTURAS_VENTAS.EMPRESA            =FACTURAS_SUSTITUCIONES.EMPRESA
                                and FACTURAS_VENTAS.EJERCICIO      =FACTURAS_SUSTITUCIONES.EJERCICIO
                                and FACTURAS_VENTAS.NUMERO_SERIE   =FACTURAS_SUSTITUCIONES.NUMERO_SERIE
                                and FACTURAS_VENTAS.NUMERO_FACTURA = FACTURAS_SUSTITUCIONES.NUMERO_FACTURA
                  )
                  AND
                  (
                           FACTURAS_VENTAS.EMPRESA                    = CLIENTES.CODIGO_EMPRESA
                           AND FACTURAS_VENTAS.CLIENTE                = CLIENTES.CODIGO_RAPIDO
                           AND FACTURAS_VENTAS.NUMERO_FACTURA         = V_FACTURAS_VENTAS_LIN.NUMERO_FACTURA
                           AND FACTURAS_VENTAS.NUMERO_SERIE           = V_FACTURAS_VENTAS_LIN.NUMERO_SERIE_FRA
                           AND FACTURAS_VENTAS.ORGANIZACION_COMERCIAL = V_FACTURAS_VENTAS_LIN.ORGANIZACION_COMERCIAL
                           AND FACTURAS_VENTAS.EJERCICIO              = V_FACTURAS_VENTAS_LIN.EJERCICIO_FACTURA
                           and V_FACTURAS_VENTAS_LIN.EMPRESA          =ARTICULOS.CODIGO_EMPRESA
                           and V_FACTURAS_VENTAS_LIN.ARTICULO         =ARTICULOS.CODIGO_ARTICULO
                           AND FACTURAS_VENTAS.EMPRESA                ='004'
                  )
                  AND
                  (
                           FACTURAS_VENTAS.NUMERO_SERIE <> 'CAN'
                  )
                  AND V_FACTURAS_VENTAS_LIN.UNIDADES_SERVIDAS<>0
                  and V_FACTURAS_VENTAS_LIN.EMPRESA           =DOMICILIOS_ENVIO.EMPRESA
                  and V_FACTURAS_VENTAS_LIN.CLIENTE           =DOMICILIOS_ENVIO.CODIGO_CLIENTE
                  and V_FACTURAS_VENTAS_LIN.DOMICILIO_ENVIO   =DOMICILIOS_ENVIO.NUMERO_DIRECCION
                  and FACTURAS_VENTAS.CLIENTE                 =AGENTES_CLIENTES.CODIGO_CLIENTE
                  and FACTURAS_VENTAS.EMPRESA                 =AGENTES_CLIENTES.EMPRESA
                  and
                  (
                           agentes.empresa   =clientes.codigo_empresa
                           and agentes.codigo=AGENTES_CLIENTES.AGENTE
                  )
         )
         AND articulos.codigo_articulo not in ('00018653'
                                             ,'00018654'
                                             ,'00018656'
                                             ,'00027574'
                                             ,'00018812')
GROUP BY
         facturas_ventas.fecha_factura
       , facturas_ventas.ejercicio
       , facturas_ventas.v_mes
	   , FACTURAS_VENTAS.NUMERO_SERIE
	   , FACTURAS_VENTAS.NUMERO_FACTURA
	   , facturas_ventas.empresa
       , decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ALTO','0460','SCR','0461','SCR','0470','BENI','0471','BENI','SIN REG')
       , decode(DOMICILIOS_ENVIO.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ORU','0460','SCR','0461','POT','0470','BENI','0471','PAN','SIN REG')
       , facturas_ventas.canalv
       , facturas_ventas.cadena
       , facturas_ventas.RPN2
       , facturas_ventas.RPN3
       , facturas_ventas.RPN4
       , facturas_ventas.RPN5
       , facturas_ventas.RPN6
       , TNEGOCIO /*DECODE(facturas_ventas.CANALV,'DISTRIBUIDORES','DISTRIBUIDORES' ,'ACCESO','ACCESO','INDEPENDIENTE','INDEPENDIENTE',FACTURAS_VENTAS.CADENA)*/
       , agentes_clientes.agente
       , agentes.nif
       , agentes.nombre
       , v_facturas_ventas_lin.cliente
       , facturas_ventas.d_cliente
       , clientes.tipo_cliente
       , articulos.d_codigo_estad5
	   , articulos.codigo_estad5
       , articulos.codigo_estad3
       , articulos.codigo_articulo
       , articulos.descrip_comercial
       , articulos.codigo_estad2
       , articulos.d_codigo_estad2
       , articulos.codigo_estad4
       , articulos.d_codigo_estad4
       , v_facturas_ventas_lin.tipo_pedido
       , NVL(v_facturas_ventas_lin.usuario_pedido, FACTURAS_VENTAS.USUARIO)  /*nuevo campo agregado*/
       , DECODE(v_facturas_ventas_lin.tipo_pedido,'10','ENTIDADES','ÉTICO')
       , DECODE(v_facturas_ventas_lin.tipo_pedido,'10','ENTIDADES','11','ÉTICO','12','ÉTICO','13','ÉTICO','NOTA CREDITO')
	   , V_FACTURAS_VENTAS_LIN.ALMACEN
       ,'VTAS'
UNION ALL
SELECT null FECHA_FACTURA, v_xls_planes_ventas.ejercicio, v_xls_planes_ventas.periodo V_MES ,
     decode(CLIENTES.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ALTO','0460','SCR','0461','SCR','0470','BENI','0471','BENI','SIN REG') REG
     , decode(CLIENTES.ZONA,'0410','SCZ','0420','LPZ','0430','CBBA','0440','TJA','0450','ALTO','0451','ORU','0460','SCR','0461','POT','0470','BENI','0471','PAN','SIN REG') SUBREG
     , clientes.canalv
     , clientes.cadena
     , clientes.RPN2
     , clientes.RPN3 /*nuevo campo adicionado*/
     , clientes.RPN4
     , clientes.RPN5
     , clientes.RPN6
     , TNEGOCIO /*DECODE(CLIENTES.CANALV,'DISTRIBUIDORES','DISTRIBUIDORES','ACCESO','ACCESO','INDEPENDIENTE','INDEPENDIENTE',CLIENTES.CADENA) */ CADENA_AUX
     , agentes_clientes.agente
     , agentes.nif                 COD_RPN
     , agentes.nombre              NOMBRE_AGENTE
     , v_xls_planes_ventas.cliente CLINETE_ID
     , clientes.razon_social       CLIENTE_NOMBRE
     , clientes.tipo_cliente       CAT_COD
     , ( SELECT REPLACE(tipos_cliente.descripcion,'CATEGORÍA ','')
         FROM TIPOS_CLIENTE
         WHERE tipos_cliente.codigo=CLIENTES.TIPO_CLIENTE
       ) CAT,
        UEN,
       articulos.codigo_estad5
     , articulos.codigo_estad3      LAB
     , v_xls_planes_ventas.articulo CODIGO_ARTICULO
     , articulos.descrip_comercial  ARTICULO_NOMBRE
     , articulos.codigo_estad2      JP_COD
     , (
              SELECT
                     descripcion
              FROM
                     familias
              WHERE
                     codigo_familia     = articulos.codigo_estad2
                     AND numero_tabla   = 2
                     AND ultimo_nivel   = 'S'
                     AND codigo_empresa = articulos.codigo_empresa
       )
                               JP_NOMBRE
     , articulos.codigo_estad4 ST_COD
     , (
              SELECT
                     descripcion
              FROM
                     familias
              WHERE
                     codigo_familia     = articulos.codigo_estad4
                     AND numero_tabla   = 4
                     AND ultimo_nivel   = 'S'
                     AND codigo_empresa = articulos.codigo_empresa
       )
           ST_NOMBRE
     ,'11' tipo_pedido
     , agentes.usuario usuario_pedido
     , case
              when v_xls_planes_ventas.codigo in ('824'
                                                ,'864'
                                                ,'1004'
                                                ,'1164', '1327','1424','1604')
                     then 'ÉTICO'
              when v_xls_planes_ventas.codigo in ('964')
                     then 'ENTIDADES'
                     ELSE 'SERVICIOS'
       END TIPO
     , case
              when v_xls_planes_ventas.codigo in ('824'
                                                ,'864'
                                                ,'1004'
                                                ,'1164','1327','1424','1604')
                     then 'ÉTICO'
              when v_xls_planes_ventas.codigo in ('964')
                     then 'ENTIDADES'
                     ELSE 'SERVICIOS'
       END                          TIPO_VTA
     ,'PPTO'                        FUENTE, 0 CANTIDAD, 0 IMP_NETO, 0 IMP_FACTURADO
     , v_xls_planes_ventas.cantidad PPTO_UND
     , v_xls_planes_ventas.importe  PPTO_VLR
     , CASE
              when articulos.codigo_estad3 in ('GRUNENTHAL')
                THEN trim(subStr(clientes.RPN2,0,3))
              when articulos.codigo_estad5 in ('040101')
                THEN trim(subStr(clientes.RPN2,0,3))
              when articulos.codigo_estad3 in ('HERSIL')
                THEN trim(subStr(clientes.RPN4,0,3))
              when articulos.codigo_estad3 in ('BONAPHARM')
                THEN trim(subStr(clientes.RPN5,0,3))
              when articulos.codigo_estad3 in ('LAFAGE')
                THEN trim(subStr(clientes.RPN6,0,3))
                else agentes.nif
         end GESTOR_VTAS
	   , V_XLS_PLANES_VENTAS.ALMACEN COD_ALMAC
       , DECODE(articulos.codigo_estad3,'LAFAGE', articulos.UEN||' - '||articulos.codigo_estad3, 'BONAPHARM', articulos.UEN||' - '||articulos.codigo_estad3, articulos.UEN) UEN_AUX1
FROM
       V_XLS_PLANES_VENTAS
     , (
              SELECT
                     CLIENTES.*
                   , (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='CANALV'
                                   AND V.VALOR_CLAVE=
                                   (
                                          SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='CANALV'
                                                 AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                                 AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                                   )
                     )
                     CANALV
                   , (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='CADN'
                                   AND V.VALOR_CLAVE=
                                   (
                                          SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='CADN'
                                                 AND c.CODIGO_CLIENTE=CLIENTES.CODIGO_RAPIDO
                                                 AND c.CODIGO_EMPRESA=CLIENTES.codigo_empresa
                                   )
                     )
                     CADENA
                   , (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='TNEG'
                                   AND V.VALOR_CLAVE=
                                   (
                                          SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='TNEG'
                                                 AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                                 AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                                   )
                     ) TNEGOCIO
       				, (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='RPN2'
                                   AND V.VALOR_CLAVE=
                                   (
                                          SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='RPN2'
                                                 AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                                 AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                                   )
                     )
                     RPN2
                   , ( SELECT NOMBRE
                       FROM VALORES_CLAVES V
                       WHERE V.CLAVE ='RPN3' AND V.VALOR_CLAVE=
                            ( SELECT VALOR_CLAVE
                               FROM CLIENTES_CLAVES_ESTADISTICAS c
                               WHERE c.CLAVE ='RPN3'
                                  AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                  AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                            )
                     )
                     RPN3 /*nuevo campo*/
                   , (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='RPN4'
                                   AND V.VALOR_CLAVE=
                                   (
                                          SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='RPN4'
                                                 AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                                 AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                                   )
                     )
                     RPN4
                          , (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='RPN5'
                                   AND V.VALOR_CLAVE=
                                   (
                                        SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='RPN5'
                                                 AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                                 AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                                   )
                     )
                     RPN5
                   , (
                            SELECT
                                   NOMBRE
                            FROM
                                   VALORES_CLAVES V
                            WHERE
                                   V.CLAVE          ='RPN6'
                                   AND V.VALOR_CLAVE=
                                   (
                                          SELECT
                                                 VALOR_CLAVE
                                          FROM
                                                 CLIENTES_CLAVES_ESTADISTICAS c
                                          WHERE
                                                 c.CLAVE             ='RPN6'
                                                 AND c.CODIGO_CLIENTE=clientes.codigo_rapido
                                                 AND c.CODIGO_EMPRESA=clientes.codigo_empresa
                                   )
                     )
                     RPN6
              FROM
                     CLIENTES
       )
       CLIENTES
     , AGENTES_CLIENTES
     , AGENTES
     , (SELECT ARTICULOS.*, (
       SELECT descripcion
       FROM familias
       WHERE codigo_familia     = articulos.codigo_estad5
              AND numero_tabla   = 5
              AND ultimo_nivel   = 'S'
              AND codigo_empresa = articulos.codigo_empresa
       ) UEN FROM ARTICULOS ) ARTICULOS
WHERE
       (
              V_XLS_PLANES_VENTAS.CLIENTE     =CLIENTES.CODIGO_RAPIDO
              and V_XLS_PLANES_VENTAS.EMPRESA =CLIENTES.CODIGO_EMPRESA
              and CLIENTES.CODIGO_RAPIDO      =AGENTES_CLIENTES.CODIGO_CLIENTE
              and CLIENTES.CODIGO_EMPRESA     =AGENTES_CLIENTES.EMPRESA
              and AGENTES.CODIGO              =AGENTES_CLIENTES.AGENTE
              and AGENTES.EMPRESA             =AGENTES_CLIENTES.EMPRESA
              and V_XLS_PLANES_VENTAS.EMPRESA =ARTICULOS.CODIGO_EMPRESA
              and V_XLS_PLANES_VENTAS.ARTICULO=ARTICULOS.CODIGO_ARTICULO
       )
       AND v_xls_planes_ventas.codigo IN ('824','864', '964','1004','1164',
        '1327','1424','1604')
       AND v_xls_planes_ventas.empresa LIKE '004';
