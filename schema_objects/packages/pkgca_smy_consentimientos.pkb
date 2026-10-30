CREATE OR REPLACE PACKAGE BODY PKGCA_SMY_CONSENTIMIENTOS 
AS

    FUNCTION fn_obtener_id_estado_aprobado RETURN NUMBER
    IS
        vn_id NUMBER;
    BEGIN
        SELECT id
          INTO vn_id
          FROM smy_estados_consentimientos
         WHERE (UPPER(nombre_estado_consentimiento) LIKE '%APROBADO%'
             OR UPPER(nombre_estado_consentimiento) LIKE '%FIRMADO%')
           AND ROWNUM = 1;

        RETURN vn_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END fn_obtener_id_estado_aprobado;

    FUNCTION fn_obtener_id_estado_firmado_dest RETURN NUMBER
    IS
        vn_id NUMBER;
    BEGIN
        SELECT id
          INTO vn_id
          FROM smy_estados_firmas_cons
         WHERE (UPPER(nombre_estado_firma_cons) LIKE '%FIRMADO%'
             OR UPPER(nombre_estado_firma_cons) LIKE '%APROBADO%')
           AND ROWNUM = 1;

        RETURN vn_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END fn_obtener_id_estado_firmado_dest;

    FUNCTION fn_buscar_id_destinatario (
        p_id_consentimiento IN smy_consentimientos.id%TYPE,
        p_id_acudiente      IN smy_acudientes.id%TYPE DEFAULT NULL
    ) RETURN smy_consentimiento_destinatarios.id%TYPE
    IS
        v_id smy_consentimiento_destinatarios.id%TYPE;
    BEGIN
        SELECT id
          INTO v_id
          FROM smy_consentimiento_destinatarios
         WHERE id_consentimiento = p_id_consentimiento
           AND (p_id_acudiente IS NULL OR id_acudiente = p_id_acudiente)
           AND ROWNUM = 1;

        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END fn_buscar_id_destinatario;

END PKGCA_SMY_CONSENTIMIENTOS;
/
