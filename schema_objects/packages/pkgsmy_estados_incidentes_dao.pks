CREATE OR REPLACE PACKAGE PKGSMY_ESTADOS_INCIDENTES_DAO 
AS
    /*
    || =========================================================================
    || Paquete: PKGSMY_ESTADOS_INCIDENTES_DAO
    || Propósito: Capa de acceso a datos exclusiva para la tabla SMY_ESTADOS_INCIDENTES
    || Estándar: Plantilla oficial DAO PL/SQL Oracle
    || =========================================================================
    */

    -- Tipo de colección estándar para registros de la tabla
    TYPE ta_smy_estados_incidentes IS TABLE OF smy_estados_incidentes%ROWTYPE INDEX BY BINARY_INTEGER;

    -- 1. Insertar registro
    PROCEDURE p_insertar (
        pro_smy_estados_incidentes IN smy_estados_incidentes%ROWTYPE
    );

    -- 2. Traer registro por PK
    FUNCTION f_traer (
        pty_id IN smy_estados_incidentes.id%TYPE
    ) RETURN smy_estados_incidentes%ROWTYPE;

    -- 3. Consultar todos los registros
    PROCEDURE p_consultar_registros (
        pta_smy_estados_incidentes OUT PKGSMY_ESTADOS_INCIDENTES_DAO.ta_smy_estados_incidentes
    );

    -- 4. Eliminar por ROWID
    PROCEDURE p_eliminar_rowid (
        p_rowid IN VARCHAR2
    );

    -- 5. Eliminar por PK
    PROCEDURE p_eliminar (
        pty_id IN smy_estados_incidentes.id%TYPE
    );

    -- 6. Eliminar todos los registros
    PROCEDURE p_eliminar_registros;

    -- 7. Verificar existencia por PK
    FUNCTION f_existe (
        pty_id IN smy_estados_incidentes.id%TYPE
    ) RETURN BOOLEAN;

    -- 8. Verificar existencia y retornar registro
    FUNCTION f_existe (
        pty_id       IN  smy_estados_incidentes.id%TYPE,
        pro_smy_estados_incidentes  OUT smy_estados_incidentes%ROWTYPE
    ) RETURN BOOLEAN;

    -- 9. Verificar existencia, retornar registro y ROWID
    FUNCTION f_existe (
        pty_id       IN  smy_estados_incidentes.id%TYPE,
        pro_smy_estados_incidentes  OUT smy_estados_incidentes%ROWTYPE,
        p_rowid      OUT VARCHAR2
    ) RETURN BOOLEAN;

    -- 10. Verificar existencia por ROWID
    FUNCTION f_existe_rowid (
        p_rowid IN VARCHAR2
    ) RETURN BOOLEAN;

    -- 11. Verificar existencia por ROWID y retornar registro
    FUNCTION f_existe_rowid (
        p_rowid      IN  VARCHAR2,
        pro_smy_estados_incidentes  OUT smy_estados_incidentes%ROWTYPE
    ) RETURN BOOLEAN;

    -- 12. Actualizar por registro
    PROCEDURE p_actualizar (
        pro_smy_estados_incidentes IN smy_estados_incidentes%ROWTYPE
    );

    -- 13. Actualizar indicando PK
    PROCEDURE p_actualizar (
        pro_smy_estados_incidentes IN smy_estados_incidentes%ROWTYPE,
        pty_id      IN smy_estados_incidentes.id%TYPE
    );

    -- 14. Actualizar por ROWID
    PROCEDURE p_actualizar_rowid (
        pro_smy_estados_incidentes IN smy_estados_incidentes%ROWTYPE,
        p_rowid     IN VARCHAR2
    );

    -- 15. Actualizar todos los registros
    PROCEDURE p_actualizar_registros (
        pro_smy_estados_incidentes IN smy_estados_incidentes%ROWTYPE
    );

    -- 16. Obtener valores por defecto
    PROCEDURE p_valores_defecto (
        pro_smy_estados_incidentes IN OUT smy_estados_incidentes%ROWTYPE
    );

    -- 17. Verificar existencia y retornar JSON
    FUNCTION f_existe_json (
        p_id            IN  smy_estados_incidentes.id%TYPE,
        p_json_smy_estados_incidentes  OUT CLOB
    ) RETURN NUMBER;

    -- 18. Obtener JSON por PK (Retorna CLOB nativo)
    FUNCTION f_json (
        p_id IN smy_estados_incidentes.id%TYPE
    ) RETURN CLOB;

END PKGSMY_ESTADOS_INCIDENTES_DAO;
/
