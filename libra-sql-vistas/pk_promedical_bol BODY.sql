CREATE OR REPLACE PACKAGE BODY pk_promedical_bol AS

procedure ejecutar_bpm_vta(cod_sec varchar2) is
cursor c1(pc_cod_sec varchar2) is SELECT distinct NUMERO_EXPEDIENTE, NUMERO_LINEA, CODIGO_SECUENCIA FROM crmexpedientes_lin
WHERE EMPRESA='004' AND STATUS_TAREA='01' and codigo_secuencia = pc_cod_sec and numero_expediente in (Select numero_expediente from crmexpedientes_cab 	where FECHA_INICIO >=trunc(current_date-180,'MONTH') and empresa='004' and tipo_expediente='04003' and status_expediente='01') GROUP BY NUMERO_EXPEDIENTE, NUMERO_LINEA, CODIGO_SECUENCIA;

v_forma_pago varchar2(5);
v_forma_pago2 varchar2(5);
V_RTN varchar2(50);
v_cadena varchar2(12);
v_canalv varchar2(12);
v_equipo varchar2(10);
v_org varchar2(6);
v_serie varchar2(4);
v_numero number;
v_ejercicio NUMBER;
v_cliente varchar2(15);
v_bodega varchar2(10);
v_ped_ok number;
begin

FOR rs IN c1(pc_cod_Sec =>cod_Sec) LOOP
  begin
  V_RTN:= '*** N. Exp= ' || rs.numero_expediente ||'-'||rs.numero_linea;

if rs.numero_expediente is not null then
	v_forma_pago :='';
	Select distinct itema078, itema041, itemn001, itemn002
    into v_org, v_serie, v_ejercicio, v_numero
    from crmexpedientes_cab
	where numero_expediente = rs.numero_expediente
		and empresa='004'
		and tipo_expediente='04003' ;
		--and status_expediente='01';  -- Para que siempre encuentre datos
    v_ped_ok :=0;

      SELECT count(*) X INTO v_ped_ok FROM DUAL
  	 WHERE exists (
  	select * from pedidos_ventas pv where pv.empresa='004' and pv.id_crm in
     (SELECT id_documento FROM crmexpedientes_documentos x WHERE x.EMPRESA = pv.empresa AND x.NUMERO_EXPEDIENTE = rs.numero_expediente) );

  IF v_ped_ok= 0 THEN
   UPDATE crmexpedientes_lin
       SET CODIGO_SECUENCIA='999', TIPO_TAREA='990'
      WHERE STATUS_TAREA='01'
       and codigo_secuencia=rs.codigo_secuencia
       and numero_expediente = rs.numero_expediente
       AND numero_linea = rs.numero_linea
       AND empresa = '004';
      commit;
       --V_RTN := pkcrmexpedientes_tareas.finalizar_tarea_at('004', rs.numero_expediente, rs.numero_linea, sysdate(),'AUTOMATICO','99',TRUE,TRUE);
       V_rtn := pkcrmexpedientes.cerrar_expediente('004',rs.numero_expediente,'AUTOMATICO',sysdate(),'99','99',true);
  ELSE
   select  forma_pago, canalv, cadena, almacen_entrega, cliente
    into v_forma_pago, v_canalv, v_cadena, v_bodega, v_cliente
    from (select pedidos_ventas.*, (SELECT VALOR_CLAVE FROM  CLIENTES_CLAVES_ESTADISTICAS c WHERE c.CLAVE='CANALV' AND c.CODIGO_CLIENTE=pedidos_ventas.CLIENTE AND c.CODIGO_EMPRESA=pedidos_ventas.empresa) canalv, (SELECT VALOR_CLAVE FROM  CLIENTES_CLAVES_ESTADISTICAS c WHERE c.CLAVE='CADN' AND c.CODIGO_CLIENTE=pedidos_ventas.CLIENTE AND c.CODIGO_EMPRESA=pedidos_ventas.empresa) cadena from pedidos_ventas) pedidos_ventas
    where empresa= '004'
      and organizacion_comercial = v_org
      and ejercicio = v_ejercicio
      and numero_serie= v_serie
      and numero_pedido = v_numero;
 -- IF (v_bodega IS NOT NULL OR v_cliente IS NOT NULL) THEN
    UPDATE PEDIDOS_VENTAS
    SET STATUS_PEDIDO='1000'
    where empresa='004'
      and NUMERO_PEDIDO = v_numero
      and numero_serie= v_serie
      AND EJERCICIO= v_ejercicio
      and organizacion_comercial = v_org
      and status_pedido < '0999';

    select FORMA_COBRO_PAGO
      into v_forma_pago2
      from clientes
     where codigo_rapido= v_cliente and codigo_empresa='004';

   IF rs.codigo_secuencia = ('075') then
      select equipo
      into v_equipo
      from crmequipos
      where substr(descripcion,1,5)= v_bodega
      and substr(equipo,3,2)='20'
      and empresa= '004';
	    IF substr(v_bodega,1,5) ='04017'  then
        v_equipo:='402004';
      END IF;
     --    pkcrmexpedientes_tareas.asignar_tarea(p_empresa => '004', p_numero_expediente => rs.numero_expediente, p_numero_linea => rs.numero_linea, p_usuario => 'AUTOMATICO', p_usuario_asignacion => NULL , p_equipo_asignacion => v_equipo, p_ora_rowscn_explin => null);
     -- V_RTN := pkcrmexpedientes_tareas.asignar_tarea('004', rs.numero_expediente, rs.numero_linea, 'AUTOMATICO', null, v_equipo);
     UPDATE crmexpedientes_lin
       SET  usuario_a_realizarlo = null,
           equipo_a_realizarlo = NVL(v_equipo, '402008')
      WHERE STATUS_TAREA='01'
       and codigo_secuencia='075'
       and numero_expediente = rs.numero_expediente
       AND numero_linea = rs.numero_linea
       AND empresa = '004';
    end if;

    if rs.codigo_secuencia in ('060','070') then
        V_RTN := pkcrmexpedientes_tareas.finalizar_tarea_at('004', rs.numero_expediente, rs.numero_linea, sysdate(),'AUTOMATICO','99',TRUE,TRUE);
    end if;

    --    WHEN rs.codigo_secuencia in ('030','031','040','050') then
    if rs.codigo_secuencia in ('030','031','040','050') then
      -- B005 RED BOLIVIA no esta incluido en el pase directo
      if (v_forma_pago='0200' and v_forma_pago2='0200') OR (rs.codigo_secuencia='031') or (v_canalv='B01' and v_cadena<>'B005') then
        /*** valida si es pedido al contado, si es asi lo pasa directo*/
            V_RTN := pkcrmexpedientes_tareas.finalizar_tarea_at('004', rs.numero_expediente, rs.numero_linea, sysdate(),'AUTOMATICO','13',TRUE,TRUE);
            commit;
      ELSE
        if rs.codigo_secuencia= '030' then
          V_RTN := pkcrmexpedientes_tareas.asignar_tarea('004', rs.numero_expediente, rs.numero_linea, 'AUTOMATICO', null, '402001');
        end if;
        if rs.codigo_secuencia='040' then
          V_RTN := pkcrmexpedientes_tareas.asignar_tarea('004', rs.numero_expediente, rs.numero_linea, 'AUTOMATICO', null, '402002');
        end if;
        if rs.codigo_secuencia='050' then
          V_RTN := pkcrmexpedientes_tareas.asignar_tarea('004', rs.numero_expediente, rs.numero_linea, 'AUTOMATICO', null, '401001');
        end if;
      end if;
    end if;
  END IF;
  END IF;
   commit;
 end;
