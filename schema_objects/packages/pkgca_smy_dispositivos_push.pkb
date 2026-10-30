CREATE OR REPLACE PACKAGE BODY PKGCA_SMY_DISPOSITIVOS_PUSH 
AS

    FUNCTION fn_buscar_por_token (
        p_token_dispositivo IN  smy_dispositivos_push.token_dispositivo%TYPE,
        pro_dispositivo     OUT smy_dispositivos_push%ROWTYPE
    ) RETURN BOOLEAN
    IS
    BEGIN
        SELECT *
          INTO pro_dispositivo
          FROM smy_dispositivos_push
         WHERE token_dispositivo = p_token_dispositivo
           AND ROWNUM = 1;

        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END fn_buscar_por_token;

END PKGCA_SMY_DISPOSITIVOS_PUSH;
/
