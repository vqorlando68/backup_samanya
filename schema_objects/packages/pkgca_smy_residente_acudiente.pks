CREATE OR REPLACE PACKAGE PKGCA_SMY_RESIDENTE_ACUDIENTE 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_RESIDENTE_ACUDIENTE
    || Propósito: Sentencias DML sobre la tabla SMY_RESIDENTE_ACUDIENTE cuando no es por ID
    || Estándar: Parámetro pcl_json IN CLOB, extracción vía JSON_VALUE
    || =========================================================================
    */

    /**
     * Elimina las relaciones de un acudiente con sus residentes asociados
     * Parámetro pcl_json:
     * {
     *   "idAcudiente": 102
     * }
     */
    PROCEDURE pr_eliminar_por_acudiente (
        pcl_json IN CLOB
    );

END PKGCA_SMY_RESIDENTE_ACUDIENTE;
/