end loop;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    pkpantallas.log( 'Datos Pedido: ' || v_org ||'/'|| v_ejercicio || '/' || v_serie||'/'||v_numero);
    --pkpantallas.log(SQLERRM, $$PLSQL_UNIT, 'pk_automatico_bol');
end ejecutar_bpm_vta;

procedure act_bolpmp(f_ini date , f_fin date) is
begin

update historico_movim_almacen set PRECIO_MEDIO_PONDERADO=(SELECT  PRECIO_MEDIO_PONDERADO FROM HISTORICO_VALORACION H WHERE H.CODIGO_EMPRESA = '004' and H.EJERCICIO = TO_NUMBER(TO_CHAR(f_ini,'YYYY')) AND H.NUMERO_PERIODO=TO_NUMBER(TO_CHAR(f_ini ,'MM')) and H.CODIGO_ARTICULO=historico_movim_almacen.CODIGO_ARTICULO)
where  CODIGO_EMPRESA='004' AND FECHA_VALOR BETWEEN to_date(to_char(f_ini,'DD/MM/YYYY'),'DD/MM/YYYY') AND to_date(to_char(f_fin,'DD/MM/YYYY'),'DD/MM/YYYY');
COMMIT;

END act_bolpmp;

/*** generar libro de ventas local en Bolivia de acuerdo a solicitud de finanzas Bol.*/
procedure libro_vtas_bol(nro_meses number) is
CURSOR c is select * from BOL_LIBRO_VTAS_TEMP ORDER BY nro_autorizacion asc,nro_fact asc, nro_factura asc;
  nro_aut varchar2(50):='0';
  nro_fact2 varchar2(15):='0';
  n number:=0;
  n2 number;
  f date;

 begin
  DELETE FROM BOL_LIBRO_VTAS_TEMP;
  commit;
  insert into BOL_LIBRO_VTAS_TEMP(fecha_factura,nro_fact,nro_serie_just,cod_entidad,razon_social,imp_dscto_global,imp_fact_bruto,imp_d01,imp_d02,imp_d03,imp_d04,imp_d05,imp_base_df,nro_asiento_borrador,usuario,estado,codigo_control,imp_vta_bruta,imp_ttl_dsctos,nit_cliente) SELECT fecha_factura,numero_factura,numero_serie,cliente,d_cliente,imp_dto_global,imp_fac_bruto,imp_fac_dto1,imp_fac_dto2,imp_fac_dto3,imp_fac_dto4,imp_fac_dto5,liquido_factura,numero_asiento_borrador,usuario, estado, cod_control,(FACTURAS_VENTAS.IMP_FAC_BRUTO+FACTURAS_VENTAS.IMP_DTO_GLOBAL+FACTURAS_VENTAS.IMP_FAC_DTO1+FACTURAS_VENTAS.IMP_FAC_DTO2+FACTURAS_VENTAS.IMP_FAC_DTO3+FACTURAS_VENTAS.IMP_FAC_DTO4+FACTURAS_VENTAS.IMP_FAC_DTO5) vta_bruta,(FACTURAS_VENTAS.IMP_DTO_GLOBAL+FACTURAS_VENTAS.IMP_FAC_DTO1+FACTURAS_VENTAS.IMP_FAC_DTO2+FACTURAS_VENTAS.IMP_FAC_DTO3+FACTURAS_VENTAS.IMP_FAC_DTO4+FACTURAS_VENTAS.IMP_FAC_DTO5+ FACTURAS_VENTAS.IMP_FAC_DTO6) ttl_dsctos,nit FROM (SELECT FACTURAS_VENTAS.*,(SELECT c.razon_social FROM clientes c WHERE c.codigo_rapido = facturas_ventas.cliente AND c.codigo_empresa = facturas_ventas.empresa) D_CLIENTE,(SELECT c.nif FROM clientes c WHERE c.codigo_rapido = facturas_ventas.cliente AND c.codigo_empresa = facturas_ventas.empresa) nit,((SELECT DECODE(MAX(status),4000,'A',4020,'Anulaci�n',4030,'Sustituida','V') FROM facturas_sustituciones WHERE numero_factura=facturas_ventas.numero_factura and numero_serie=facturas_ventas.numero_serie and ejercicio=facturas_ventas.ejercicio and status<>'4040')) estado,(select uuid from facturas_ventas_doc fd where fd.empresa=facturas_ventas.empresa and fd.ejercicio=facturas_ventas.ejercicio and fd.numero_serie=facturas_ventas.numero_serie and fd.numero_factura=facturas_ventas.numero_factura) cod_control FROM FACTURAS_VENTAS) FACTURAS_VENTAS WHERE (FACTURAS_VENTAS.NUMERO_SERIE<>'CAN') AND (facturas_ventas.empresa = '004') AND facturas_ventas.fecha_factura BETWEEN TO_DATE(TRUNC(ADD_MONTHS(SYSDATE,-nro_meses),'MONTH'), 'DD/MM/YYYY') AND TO_DATE(LAST_DAY(ADD_MONTHS(SYSDATE,1)), 'DD/MM/YYYY');
  commit;
  update BOL_LIBRO_VTAS_TEMP set nro_factura=to_char(nro_fact);
    /**** para actualizar datos complementarios */
  update BOL_LIBRO_VTAS_TEMP l set
    nro_autorizacion=(SELECT numero_autorizacion_rango from HISTORICO_IMPUESTOS where HISTORICO_IMPUESTOS.EMPRESA='004' and HISTORICO_IMPUESTOS.SERIE_JUSTIFICANTE=l.nro_serie_just and TO_NUMBER(HISTORICO_IMPUESTOS.JUSTIFICANTE)= l.NRO_FACT and HISTORICO_IMPUESTOS.CODIGO_ENTIDAD=l.cod_entidad and HISTORICO_IMPUESTOS.NUMERO_ASIENTO_BORRADOR=l.NRO_ASIENTO_BORRADOR),
    documento=(SELECT documento from HISTORICO_IMPUESTOS where HISTORICO_IMPUESTOS.EMPRESA='004' and HISTORICO_IMPUESTOS.SERIE_JUSTIFICANTE=l.nro_serie_just and TO_NUMBER(HISTORICO_IMPUESTOS.JUSTIFICANTE)= l.NRO_FACT and HISTORICO_IMPUESTOS.CODIGO_ENTIDAD=l.cod_entidad and HISTORICO_IMPUESTOS.NUMERO_ASIENTO_BORRADOR=l.NRO_ASIENTO_BORRADOR),
    entidad=(SELECT entidad from HISTORICO_IMPUESTOS where HISTORICO_IMPUESTOS.EMPRESA='004' and HISTORICO_IMPUESTOS.SERIE_JUSTIFICANTE=l.nro_serie_just and TO_NUMBER(HISTORICO_IMPUESTOS.JUSTIFICANTE)= l.NRO_FACT and HISTORICO_IMPUESTOS.CODIGO_ENTIDAD=l.cod_entidad and HISTORICO_IMPUESTOS.NUMERO_ASIENTO_BORRADOR=l.NRO_ASIENTO_BORRADOR),
    nro_factura=(SELECT justificante from HISTORICO_IMPUESTOS where HISTORICO_IMPUESTOS.EMPRESA='004' and HISTORICO_IMPUESTOS.SERIE_JUSTIFICANTE=l.nro_serie_just and TO_NUMBER(HISTORICO_IMPUESTOS.JUSTIFICANTE)= l.NRO_FACT and HISTORICO_IMPUESTOS.CODIGO_ENTIDAD=l.cod_entidad and HISTORICO_IMPUESTOS.NUMERO_ASIENTO_BORRADOR=l.NRO_ASIENTO_BORRADOR);
  update BOL_LIBRO_VTAS_TEMP set Imp_ice_tasas=0, imp_export_op=0,imp_vta_tasacero=0;
  commit;
  /**** segunda parte ==== BO(2)L-COMPLETAR DATOS LIBRO VENTAS */
  update BOL_LIBRO_VTAS_TEMP l set debito_fiscal=(select importe from (select historico_impuestos.*,(select h.importe from historico_det_impuestos h where HISTORICO_IMPUESTOS.ESTADO=h.ESTADO and HISTORICO_IMPUESTOS.EMPRESA=h.EMPRESA and HISTORICO_IMPUESTOS.FECHA_ASIENTO=h.FECHA_ASIENTO and HISTORICO_IMPUESTOS.DIARIO=h.DIARIO and HISTORICO_IMPUESTOS.NUMERO_ASIENTO_BORRADOR=h.NUMERO_ASIENTO_BORRADOR and HISTORICO_IMPUESTOS.NUMERO_LINEA_BORRADOR=h.NUMERO_LINEA_BORRADOR and HISTORICO_IMPUESTOS.NUMERO_LINEA_IMPUESTO=h.NUMERO_LINEA_IMPUESTO and h.porcentaje LIKE '13%') importe from historico_impuestos) historico_impuestos where HISTORICO_IMPUESTOS.EMPRESA='004' and HISTORICO_IMPUESTOS.SERIE_JUSTIFICANTE=l.nro_serie_just and TO_NUMBER(HISTORICO_IMPUESTOS.JUSTIFICANTE)= l.NRO_FACT and HISTORICO_IMPUESTOS.CODIGO_ENTIDAD=l.cod_entidad and HISTORICO_IMPUESTOS.NUMERO_ASIENTO_BORRADOR=l.NRO_ASIENTO_BORRADOR);
  commit;
  /*** tercera parte === BOL(3)- AJUSTES LIBRO VENTAS*/
  FOR reg IN c LOOP
    if reg.nro_autorizacion=nro_aut then
      if reg.nro_fact=(n+1) then
        n:=to_number(reg.nro_factura);
      else
        for n1 in (n+1)..(reg.nro_fact-1) LOOP
          insert into BOL_LIBRO_VTAS_TEMP(fecha_factura,nro_fact,nro_factura,nro_autorizacion, nit_cliente,razon_social, imp_vta_bruta,Imp_ice_tasas,imp_export_op,imp_vta_tasacero,imp_subtotal,imp_ttl_dsctos,imp_base_df, debito_fiscal,estado,documento, usuario,entidad,cod_entidad,porcentaje) VALUES (f,TO_NUMBER(n1),n1,reg.nro_autorizacion,'0','SIN NOMBRE',0,0,0,0,0,0,0,0,'A',n1,'PROMEDICAL','CL','0','13');
        END LOOP;
      end if;
    end IF;
    nro_aut:=reg.nro_autorizacion;
    nro_fact2:=reg.nro_factura;
    n:=to_number(reg.nro_fact);
    f:=reg.fecha_factura;
  END LOOP;
  UPDATE BOL_LIBRO_VTAS_TEMP
  SET nit_cliente='0',razon_social='SIN NOMBRE', imp_vta_bruta=0,Imp_ice_tasas=0, imp_export_op=0, imp_vta_tasacero=0,imp_subtotal=0,imp_ttl_dsctos=0,imp_base_df=0,debito_fiscal=0,codigo_control=null
  WHERE ESTADO<>'V';
    COMMIT;

 end libro_vtas_bol;

