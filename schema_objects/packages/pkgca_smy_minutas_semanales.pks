CREATE OR REPLACE PACKAGE PKGCA_SMY_MINUTAS_SEMANALES 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_MINUTAS_SEMANALES
    || Propósito: Consultas operativas de minutas de alimentación y menús semanales.
    || Estándar: Familia pkgca_, parámetro pcl_json IN CLOB, extracción JSON_VALUE,
    ||           sintaxis tradicional Oracle (CERO ANSI JOIN).
    || =========================================================================
    */

    /**
     * Consulta minutas semanales de un centro por estado o rango de fechas
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "estado": "ACTIVO",
     *   "fecha": "2026-10-04"
     * }
     */
    PROCEDURE p_consultar_minutas_centro (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * Consulta los ítems de una minuta semanal específica organizados por día y tiempo de comida
     * Parámetro pcl_json:
     * {
     *   "idMinuta": 1,
     *   "diaSemana": 1
     * }
     */
    PROCEDURE p_consultar_items_minuta (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * DML mono-tabla: Desactiva minutas anteriores de una sede cuando se activa una nueva (no por PK)
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "actualizadoPor": "ADMIN"
     * }
     */
    PROCEDURE p_desactivar_minutas_anteriores (
        pcl_json IN CLOB
    );

END PKGCA_SMY_MINUTAS_SEMANALES;
/
