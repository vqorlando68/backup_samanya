CREATE OR REPLACE PACKAGE PKGSMY_CONSISTENCIAS_DIETA_DAO 
AS
    /*
    || =========================================================================
    || Paquete: PKGSMY_CONSISTENCIAS_DIETA_DAO
    || Propósito: Capa de acceso a datos exclusiva para la tabla SMY_CONSISTENCIAS_DIETA
    || Estándar: Plantilla oficial DAO PL/SQL Oracle
    || =========================================================================
    */

    -- Tipo de colección estándar para registros de la tabla
    TYPE ta_smy_consistencias_dieta IS TABLE OF smy_consistencias_dieta%ROWTYPE INDEX BY BINARY_INTEGER;

    -- 1. Insertar registro
    PROCEDURE p_insertar (
        pro_smy_consistencias_dieta IN smy_consistencias_dieta%ROWTYPE
    );

    -- 2. Traer registro por PK
    FUNCTION f_traer (
        pty_id IN smy_consistencias_dieta.id%TYPE
    ) RETURN smy_consistencias_dieta%ROWTYPE;

    -- 3. Consultar todos los registros
    PROCEDURE p_consultar_registros (
        pta_smy_consistencias_dieta OUT PKGSMY_CONSISTENCIAS_DIETA_DAO.ta_smy_consistencias_dieta
    );

    -- 4. Eliminar por ROWID
    PROCEDURE p_eliminar_rowid (
        p_rowid IN VARCHAR2
    );

    -- 5. Eliminar por PK
    PROCEDURE p_eliminar (
        pty_id IN smy_consistencias_dieta.id%TYPE
    );

    -- 6. Eliminar todos los registros
    PROCEDURE p_eliminar_registros;

    -- 7. Verificar existencia por PK
    FUNCTION f_existe (
        pty_id IN smy_consistencias_dieta.id%TYPE
    ) RETURN BOOLEAN;

    -- 8. Verificar existencia y retornar registro
    FUNCTION f_existe (
        pty_id       IN  smy_consistencias_dieta.id%TYPE,
        pro_smy_consistencias_dieta  OUT smy_consistencias_dieta%ROWTYPE
    ) RETURN BOOLEAN;

    -- 9. Verificar existencia, retornar registro y ROWID
    FUNCTION f_existe (
        pty_id       IN  smy_consistencias_dieta.id%TYPE,
        pro_smy_consistencias_dieta  OUT smy_consistencias_dieta%ROWTYPE,
        p_rowid      OUT VARCHAR2
    ) RETURN BOOLEAN;

    -- 10. Verificar existencia por ROWID
    FUNCTION f_existe_rowid (
        p_rowid IN VARCHAR2
    ) RETURN BOOLEAN;

    -- 11. Verificar existencia por ROWID y retornar registro
    FUNCTION f_existe_rowid (
        p_rowid      IN  VARCHAR2,
        pro_smy_consistencias_dieta  OUT smy_consistencias_dieta%ROWTYPE
    ) RETURN BOOLEAN;

    -- 12. Actualizar por registro
    PROCEDURE p_actualizar (
        pro_smy_consistencias_dieta IN smy_consistencias_dieta%ROWTYPE
    );

    -- 13. Actualizar indicando PK
    PROCEDURE p_actualizar (
        pro_smy_consistencias_dieta IN smy_consistencias_dieta%ROWTYPE,
        pty_id      IN smy_consistencias_dieta.id%TYPE
    );

    -- 14. Actualizar por ROWID
    PROCEDURE p_actualizar_rowid (
        pro_smy_consistencias_dieta IN smy_consistencias_dieta%ROWTYPE,
        p_rowid     IN VARCHAR2
    );

    -- 15. Actualizar todos los registros
    PROCEDURE p_actualizar_registros (
        pro_smy_consistencias_dieta IN smy_consistencias_dieta%ROWTYPE
    );

    -- 16. Obtener valores por defecto
    PROCEDURE p_valores_defecto (
        pro_smy_consistencias_dieta IN OUT smy_consistencias_dieta%ROWTYPE
    );

    -- 17. Verificar existencia y retornar JSON
    FUNCTION f_existe_json (
        p_id            IN  smy_consistencias_dieta.id%TYPE,
        p_json_smy_consistencias_dieta  OUT CLOB
    ) RETURN NUMBER;

    -- 18. Obtener JSON por PK (Retorna CLOB nativo)
    FUNCTION f_json (
        p_id IN smy_consistencias_dieta.id%TYPE
    ) RETURN CLOB;

END PKGSMY_CONSISTENCIAS_DIETA_DAO;
/