/*** SCRIPT PARA ENVIAR CORREOS DE BPM PENDIENTES DE GRUPOS */
procedure Enviar_bpm_abiertos_g is

     html_content_inicio CLOB := '<html><style>* {font-family: sans-serif;}.content-table {border-collapse: collapse;margin: 25px 0;font-size: 0.9em; min-width: 400px;border-radius: 5px 5px 0 0;overflow: hidden;box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
}.content-table thead tr {background-color: #28367f;color: #ffffff;text-align: left;font-weight: bold;}.content-table th,.content-table td {padding: 12px 15px;}
.content-table tbody tr {border-bottom: 1px solid #dddddd;}.content-table tbody tr:nth-of-type(even) {background-color: #f3f3f3;
}.content-table tbody tr:last-of-type {border-bottom: 2px solid #f80000;}.content-table tbody tr.active-row {font-weight: bold;color: #f80000;}</style><body>';
    html_content CLOB := '';html_content_fin CLOB := '</body></html>';v_resultado VARCHAR2(30);
    CURSOR C_EXPEDIENTES_C IS
    SELECT CRMEQUIPOS_USUARIOS.USUARIO AS USUARIO,MAX(CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO) AS EQUIPO_A_REALIZARLO,MAX(CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO) AS USUARIO_A_REALIZARLO,MAX(USUARIOS.FBAJA) AS FECHA,MAX(USUARIOS.EMAIL) AS CORREO
    FROM CRMEXPEDIENTES_LIN,CRMEXPEDIENTES_CAB,CRMEQUIPOS_USUARIOS,USUARIOS WHERE CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO = CRMEQUIPOS_USUARIOS.EQUIPO AND USUARIOS.ESTADO = 'BOL'
    AND CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE AND CRMEQUIPOS_USUARIOS.USUARIO = USUARIOS.USUARIO AND CRMEXPEDIENTES_CAB.EMPRESA IN('004') AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01')
    AND CRMEXPEDIENTES_LIN.STATUS_TAREA IN('01') AND EQUIPO_A_REALIZARLO IS NOT NULL AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IS NULL
    AND USUARIOS.FBAJA IS NULL AND (USUARIOS.PERFIL != 'EMPLEADO' AND USUARIOS.PERFIL NOT LIKE '%CLIENT%' AND USUARIOS.PERFIL NOT LIKE '%PROVEE%')
    GROUP BY CRMEQUIPOS_USUARIOS.USUARIO;
BEGIN
    FOR USUARIOS IN C_EXPEDIENTES_C LOOP
        html_content := html_content_inicio || 'Estimado miembro de equipo: <br/>A continuaci�n se muestran los expedientes que se encuentran abiertos y a la espera de atencion de uno de los integrantes del equipo, coordinar para su ejecucion y el proceso siga su curso normal:<hr/><table border="1" class="content-table"><thead><tr><th>Nro. expediente</th><th>Fecha</th><th>Descripci�n</th> <th>T�po Expediente</th></tr></thead><tbody>';
        FOR EXPEDIENTE_ABIERTO IN ( SELECT DISTINCT CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE AS NUMERO_EXPEDIENTE,CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO AS EQUIPO,CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE AS STATUS,
            CRMEXPEDIENTES_CAB.FECHA_INICIO  AS FECHA_INICIO,CRMEXPEDIENTES_CAB.DESCRIPCION_EXPEDIENTE1 AS DESCRIPCION_EXPEDIENTE1,
            (SELECT DESCRIPCION FROM crmtipos_expediente t WHERE t.TIPO_EXPEDIENTE = CRMEXPEDIENTES_CAB.TIPO_EXPEDIENTE AND t.empresa = '004') AS TIPO_EXPEDIENTE
                FROM CRMEXPEDIENTES_LIN,CRMEXPEDIENTES_CAB,CRMEQUIPOS_USUARIOS WHERE CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO = CRMEQUIPOS_USUARIOS.EQUIPO
                AND CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE AND CRMEQUIPOS_USUARIOS.USUARIO = USUARIOS.USUARIO
                AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01')AND CRMEXPEDIENTES_LIN.STATUS_TAREA IN('01') AND CRMEXPEDIENTES_CAB.EMPRESA IN('004') AND CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO IS NOT NULL
                AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IS NULL) LOOP
        html_content :=html_content||'<tr><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.NUMERO_EXPEDIENTE)||'</td><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.FECHA_INICIO)||'</td><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.DESCRIPCION_EXPEDIENTE1)||'</td><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.TIPO_EXPEDIENTE)||'</td></tr>';
        END LOOP;
        html_content := html_content || '</tbody></table>'|| html_content_fin;
        PK_EMAIL.INICIALIZAR('OSINAGA');
        PK_EMAIL.SET_ASUNTO('[RECORDATORIO] EXPEDIENTES ABIERTOS ASIGNADO(S) AL EQUIPO(S) AL QUE PERTENECE.');
        PK_EMAIL.SET_CUERPO_HTML(html_content);
        PK_EMAIL.ADD_DESTINATARIO('TO', USUARIOS.CORREO);
        PK_EMAIL.ADD_DESTINATARIO('CC', 'daniel.lobo@promedical.com.bo,edgar.mercado@promedical.com.bo,marcelo.osinaga@promedical.com.bo');
        v_resultado := PK_EMAIL.ENVIAR();
        html_content :='';
    END LOOP;
