CREATE OR REPLACE PACKAGE PKGSMY_SIGNOS_VITALES_DAO 
AS
    /*
    || =========================================================================
    || Paquete: PKGSMY_SIGNOS_VITALES_DAO
    || Propósito: Capa de acceso a datos exclusiva para la tabla SMY_SIGNOS_VITALES
    || Estándar: Plantilla oficial DAO PL/SQL Oracle
    || =========================================================================
    */

    -- Tipo de colección estándar para registros de la tabla
    TYPE ta_smy_signos_vitales IS TABLE OF smy_signos_vitales%ROWTYPE INDEX BY BINARY_INTEGER;

    -- 1. Insertar registro
    PROCEDURE p_insertar (
        pro_smy_signos_vitales IN smy_signos_vitales%ROWTYPE
    );

    -- 2. Traer registro por PK
    FUNCTION f_traer (
        pty_id IN smy_signos_vitales.id%TYPE
    ) RETURN smy_signos_vitales%ROWTYPE;

    -- 3. Consultar todos los registros
    PROCEDURE p_consultar_registros (
        pta_smy_signos_vitales OUT PKGSMY_SIGNOS_VITALES_DAO.ta_smy_signos_vitales
    );

    -- 4. Eliminar por ROWID
    PROCEDURE p_eliminar_rowid (
        p_rowid IN VARCHAR2
    );

    -- 5. Eliminar por PK
    PROCEDURE p_eliminar (
        pty_id IN smy_signos_vitales.id%TYPE
    );

    -- 6. Eliminar todos los registros
    PROCEDURE p_eliminar_registros;

    -- 7. Verificar existencia por PK
    FUNCTION f_existe (
        pty_id IN smy_signos_vitales.id%TYPE
    ) RETURN BOOLEAN;

    -- 8. Verificar existencia y retornar registro
    FUNCTION f_existe (
        pty_id       IN  smy_signos_vitales.id%TYPE,
        pro_smy_signos_vitales  OUT smy_signos_vitales%ROWTYPE
    ) RETURN BOOLEAN;

    -- 9. Verificar existencia, retornar registro y ROWID
    FUNCTION f_existe (
        pty_id       IN  smy_signos_vitales.id%TYPE,
        pro_smy_signos_vitales  OUT smy_signos_vitales%ROWTYPE,
        p_rowid      OUT VARCHAR2
    ) RETURN BOOLEAN;

    -- 10. Verificar existencia por ROWID
    FUNCTION f_existe_rowid (
        p_rowid IN VARCHAR2
    ) RETURN BOOLEAN;

    -- 11. Verificar existencia por ROWID y retornar registro
    FUNCTION f_existe_rowid (
        p_rowid      IN  VARCHAR2,
        pro_smy_signos_vitales  OUT smy_signos_vitales%ROWTYPE
    ) RETURN BOOLEAN;

    -- 12. Actualizar por registro
    PROCEDURE p_actualizar (
        pro_smy_signos_vitales IN smy_signos_vitales%ROWTYPE
    );

    -- 13. Actualizar indicando PK
    PROCEDURE p_actualizar (
        pro_smy_signos_vitales IN smy_signos_vitales%ROWTYPE,
        pty_id      IN smy_signos_vitales.id%TYPE
    );

    -- 14. Actualizar por ROWID
    PROCEDURE p_actualizar_rowid (
        pro_smy_signos_vitales IN smy_signos_vitales%ROWTYPE,
        p_rowid     IN VARCHAR2
    );

    -- 15. Actualizar todos los registros
    PROCEDURE p_actualizar_registros (
        pro_smy_signos_vitales IN smy_signos_vitales%ROWTYPE
    );

    -- 16. Obtener valores por defecto
    PROCEDURE p_valores_defecto (
        pro_smy_signos_vitales IN OUT smy_signos_vitales%ROWTYPE
    );

    -- 17. Verificar existencia y retornar JSON
    FUNCTION f_existe_json (
        p_id            IN  smy_signos_vitales.id%TYPE,
        p_json_smy_signos_vitales  OUT CLOB
    ) RETURN NUMBER;

    -- 18. Obtener JSON por PK (Retorna CLOB nativo)
    FUNCTION f_json (
        p_id IN smy_signos_vitales.id%TYPE
    ) RETURN CLOB;

END PKGSMY_SIGNOS_VITALES_DAO;
/
