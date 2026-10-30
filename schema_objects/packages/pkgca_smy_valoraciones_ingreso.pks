CREATE OR REPLACE PACKAGE PKGCA_SMY_VALORACIONES_INGRESO 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_VALORACIONES_INGRESO
    || Propósito: Capa de consultas, filtros y lectura de fichas de valoración
    ||            integral de ingreso por residente y sede.
    || Estándar: Sin ANSI JOIN (sintaxis tradicional Oracle FROM t1, t2 WHERE),
    ||           parámetros CLOB JSON con JSON_VALUE, retorno SYS_REFCURSOR y JSON nativo.
    || =========================================================================
    */

    /**
     * Retorna cursor con las valoraciones de ingreso de un residente o sede
     * Parámetro pcl_json:
     * {
     *   "idResidente": 1,
     *   "idCentro": 1
     * }
     */
    PROCEDURE p_consultar_por_residente (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Retorna el documento JSON completo de la última valoración de ingreso del residente
     * Parámetro pcl_json:
     * {
     *   "idResidente": 1
     * }
     */
    FUNCTION f_traer_ultima_ficha_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

END PKGCA_SMY_VALORACIONES_INGRESO;
/
