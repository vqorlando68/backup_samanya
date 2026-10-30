CREATE OR REPLACE PACKAGE BODY PKGCN_AUTH 
AS

    PROCEDURE pr_desactivar_tokens_usuarios_inactivos IS
    BEGIN
        -- Sentencia DML única que involucra como mínimo dos tablas: SMY_DISPOSITIVOS_PUSH y SMY_USUARIOS
        UPDATE smy_dispositivos_push dp
           SET dp.activo = 'N'
         WHERE dp.activo = 'S'
           AND EXISTS (
               SELECT 1
                 FROM smy_usuarios u
                WHERE u.id = dp.id_usuario
                  AND u.id_estado_usuario != 1
           );
        -- Sin COMMIT; el commit pertenece al orquestador pkgln_
    END pr_desactivar_tokens_usuarios_inactivos;

END PKGCN_AUTH;
/
