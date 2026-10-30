CREATE OR REPLACE PACKAGE BODY PKGLN_DASHBOARD_ADMINISTRADOR 
AS
    vro_error smy_errores%ROWTYPE;

    FUNCTION f_obtener_resumen_json (
        pcl_json IN CLOB
    ) RETURN CLOB
    IS
        v_id_centro   smy_centros.id%TYPE;
        vro_centro    smy_centros%ROWTYPE;
        vcl_resultado CLOB;
    BEGIN
        -- 1. Extracción obligatoria de parámetros con JSON_VALUE
        v_id_centro := TO_NUMBER(JSON_VALUE(pcl_json, '$.idCentro'));

        IF v_id_centro IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del centro médico es obligatorio.');
        END IF;

        -- 2. Validar existencia del centro a través del DAO (Sin SELECT directo)
        IF PKGSMY_CENTROS_DAO.f_existe(v_id_centro, vro_centro) = FALSE THEN
            RAISE_APPLICATION_ERROR(-20002, 'El centro médico especificado no existe.');
        END IF;

        -- 3. Delegación de la consulta multi-tabla y JSON a la capa pkgcn_ (CERO SELECT directo en pkgln_)
        vcl_resultado := PKGCN_DASHBOARD_ADMINISTRADOR.fn_obtener_resumen_json(pcl_json);

        RETURN vcl_resultado;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_DASHBOARD_ADMINISTRADOR';
            vro_error.nombre_metodo   := 'F_OBTENER_RESUMEN_JSON';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END f_obtener_resumen_json;

    PROCEDURE pr_consultar_alertas_prioritarias (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    ) IS
        v_id_centro smy_centros.id%TYPE;
    BEGIN
        v_id_centro := TO_NUMBER(JSON_VALUE(pcl_json, '$.idCentro'));

        IF v_id_centro IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El identificador del centro médico es obligatorio.');
        END IF;

        -- Delegación obligatoria a la capa pkgcn_ para cursores multi-tabla (CERO SELECT directo en pkgln_)
        PKGCN_DASHBOARD_ADMINISTRADOR.pr_consultar_alertas_prioritarias(pcl_json, p_cursor);

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20999 AND -20001 THEN
                RAISE;
            END IF;
            vro_error.nombre_programa := 'PKGLN_DASHBOARD_ADMINISTRADOR';
            vro_error.nombre_metodo   := 'PR_CONSULTAR_ALERTAS_PRIORITARIAS';
            vro_error.parametros      := pcl_json;
            uti_ge_excepciones_pkg.p_grabar_log(vro_error);
            RAISE_APPLICATION_ERROR(-20000, 'Se presento un error comunicarse con soporte. Número error: ' || vro_error.id || ' - ' || SQLERRM);
    END pr_consultar_alertas_prioritarias;

END PKGLN_DASHBOARD_ADMINISTRADOR;
/
