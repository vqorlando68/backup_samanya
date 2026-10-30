CREATE OR REPLACE PACKAGE PKGCA_SMY_NOTIFICACIONES_SISTEMA 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_NOTIFICACIONES_SISTEMA
    || Propósito: Sentencia DML mono-tabla cuando NO es por el ID (PK) sobre
    ||            SMY_NOTIFICACIONES_SISTEMA (marcar notificaciones como leídas por usuario).
    || Estándar: oracle-plsql-architecture (Familia pkgca_)
    ||           - Un único método por sentencia DML mono-tabla no-PK.
    ||           - Parámetro pcl_json IN CLOB con extracción vía JSON_VALUE.
    || =========================================================================
    */

    /**
     * Marca todas las notificaciones pendientes de un usuario como leídas.
     * Parámetro pcl_json: { "idUsuario": 2 }
     */
    PROCEDURE p_marcar_todas_leidas_usuario (
        pcl_json IN CLOB
    );

END PKGCA_SMY_NOTIFICACIONES_SISTEMA;
/