--END;
end  Enviar_bpm_abiertos_g;


/*==============CODIGO FUNCIONAL INDIVIDUAL V2================*/
procedure Enviar_bpm_abiertos_ind is

  html_content_inicio CLOB := '<html><style>* {font-family: sans-serif;}.content-table {border-collapse: collapse;margin: 25px 0;font-size: 0.9em;
    min-width: 400px;border-radius: 5px 5px 0 0;overflow: hidden;box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
}.content-table thead tr {background-color: #28367f;color: #ffffff;text-align: left;font-weight: bold;}.content-table th,.content-table td {padding: 12px 15px;}
.content-table tbody tr {border-bottom: 1px solid #dddddd;}.content-table tbody tr:nth-of-type(even) {background-color: #f3f3f3;
}.content-table tbody tr:last-of-type {border-bottom: 2px solid #f80000;}.content-table tbody tr.active-row {font-weight: bold;color: #f80000;}</style><body>';
    html_content CLOB := '';html_content_fin CLOB := '</body></html>';v_resultado VARCHAR2(30);
    CURSOR C_EXPEDIENTES_C IS
    SELECT DISTINCT CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO AS USUARIO_A_REALIZARLO,CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO AS EQUIPO_A_REALIZARLO, CRMEXPEDIENTES_LIN.EMPRESA AS EMPRESA,CRMEXPEDIENTES_LIN.STATUS_TAREA AS STATUS_TAREA,USUARIOS.EMAIL AS CORREO
    FROM CRMEXPEDIENTES_LIN,CRMEXPEDIENTES_CAB,USUARIOS
    WHERE CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO = USUARIOS.USUARIO
    AND CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE
    AND CRMEXPEDIENTES_CAB.EMPRESA IN('004')AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01')AND STATUS_TAREA in('01') AND USUARIOS.ESTADO = 'BOL'
    AND EQUIPO_A_REALIZARLO IS NULL AND USUARIO_A_REALIZARLO IS NOT NULL;
BEGIN
        FOR USUARIOS IN C_EXPEDIENTES_C LOOP
        html_content := html_content_inicio || 'Estimado usuario <strong>['||USUARIOS.USUARIO_A_REALIZARLO||']</strong>:<br/>A continuaci�n se muestran los expedientes que estan pendientes y asignados a su usuario, gestionar su ejecucion para que el proceso sigua su curso normal:<hr/><table border="1" class="content-table"><thead><tr><th>Nro. expediente</th><th>Fecha</th><th>Descripci�n</th><th>T�po Expediente</th></tr></thead><tbody>';
            FOR EXPEDIENTE_ABIERTO IN (SELECT CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE AS NUMERO_EXPEDIENTE,
                CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO AS USUARIO_A_REALIZARLO,CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO AS EQUIPO_A_REALIZARLO,
                CRMEXPEDIENTES_CAB.EMPRESA AS EMPRESA,CRMEXPEDIENTES_CAB.FECHA_INICIO AS FECHA_INICIO,
                CRMEXPEDIENTES_CAB.DESCRIPCION_EXPEDIENTE1 AS DESCRIPCION_EXPEDIENTE1,(SELECT DESCRIPCION FROM crmtipos_expediente t WHERE t.TIPO_EXPEDIENTE = CRMEXPEDIENTES_CAB.TIPO_EXPEDIENTE AND t.empresa = '004') AS TIPO_EXPEDIENTE,CRMEXPEDIENTES_LIN.STATUS_TAREA AS STATUS_TAREA
                        FROM CRMEXPEDIENTES_LIN,CRMEXPEDIENTES_CAB
                        WHERE CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE AND CRMEXPEDIENTES_CAB.EMPRESA IN('004') AND CRMEXPEDIENTES_LIN.STATUS_TAREA = '01'
                        AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01') AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IS NOT NULL
                        AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO = USUARIOS.USUARIO_A_REALIZARLO ) LOOP
              html_content :=html_content||'<tr><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.NUMERO_EXPEDIENTE)||'</td><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.FECHA_INICIO)||'</td><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.DESCRIPCION_EXPEDIENTE1)||'</td><td>'||TO_CHAR(EXPEDIENTE_ABIERTO.TIPO_EXPEDIENTE)||'</td></tr>';
            END LOOP;
            html_content := html_content || '</tbody></table>'|| html_content_fin;
            PK_EMAIL.INICIALIZAR('OSINAGA');
            PK_EMAIL.SET_ASUNTO('[RECORDATORIO] EXPEDIENTES ABIERTOS QUE REQUIEREN DE SU ATENCION.');
            PK_EMAIL.SET_CUERPO_HTML(html_content);
            PK_EMAIL.ADD_DESTINATARIO('TO', USUARIOS.CORREO);
            PK_EMAIL.ADD_DESTINATARIO('CC', 'daniel.lobo@promedical.com.bo,edgar.mercado@promedical.com.bo,marcelo.osinaga@promedical.com.bo');
            v_resultado := PK_EMAIL.ENVIAR();
            html_content :='';
        END LOOP;
end  Enviar_bpm_abiertos_ind;

procedure bpm_notificar_duplicados is
    html_content_inicio CLOB := '<html><style>* {font-family: sans-serif;}.content-table {border-collapse: collapse;margin: 25px 0;font-size: 0.9em; min-width: 400px;border-radius: 5px 5px 0 0;overflow: hidden;box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
    }.content-table thead tr {background-color: #28367f;color: #ffffff;text-align: left;font-weight: bold;}.content-table th,.content-table td {padding: 12px 15px;}
    .content-table tbody tr {border-bottom: 1px solid #dddddd;}.content-table tbody tr:nth-of-type(even) {background-color: #f3f3f3;
    }.content-table tbody tr:last-of-type {border-bottom: 2px solid #f80000;}.content-table tbody tr.active-row {font-weight: bold;color: #f80000;}</style><body>';

    html_content CLOB := '';
    html_content_fin CLOB := '</body></html>';
    v_resultado VARCHAR2(30);
    cursor c_exp is select numero_expediente, CODIGO_SECUENCIA, count(numero_expediente) nro_tareas  from crmexpedientes_lin where empresa='004' AND STATUS_TAREA='01'   group by numero_expediente, CODIGO_SECUENCIA HAVING count(numero_expediente)>=2;

BEGIN
    html_content := html_content_inicio || 'Estimado equipo de Tecnologia: <br/>A continuaci�n se muestran los expedientes duplicados que figuran en el sistema:<hr/><table border="1" class="content-table"><thead><tr><th>Nro. expediente</th><th>Cod. Secuencia</th><th>Nro de Tareas</th> </tr></thead><tbody>';

    FOR BPM_EXP in c_exp LOOP

        html_content :=html_content||'<tr><td>'||TO_CHAR(BPM_EXP.NUMERO_EXPEDIENTE)||'</td><td>'||TO_CHAR(BPM_EXP.CODIGO_SECUENCIA)||'</td><td>'||TO_CHAR(BPM_EXP.nro_tareas)||'</td></tr>';

		v_resultado:='ENVIAR';
    END LOOP;
        html_content := html_content || '</tbody></table>'|| html_content_fin;
        PK_EMAIL.INICIALIZAR('BPM');
        PK_EMAIL.SET_ASUNTO('[ALERTA] EXPEDIENTES DUPLICADOS QUE REQUIEREN ATENCION');
        PK_EMAIL.SET_CUERPO_HTML(html_content);
        --PK_EMAIL.ADD_DESTINATARIO('TO', 'soporte-ti@promedical.com.bo');
        --PK_EMAIL.ADD_DESTINATARIO('CC', 'daniel.lobo@promedical.com.bo,edgar.mercado@promedical.com.bo,marcelo.osinaga@promedical.com.bo');
        PK_EMAIL.ADD_DESTINATARIO('TO', 'daniel.lobo@promedical.com.bo,edgar.mercado@promedical.com.bo,marcelo.osinaga@promedical.com.bo');

        IF v_resultado = 'ENVIAR' THEN
            v_resultado := PK_EMAIL.ENVIAR();
        END IF;
        html_content :='';
END bpm_notificar_duplicados;

procedure validar_campos(empresa varchar2, plantilla varchar2, campo_validar varchar2) is
BEGIN
    Pkpantallas.inicializar_codigo_plug_in;
  IF empresa = '004' THEN
    if plantilla ='09004' AND campo_validar = '040' OR campo_validar = '062' OR campo_validar = '068' OR campo_validar = 'B010' OR campo_validar = 'B011' then
            if campo_validar = '040' then
                PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'S');
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN020','N' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.D_ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMA062','N' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );

                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN007', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'ENABLED', 'PROPERTY_TRUE');

                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
            elsif campo_validar = '062' then
            	PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'N');
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN020','N' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.D_ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );

                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN013','N' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMD007','N' );
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'ENABLED', 'PROPERTY_TRUE');


                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMH002', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMH001', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN014', 'ENABLED', 'PROPERTY_TRUE');
            elsif campo_validar = '068' then
            	PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'N');
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.D_ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMA062','S' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN020','N' );
                PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'CAMPOS.ITEMA062', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );

                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN007', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'ENABLED', 'PROPERTY_TRUE');

                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
            elsif campo_validar = 'B010' then
            	PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'N');
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.D_ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMA062','N' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN020','N' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );

                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN013','N' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMD006','N' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMD007','N' );
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN007', 'ENABLED', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'ENABLED', 'PROPERTY_FALSE');

                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
             elsif campo_validar = 'B011' then
            	PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'N');
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.D_ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMA062','N' );
                pkpantallas.comando_plug_in( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_TRUE' );
                pkpantallas.comando_plug_in( 'SIP', 'ETQCAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_TRUE' );
                PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'CAMPOS.ITEMN020', 'ENABLED', 'PROPERTY_TRUE');
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN020','S' );

                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN013','N' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMD006','N' );
                pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMD007','N' );
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN007', 'ENABLED', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE');
                pkpantallas.comando_plug_in('SIP', 'ETQCAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE');

                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
                pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
            end if;

        pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
        else
        PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'N');
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.D_ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
        pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMA062','N' );
        pkpantallas.comando_plug_in('FITEM','OBLIGATORIO', 'CAMPOS.ITEMN020','N' );

    end if;
  END IF;
