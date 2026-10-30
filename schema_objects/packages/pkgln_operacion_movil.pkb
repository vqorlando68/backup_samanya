CREATE OR REPLACE PACKAGE BODY PKGLN_OPERACION_MOVIL 
AS
    vro_error smy_errores%ROWTYPE;

    -- -------------------------------------------------------------------------
    -- 1. Obtener estado consolidado móvil en formato JSON nativo
    -- -------------------------------------------------------------------------
    FUNCTION f_obtener_estado_movil_json (
        pcl_json IN CLOB
    ) RETURN CLOB
    IS
        vcl_resultado CLOB;
    BEGIN
        vcl_resultado := PKGCN_OPERACION_MOVIL.fn_obtener_estado_movil_json(pcl_json);
        RETURN vcl_resultado;
    EXCEPTION
        WHEN OTHERS THEN
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'F_OBTENER_ESTADO_MOVIL_JSON';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END f_obtener_estado_movil_json;

    -- -------------------------------------------------------------------------
    -- 2. Registrar entrada en la bitácora asistencial del residente
    -- -------------------------------------------------------------------------
    PROCEDURE pr_registrar_bitacora (
        pcl_json IN CLOB
    ) IS
        v_id_residente   smy_bitacora_residente.id_residente%TYPE;
        v_id_usuario     smy_bitacora_residente.id_usuario%TYPE;
        v_id_empleado    smy_bitacora_residente.id_empleado%TYPE;
        v_categoria_str  VARCHAR2(100);
        v_id_categoria   smy_bitacora_residente.id_categoria_bitacora%TYPE;
        v_fecha_str      VARCHAR2(30);
        v_hora           VARCHAR2(15);
        v_contenido      CLOB;
        v_voz_str        VARCHAR2(10);
        vro_residente    smy_residentes%ROWTYPE;
        vro_bitacora     smy_bitacora_residente%ROWTYPE;
    BEGIN
        v_id_residente  := TO_NUMBER(JSON_VALUE(pcl_json, '$.idResidente'));
        v_id_usuario    := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));
        v_id_empleado   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idEmpleado'));
        v_id_categoria  := TO_NUMBER(JSON_VALUE(pcl_json, '$.idCategoriaBitacora'));
        v_categoria_str := LOWER(TRIM(JSON_VALUE(pcl_json, '$.categoria')));
        v_fecha_str     := JSON_VALUE(pcl_json, '$.fecha');
        v_hora          := JSON_VALUE(pcl_json, '$.hora');
        v_contenido     := JSON_VALUE(pcl_json, '$.contenido');
        v_voz_str       := JSON_VALUE(pcl_json, '$.grabadoPorVoz');

        IF v_id_residente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del residente es obligatorio para registrar bitácora.');
        END IF;

        IF PKGSMY_RESIDENTES_DAO.f_existe(v_id_residente, vro_residente) = FALSE THEN
            RAISE_APPLICATION_ERROR(-20002, 'El residente especificado no existe en el sistema.');
        END IF;

        IF v_id_categoria IS NULL THEN
            IF v_categoria_str LIKE '%comportamiento%' OR v_categoria_str LIKE '%animo%' OR v_categoria_str LIKE '%ánimo%' THEN
                v_id_categoria := 2;
            ELSIF v_categoria_str LIKE '%salud%' OR v_categoria_str LIKE '%medic%' OR v_categoria_str LIKE '%sintoma%' THEN
                v_id_categoria := 3;
            ELSIF v_categoria_str LIKE '%visita%' OR v_categoria_str LIKE '%familiar%' THEN
                v_id_categoria := 4;
            ELSIF v_categoria_str LIKE '%actividad%' OR v_categoria_str LIKE '%recrea%' THEN
                v_id_categoria := 5;
            ELSIF v_categoria_str LIKE '%alerta%' THEN
                v_id_categoria := 6;
            ELSE
                v_id_categoria := 1;
            END IF;
        END IF;

        vro_bitacora.id                             := SEQ_SMY_BITACORA_RESIDENTE.NEXTVAL;
        vro_bitacora.id_residente                   := v_id_residente;
        vro_bitacora.id_empleado                    := v_id_empleado;
        vro_bitacora.id_usuario                     := v_id_usuario;
        IF v_fecha_str IS NOT NULL AND LENGTH(TRIM(v_fecha_str)) >= 10 THEN
            vro_bitacora.fecha                      := TO_DATE(SUBSTR(v_fecha_str, 1, 10), 'YYYY-MM-DD');
        ELSE
            vro_bitacora.fecha                      := TRUNC(f_fecha_actual);
        END IF;
        vro_bitacora.hora                           := NVL(SUBSTR(v_hora, 1, 8), TO_CHAR(f_fecha_actual, 'HH24:MI'));
        vro_bitacora.id_categoria_bitacora          := v_id_categoria;
        vro_bitacora.contenido                      := NVL(v_contenido, 'Registro asistencial');
        vro_bitacora.grabado_por_voz                := CASE WHEN UPPER(NVL(v_voz_str, 'N')) IN ('S', 'TRUE', '1') THEN 'S' ELSE 'N' END;
        vro_bitacora.visible_acudiente              := 'S';
        vro_bitacora.fecha_creacion                 := f_fecha_actual;
        vro_bitacora.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_BITACORA_RESIDENTE_DAO.p_insertar(vro_bitacora);

        p_do_commit('pkgln_operacion_movil.pr_registrar_bitacora');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_REGISTRAR_BITACORA';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_registrar_bitacora;

    -- -------------------------------------------------------------------------
    -- 3. Registrar toma de signos vitales del residente
    -- -------------------------------------------------------------------------
    PROCEDURE pr_registrar_signos_vitales (
        pcl_json IN CLOB
    ) IS
        v_id_residente  smy_signos_vitales.id_residente%TYPE;
        v_id_usuario    smy_signos_vitales.id_usuario_registro%TYPE;
        v_fecha_str     VARCHAR2(30);
        v_hora          VARCHAR2(15);
        v_sistolica     NUMBER;
        v_diastolica    NUMBER;
        v_fc            NUMBER;
        v_spo2          NUMBER;
        v_temp          NUMBER;
        v_glucosa       NUMBER;
        v_notas         VARCHAR2(500);
        vro_residente   smy_residentes%ROWTYPE;
        vro_signos      smy_signos_vitales%ROWTYPE;
    BEGIN
        v_id_residente := TO_NUMBER(JSON_VALUE(pcl_json, '$.idResidente'));
        v_id_usuario   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));
        v_fecha_str    := JSON_VALUE(pcl_json, '$.fecha');
        v_hora         := JSON_VALUE(pcl_json, '$.hora');
        v_sistolica    := TO_NUMBER(JSON_VALUE(pcl_json, '$.systolic'));
        v_diastolica   := TO_NUMBER(JSON_VALUE(pcl_json, '$.diastolic'));
        v_fc           := TO_NUMBER(JSON_VALUE(pcl_json, '$.heartRate'));
        v_spo2         := TO_NUMBER(JSON_VALUE(pcl_json, '$.spO2'));
        v_temp         := TO_NUMBER(REPLACE(JSON_VALUE(pcl_json, '$.temperature'), ',', '.'));
        v_glucosa      := TO_NUMBER(JSON_VALUE(pcl_json, '$.glucose'));
        v_notas        := JSON_VALUE(pcl_json, '$.notes');

        IF v_id_residente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del residente es obligatorio para registrar signos vitales.');
        END IF;

        IF PKGSMY_RESIDENTES_DAO.f_existe(v_id_residente, vro_residente) = FALSE THEN
            RAISE_APPLICATION_ERROR(-20002, 'El residente especificado no existe en el sistema.');
        END IF;

        vro_signos.id                             := SEQ_SMY_SIGNOS_VITALES.NEXTVAL;
        vro_signos.id_residente                   := v_id_residente;
        vro_signos.id_usuario_registro            := v_id_usuario;
        IF v_fecha_str IS NOT NULL AND LENGTH(TRIM(v_fecha_str)) >= 10 THEN
            vro_signos.fecha                      := TO_DATE(SUBSTR(v_fecha_str, 1, 10), 'YYYY-MM-DD');
        ELSE
            vro_signos.fecha                      := TRUNC(f_fecha_actual);
        END IF;
        vro_signos.hora                           := NVL(SUBSTR(v_hora, 1, 8), TO_CHAR(f_fecha_actual, 'HH24:MI'));
        vro_signos.presion_sistolica              := NVL(v_sistolica, 120);
        vro_signos.presion_diastolica             := NVL(v_diastolica, 80);
        vro_signos.frecuencia_cardiaca            := NVL(v_fc, 72);
        vro_signos.saturacion_oxigeno             := NVL(v_spo2, 96);
        vro_signos.temperatura                    := NVL(v_temp, 36.5);
        vro_signos.glucometria                    := v_glucosa;
        vro_signos.observaciones                  := SUBSTR(v_notas, 1, 450);
        IF NVL(v_sistolica, 120) >= 140 OR NVL(v_spo2, 96) < 92 OR NVL(v_temp, 36.5) >= 38 THEN
            vro_signos.es_alerta_rango            := 'S';
        ELSE
            vro_signos.es_alerta_rango            := 'N';
        END IF;
        vro_signos.fecha_creacion                 := f_fecha_actual;
        vro_signos.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_SIGNOS_VITALES_DAO.p_insertar(vro_signos);

        p_do_commit('pkgln_operacion_movil.pr_registrar_signos_vitales');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_REGISTRAR_SIGNOS_VITALES';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_registrar_signos_vitales;

    -- -------------------------------------------------------------------------
    -- 4. Registrar reporte de incidente o evento adverso
    -- -------------------------------------------------------------------------
    PROCEDURE pr_registrar_incidente (
        pcl_json IN CLOB
    ) IS
        v_tipo_str       VARCHAR2(50);
        v_severidad_str  VARCHAR2(50);
        v_id_tipo        NUMBER;
        v_id_severidad   NUMBER;
        v_descripcion    CLOB;
        v_id_usuario     NUMBER;
        v_id_res_principal NUMBER;
        vro_incidente    smy_incidentes%ROWTYPE;
        vro_inc_res      smy_incidente_residentes%ROWTYPE;
        vro_notif        smy_notificaciones_sistema%ROWTYPE;
    BEGIN
        v_tipo_str         := LOWER(TRIM(JSON_VALUE(pcl_json, '$.incidentType')));
        v_severidad_str    := LOWER(TRIM(JSON_VALUE(pcl_json, '$.severity')));
        v_descripcion      := JSON_VALUE(pcl_json, '$.description');
        v_id_usuario       := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));
        v_id_res_principal := TO_NUMBER(JSON_VALUE(pcl_json, '$.idResidentePrincipal'));

        IF v_tipo_str = 'caida' THEN
            v_id_tipo := 1;
        ELSIF v_tipo_str = 'cambio_salud' THEN
            v_id_tipo := 2;
        ELSIF v_tipo_str = 'conflicto' THEN
            v_id_tipo := 3;
        ELSIF v_tipo_str = 'medicacion' THEN
            v_id_tipo := 4;
        ELSE
            v_id_tipo := 5;
        END IF;

        IF v_severidad_str = 'critica' THEN
            v_id_severidad := 3;
        ELSIF v_severidad_str = 'moderada' THEN
            v_id_severidad := 2;
        ELSE
            v_id_severidad := 1;
        END IF;

        vro_incidente.id                             := SEQ_SMY_INCIDENTES.NEXTVAL;
        vro_incidente.id_tipo_incidente              := v_id_tipo;
        vro_incidente.id_severidad_incidente         := v_id_severidad;
        vro_incidente.fecha_hora_evento              := f_fecha_actual;
        vro_incidente.descripcion                    := NVL(v_descripcion, 'Reporte de incidente asistencial');
        vro_incidente.id_usuario_reporto             := v_id_usuario;
        vro_incidente.id_estado_incidente            := 1; -- recibido
        vro_incidente.notificado_acudiente           := 'S';
        vro_incidente.fecha_creacion                 := f_fecha_actual;
        vro_incidente.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_INCIDENTES_DAO.p_insertar(vro_incidente);

        IF v_id_res_principal IS NOT NULL THEN
            vro_inc_res.id                             := SEQ_SMY_INCIDENTE_RESIDENTES.NEXTVAL;
            vro_inc_res.id_incidente                   := vro_incidente.id;
            vro_inc_res.id_residente                   := v_id_res_principal;
            vro_inc_res.id_rol_incidente               := 1; -- Afectado
            vro_inc_res.fecha_creacion                 := f_fecha_actual;
            vro_inc_res.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_INCIDENTE_RESIDENTES_DAO.p_insertar(vro_inc_res);
        END IF;

        -- Generar notificación de alerta en sistema vía DAO
        vro_notif.id                             := SEQ_SMY_NOTIFICACIONES_SISTEMA.NEXTVAL;
        vro_notif.id_usuario_destino             := 1; -- Administrador
        vro_notif.titulo                         := 'Nuevo incidente (' || NVL(v_severidad_str, 'leve') || ')';
        vro_notif.mensaje                        := SUBSTR(DBMS_LOB.SUBSTR(v_descripcion, 240, 1), 1, 240);
        vro_notif.id_tipo_notificacion           := 2; -- incidente
        vro_notif.pantalla_destino               := 'incidents';
        vro_notif.id_objeto_destino              := vro_incidente.id;
        vro_notif.leido                          := 'N';
        vro_notif.fecha_creacion                 := f_fecha_actual;
        vro_notif.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_NOTIFICACIONES_SISTEMA_DAO.p_insertar(vro_notif);

        p_do_commit('pkgln_operacion_movil.pr_registrar_incidente');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_REGISTRAR_INCIDENTE';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_registrar_incidente;

    -- -------------------------------------------------------------------------
    -- 5. Crear o actualizar tarea operativa asistencial
    -- -------------------------------------------------------------------------
    PROCEDURE pr_guardar_tarea_operativa (
        pcl_json IN CLOB
    ) IS
        v_id_tarea       smy_tareas_operativas.id%TYPE;
        v_titulo         VARCHAR2(200);
        v_tipo_str       VARCHAR2(50);
        v_alcance_str    VARCHAR2(50);
        v_estado_str     VARCHAR2(50);
        v_id_tipo        NUMBER;
        v_id_alcance     NUMBER;
        v_id_estado      NUMBER;
        v_fecha_str      VARCHAR2(30);
        v_hora           VARCHAR2(15);
        v_id_residente   NUMBER;
        v_cant_res       NUMBER;
        v_descripcion    VARCHAR2(1000);
        v_id_usr_asig    NUMBER;
        v_id_usuario     NUMBER;
        vro_tarea        smy_tareas_operativas%ROWTYPE;
    BEGIN
        v_id_tarea     := TO_NUMBER(JSON_VALUE(pcl_json, '$.id'));
        v_titulo       := TRIM(JSON_VALUE(pcl_json, '$.title'));
        v_tipo_str     := LOWER(TRIM(JSON_VALUE(pcl_json, '$.type')));
        v_alcance_str  := LOWER(TRIM(JSON_VALUE(pcl_json, '$.scope')));
        v_estado_str   := LOWER(TRIM(JSON_VALUE(pcl_json, '$.status')));
        v_fecha_str    := JSON_VALUE(pcl_json, '$.date');
        v_hora         := JSON_VALUE(pcl_json, '$.time');
        v_id_residente := TO_NUMBER(JSON_VALUE(pcl_json, '$.residentId'));
        v_cant_res     := TO_NUMBER(JSON_VALUE(pcl_json, '$.residentCount'));
        v_descripcion  := JSON_VALUE(pcl_json, '$.description');
        v_id_usr_asig  := TO_NUMBER(JSON_VALUE(pcl_json, '$.assignedWorkerId'));
        v_id_usuario   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_titulo IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El título de la tarea operativa es obligatorio.');
        END IF;

        IF v_tipo_str = 'alimentacion' THEN
            v_id_tipo := 1;
        ELSIF v_tipo_str = 'medicacion' THEN
            v_id_tipo := 2;
        ELSIF v_tipo_str = 'fisioterapia' THEN
            v_id_tipo := 3;
        ELSIF v_tipo_str = 'higiene' THEN
            v_id_tipo := 4;
        ELSE
            v_id_tipo := 5;
        END IF;

        IF v_alcance_str = 'grupal' THEN
            v_id_alcance := 1;
        ELSE
            v_id_alcance := 2;
        END IF;

        IF v_estado_str = 'completada' THEN
            v_id_estado := 3;
        ELSIF v_estado_str = 'en_curso' THEN
            v_id_estado := 2;
        ELSE
            v_id_estado := 1;
        END IF;

        IF v_id_tarea IS NOT NULL AND PKGSMY_TAREAS_OPERATIVAS_DAO.f_existe(v_id_tarea, vro_tarea) = TRUE THEN
            vro_tarea.titulo                         := SUBSTR(v_titulo, 1, 150);
            vro_tarea.id_tipo_tarea                  := v_id_tipo;
            vro_tarea.id_alcance_tarea               := v_id_alcance;
            vro_tarea.id_estado_tarea                := v_id_estado;
            IF v_fecha_str IS NOT NULL AND LENGTH(TRIM(v_fecha_str)) >= 10 THEN
                vro_tarea.fecha_programada           := TO_DATE(SUBSTR(v_fecha_str, 1, 10), 'YYYY-MM-DD');
            END IF;
            vro_tarea.hora_programada                := NVL(SUBSTR(v_hora, 1, 8), vro_tarea.hora_programada);
            vro_tarea.id_residente                   := v_id_residente;
            vro_tarea.cantidad_residentes            := NVL(v_cant_res, vro_tarea.cantidad_residentes);
            vro_tarea.descripcion                    := SUBSTR(NVL(v_descripcion, v_titulo), 1, 500);
            vro_tarea.id_usuario_asignado            := v_id_usr_asig;
            vro_tarea.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_TAREAS_OPERATIVAS_DAO.p_actualizar(vro_tarea);
        ELSE
            vro_tarea.id                             := SEQ_SMY_TAREAS_OPERATIVAS.NEXTVAL;
            vro_tarea.titulo                         := SUBSTR(v_titulo, 1, 150);
            vro_tarea.id_tipo_tarea                  := v_id_tipo;
            vro_tarea.id_alcance_tarea               := v_id_alcance;
            vro_tarea.id_estado_tarea                := v_id_estado;
            IF v_fecha_str IS NOT NULL AND LENGTH(TRIM(v_fecha_str)) >= 10 THEN
                vro_tarea.fecha_programada           := TO_DATE(SUBSTR(v_fecha_str, 1, 10), 'YYYY-MM-DD');
            ELSE
                vro_tarea.fecha_programada           := TRUNC(f_fecha_actual);
            END IF;
            vro_tarea.hora_programada                := NVL(SUBSTR(v_hora, 1, 8), '08:00');
            vro_tarea.id_residente                   := v_id_residente;
            vro_tarea.cantidad_residentes            := NVL(v_cant_res, 1);
            vro_tarea.descripcion                    := SUBSTR(NVL(v_descripcion, v_titulo), 1, 500);
            vro_tarea.id_usuario_asignado            := v_id_usr_asig;
            vro_tarea.fecha_creacion                 := f_fecha_actual;
            vro_tarea.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_TAREAS_OPERATIVAS_DAO.p_insertar(vro_tarea);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_guardar_tarea_operativa');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_GUARDAR_TAREA_OPERATIVA';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_guardar_tarea_operativa;

    -- -------------------------------------------------------------------------
    -- 6. Cambiar estado de tarea operativa
    -- -------------------------------------------------------------------------
    PROCEDURE pr_cambiar_estado_tarea (
        pcl_json IN CLOB
    ) IS
        v_id_tarea   smy_tareas_operativas.id%TYPE;
        v_estado_str VARCHAR2(50);
        v_id_usuario NUMBER;
        vro_tarea    smy_tareas_operativas%ROWTYPE;
    BEGIN
        v_id_tarea   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idTarea'));
        v_estado_str := LOWER(TRIM(JSON_VALUE(pcl_json, '$.status')));
        v_id_usuario := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_id_tarea IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador de la tarea es obligatorio.');
        END IF;

        IF PKGSMY_TAREAS_OPERATIVAS_DAO.f_existe(v_id_tarea, vro_tarea) = TRUE THEN
            IF v_estado_str = 'completada' THEN
                vro_tarea.id_estado_tarea     := 3;
                vro_tarea.id_usuario_completo := v_id_usuario;
                vro_tarea.completado_el       := f_fecha_actual;
            ELSIF v_estado_str = 'en_curso' THEN
                vro_tarea.id_estado_tarea     := 2;
            ELSE
                vro_tarea.id_estado_tarea     := 1;
                vro_tarea.completado_el       := NULL;
            END IF;
            vro_tarea.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_TAREAS_OPERATIVAS_DAO.p_actualizar(vro_tarea);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_cambiar_estado_tarea');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_CAMBIAR_ESTADO_TAREA';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_cambiar_estado_tarea;

    -- -------------------------------------------------------------------------
    -- 7. Eliminar tarea operativa asistencial
    -- -------------------------------------------------------------------------
    PROCEDURE pr_eliminar_tarea_operativa (
        pcl_json IN CLOB
    ) IS
        v_id_tarea smy_tareas_operativas.id%TYPE;
        vro_tarea  smy_tareas_operativas%ROWTYPE;
    BEGIN
        v_id_tarea := TO_NUMBER(JSON_VALUE(pcl_json, '$.idTareaOperativa'));

        IF v_id_tarea IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador de la tarea operativa es obligatorio.');
        END IF;

        IF PKGSMY_TAREAS_OPERATIVAS_DAO.f_existe(v_id_tarea, vro_tarea) = TRUE THEN
            PKGCA_SMY_TAREA_RESIDENTES.p_eliminar_por_tarea(pcl_json);
            PKGSMY_TAREAS_OPERATIVAS_DAO.p_eliminar(v_id_tarea);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_eliminar_tarea_operativa');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_ELIMINAR_TAREA_OPERATIVA';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_eliminar_tarea_operativa;

    -- -------------------------------------------------------------------------
    -- 8. Crear solicitud de consentimiento informado
    -- -------------------------------------------------------------------------
    PROCEDURE pr_crear_consentimiento (
        pcl_json IN CLOB
    ) IS
        v_id_residente   NUMBER;
        v_tipo_str       VARCHAR2(100);
        v_id_tipo        NUMBER;
        v_descripcion    CLOB;
        v_id_usuario     NUMBER;
        v_dest_nombre    VARCHAR2(150);
        v_dest_email     VARCHAR2(150);
        vro_cons         smy_consentimientos%ROWTYPE;
        vro_dest         smy_consentimiento_destinatarios%ROWTYPE;
    BEGIN
        v_id_residente := TO_NUMBER(JSON_VALUE(pcl_json, '$.idResidente'));
        v_tipo_str     := TRIM(JSON_VALUE(pcl_json, '$.type'));
        v_descripcion  := JSON_VALUE(pcl_json, '$.description');
        v_id_usuario   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));
        v_dest_nombre  := JSON_VALUE(pcl_json, '$.recipientName');
        v_dest_email   := JSON_VALUE(pcl_json, '$.recipientEmail');

        IF v_id_residente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El residente es obligatorio para solicitar consentimiento.');
        END IF;

        IF v_tipo_str = 'Salida con familiar' THEN
            v_id_tipo := 2;
        ELSIF v_tipo_str = 'Procedimiento de enfermería' THEN
            v_id_tipo := 3;
        ELSIF v_tipo_str = 'Actividad especial' THEN
            v_id_tipo := 4;
        ELSIF v_tipo_str = 'Uso de imágenes' THEN
            v_id_tipo := 5;
        ELSIF v_tipo_str = 'Otro' THEN
            v_id_tipo := 6;
        ELSE
            v_id_tipo := 1;
        END IF;

        vro_cons.id                             := SEQ_SMY_CONSENTIMIENTOS.NEXTVAL;
        vro_cons.id_residente                   := v_id_residente;
        vro_cons.id_tipo_consentimiento         := v_id_tipo;
        vro_cons.descripcion                    := NVL(v_descripcion, 'Consentimiento informado asistencial');
        vro_cons.id_estado_consentimiento       := 1; -- pendiente
        vro_cons.fecha_envio                    := f_fecha_actual;
        vro_cons.id_usuario_creador             := v_id_usuario;
        vro_cons.fecha_creacion                 := f_fecha_actual;
        vro_cons.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_CONSENTIMIENTOS_DAO.p_insertar(vro_cons);

        vro_dest.id                             := SEQ_SMY_CONSENTIMIENTO_DESTINATARIOS.NEXTVAL;
        vro_dest.id_consentimiento              := vro_cons.id;
        vro_dest.nombre_destinatario            := NVL(v_dest_nombre, 'Acudiente Principal');
        vro_dest.email                          := NVL(v_dest_email, 'familiar@com.co');
        vro_dest.id_estado_firma_cons           := 1; -- enviado
        vro_dest.fecha_creacion                 := f_fecha_actual;
        vro_dest.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_CONSENTIMIENTO_DESTINATARIOS_DAO.p_insertar(vro_dest);

        p_do_commit('pkgln_operacion_movil.pr_crear_consentimiento');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_CREAR_CONSENTIMIENTO';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_crear_consentimiento;

    -- -------------------------------------------------------------------------
    -- 9. Responder (firmar o rechazar) consentimiento informado
    -- -------------------------------------------------------------------------
    PROCEDURE pr_responder_consentimiento (
        pcl_json IN CLOB
    ) IS
        v_id_cons      NUMBER;
        v_accion       VARCHAR2(30);
        v_motivo       VARCHAR2(500);
        v_firma_b64    CLOB;
        v_id_usuario   NUMBER;
        vro_cons       smy_consentimientos%ROWTYPE;
    BEGIN
        v_id_cons    := TO_NUMBER(JSON_VALUE(pcl_json, '$.idConsentimiento'));
        v_accion     := LOWER(TRIM(JSON_VALUE(pcl_json, '$.action')));
        v_motivo     := JSON_VALUE(pcl_json, '$.rejectReason');
        v_firma_b64  := JSON_VALUE(pcl_json, '$.signatureBase64');
        v_id_usuario := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_id_cons IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del consentimiento es obligatorio.');
        END IF;

        IF PKGSMY_CONSENTIMIENTOS_DAO.f_existe(v_id_cons, vro_cons) = TRUE THEN
            IF v_accion = 'rechazar' OR v_accion = 'rechazado' THEN
                vro_cons.id_estado_consentimiento := 3; -- rechazado
            ELSE
                vro_cons.id_estado_consentimiento := 2; -- aprobado
            END IF;
            vro_cons.fecha_respuesta                := f_fecha_actual;
            vro_cons.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_CONSENTIMIENTOS_DAO.p_actualizar(vro_cons);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_responder_consentimiento');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_RESPONDER_CONSENTIMIENTO';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_responder_consentimiento;

    -- -------------------------------------------------------------------------
    -- 10. Registrar entrega de insumo o gasto adicional de residente
    -- -------------------------------------------------------------------------
    PROCEDURE pr_registrar_suministro (
        pcl_json IN CLOB
    ) IS
        v_id_residente  NUMBER;
        v_tipo_str      VARCHAR2(50);
        v_id_tipo       NUMBER;
        v_descripcion   VARCHAR2(300);
        v_cantidad      VARCHAR2(100);
        v_costo         NUMBER;
        v_entregado_por VARCHAR2(150);
        v_reg_nom       VARCHAR2(150);
        v_reg_rol       VARCHAR2(50);
        v_notas         VARCHAR2(500);
        v_id_usuario    NUMBER;
        vro_sum         smy_suministros_registro%ROWTYPE;
    BEGIN
        v_id_residente  := TO_NUMBER(JSON_VALUE(pcl_json, '$.idResidente'));
        v_tipo_str      := LOWER(TRIM(JSON_VALUE(pcl_json, '$.type')));
        v_descripcion   := JSON_VALUE(pcl_json, '$.description');
        v_cantidad      := JSON_VALUE(pcl_json, '$.quantity');
        v_costo         := TO_NUMBER(JSON_VALUE(pcl_json, '$.cost'));
        v_entregado_por := JSON_VALUE(pcl_json, '$.deliveredBy');
        v_reg_nom       := JSON_VALUE(pcl_json, '$.recordedByName');
        v_reg_rol       := JSON_VALUE(pcl_json, '$.recordedByRole');
        v_notas         := JSON_VALUE(pcl_json, '$.notes');
        v_id_usuario    := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_id_residente IS NULL OR v_descripcion IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El residente y la descripción del insumo son obligatorios.');
        END IF;

        IF v_tipo_str = 'gasto_adicional' THEN
            v_id_tipo := 1;
        ELSE
            v_id_tipo := 2;
        END IF;

        vro_sum.id                             := SEQ_SMY_SUMINISTROS_REGISTRO.NEXTVAL;
        vro_sum.id_residente                   := v_id_residente;
        vro_sum.id_tipo_suministro             := v_id_tipo;
        vro_sum.descripcion                    := SUBSTR(v_descripcion, 1, 240);
        vro_sum.cantidad                       := SUBSTR(NVL(v_cantidad, '1 unidad'), 1, 80);
        vro_sum.fecha                          := TRUNC(f_fecha_actual);
        vro_sum.hora                           := TO_CHAR(f_fecha_actual, 'HH24:MI');
        vro_sum.costo                          := v_costo;
        vro_sum.id_estado_pago                 := CASE WHEN v_id_tipo = 1 THEN 1 ELSE NULL END;
        vro_sum.entregado_por                  := SUBSTR(v_entregado_por, 1, 140);
        vro_sum.id_usuario_registra            := v_id_usuario;
        vro_sum.registrado_por_nom             := SUBSTR(NVL(v_reg_nom, 'Personal Samanya'), 1, 140);
        vro_sum.registrado_por_rol             := SUBSTR(NVL(v_reg_rol, 'cuidador'), 1, 40);
        vro_sum.notas                          := SUBSTR(v_notas, 1, 450);
        vro_sum.fecha_creacion                 := f_fecha_actual;
        vro_sum.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_SUMINISTROS_REGISTRO_DAO.p_insertar(vro_sum);

        p_do_commit('pkgln_operacion_movil.pr_registrar_suministro');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_REGISTRAR_SUMINISTRO';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_registrar_suministro;

    -- -------------------------------------------------------------------------
    -- 11. Registrar pago de suministro / gasto adicional
    -- -------------------------------------------------------------------------
    PROCEDURE pr_pagar_suministro (
        pcl_json IN CLOB
    ) IS
        v_id_sum     NUMBER;
        v_pagado_por VARCHAR2(150);
        v_id_usuario NUMBER;
        vro_sum      smy_suministros_registro%ROWTYPE;
    BEGIN
        v_id_sum     := TO_NUMBER(JSON_VALUE(pcl_json, '$.idSuministro'));
        v_pagado_por := JSON_VALUE(pcl_json, '$.paidBy');
        v_id_usuario := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_id_sum IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del suministro es obligatorio.');
        END IF;

        IF PKGSMY_SUMINISTROS_REGISTRO_DAO.f_existe(v_id_sum, vro_sum) = TRUE THEN
            vro_sum.id_estado_pago                 := 2; -- pagado
            vro_sum.pagado_por                     := SUBSTR(NVL(v_pagado_por, 'Familiar Autorizado'), 1, 140);
            vro_sum.fecha_pago                     := f_fecha_actual;
            vro_sum.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_SUMINISTROS_REGISTRO_DAO.p_actualizar(vro_sum);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_pagar_suministro');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_PAGAR_SUMINISTRO';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_pagar_suministro;

    -- -------------------------------------------------------------------------
    -- 12. Registrar documento o nota en la historia clínica del residente
    -- -------------------------------------------------------------------------
    PROCEDURE pr_registrar_documento_clinico (
        pcl_json IN CLOB
    ) IS
        v_id_residente  NUMBER;
        v_titulo        VARCHAR2(200);
        v_cat_str       VARCHAR2(50);
        v_id_cat        NUMBER;
        v_descripcion   VARCHAR2(1000);
        v_entry_type    VARCHAR2(30);
        v_file_type     VARCHAR2(30);
        v_rol           VARCHAR2(50);
        v_nombre        VARCHAR2(150);
        v_id_usuario    NUMBER;
        vro_doc         smy_documentos_clinicos%ROWTYPE;
    BEGIN
        v_id_residente := TO_NUMBER(JSON_VALUE(pcl_json, '$.idResidente'));
        v_titulo       := TRIM(JSON_VALUE(pcl_json, '$.title'));
        v_cat_str      := LOWER(TRIM(JSON_VALUE(pcl_json, '$.category')));
        v_descripcion  := JSON_VALUE(pcl_json, '$.description');
        v_entry_type   := LOWER(TRIM(JSON_VALUE(pcl_json, '$.entryType')));
        v_file_type    := LOWER(TRIM(JSON_VALUE(pcl_json, '$.fileType')));
        v_rol          := JSON_VALUE(pcl_json, '$.uploadedByRole');
        v_nombre       := JSON_VALUE(pcl_json, '$.uploadedByName');
        v_id_usuario   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_id_residente IS NULL OR v_titulo IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El residente y el título del documento clínico son obligatorios.');
        END IF;

        IF v_cat_str = 'examen' THEN v_id_cat := 1;
        ELSIF v_cat_str = 'laboratorio' THEN v_id_cat := 2;
        ELSIF v_cat_str = 'receta' THEN v_id_cat := 3;
        ELSIF v_cat_str = 'nota_clinica' THEN v_id_cat := 4;
        ELSIF v_cat_str = 'consentimiento' THEN v_id_cat := 5;
        ELSIF v_cat_str = 'legal_personal' THEN v_id_cat := 6;
        ELSIF v_cat_str = 'administrativo' THEN v_id_cat := 7;
        ELSE v_id_cat := 8;
        END IF;

        vro_doc.id                             := SEQ_SMY_DOCUMENTOS_CLINICOS.NEXTVAL;
        vro_doc.id_residente                   := v_id_residente;
        vro_doc.titulo                         := SUBSTR(v_titulo, 1, 180);
        vro_doc.id_categoria_doc_clinico       := v_id_cat;
        vro_doc.descripcion                    := SUBSTR(v_descripcion, 1, 480);
        vro_doc.id_tipo_entrada_doc            := CASE WHEN v_entry_type = 'archivo' THEN 1 ELSE 2 END;
        vro_doc.id_tipo_archivo_doc            := CASE WHEN v_file_type = 'imagen' THEN 2 ELSE 1 END;
        vro_doc.subido_por_rol                 := SUBSTR(NVL(v_rol, 'cuidador'), 1, 30);
        vro_doc.subido_por_nombre              := SUBSTR(NVL(v_nombre, 'Personal Asistencial'), 1, 140);
        vro_doc.id_usuario                     := v_id_usuario;
        vro_doc.fecha_documento                := TRUNC(f_fecha_actual);
        vro_doc.id_estado_doc_clinico          := 1; -- ACTIVO
        vro_doc.fecha_creacion                 := f_fecha_actual;
        vro_doc.id_usuario_ultima_modificacion := v_id_usuario;

        PKGSMY_DOCUMENTOS_CLINICOS_DAO.p_insertar(vro_doc);

        p_do_commit('pkgln_operacion_movil.pr_registrar_documento_clinico');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_REGISTRAR_DOCUMENTO_CLINICO';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_registrar_documento_clinico;

    -- -------------------------------------------------------------------------
    -- 13. Eliminar documento clínico con trazabilidad en log de auditoría
    -- -------------------------------------------------------------------------
    PROCEDURE pr_eliminar_documento_clinico (
        pcl_json IN CLOB
    ) IS
        v_id_doc       NUMBER;
        v_id_usuario   NUMBER;
        v_elim_por_nom VARCHAR2(150);
        vro_doc        smy_documentos_clinicos%ROWTYPE;
        vro_log        smy_documentos_eliminados_log%ROWTYPE;
    BEGIN
        v_id_doc       := TO_NUMBER(JSON_VALUE(pcl_json, '$.idDocumento'));
        v_id_usuario   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));
        v_elim_por_nom := JSON_VALUE(pcl_json, '$.deletedByName');

        IF v_id_doc IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del documento clínico es obligatorio.');
        END IF;

        IF PKGSMY_DOCUMENTOS_CLINICOS_DAO.f_existe(v_id_doc, vro_doc) = TRUE THEN
            vro_doc.id_estado_doc_clinico          := 2; -- ELIMINADO
            vro_doc.id_usuario_ultima_modificacion := v_id_usuario;
            PKGSMY_DOCUMENTOS_CLINICOS_DAO.p_actualizar(vro_doc);

            vro_log.id                             := SEQ_SMY_DOC_ELIM_LOG.NEXTVAL;
            vro_log.id_documento_clinico           := vro_doc.id;
            vro_log.id_residente                   := vro_doc.id_residente;
            vro_log.titulo                         := vro_doc.titulo;
            vro_log.id_categoria_doc_clinico       := vro_doc.id_categoria_doc_clinico;
            vro_log.id_archivo                     := vro_doc.id_archivo_clinico;
            vro_log.subido_por_nombre              := vro_doc.subido_por_nombre;
            vro_log.id_usuario_elimino             := v_id_usuario;
            vro_log.eliminado_por_nom              := SUBSTR(NVL(v_elim_por_nom, 'Usuario Autorizado'), 1, 140);
            vro_log.motivo_eliminacion             := 'Eliminado desde aplicativo móvil';
            vro_log.fecha_eliminacion              := f_fecha_actual;
            vro_log.fecha_creacion                 := f_fecha_actual;
            vro_log.id_usuario_ultima_modificacion := v_id_usuario;

            PKGSMY_DOCUMENTOS_ELIMINADOS_LOG_DAO.p_insertar(vro_log);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_eliminar_documento_clinico');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_ELIMINAR_DOCUMENTO_CLINICO';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_eliminar_documento_clinico;

    -- -------------------------------------------------------------------------
    -- 14. Marcar notificación individual o todas como leídas
    -- -------------------------------------------------------------------------
    PROCEDURE pr_marcar_notificacion_leida (
        pcl_json IN CLOB
    ) IS
        v_id_notif   NUMBER;
        v_id_usuario NUMBER;
        vro_notif    smy_notificaciones_sistema%ROWTYPE;
    BEGIN
        v_id_notif   := TO_NUMBER(JSON_VALUE(pcl_json, '$.idNotificacion'));
        v_id_usuario := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        IF v_id_notif IS NOT NULL THEN
            IF PKGSMY_NOTIFICACIONES_SISTEMA_DAO.f_existe(v_id_notif, vro_notif) = TRUE THEN
                vro_notif.leido                          := 'S';
                vro_notif.fecha_leido                    := f_fecha_actual;
                vro_notif.id_usuario_ultima_modificacion := v_id_usuario;
                PKGSMY_NOTIFICACIONES_SISTEMA_DAO.p_actualizar(vro_notif);
            END IF;
        ELSE
            PKGCA_SMY_NOTIFICACIONES_SISTEMA.p_marcar_todas_leidas_usuario(pcl_json);
        END IF;

        p_do_commit('pkgln_operacion_movil.pr_marcar_notificacion_leida');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_OPERACION_MOVIL';
            vro_error.nombre_metodo   := 'PR_MARCAR_NOTIFICACION_LEIDA';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_marcar_notificacion_leida;

END PKGLN_OPERACION_MOVIL;
/
