CREATE OR REPLACE PACKAGE PKGLN_CONSENTIMIENTOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_CONSENTIMIENTOS
    || Propósito: Lógica de negocio para la gestión de consentimientos informados,
    ||            validación de firmas digitales y trazabilidad de aprobaciones.
    || Estándar: oracle-plsql-architecture (Familia pkgln_)
    || =========================================================================
    */

    -- Firma digital de un consentimiento informado por parte de un acudiente
    PROCEDURE pr_firmar_consentimiento (
        p_id_consentimiento       IN  smy_consentimientos.id%TYPE,
        p_id_acudiente            IN  smy_acudientes.id%TYPE,
        p_ip_firma                IN  VARCHAR2,
        p_firma_canvas_base64     IN  CLOB,
        p_firma_hash              IN  VARCHAR2,
        p_id_usuario_accion       IN  smy_usuarios.id%TYPE,
        p_mensaje_resultado       OUT VARCHAR2
    );

END PKGLN_CONSENTIMIENTOS;
/