END validar_campos;

PROCEDURE validar_campos_web(empresa varchar2, plantilla varchar2, campo_validar varchar2) is
BEGIN
    IF empresa ='004' and plantilla ='09004' THEN
        IF campo_validar = '040' then
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_TRUE' );
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMA062', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD006', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD007', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN013', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN020', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH002', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH001', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN014', 'REQUIRED', 'PROPERTY_FALSE');
        ELSIF campo_validar = '068' then
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_TRUE' );
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMA062', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD006', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD007', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN013', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN020', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH002', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH001', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN014', 'REQUIRED', 'PROPERTY_FALSE');
        ELSIF campo_validar = '062' then
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMA062', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD006', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD007', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN013', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN020', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH002', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH001', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN014', 'REQUIRED', 'PROPERTY_TRUE');
        ELSIF campo_validar = 'B010' then
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD006', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD007', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN013', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMA062', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN020', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH002', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH001', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN014', 'REQUIRED', 'PROPERTY_FALSE');
        ELSIF campo_validar = 'B011' then
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD006', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMD007', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN013', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN020', 'VISIBLE', 'PROPERTY_TRUE' );

            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );

            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD006', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMD007', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN013', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMA062', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN020', 'REQUIRED', 'PROPERTY_TRUE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH002', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH001', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN014', 'REQUIRED', 'PROPERTY_FALSE');
        ELSE
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_TRUE' );
            pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMA062', 'VISIBLE', 'PROPERTY_FALSE' );
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMA062', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH002', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMH001', 'REQUIRED', 'PROPERTY_FALSE');
            PKPANTALLAS.COMANDO_PLUG_IN('SIP', 'ITEMN014', 'REQUIRED', 'PROPERTY_FALSE');
        END IF;
    END IF;
