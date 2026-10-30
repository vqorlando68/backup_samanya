CREATE OR REPLACE PACKAGE PKGCN_CONSENTIMIENTOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_CONSENTIMIENTOS
    || Propósito: Sentencias DML técnicas que involucran como mínimo dos tablas
    ||            dentro de una misma sentencia SQL en el dominio de consentimientos.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_)
    || Reglas:
    ||   1. Exactamente un método por cada sentencia DML.
    ||   2. La sentencia DML debe involucrar como mínimo dos tablas en su sintaxis SQL.
    ||   3. Sin lógica de negocio ni COMMIT/ROLLBACK.
    || =========================================================================
    */

    -- Sentencia DML única que involucra SMY_CONSENTIMIENTO_DESTINATARIOS y SMY_CONSENTIMIENTOS
    PROCEDURE pr_anular_destinatarios_por_consentimiento (
        p_id_consentimiento IN smy_consentimientos.id%TYPE,
        p_id_estado_anulado IN NUMBER,
        p_id_usuario        IN smy_usuarios.id%TYPE
    );

END PKGCN_CONSENTIMIENTOS;
/
