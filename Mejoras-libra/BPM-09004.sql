DECLARE
  cant_dias FLOAT;
BEGIN
  IF :CAMPOS.TIPO_EXPEDIENTE_MIRROR = '09004' AND :CAMPOS.ITEMA038 = '040' AND :global.codigo_empresa = '004' THEN
    SELECT MAX(RH_TRABAJADOR_VACAMEX_TMP.SALDO_VACACIONES) INTO cant_dias
    FROM RH_TRABAJADORES,
         RH_TRABAJADOR_VACAMEX_TMP
    WHERE RH_TRABAJADOR_VACAMEX_TMP.EMPRESA = '004'
      and RH_TRABAJADOR_VACAMEX_TMP.EMPRESA = RH_TRABAJADORES.EMPRESA
      and RH_TRABAJADOR_VACAMEX_TMP.SUBEMPRESA = RH_TRABAJADORES.SUBEMPRESA
      and RH_TRABAJADOR_VACAMEX_TMP.TRABAJADOR = RH_TRABAJADORES.CODIGO_TRABAJADOR
      and RH_TRABAJADOR_VACAMEX_TMP.TRABAJADOR = :CAMPOS.ITEMA006
      and RH_TRABAJADOR_VACAMEX_TMP.TIPO_VALOR = '00'
    GROUP BY RH_TRABAJADOR_VACAMEX_TMP.SALDO_VACACIONES;

    IF :CAMPOS.ITEMN013 > cant_dias THEN
      :CAMPOS.ITEMN013:='';
      :p_tipo_mensaje := 'CAMPO';
      :p_codigo_mensaje := 'TEXTOLIB';
      :p_texto_mensaje := 'No cuenta con el saldo de días necesario para realizar esta solicitud, Por favor comunicarse con talento humano. Usted cuenta con '||cant_dias||' días.';
    ELSIF :CAMPOS.ITEMN013 <= 0 THEN
      :CAMPOS.ITEMN013:='';
      :p_tipo_mensaje := 'CAMPO';
      :p_codigo_mensaje := 'TEXTOLIB';
      :p_texto_mensaje := 'Este campo no acepta valores negativos ni 0.';
    END IF;
  END IF;
END;



/*============LIMPIO OCULTAR MOSTRAR CAMPOS===========*/

    ITEMA038


    Pkpantallas.inicializar_codigo_plug_in;
if :GLOBAL.codigo_empresa ='004' and :plantilla.codigo_plantilla='09004' AND :CAMPOS.ITEMA038 = '040' then
	PKPANTALLAS.COMANDO_PLUG_IN('PKLIBPNT_SIP', 'CAMPOS.ITEMN013', 'BLOQUEA_VALIDA_SIN_INTRO', 'S');

    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );

   	pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );

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

end if;
/*================ENTRADA EN EL BLOQUE=========================*/
if :GLOBAL.codigo_empresa ='004' and :plantilla.codigo_plantilla='09004' then
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );

	pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ETQCAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
end if;



/*===========INICIALIZAR WEB ===============*/
if :GLOBAL.codigo_empresa ='004' and :parametros.tipo_expediente='09004' then
    pkpantallas.comando_plug_in ( 'SIP', 'ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
end if;




if :GLOBAL.codigo_empresa ='004' and :parametros.tipo_expediente ='09004' AND :CAMPOS.ITEMA038 = '040' then
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_FALSE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_FALSE' );
else
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH002', 'VISIBLE', 'PROPERTY_TRUE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMH001', 'VISIBLE', 'PROPERTY_TRUE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN014', 'VISIBLE', 'PROPERTY_TRUE' );
    pkpantallas.comando_plug_in ( 'SIP', 'CAMPOS.ITEMN012', 'VISIBLE', 'PROPERTY_TRUE' );
end if;
