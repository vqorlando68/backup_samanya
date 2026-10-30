CREATE OR REPLACE PACKAGE PKGCA_SMY_EMPLEADOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_EMPLEADOS
    || Propósito: Consultas multi-criterio y filtros del personal de talento humano.
    || Estándar: Familia pkgca_, parámetro pcl_json IN CLOB, extracción JSON_VALUE,
    ||           sintaxis tradicional Oracle (CERO ANSI JOIN).
    || =========================================================================
    */

    /**
     * Retorna cursor multi-fila con colaboradores filtrados por centro, estado o búsqueda textual
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idEstado": 1,
     *   "filtroTexto": "Rodriguez"
     * }
     */
    PROCEDURE p_consultar_empleados (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

END PKGCA_SMY_EMPLEADOS;
/
