CREATE OR REPLACE PACKAGE PKGLN_DASHBOARD_ADMINISTRADOR 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_DASHBOARD_ADMINISTRADOR
    || Propósito: Orquestar la consolidación de KPIs gerenciales, ocupación de camas,
    ||            cobertura de turnos activos y alertas clínicas para el administrador.
    || REGLA ESTRICTA ARQUITECTÓNICA:
    || - CERO sentencias SELECT directas sobre tablas (se delegan en pkgcn_ / DAOs).
    || - CERO sentencias DML directas (INSERT, UPDATE, DELETE).
    || - Consultas multi-tabla y generación de JSON CLOB delegadas en PKGCN_DASHBOARD_ADMINISTRADOR.
    || - Parámetros de entrada exclusivamente en pcl_json IN CLOB (extracción con JSON_VALUE).
    || - Manejo de excepciones centralizado con uti_ge_excepciones_pkg y ROLLBACK.
    || =========================================================================
    */

    /**
     * Retorna el resumen consolidado del dashboard en formato JSON nativo
     * Parámetro pcl_json: { "idCentro": 1 }
     */
    FUNCTION f_obtener_resumen_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

    /**
     * Retorna cursor con las alertas operativas prioritarias del turno activo
     * Parámetro pcl_json: { "idCentro": 1 }
     */
    PROCEDURE pr_consultar_alertas_prioritarias (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

END PKGLN_DASHBOARD_ADMINISTRADOR;
/
