CREATE OR REPLACE PACKAGE PKGCN_ALIMENTACION 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_ALIMENTACION
    || Propósito: Procesos multi-tabla de alimentación y consultas JSON consolidadas.
    || Estándar: Familia pkgcn_, parámetro pcl_json IN CLOB, extracción JSON_VALUE,
    ||           sintaxis tradicional Oracle (CERO ANSI JOIN), JSON_OBJECT nativo.
    || =========================================================================
    */

    /**
     * DML multi-tabla: Precarga registros de ingesta para todos los residentes activos
     * de una sede que tengan plan nutricional activo y aún no tengan registro para la fecha/tiempo.
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idTiempoComida": 3,
     *   "fecha": "2026-10-04",
     *   "creadoPor": "SISTEMA"
     * }
     */
    PROCEDURE p_precargar_ingestas_dia (
        pcl_json IN CLOB
    );

    /**
     * Consulta multi-tabla que retorna el JSON consolidado de una minuta semanal con sus items
     * Parámetro pcl_json:
     * {
     *   "idMinuta": 1
     * }
     */
    FUNCTION f_minuta_completa_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

    /**
     * Consulta multi-tabla que retorna el resumen consolidado en JSON del comedor del día
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idTiempoComida": 3,
     *   "fecha": "2026-10-04"
     * }
     */
    FUNCTION f_resumen_comedor_dia_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

END PKGCN_ALIMENTACION;
/
