CREATE OR REPLACE PACKAGE PKGCA_SMY_CONSENTIMIENTOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_CONSENTIMIENTOS
    || Propósito: Búsquedas, consultas no-PK y resolución de catálogos para consentimientos.
    || Estándar: oracle-plsql-architecture (Familia pkgca_)
    || =========================================================================
    */

    -- Retorna el ID del estado de consentimiento correspondiente a "Aprobado" o "Firmado"
    FUNCTION fn_obtener_id_estado_aprobado RETURN NUMBER;

    -- Retorna el ID del estado de firma de destinatario correspondiente a "Firmado" o "Aprobado"
    FUNCTION fn_obtener_id_estado_firmado_dest RETURN NUMBER;

    -- Busca el ID del registro destinatario por consentimiento y acudiente
    FUNCTION fn_buscar_id_destinatario (
        p_id_consentimiento IN smy_consentimientos.id%TYPE,
        p_id_acudiente      IN smy_acudientes.id%TYPE DEFAULT NULL
    ) RETURN smy_consentimiento_destinatarios.id%TYPE;

END PKGCA_SMY_CONSENTIMIENTOS;
/
