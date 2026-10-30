CREATE OR REPLACE PACKAGE PKGCN_CUADRANTES_TURNOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_CUADRANTES_TURNOS
    || Propósito: Sentencias SQL multi-tabla y generación de JSON CLOB para
    ||            el proceso de verificación de cobertura de turnos asistenciales.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_ por proceso)
    || Reglas:
    || 1. Parámetro de entrada exclusivamente en pcl_json IN CLOB.
    || 2. Nomenclatura SQL tradicional SIN cláusula JOIN (unión vía WHERE y (+)).
    || 3. Generación nativa de JSON en UNA SOLA sentencia SELECT con JSON_OBJECT.
    || 4. Sin lógica de negocio ni COMMIT / ROLLBACK.
    || Tablas físicas reales: SMY_PLANTILLAS_TURNO y SMY_TURNOS_ASIGNADOS
    || =========================================================================
    */

    /**
     * Retorna la validación de cobertura mínima para un turno en una fecha en JSON CLOB.
     * Ejecuta una ÚNICA sentencia SELECT multi-tabla sobre solamente JSON (RETURNING CLOB).
     * Parámetro pcl_json: { "idTurno": 301, "fecha": "2025-02-18" }
     */
    FUNCTION fn_validar_cobertura_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

END PKGCN_CUADRANTES_TURNOS;
/