END validar_campos_web;

PROCEDURE direccionar_bpm_beneficio(nempresa varchar2, expediente number, linea number) IS
    v_usuario varchar2(20);
    v_usuario_alta varchar2(20);
    v_cnt number;
    V_RDO varchar2(20);
    V_TIPO varchar2(20);
BEGIN
        SELECT ITEMA038 INTO V_TIPO  FROM CRMEXPEDIENTES_CAB
         WHERE NUMERO_EXPEDIENTE = expediente
           AND EMPRESA = nempresa;
           SELECT itema010,usuario_alta INTO v_usuario,v_usuario_alta FROM crmexpedientes_cab WHERE numero_expediente = expediente AND empresa = nempresa;
           COMMIT;
  			IF V_TIPO ='040'THEN
                        pkcrmnotificaciones.inicializar_destinatarios;
                        pkcrmnotificaciones.add_destinatario('USUARIO', v_usuario);
                        pkcrmnotificaciones.enviar(nempresa, expediente, linea, 'BOL_BEN_01');
                    SELECT count(*) INTO v_cnt
                    FROM crmexpedientes_lin WHERE numero_expediente = expediente
                    AND empresa = nempresa and codigo_secuencia ='40';
                    UPDATE crmexpedientes_lin
                        SET usuario_a_realizarlo = v_usuario, status_interno = '0200', equipo_a_realizarlo = null,
                        CODIGO_SECUENCIA = '15', TIPO_TAREA = '901',STATUS_TAREA = '01'
                    WHERE numero_expediente = expediente
                        AND numero_linea = linea
                        AND empresa = nempresa;
            ELSIF V_TIPO ='062'THEN
            	UPDATE crmexpedientes_lin
                        SET usuario_a_realizarlo = v_usuario_alta,
                        status_interno = '0200',
                        equipo_a_realizarlo = null,
                        CODIGO_SECUENCIA = '160',
                        TIPO_TAREA = '000',
                        STATUS_TAREA = '01'
                    WHERE numero_expediente = expediente
                        AND numero_linea = linea
                        AND empresa = nempresa;
            ELSIF V_TIPO ='068'THEN
            	UPDATE crmexpedientes_lin
                        SET usuario_a_realizarlo = v_usuario_alta,
                        status_interno = '0200',
                        equipo_a_realizarlo = null,
                        CODIGO_SECUENCIA = '30',
                        TIPO_TAREA = '000',
                        STATUS_TAREA = '01'
                    WHERE numero_expediente = expediente
                        AND numero_linea = linea
                        AND empresa = nempresa;
            ELSIF V_TIPO ='B010'THEN
            	UPDATE crmexpedientes_lin SET usuario_a_realizarlo = v_usuario_alta,status_interno = '0200', equipo_a_realizarlo = null,
                        CODIGO_SECUENCIA = '70', TIPO_TAREA = '000', STATUS_TAREA = '01'
                    WHERE numero_expediente = expediente AND numero_linea = linea AND empresa = nempresa;
            ELSIF V_TIPO ='B011'THEN
            	UPDATE crmexpedientes_lin SET usuario_a_realizarlo = v_usuario_alta,status_interno = '0200', equipo_a_realizarlo = null,
                        CODIGO_SECUENCIA = '130', TIPO_TAREA = '000', STATUS_TAREA = '01'
                    WHERE numero_expediente = expediente AND numero_linea = linea AND empresa = nempresa;
            ELSIF V_TIPO ='060'THEN
            	UPDATE crmexpedientes_lin SET usuario_a_realizarlo = v_usuario ,status_interno = '0200', equipo_a_realizarlo = null,
                        CODIGO_SECUENCIA = '120', TIPO_TAREA = '000', STATUS_TAREA = '01'
                 WHERE numero_expediente = expediente AND numero_linea = linea AND empresa = nempresa;
            END IF;
            COMMIT;
END direccionar_bpm_beneficio;



end pk_promedical_bol;
/
