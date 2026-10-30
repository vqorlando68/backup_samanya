CREATE OR REPLACE PACKAGE BODY PKGLN_TALENTO_HUMANO 
AS
    vro_error smy_errores%ROWTYPE;

    PROCEDURE pr_registrar_trabajador (
        pcl_json IN CLOB
    ) IS
        v_id_centro      smy_empleados.id_centro%TYPE;
        v_identificacion smy_empleados.identificacion%TYPE;
        v_nombres        smy_empleados.nombres%TYPE;
        v_apellidos      smy_empleados.apellidos%TYPE;
        v_fecha_cont_str VARCHAR2(30);

        vro_empleado     smy_empleados%ROWTYPE;
    BEGIN
        -- 1. Extracción con JSON_VALUE
        v_id_centro      := TO_NUMBER(JSON_VALUE(pcl_json, '$.idCentro'));
        v_identificacion := TRIM(JSON_VALUE(pcl_json, '$.identificacion'));
        v_nombres        := TRIM(JSON_VALUE(pcl_json, '$.nombres'));
        v_apellidos      := TRIM(JSON_VALUE(pcl_json, '$.apellidos'));
        v_fecha_cont_str := JSON_VALUE(pcl_json, '$.fechaContratacion');

        -- 2. Validaciones de negocio
        IF v_id_centro IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del centro médico es obligatorio.');
        END IF;
        IF v_nombres IS NULL OR v_apellidos IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nombres y apellidos del trabajador son obligatorios.');
        END IF;
        IF v_identificacion IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'El número de identificación del trabajador es obligatorio.');
        END IF;

        -- 3. Asignación directa de secuencia
        vro_empleado.id                     := SEQ_SMY_EMPLEADOS.NEXTVAL;
        vro_empleado.id_centro              := v_id_centro;
        vro_empleado.id_tipo_identificacion := NVL(TO_NUMBER(JSON_VALUE(pcl_json, '$.idTipoIdentificacion')), 1);
        vro_empleado.identificacion         := v_identificacion;
        vro_empleado.nombres                := v_nombres;
        vro_empleado.apellidos              := v_apellidos;
        vro_empleado.id_cargo_empleado      := NVL(TO_NUMBER(JSON_VALUE(pcl_json, '$.idCargoEmpleado')), 1);
        vro_empleado.id_area_empleado       := NVL(TO_NUMBER(JSON_VALUE(pcl_json, '$.idAreaEmpleado')), 1);
        vro_empleado.unidad_asignada        := TRIM(JSON_VALUE(pcl_json, '$.unidadAsignada'));
        vro_empleado.telefono               := TRIM(JSON_VALUE(pcl_json, '$.telefono'));
        vro_empleado.email_corp             := TRIM(JSON_VALUE(pcl_json, '$.emailCorp'));

        IF v_fecha_cont_str IS NOT NULL THEN
            vro_empleado.fecha_contratacion := TO_DATE(SUBSTR(v_fecha_cont_str, 1, 10), 'YYYY-MM-DD');
        ELSE
            vro_empleado.fecha_contratacion := f_fecha_actual;
        END IF;

        vro_empleado.id_estado_empleado     := NVL(TO_NUMBER(JSON_VALUE(pcl_json, '$.idEstadoEmpleado')), 1);
        vro_empleado.fecha_creacion         := f_fecha_actual;

        -- Inserción delegada al DAO
        PKGSMY_EMPLEADOS_DAO.p_insertar(vro_empleado);

        -- Commit controlado
        p_do_commit('pkgln_talento_humano.pr_registrar_trabajador');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_TALENTO_HUMANO';
            vro_error.nombre_metodo   := 'PR_REGISTRAR_TRABAJADOR';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_registrar_trabajador;

    PROCEDURE pr_actualizar_estado_trabajador (
        pcl_json IN CLOB
    ) IS
        v_id_trabajador   smy_empleados.id%TYPE;
        v_id_estado       smy_empleados.id_estado_empleado%TYPE;
        vro_empleado      smy_empleados%ROWTYPE;
    BEGIN
        v_id_trabajador := TO_NUMBER(JSON_VALUE(pcl_json, '$.idTrabajador'));
        v_id_estado     := TO_NUMBER(JSON_VALUE(pcl_json, '$.idEstadoEmpleado'));

        IF v_id_trabajador IS NULL OR v_id_estado IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Identificador de trabajador y nuevo estado son obligatorios.');
        END IF;

        IF PKGSMY_EMPLEADOS_DAO.f_existe(v_id_trabajador, vro_empleado) = FALSE THEN
            RAISE_APPLICATION_ERROR(-20005, 'El trabajador indicado no existe.');
        END IF;

        vro_empleado.id_estado_empleado := v_id_estado;
        IF v_id_estado = 3 THEN -- Inactivo
            vro_empleado.fecha_terminacion := f_fecha_actual;
        END IF;

        PKGSMY_EMPLEADOS_DAO.p_actualizar(vro_empleado);

        p_do_commit('pkgln_talento_humano.pr_actualizar_estado_trabajador');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_TALENTO_HUMANO';
            vro_error.nombre_metodo   := 'PR_ACTUALIZAR_ESTADO_TRABAJADOR';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_actualizar_estado_trabajador;

    PROCEDURE pr_actualizar_trabajador (
        pcl_json IN CLOB
    ) IS
        v_id_trabajador   smy_empleados.id%TYPE;
        vro_empleado      smy_empleados%ROWTYPE;
    BEGIN
        v_id_trabajador := TO_NUMBER(JSON_VALUE(pcl_json, '$.idTrabajador'));

        IF v_id_trabajador IS NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'El identificador del trabajador es obligatorio.');
        END IF;

        IF PKGSMY_EMPLEADOS_DAO.f_existe(v_id_trabajador, vro_empleado) = FALSE THEN
            RAISE_APPLICATION_ERROR(-20007, 'El trabajador indicado no existe.');
        END IF;

        IF JSON_VALUE(pcl_json, '$.nombres') IS NOT NULL THEN
            vro_empleado.nombres := TRIM(JSON_VALUE(pcl_json, '$.nombres'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.apellidos') IS NOT NULL THEN
            vro_empleado.apellidos := TRIM(JSON_VALUE(pcl_json, '$.apellidos'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.identificacion') IS NOT NULL THEN
            vro_empleado.identificacion := TRIM(JSON_VALUE(pcl_json, '$.identificacion'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.idTipoIdentificacion') IS NOT NULL THEN
            vro_empleado.id_tipo_identificacion := TO_NUMBER(JSON_VALUE(pcl_json, '$.idTipoIdentificacion'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.idCargoEmpleado') IS NOT NULL THEN
            vro_empleado.id_cargo_empleado := TO_NUMBER(JSON_VALUE(pcl_json, '$.idCargoEmpleado'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.idAreaEmpleado') IS NOT NULL THEN
            vro_empleado.id_area_empleado := TO_NUMBER(JSON_VALUE(pcl_json, '$.idAreaEmpleado'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.unidadAsignada') IS NOT NULL THEN
            vro_empleado.unidad_asignada := TRIM(JSON_VALUE(pcl_json, '$.unidadAsignada'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.telefono') IS NOT NULL THEN
            vro_empleado.telefono := TRIM(JSON_VALUE(pcl_json, '$.telefono'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.emailCorp') IS NOT NULL THEN
            vro_empleado.email_corp := TRIM(JSON_VALUE(pcl_json, '$.emailCorp'));
        END IF;
        IF JSON_VALUE(pcl_json, '$.idEstadoEmpleado') IS NOT NULL THEN
            vro_empleado.id_estado_empleado := TO_NUMBER(JSON_VALUE(pcl_json, '$.idEstadoEmpleado'));
            IF vro_empleado.id_estado_empleado = 3 THEN
                vro_empleado.fecha_terminacion := f_fecha_actual;
            END IF;
        END IF;

        PKGSMY_EMPLEADOS_DAO.p_actualizar(vro_empleado);

        p_do_commit('pkgln_talento_humano.pr_actualizar_trabajador');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_TALENTO_HUMANO';
            vro_error.nombre_metodo   := 'PR_ACTUALIZAR_TRABAJADOR';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_actualizar_trabajador;

END PKGLN_TALENTO_HUMANO;
/
