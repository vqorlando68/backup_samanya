CREATE OR REPLACE PACKAGE PKGCN_ARCHIVOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_ARCHIVOS
    || Propósito: Sentencias DML técnicas que involucran como mínimo dos tablas
    ||            dentro de una misma sentencia SQL en el dominio de archivos.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_)
    || Reglas:
    ||   1. Exactamente un método por cada sentencia DML.
    ||   2. La sentencia DML debe involucrar como mínimo dos tablas en su sintaxis SQL.
    ||   3. Sin lógica de negocio ni COMMIT/ROLLBACK.
    || =========================================================================
    */

    -- Sentencia DML única que involucra SMY_ARCHIVOS y SMY_DOCUMENTOS_CLINICOS
    PROCEDURE pr_desvincular_archivos_doc (
        p_id_documento_clinico IN smy_documentos_clinicos.id%TYPE,
        p_id_usuario           IN smy_usuarios.id%TYPE
    );

END PKGCN_ARCHIVOS;
/
