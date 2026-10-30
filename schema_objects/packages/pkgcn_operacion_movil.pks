CREATE OR REPLACE PACKAGE PKGCN_OPERACION_MOVIL 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_OPERACION_MOVIL
    || Propósito: Consolidar la proyección JSON multi-tabla para alimentar la
    ||            aplicación móvil Samanya Celular (Cuidadores, Familiares y Admin)
    ||            exclusivamente con datos reales de Oracle Autonomous Database.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_)
    ||           - CERO sintaxis ANSI JOIN (exclusivamente FROM t1, t2 WHERE y (+)).
    ||           - Parámetro pcl_json IN CLOB con extracción vía JSON_VALUE.
    ||           - Retorno JSON nativo con JSON_OBJECT / JSON_ARRAYAGG RETURNING CLOB.
    ||           - Fechas con f_fecha_actual (UTC-5 Bogotá).
    || =========================================================================
    */

    /**
     * Retorna en un único CLOB JSON todo el estado operativo del centro/usuario móvil.
     * Parámetro pcl_json: { "idCentro": 1, "idUsuario": 2 }
     */
    FUNCTION fn_obtener_estado_movil_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

END PKGCN_OPERACION_MOVIL;
/
