CREATE OR REPLACE PACKAGE PKGCA_SMY_DISPOSITIVOS_PUSH 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_DISPOSITIVOS_PUSH
    || Propósito: Búsquedas y consultas no-PK sobre SMY_DISPOSITIVOS_PUSH.
    || Estándar: oracle-plsql-architecture (Familia pkgca_)
    || =========================================================================
    */

    -- Busca un dispositivo por token único retornando el registro completo
    FUNCTION fn_buscar_por_token (
        p_token_dispositivo IN  smy_dispositivos_push.token_dispositivo%TYPE,
        pro_dispositivo     OUT smy_dispositivos_push%ROWTYPE
    ) RETURN BOOLEAN;

END PKGCA_SMY_DISPOSITIVOS_PUSH;
/
