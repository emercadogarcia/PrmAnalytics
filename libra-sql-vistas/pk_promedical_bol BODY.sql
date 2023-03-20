CREATE OR REPLACE PACKAGE BODY pk_promedical_bol AS

procedure ejecutar_bpm_vta(cod_sec varchar2) is
cursor c1(pc_cod_sec varchar2) is SELECT distinct NUMERO_EXPEDIENTE, NUMERO_LINEA, CODIGO_SECUENCIA FROM crmexpedientes_lin
WHERE EMPRESA='004' AND STATUS_TAREA='01' and codigo_secuencia = pc_cod_sec and numero_expediente in (Select numero_expediente from crmexpedientes_cab 	where FECHA_INICIO >=trunc(current_date,'MONTH') and empresa='004' and tipo_expediente='04003' and status_expediente='01') GROUP BY NUMERO_EXPEDIENTE, NUMERO_LINEA, CODIGO_SECUENCIA;

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

   select  forma_pago, canalv, cadena, almacen_entrega, cliente
    into v_forma_pago, v_canalv, v_cadena, v_bodega, v_cliente
    from (select pedidos_ventas.*, (SELECT VALOR_CLAVE FROM  CLIENTES_CLAVES_ESTADISTICAS c WHERE c.CLAVE='CANALV' AND c.CODIGO_CLIENTE=pedidos_ventas.CLIENTE AND c.CODIGO_EMPRESA=pedidos_ventas.empresa) canalv, (SELECT VALOR_CLAVE FROM  CLIENTES_CLAVES_ESTADISTICAS c WHERE c.CLAVE='CADN' AND c.CODIGO_CLIENTE=pedidos_ventas.CLIENTE AND c.CODIGO_EMPRESA=pedidos_ventas.empresa) cadena from pedidos_ventas) pedidos_ventas
    where empresa= '004'
      and organizacion_comercial = v_org
      and ejercicio = v_ejercicio
      and numero_serie= v_serie
      and numero_pedido = v_numero;
 IF (v_bodega IS NOT NULL OR v_cliente IS NOT NULL) THEN
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
      if (/*v_forma_pago='0200' and v_forma_pago2='0200')*/ rs.codigo_secuencia='031') or (v_canalv='B01' and v_cadena<>'B005') then
        /*** valida si es pedido al contado, si es asi lo pasa directo*/
            V_RTN := pkcrmexpedientes_tareas.finalizar_tarea_at('004', rs.numero_expediente, rs.numero_linea, sysdate(),'AUTOMATICO','13',TRUE,TRUE);
            commit;
      end if;
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
 else
    -- cuando existe un dato no encontrado
    pkcrmnotificaciones.inicializar_destinatarios;
    pkcrmnotificaciones.add_destinatario('USUARIO', 'EMERCADO');
    pkcrmnotificaciones.enviar('004', rs.numero_expediente, rs.numero_linea, 'BOL_CRM_05');

   end if;
 END IF;
   commit;
 end;
end loop;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    pkpantallas.log( 'Datos Pedido: ' || v_org ||'/'|| v_ejercicio || '/' || v_serie||'/'||v_numero);
    --pkpantallas.log(SQLERRM, $$PLSQL_UNIT, 'pk_automatico_bol');
    RAISE;
end ejecutar_bpm_vta;

end pk_promedical_bol;
/
