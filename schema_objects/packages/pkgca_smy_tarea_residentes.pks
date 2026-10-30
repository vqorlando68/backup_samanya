CREATE OR REPLACE PACKAGE PKGCA_SMY_TAREA_RESIDENTES 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_TAREA_RESIDENTES
    || Propósito: Operaciones DML mono-tabla cuando NO es por el ID (PK) y
    ||            consultas filtradas sobre la tabla SMY_TAREA_RESIDENTES.
    || Estándar: oracle-plsql-architecture (Familia pkgca_)
    ||           - Un único método por sentencia DML mono-tabla no-PK.
    ||           - Parámetro pcl_json IN CLOB con extracción vía JSON_VALUE.
    || =========================================================================
    */

    /**
     * Elimina las asociaciones de residentes para una tarea operativa específica.
     * Parámetro pcl_json: { "idTareaOperativa": 10 }
     */
    PROCEDURE p_eliminar_por_tarea (
        pcl_json IN CLOB
    );

END PKGCA_SMY_TAREA_RESIDENTES;
/
