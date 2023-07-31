/*======================CODIGO FUNCIONAL DE GRUPOS V1=======================*/
DECLARE
    html_content_inicio CLOB := '<html><body>';
    html_content CLOB := '';
    html_content_fin CLOB := '</body></html>';
    v_resultado VARCHAR2(30);
    CURSOR C_EXPEDIENTES_C IS
        SELECT CRMEQUIPOS_USUARIOS.USUARIO AS USUARIO,
               MAX(CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO) AS EQUIPO_A_REALIZARLO,
               MAX(CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO) AS USUARIO_A_REALIZARLO,
               MAX(USUARIOS.FBAJA) AS FECHA,
               MAX(USUARIOS.EMAIL) AS CORREO
        FROM CRMEXPEDIENTES_LIN,
             CRMEXPEDIENTES_CAB,
             CRMEQUIPOS_USUARIOS,
             USUARIOS
        WHERE CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO = CRMEQUIPOS_USUARIOS.EQUIPO
          AND CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE
          AND CRMEQUIPOS_USUARIOS.USUARIO = USUARIOS.USUARIO
          AND CRMEXPEDIENTES_CAB.EMPRESA IN('004')
          AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01')
          AND CRMEXPEDIENTES_LIN.STATUS_TAREA IN('01')
          AND EQUIPO_A_REALIZARLO IS NOT NULL
          AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IS NULL
          AND CRMEQUIPOS_USUARIOS.USUARIO IN ('MOSINAGA')
          AND USUARIOS.FBAJA IS NULL
          AND (USUARIOS.PERFIL != 'EMPLEADO' AND USUARIOS.PERFIL NOT LIKE '%CLIENT%' AND USUARIOS.PERFIL NOT LIKE '%PROVEE%')
        GROUP BY CRMEQUIPOS_USUARIOS.USUARIO;
BEGIN
        FOR USUARIOS IN C_EXPEDIENTES_C LOOP
         html_content := html_content_inicio || '<table border="1"><tr><th>Nro expediente</th></tr>';
            FOR EXPEDIENTE_ABIERTO IN (SELECT DISTINCT CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE AS NUMERO_EXPEDIENTE,
                                                        CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO AS EQUIPO,
                                                        CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE AS STATUS
                                        FROM CRMEXPEDIENTES_LIN,
                                             CRMEXPEDIENTES_CAB,
                                             CRMEQUIPOS_USUARIOS
                                        WHERE CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO = CRMEQUIPOS_USUARIOS.EQUIPO
                                            AND CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE
                                            AND CRMEQUIPOS_USUARIOS.USUARIO = USUARIOS.USUARIO
                                            AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01')
                                            AND CRMEXPEDIENTES_LIN.STATUS_TAREA IN('01')
                                            AND CRMEXPEDIENTES_CAB.EMPRESA IN('004')
                                            AND CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO IS NOT NULL
                                            AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IS NULL ) LOOP
              html_content := html_content || '<tr><td>' || EXPEDIENTE_ABIERTO.NUMERO_EXPEDIENTE || USUARIOS.USUARIO|| '</td></tr>';
            END LOOP;
            html_content := html_content || '</table>'|| html_content_fin;
            PK_EMAIL.INICIALIZAR('OSINAGA');
            PK_EMAIL.SET_ASUNTO('EXPEDIENTES QUE TIENE ABIERTO');
            PK_EMAIL.SET_CUERPO('Expedientes abiertos que tiene asignado a los grupos que usted pertenece.');
            PK_EMAIL.SET_CUERPO_HTML(html_content);
            PK_EMAIL.ADD_DESTINATARIO('TO', USUARIOS.CORREO);
            v_resultado := PK_EMAIL.ENVIAR();
            html_content :='';
        END LOOP;
END;

/*==============CODIGO FUNCIONAL INDIVIDUAL V1================*/

DECLARE
    html_content_inicio CLOB := '<html><body>';
    html_content CLOB := '';
    html_content_fin CLOB := '</body></html>';
    v_resultado VARCHAR2(30);
    CURSOR C_EXPEDIENTES_C IS
        SELECT DISTINCT CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO AS USUARIO_A_REALIZARLO,
                CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO AS EQUIPO_A_REALIZARLO,
                CRMEXPEDIENTES_LIN.EMPRESA AS EMPRESA,
                CRMEXPEDIENTES_LIN.STATUS_TAREA AS STATUS_TAREA,
                USUARIOS.EMAIL AS CORREO
        FROM CRMEXPEDIENTES_LIN,
             CRMEXPEDIENTES_CAB,
             USUARIOS
        WHERE CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO = USUARIOS.USUARIO
            AND CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE
            AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IN ('MOSINAGA')
            AND CRMEXPEDIENTES_CAB.EMPRESA IN('004')
            AND CRMEXPEDIENTES_CAB.STATUS_EXPEDIENTE IN('01')
            AND STATUS_TAREA in('01')
            AND EQUIPO_A_REALIZARLO IS NULL
            AND USUARIO_A_REALIZARLO IS NOT NULL;
    TYPE NUMERO_EXPEDIENTE IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    NUMERO_EXPEDIENTES NUMERO_EXPEDIENTE;
BEGIN
        FOR USUARIOS IN C_EXPEDIENTES_C LOOP
        html_content := html_content_inicio || '<table border="1"><tr><th>Nro expediente</th></tr>';
            FOR EXPEDIENTE_ABIERTO IN (SELECT CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE AS NUMERO_EXPEDIENTE,
                                           CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO AS USUARIO_A_REALIZARLO,
                                           CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO AS EQUIPO_A_REALIZARLO,
                                           CRMEXPEDIENTES_CAB.EMPRESA AS EMPRESA,
                                           CRMEXPEDIENTES_LIN.STATUS_TAREA AS STATUS_TAREA
                                    FROM CRMEXPEDIENTES_LIN,
                                          CRMEXPEDIENTES_CAB
                                    WHERE CRMEXPEDIENTES_CAB.NUMERO_EXPEDIENTE = CRMEXPEDIENTES_LIN.NUMERO_EXPEDIENTE
                                        AND CRMEXPEDIENTES_CAB.EMPRESA IN('004')
                                        AND CRMEXPEDIENTES_LIN.STATUS_TAREA = '01'
                                        AND CRMEXPEDIENTES_LIN.EQUIPO_A_REALIZARLO IS NULL
                                        AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO IS NOT NULL
                                        AND CRMEXPEDIENTES_LIN.USUARIO_A_REALIZARLO = USUARIOS.USUARIO_A_REALIZARLO ) LOOP
              html_content := html_content || '<tr><td>' || EXPEDIENTE_ABIERTO.NUMERO_EXPEDIENTE || '</td></tr>';
            END LOOP;
            html_content := html_content || '</table>'|| html_content_fin;
            PK_EMAIL.INICIALIZAR('OSINAGA');
            PK_EMAIL.SET_ASUNTO('EXPEDIENTES QUE TIENE ABIERTO');
            PK_EMAIL.SET_CUERPO('Esta es un la lista de expedientes que tiene pendiente de ejecutar.');
            PK_EMAIL.SET_CUERPO_HTML(html_content);
            PK_EMAIL.ADD_DESTINATARIO('TO', USUARIOS.CORREO);
            v_resultado := PK_EMAIL.ENVIAR();
            html_content :='';
        END LOOP;
END;

