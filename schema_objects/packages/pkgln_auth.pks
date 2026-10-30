CREATE OR REPLACE PACKAGE PKGLN_AUTH 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_AUTH
    || Propósito: Lógica de negocio de autenticación, control de accesos y gestión
    ||            de tokens de dispositivos móviles push.
    || Estándar: oracle-plsql-architecture (Familia pkgln_)
    || =========================================================================
    */

    -- Autenticación y orquestación del proceso de acceso
    PROCEDURE pr_autenticar (
        p_usuario_o_email   IN VARCHAR2,
        p_direccion_ip      IN VARCHAR2,
        p_dispositivo_info  IN VARCHAR2,
        p_cursor_usuario    OUT SYS_REFCURSOR
    );

    -- Registro de acceso exitoso actualizando usuario e insertando auditoría vía DAOs con COMMIT
    PROCEDURE pr_registrar_acceso_exitoso (
        p_id_usuario        IN smy_usuarios.id%TYPE,
        p_direccion_ip      IN VARCHAR2,
        p_dispositivo_info  IN VARCHAR2
    );

    -- Registro y actualización de token push para dispositivos móviles
    PROCEDURE pr_registrar_dispositivo_push (
        p_id_usuario        IN smy_usuarios.id%TYPE,
        p_token_dispositivo IN smy_dispositivos_push.token_dispositivo%TYPE,
        p_plataforma        IN smy_dispositivos_push.plataforma%TYPE
    );

    -- Desactivación de token push al cerrar sesión
    PROCEDURE pr_desactivar_dispositivo_push (
        p_id_usuario        IN smy_usuarios.id%TYPE,
        p_token_dispositivo IN smy_dispositivos_push.token_dispositivo%TYPE
    );

    -- Actualización de información de perfil del usuario
    PROCEDURE pr_actualizar_perfil (
        pcl_json IN CLOB
    );

    -- Cambio seguro de contraseña de usuario
    PROCEDURE pr_cambiar_clave (
        pcl_json IN CLOB
    );

END PKGLN_AUTH;
/
