CREATE OR REPLACE VIEW BOL_INFORME_COBOFAR AS SELECT venta.cliente, venta.NOMBRE_CLIENTE1, venta.empresa, RTRIM(venta.CODIGO_ALMACEN_COBOFAR) CODIGO_ALMACEN_COBOFAR, venta.ID_PROVEEDOR, venta.NUMERO_FACTURA, venta.FECHA_FACTURA, venta.FECHA_VENCIMIENTO_FACTURA, venta.NIT, venta.CODIGO_CONTROL_, venta.AUTORIZACION, venta.MONTO_FACTURA_INICIAL, venta.MONTO_FACTURA_FINAL, venta.DTO_1, venta.DTO_2, venta.DTO_3, venta.DTO_4, venta.CODIGO_COBOFAR,(SELECT FECHA_CADUCIDAD FROM HISTORICO_LOTES h WHERE h.CODIGO_EMPRESA = venta.EMPRESA and h.CODIGO_ARTICULO = venta.ARTICULO and h.NUMERO_LOTE_INT = NVL(venta.NUMERO_LOTE_INTERNO,da.numero_lote_int1)) FECHA_VENCIMIENTO_PRODUCTO, da.numero_lote_int1 NUMERO_LOTE, venta.REGISTRO_, venta.CANTIDAD_CAJA, '0' CANTIDAD_SUELTAS, da.cantidad_unidad1, da.cantidad_unidad2, venta.VALOR_COMPRA, venta.DESCUENTO_COMERCIAL, '0'DESPOR, '0' NROPEDID FROM 
(SELECT (SELECT substr(d.direccion,0,10) DIRECCION FROM domicilios_envio d WHERE d.codigo_cliente = v.cliente AND d.numero_direccion = v.domicilio_envio AND d.empresa = v.empresa) CODIGO_ALMACEN_COBOFAR
,'40' ID_PROVEEDOR, v.NUMERO_FACTURA, f.FECHA_FACTURA
, (select fecha_vencimiento from facturas_ventas_vctos where (EMPRESA=f.empresa) and (NUMERO_SERIE=f.numero_serie) and (NUMERO_FACTURA=f.numero_factura) and (EJERCICIO=f.ejercicio)) fecha_vencimiento_factura
, '1015469022' NIT
, (SELECT UUID FROM facturas_ventas_doc where empresa=f.EMPRESA and NUMERO_SERIE=f.numero_serie and numero_factura=f.numero_factura AND EJERCICIO=f.ejercicio)  CODIGO_CONTROL_
, (SELECT NO_CERTIFICADO FROM facturas_ventas_doc where empresa=f.EMPRESA and NUMERO_SERIE=f.numero_serie and numero_factura=f.numero_factura AND EJERCICIO=f.ejercicio)  AUTORIZACION
/*, (f.LIQUIDO_FACTURA) + (dv.IMPORTE_NETO_LIN*v.DCTO_GLOBAL/100) MONTO_FACTURA_INICIAL*/
, (f.LIQUIDO_FACTURA) MONTO_FACTURA_INICIAL
, (f.LIQUIDO_FACTURA - nvl(I_DCTO_GLOBAL,0)) MONTO_FACTURA_FINAL
/*, (dv.IMPORTE_NETO_LIN*v.DCTO_GLOBAL/100) DTO_1*/
, I_DCTO_GLOBAL DTO_1
/*, dv.DTO_2
, dv.DTO_3
, dv.DTO_4 */
, 0 DTO_2
, 0 DTO_3
, 0 DTO_4 
, (SELECT ra.CODIGO_SUBREFERENCIA FROM DETALLE_LISTA_RFCAS ra WHERE ra.codigo_Articulo = dv.ARTICULO and v.CLIENTE = ra.RESERVADO_CHAR4 and ra.empresa=f.EMPRESA) CODIGO_COBOFAR
/*, (SELECT FECHA_CADUCIDAD FROM HISTORICO_LOTES h WHERE h.CODIGO_EMPRESA = f.EMPRESA and h.CODIGO_ARTICULO = dv.ARTICULO and h.NUMERO_LOTE_INT = NVL(dv.NUMERO_LOTE_INT, pkconsgen.get_numero_lote_int_albvta(v.empresa, dv.articulo, v.numero_albaran,v.numero_serie,v.ejercicio,v.sub_albaran,v.organizacion_comercial, dv.numero_linea_albaran))) FECHA_VENCIMIENTO_PRODUCTO
, NVL(dv.NUMERO_LOTE_INT, pkconsgen.get_numero_lote_int_albvta(v.empresa, dv.articulo, v.numero_albaran,v.numero_serie,v.ejercicio,v.sub_albaran,v.organizacion_comercial, dv.numero_linea_albaran)) NUMERO_LOTE*/
, (SELECT NUMERO_REGISTRO FROM registros_sanitarios rs WHERE rs.empresa = v.EMPRESA and substr(rs.DESCRIPCION,0,8) = dv.ARTICULO and ROWNUM = 1) REGISTRO_
, dv.UNIDADES_SERVIDAS CANTIDAD_CAJA
, dv.NUMERO_LINEA_ALBARAN
, v.numero_albaran
, v.numero_serie 
, v.empresa
, v.cliente
, c.NOMBRE NOMBRE_CLIENTE1
, v.organizacion_comercial
, v.ejercicio
, dv.PRECIO_PRESENTACION VALOR_COMPRA
, (dv.IMPORTE_BRUTO_LIN-dv.IMPORTE_NETO_LIN) DESCUENTO_COMERCIAL
, dv.ARTICULO
, dv.NUMERO_LOTE_INT NUMERO_LOTE_INTERNO
FROM ALBARAN_VENTAS     v
     , CLIENTES           c
     , ALBARAN_VENTAS_LIN dv
     , ARTICULOS          a
     , FACTURAS_VENTAS    f
WHERE
       v.numero_albaran                  = dv.numero_albaran
       AND v.numero_serie                = dv.numero_serie
       AND v.ejercicio                   = dv.ejercicio
       AND v.sub_albaran                 = dv.sub_albaran
       AND v.organizacion_comercial      = dv.organizacion_comercial
       AND v.empresa                     = dv.empresa
       AND c.codigo_empresa              = v.empresa
       AND c.codigo_rapido               = v.cliente
       and a.CODIGO_ARTICULO             =dv.ARTICULO
       and a.CODIGO_EMPRESA              =dv.EMPRESA
       AND f.NUMERO_FACTURA              = v.NUMERO_FACTURA
       AND v.empresa                     =f.EMPRESA
       AND v.ejercicio                   =f.ejercicio
       AND f.NUMERO_SERIE                = v.NUMERO_SERIE_FRA
       AND f.NUMERO_SERIE <> 'CAN'
	   AND v.tipo_pedido <> '43'
) venta JOIN (SELECT codigo_empresa codigo_empresa1
                                     , codigo_articulo codigo_articulo1
                                     , numero_albaran numero_albaran1
                                     , serie_numeracion serie_numeracion1
                                     , numero_linea numero_linea1
                                     , ejercicio ejercicio1
                                     , organizacion_compras organizacion_compras1
                                     , subalbaran subalbaran1
                                     , codigo_zona codigo_zona1
                                     , tipo_situacion tipo_situacion1
                                     , numero_ubicacion numero_ubicacion1
                                     , numero_palet numero_palet1
                                     , numero_serie_pro numero_serie_pro1
                                     , numero_serie_int numero_serie_int1
                                     , numero_lote_int numero_lote_int1
                                     , numero_lote_pro numero_lote_pro1
                                     , codigo_almacen codigo_almacen1
                                     , SUM(cantidad_unidad1 * -1) cantidad_unidad1
                                     , SUM(cantidad_unidad2 * -1) cantidad_unidad2
                              FROM
                                       historico_movim_almacen
                              GROUP BY
                                       codigo_empresa
                                     , codigo_articulo
                                     , numero_albaran
                                     , serie_numeracion
                                     , numero_linea
                                     , ejercicio
                                     , organizacion_compras
                                     , subalbaran
                                     , codigo_zona
                                     , tipo_situacion
                                     , numero_ubicacion
                                     , numero_palet
                                     , numero_serie_pro
                                     , numero_serie_int
                                     , numero_lote_int
                                     , numero_lote_pro
                                     , codigo_almacen) da ON da.numero_albaran1 = venta.numero_albaran  and da.serie_numeracion1 = venta.numero_serie and da.ejercicio1 = venta.ejercicio and da.organizacion_compras1 = venta.organizacion_comercial and da.codigo_empresa1 = venta.empresa AND da.subalbaran1 = 0 and da.numero_linea1 = venta.NUMERO_LINEA_ALBARAN
WHERE  venta.empresa                     = '004'
      /* venta.numero_albaran              = 11677
       AND venta.numero_serie                = 011
       and venta.empresa                     = '004'
       and venta.cliente                     = 007178
	   and venta.NUMERO_LINEA_ALBARAN = 53
	    numero_factura = 2150
and fecha_factura = to_date('30/10/2021','dd/mm/yyyy')
       and venta.empresa                     = '004'
       /*and venta.cliente                     in(008078, 009162)*/