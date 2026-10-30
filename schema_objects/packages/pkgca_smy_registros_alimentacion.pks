CREATE OR REPLACE PACKAGE PKGCA_SMY_REGISTROS_ALIMENTACION 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_REGISTROS_ALIMENTACION
    || Propósito: Consultas operativas de comedor e ingesta diaria de alimentos.
    || Estándar: Familia pkgca_, parámetro pcl_json IN CLOB, extracción JSON_VALUE,
    ||           sintaxis tradicional Oracle (CERO ANSI JOIN).
    || =========================================================================
    */

    /**
     * Consulta el pase de comedor del día para una sede y tiempo de comida
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "fecha": "2026-10-04",
     *   "idTiempoComida": 3
     * }
     */
    PROCEDURE p_consultar_comedor_dia (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * Consulta el historial de ingesta de un residente en un rango de fechas
     * Parámetro pcl_json:
     * {
     *   "idResidente": 1,
     *   "fechaDesde": "2026-09-01",
     *   "fechaHasta": "2026-10-04"
     * }
     */
    PROCEDURE p_consultar_historial_ingesta (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * DML mono-tabla: Actualiza la ingesta de un residente por fecha y tiempo de comida (no por PK)
     * Parámetro pcl_json:
     * {
     *   "idResidente": 1,
     *   "fecha": "2026-10-04",
     *   "idTiempoComida": 3,
     *   "porcentajeIngesta": 75,
     *   "liquidosMl": 200,
     *   "tolerancia": "Buena",
     *   "observaciones": "Consumió casi toda la proteína",
     *   "idEmpleadoRegistra": 2
     * }
     */
    PROCEDURE p_actualizar_ingesta_residente (
        pcl_json IN CLOB
    );

    /**
     * DML mono-tabla: Alias de actualización de ingesta
     */
    PROCEDURE p_actualizar_ingesta (
        pcl_json IN CLOB
    );

END PKGCA_SMY_REGISTROS_ALIMENTACION;
/
