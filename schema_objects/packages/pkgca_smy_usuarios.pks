CREATE OR REPLACE PACKAGE PKGCA_SMY_USUARIOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_USUARIOS
    || Propósito: Consultas, filtros y búsquedas no-PK sobre la entidad SMY_USUARIOS.
    || Estándar: oracle-plsql-architecture (Familia pkgca_)
    || =========================================================================
    */

    -- Busca el ID de un usuario por username o correo electrónico normalizado
    FUNCTION fn_buscar_por_username_email (
        p_usuario_o_email IN VARCHAR2
    ) RETURN smy_usuarios.id%TYPE;

    -- Retorna el cursor multi-tabla para la sesión de usuario autenticado
    PROCEDURE pr_cursor_login (
        p_id_usuario     IN  smy_usuarios.id%TYPE,
        p_cursor_usuario OUT SYS_REFCURSOR
    );

END PKGCA_SMY_USUARIOS;
/
