CREATE OR REPLACE PACKAGE PKGCN_AUTH 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_AUTH
    || Propósito: Sentencias DML técnicas que involucran como mínimo dos tablas
    ||            dentro de una misma sentencia SQL en el dominio de autenticación.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_)
    || Reglas:
    ||   1. Exactamente un método por cada sentencia DML.
    ||   2. La sentencia DML debe involucrar como mínimo dos tablas en su sintaxis SQL.
    ||   3. Sin lógica de negocio ni COMMIT/ROLLBACK.
    || =========================================================================
    */

    -- Sentencia DML única que involucra SMY_DISPOSITIVOS_PUSH y SMY_USUARIOS
    PROCEDURE pr_desactivar_tokens_usuarios_inactivos;

END PKGCN_AUTH;
/
