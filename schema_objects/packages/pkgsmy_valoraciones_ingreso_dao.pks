CREATE OR REPLACE PACKAGE PKGSMY_VALORACIONES_INGRESO_DAO 
AS
    /*
    || =========================================================================
    || Paquete: PKGSMY_VALORACIONES_INGRESO_DAO
    || Propósito: Capa de acceso a datos exclusiva para la tabla SMY_VALORACIONES_INGRESO
    || Estándar: Plantilla oficial DAO PL/SQL Oracle (18 métodos sin commit/rollback)
    || =========================================================================
    */

    -- Tipo de colección estándar para registros de la tabla
    TYPE ta_smy_valoraciones_ingreso IS TABLE OF smy_valoraciones_ingreso%ROWTYPE INDEX BY BINARY_INTEGER;

    -- 1. Insertar registro
    PROCEDURE p_insertar (
        pro_smy_valing IN smy_valoraciones_ingreso%ROWTYPE
    );

    -- 2. Traer registro por PK
    FUNCTION f_traer (
        pty_id IN smy_valoraciones_ingreso.id%TYPE
    ) RETURN smy_valoraciones_ingreso%ROWTYPE;

    -- 3. Consultar todos los registros
    PROCEDURE p_consultar_registros (
        pta_smy_valing OUT PKGSMY_VALORACIONES_INGRESO_DAO.ta_smy_valoraciones_ingreso
    );

    -- 4. Eliminar por ROWID
    PROCEDURE p_eliminar_rowid (
        p_rowid IN VARCHAR2
    );

    -- 5. Eliminar por PK
    PROCEDURE p_eliminar (
        pty_id IN smy_valoraciones_ingreso.id%TYPE
    );

    -- 6. Eliminar todos los registros
    PROCEDURE p_eliminar_registros;

    -- 7. Verificar existencia por PK
    FUNCTION f_existe (
        pty_id IN smy_valoraciones_ingreso.id%TYPE
    ) RETURN BOOLEAN;

    -- 8. Verificar existencia y retornar registro
    FUNCTION f_existe (
        pty_id         IN  smy_valoraciones_ingreso.id%TYPE,
        pro_smy_valing OUT smy_valoraciones_ingreso%ROWTYPE
    ) RETURN BOOLEAN;

    -- 9. Verificar existencia, retornar registro y ROWID
    FUNCTION f_existe (
        pty_id         IN  smy_valoraciones_ingreso.id%TYPE,
        pro_smy_valing OUT smy_valoraciones_ingreso%ROWTYPE,
        p_rowid        OUT VARCHAR2
    ) RETURN BOOLEAN;

    -- 10. Verificar existencia por ROWID
    FUNCTION f_existe_rowid (
        p_rowid IN VARCHAR2
    ) RETURN BOOLEAN;

    -- 11. Verificar existencia por ROWID y retornar registro
    FUNCTION f_existe_rowid (
        p_rowid        IN  VARCHAR2,
        pro_smy_valing OUT smy_valoraciones_ingreso%ROWTYPE
    ) RETURN BOOLEAN;

    -- 12. Actualizar por registro
    PROCEDURE p_actualizar (
        pro_smy_valing IN smy_valoraciones_ingreso%ROWTYPE
    );

    -- 13. Actualizar indicando PK
    PROCEDURE p_actualizar (
        pro_smy_valing IN smy_valoraciones_ingreso%ROWTYPE,
        pty_id         IN smy_valoraciones_ingreso.id%TYPE
    );

    -- 14. Actualizar por ROWID
    PROCEDURE p_actualizar_rowid (
        pro_smy_valing IN smy_valoraciones_ingreso%ROWTYPE,
        p_rowid        IN VARCHAR2
    );

    -- 15. Actualizar todos los registros
    PROCEDURE p_actualizar_registros (
        pro_smy_valing IN smy_valoraciones_ingreso%ROWTYPE
    );

    -- 16. Obtener valores por defecto
    PROCEDURE p_valores_defecto (
        pro_smy_valing IN OUT smy_valoraciones_ingreso%ROWTYPE
    );

    -- 17. Verificar existencia y retornar JSON
    FUNCTION f_existe_json (
        p_id             IN  smy_valoraciones_ingreso.id%TYPE,
        p_json_smy_valing OUT CLOB
    ) RETURN NUMBER;

    -- 18. Obtener JSON por PK (Retorna CLOB nativo)
    FUNCTION f_json (
        p_id IN smy_valoraciones_ingreso.id%TYPE
    ) RETURN CLOB;

END PKGSMY_VALORACIONES_INGRESO_DAO;
/
