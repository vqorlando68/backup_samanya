CREATE OR REPLACE PACKAGE PKGCA_SMY_BITACORA_RESIDENTE 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_BITACORA_RESIDENTE
    || Propósito: Capa de consultas y filtros multi-criterio para la bitácora
    ||            asistencial y de novedades de los residentes.
    || Estándar: Sin ANSI JOIN, parámetros CLOB JSON con JSON_VALUE,
    ||           retorno multi-fila mediante SYS_REFCURSOR y JSON nativo.
    || =========================================================================
    */

    /**
     * Retorna cursor multi-fila con las anotaciones de bitácora de un residente ordenadas cronológicamente
     * Parámetro pcl_json:
     * {
     *   "idResidente": 1,
     *   "idCategoriaBitacora": 1,
     *   "fechaInicio": "2026-01-01",
     *   "fechaFin": "2026-12-31"
     * }
     */
    PROCEDURE p_consultar_por_residente (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Retorna documento JSON con las anotaciones de bitácora del residente
     * Parámetro pcl_json:
     * {
     *   "idResidente": 1
     * }
     */
    FUNCTION f_consultar_por_residente_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

END PKGCA_SMY_BITACORA_RESIDENTE;
/
