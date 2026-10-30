CREATE OR REPLACE PACKAGE PKGCA_SMY_ACUDIENTES 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_ACUDIENTES
    || Propósito: Consultas multi-criterio y listados de familiares y acudientes.
    || Estándar: Familia pkgca_, parámetro pcl_json IN CLOB, extracción JSON_VALUE,
    ||           sintaxis tradicional Oracle (CERO ANSI JOIN).
    || =========================================================================
    */

    /**
     * Retorna cursor multi-fila con familiares y sus residentes asociados
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "filtroTexto": "Delgado"
     * }
     */
    PROCEDURE p_consultar_acudientes (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

END PKGCA_SMY_ACUDIENTES;
/
