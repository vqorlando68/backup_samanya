CREATE OR REPLACE PACKAGE PKGSMY_MINUTAS_SEMANALES_DAO 
AS
    /*
    || =========================================================================
    || Paquete: PKGSMY_MINUTAS_SEMANALES_DAO
    || Propósito: Capa de acceso a datos exclusiva para la tabla SMY_MINUTAS_SEMANALES
    || Métodos: 18 operaciones estándar por ID y ROWID sin transaccionalidad.
    || =========================================================================
    */

    TYPE ta_smy_minutas_semanales IS TABLE OF smy_minutas_semanales%ROWTYPE INDEX BY BINARY_INTEGER;

    -- 1. Insertar registro
    PROCEDURE p_insertar (
        pro_smy_minutas_semanales IN smy_minutas_semanales%ROWTYPE
    );

    -- 2. Traer registro por PK
    FUNCTION f_traer (
        pty_id IN smy_minutas_semanales.id%TYPE
    ) RETURN smy_minutas_semanales%ROWTYPE;

    -- 3. Traer todos los registros
    PROCEDURE p_traer (
        pta_smy_minutas_semanales OUT PKGSMY_MINUTAS_SEMANALES_DAO.ta_smy_minutas_semanales
    );

    -- 4. Eliminar por registro
    PROCEDURE p_eliminar (
        pro_smy_minutas_semanales IN smy_minutas_semanales%ROWTYPE
    );

    -- 5. Eliminar por PK
    PROCEDURE p_eliminar (
        pty_id IN smy_minutas_semanales.id%TYPE
    );

    -- 6. Eliminar todos los registros
    PROCEDURE p_eliminar;

    -- 7. Verificar existencia por PK
    FUNCTION f_existe (
        pty_id IN smy_minutas_semanales.id%TYPE
    ) RETURN BOOLEAN;

    -- 8. Verificar existencia y retornar registro
    FUNCTION f_existe (
        pty_id       IN  smy_minutas_semanales.id%TYPE,
        pro_smy_minutas_semanales  OUT smy_minutas_semanales%ROWTYPE
    ) RETURN BOOLEAN;

    -- 9. Verificar existencia, retornar registro y ROWID
    FUNCTION f_existe (
        pty_id       IN  smy_minutas_semanales.id%TYPE,
        pro_smy_minutas_semanales  OUT smy_minutas_semanales%ROWTYPE,
        p_rowid      OUT VARCHAR2
    ) RETURN BOOLEAN;

    -- 10. Verificar existencia por ROWID
    FUNCTION f_existe_rowid (
        p_rowid IN VARCHAR2
    ) RETURN BOOLEAN;

    -- 11. Verificar existencia por ROWID y retornar registro
    FUNCTION f_existe_rowid (
        p_rowid      IN  VARCHAR2,
        pro_smy_minutas_semanales  OUT smy_minutas_semanales%ROWTYPE
    ) RETURN BOOLEAN;

    -- 12. Actualizar por registro
    PROCEDURE p_actualizar (
        pro_smy_minutas_semanales IN smy_minutas_semanales%ROWTYPE
    );

    -- 13. Actualizar indicando PK
    PROCEDURE p_actualizar (
        pro_smy_minutas_semanales IN smy_minutas_semanales%ROWTYPE,
        pty_id      IN smy_minutas_semanales.id%TYPE
    );

    -- 14. Actualizar por ROWID
    PROCEDURE p_actualizar_rowid (
        pro_smy_minutas_semanales IN smy_minutas_semanales%ROWTYPE,
        p_rowid     IN VARCHAR2
    );

    -- 15. Actualizar todos los registros
    PROCEDURE p_actualizar_registros (
        pro_smy_minutas_semanales IN smy_minutas_semanales%ROWTYPE
    );

    -- 16. Obtener valores por defecto
    PROCEDURE p_valores_defecto (
        pro_smy_minutas_semanales IN OUT smy_minutas_semanales%ROWTYPE
    );

    -- 17. Verificar existencia y retornar JSON
    FUNCTION f_existe_json (
        p_id            IN  smy_minutas_semanales.id%TYPE,
        p_json_smy_minutas_semanales  OUT CLOB
    ) RETURN NUMBER;

    -- 18. Obtener JSON por PK (Retorna CLOB nativo)
    FUNCTION f_json (
        p_id IN smy_minutas_semanales.id%TYPE
    ) RETURN CLOB;

END PKGSMY_MINUTAS_SEMANALES_DAO;
/
