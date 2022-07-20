
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "LIBRA"."SUCO_V_BOL_LIQUID_EXPEDIENTES" ("CODIGO_EMPRESA", "CODIGO_ARTICULO", "DESCRIP_COMERCIAL", "CANTIDAD", "FOB_UNITARIO", "TOTAL_FOB", "FLETE", "TOTAL_CYF", "IMPUESTOS_ADUANALES", "SERVICIOS_ADUANAS", "ALMACENAJE_ADUANERO", "CARGADORES", "OTROS_GASTOS", "GASTOS_SEGURO", "UNIMED", "CAMARA_COMERCIO", "COSTO_TOTAL", "COSTO_UNITARIO", "PRECIO_VENTA_ACTUAL", "COSTO_ANTERIOR", "NUMERO_EXPEDIENTE", "LOTE") AS 

SELECT codigo_empresa,
         codigo_articulo,
         descrip_comercial,
         cantidad,
         SUM (fob_unitario) fob_unitario,
         SUM (fob_unit_bol) fob_unit_bol,
         SUM (cant2) cant2,
         SUM (total_fob) total_fob,
           SUM (flete)
         + SUM (fletes_aereos)
         + SUM (fletes_maritimos)
         + SUM (fletes_terrestres)
         + SUM (fletes_factura)
            flete,
           SUM (total_fob)
         + SUM (flete)
         + SUM (fletes_aereos)
         + SUM (fletes_maritimos)
         + SUM (fletes_terrestres)
         + SUM (fletes_factura)
            total_cyf,
         SUM (impuestos_aduanales) impuestos_aduanales,
         SUM (servicios_aduanas) servicios_aduanas,
         SUM (almacenaje_Aduanero) almacenaje_aduanero,
         SUM (costo_cargadores) cargadores,
         SUM (otros_gastos) otros_gastos,
         SUM (gastos_seguro) gastos_seguro,
         SUM (gastos_UNIMED) UNIMED,
         SUM (camara_comercio) camara_comercio,
           SUM (total_fob)
         + SUM (flete)
         + SUM (fletes_aereos)
         + SUM (fletes_maritimos)
         + SUM (fletes_terrestres)
         + SUM (fletes_factura)
         + SUM (impuestos_aduanales)
         + SUM (servicios_aduanas)
         + SUM (almacenaje_Aduanero)
         + SUM (costo_cargadores)
         + SUM (otros_gastos)
         + SUM (gastos_seguro)
         + SUM (gastos_UNIMED)
         + SUM (camara_comercio)
            costo_total,
         ROUND (
              (  SUM (total_fob)
               + SUM (flete)
               + SUM (impuestos_aduanales)
               + SUM (servicios_aduanas))
            / cantidad,
            2)
            costo_unitario,
         MAX (precio_venta_actual) precio_venta_actual,
         MAX (costo_anterior) costo_anterior,
         numero_expediente,
         MAX (numero_lote_int) lote
    FROM (SELECT ar.codigo_empresa,
                 hma.codigo_articulo,
                 ar.descrip_comercial,
                 acc.numero_expediente,
                 hma.numero_lote_int,
                 hma.cantidad_unidad1 cantidad,
                 ROUND (
                    DECODE (
                       hma.codigo_movimiento,
                       'EMERC', DECODE (
                                   hma.cantidad_unidad1,
                                   0, 0,
                                   hma.importe_coste / hma.cantidad_unidad1),
                       0),
                    2)
                    fob_unitario,
                  ROUND (
                    DECODE (
                       hma.codigo_movimiento,
                       'EMERC', DECODE (
                                   hma.cantidad_unidad1,
                                   0, 0,
                                   acl.precio_neto* acl.cambio),
                       0),
                    2)
                    fob_unit_bol,
                    ROUND (
                    DECODE (
                       hma.codigo_movimiento,
                       'EMERC', DECODE (
                                   hma.cantidad_unidad1,
                                   0, 0,
                                   hma.cantidad_unidad1),
                       0),
                    2) cant2,
                 ROUND (
                    DECODE (hma.codigo_movimiento,
                            'EMERC', hma.importe_coste,
                            0))
                    total_fob,
                 DECODE (hma.codigo_movimiento, 'MCFLE', hma.importe_coste, 0)
                    flete,
                 DECODE (hma.codigo_movimiento, 'MCIVA', hma.importe_coste, 0)
                    impuestos_aduanales,
                 DECODE (hma.codigo_movimiento, 'MCNAC', hma.importe_coste, 0)
                    servicios_aduanas,
                 DECODE (hma.codigo_movimiento, 'MCAAD', hma.importe_coste, 0)
                    almacenaje_aduanero,
                 DECODE (hma.codigo_movimiento, 'MCCAR', hma.importe_coste, 0)
                    costo_cargadores,
                 DECODE (hma.codigo_movimiento, 'MCFAE', hma.importe_coste, 0)
                    fletes_aereos,
                 DECODE (hma.codigo_movimiento, 'MCFFA', hma.importe_coste, 0)
                    fletes_factura,
                 DECODE (hma.codigo_movimiento, 'MCFMA', hma.importe_coste, 0)
                    fletes_maritimos,
                 DECODE (hma.codigo_movimiento, 'MCFTE', hma.importe_coste, 0)
                    fletes_terrestres,
                 DECODE (hma.codigo_movimiento, 'MCOTR', hma.importe_coste, 0)
                    otros_gastos,
                 DECODE (hma.codigo_movimiento, 'MCSEG', hma.importe_coste, 0)
                    gastos_seguro,
                 DECODE (hma.codigo_movimiento, 'MCUNI', hma.importe_coste, 0)
                    gastos_UNIMED,
                 DECODE (hma.codigo_movimiento, 'MCCCO', hma.importe_coste, 0)
                    camara_comercio,
                 (SELECT hv.precio_medio_ponderado
                    FROM historico_valoracion hv
                   WHERE     hv.codigo_empresa = hma.codigo_empresa
                         AND hv.codigo_articulo = hma.codigo_articulo
                         AND (   (    hv.codigo_almacen = '02010'
                                  AND ar.codigo_empresa = '002')
                              OR (    hv.codigo_almacen = '04010'
                                  AND ar.codigo_empresa = '004'))
                         /*AND hv.codigo_divisa = hma.codigo_divisa
                         AND hv.numero_periodo =
                                TO_NUMBER (TO_CHAR (acc.fecha, 'MM')) - 1
                         AND hv.tipo_periodo = 'MES'
                         AND hv.ejercicio = TO_CHAR (acc.fecha, 'YYYY'))*/
                         AND hv.codigo_divisa = hma.codigo_divisa
                         AND hv.tipo_periodo = 'MES'
                         AND (   (    TO_CHAR (acc.fecha, 'MM') != '01'
                                  AND hv.numero_periodo =
                                           TO_NUMBER (
                                              TO_CHAR (acc.fecha, 'MM'))
                                         - 1
                                  AND hv.ejercicio =
                                         TO_CHAR (acc.fecha, 'YYYY'))
                              OR (    (TO_CHAR (acc.fecha, 'MM') = '01')
                                  AND hv.numero_periodo = '12'
                                  AND hv.ejercicio =
                                           TO_NUMBER (
                                              TO_CHAR (acc.fecha, 'YYYY'))
                                         - 1)))
                    costo_anterior,
                 (SELECT precio_consumo
                    FROM precios_listas pl
                   WHERE     pl.codigo_articulo = hma.codigo_articulo
                         AND pl.numero_lista = '01'
                         AND pl.fecha_validez =
                                (SELECT MAX (fecha_validez)
                                   FROM precios_listas pl2
                                  WHERE     pl2.codigo_articulo =
                                               pl.codigo_articulo
                                        AND pl2.numero_lista = pl.numero_lista
                                        AND pl2.fecha_validez < acc.fecha
                                        AND pl2.tipo_cadena = pl.tipo_cadena
                                        AND pl2.divisa = pl.divisa
                                        AND pl2.organizacion_comercial =
                                               pl.organizacion_comercial
                                        AND pl2.codigo_empresa =
                                               pl.codigo_empresa)
                         AND pl.tipo_cadena = 'SUC'
                         AND pl.divisa = hma.codigo_divisa
                         AND (   (    pl.organizacion_comercial = '02010'
                                  AND ar.codigo_empresa = '002')
                              OR (    pl.organizacion_comercial = '04010'
                                  AND ar.codigo_empresa = '004'))
                         AND pl.codigo_empresa = hma.codigo_empresa)
                    precio_venta_actual
            FROM historico_movim_almacen hma,
                 articulos ar,
                 albaran_compras_l acl,
                 albaran_compras_c acc
           WHERE                                 -- hma.tipo_movimiento = '09'
                ar   .codigo_empresa = hma.codigo_empresa
                 AND ar.codigo_articulo = hma.codigo_articulo
                 AND acc.codigo_empresa = acl.codigo_empresa
                 AND acc.numero_doc_interno = acl.numero_doc_interno
                 AND acc.codigo_empresa = acl.codigo_empresa
                 AND acc.codigo_empresa = hma.codigo_empresa
                 AND acc.organizacion_compras = hma.organizacion_compras
                 AND acc.numero_doc_interno = hma.albaran_compras
                 AND acl.numero_linea = hma.lin_albaran_compras
                 AND (   hma.programa = 'C_PORTES'
                      OR hma.codigo_movimiento = 'EMERC')
                  and acc.numero_expediente=401132 
                 AND hma.cantidad_unidad1 > 0 -- AND ar.codigo_empresa = '002')
                                             )
GROUP BY codigo_empresa,
         codigo_articulo,
         descrip_comercial,
         cantidad,
         numero_expediente