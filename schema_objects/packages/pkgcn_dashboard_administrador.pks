CREATE OR REPLACE PACKAGE PKGCN_DASHBOARD_ADMINISTRADOR 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_DASHBOARD_ADMINISTRADOR
    || Propósito: Sentencias SQL multi-tabla y generación de JSON CLOB / cursores
    ||            para el proceso de Dashboard del Administrador de Centro Médico.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_ por proceso multi-tabla)
    || Reglas:
    || 1. Parámetro de entrada exclusivamente en formato pcl_json IN CLOB.
    || 2. Nomenclatura SQL tradicional SIN cláusula JOIN (unión vía WHERE y (+)).
    || 3. Generación nativa de JSON en UNA SOLA sentencia SELECT con JSON_OBJECT RETURNING CLOB.
    || 4. Sin lógica de negocio ni COMMIT / ROLLBACK.
    || =========================================================================
    */

    /**
     * Retorna el resumen consolidado del dashboard en formato JSON nativo (CLOB)
     * Ejecuta una ÚNICA sentencia SELECT multi-tabla proyectando el documento JSON.
     * Parámetro pcl_json: { "idCentro": 1 }
     */
    FUNCTION fn_obtener_resumen_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

    /**
     * Retorna cursor multi-tabla con las alertas operativas prioritarias del turno activo
     * Parámetro pcl_json: { "idCentro": 1 }
     */
    PROCEDURE pr_consultar_alertas_prioritarias (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

END PKGCN_DASHBOARD_ADMINISTRADOR;
/
