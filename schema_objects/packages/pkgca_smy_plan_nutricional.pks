CREATE OR REPLACE PACKAGE PKGCA_SMY_PLAN_NUTRICIONAL 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_PLAN_NUTRICIONAL
    || Propósito: Consultas avanzadas, filtros y operaciones no-PK sobre planes nutricionales.
    || Estándar: Familia pkgca_, parámetro pcl_json IN CLOB, extracción JSON_VALUE,
    ||           sintaxis tradicional Oracle (CERO ANSI JOIN).
    || =========================================================================
    */

    /**
     * Consulta el censo nutricional de residentes de una sede con sus dietas y consistencias
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idTipoDieta": 2,
     *   "idConsistencia": 1,
     *   "filtroTexto": "Delgado"
     * }
     */
    PROCEDURE p_consultar_censo_nutricional (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * Consulta el plan nutricional individual de un residente por su ID_RESIDENTE
     * Parámetro pcl_json:
     * {
     *   "idResidente": 10
     * }
     */
    PROCEDURE p_consultar_por_residente (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * DML mono-tabla: Actualiza o sincroniza el plan nutricional por ID_RESIDENTE (no por PK)
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idResidente": 10,
     *   "idTipoDieta": 2,
     *   "idConsistencia": 1,
     *   "idNivelEspesante": null,
     *   "requerimientoCaloricoKcal": 1800,
     *   "restriccionesAlergias": "Sin sal",
     *   "alimentosPreferidos": "Frutas",
     *   "alimentosRechazados": "Cebolla",
     *   "requiereAsistencia": "S",
     *   "suplementoNutricional": "Ensure",
     *   "observaciones": "Buena ingesta",
     *   "usuario": "NUTRICIONISTA"
     * }
     */
    PROCEDURE p_actualizar_por_residente (
        pcl_json IN CLOB
    );

    /**
     * Consulta planes nutricionales de una sede (alias operativo de censo)
     */
    PROCEDURE p_consultar_planes_centro (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * DML mono-tabla: Inactiva planes nutricionales anteriores de un residente (no por PK)
     */
    PROCEDURE p_inactivar_planes_anteriores (
        pcl_json IN CLOB
    );

END PKGCA_SMY_PLAN_NUTRICIONAL;
/
