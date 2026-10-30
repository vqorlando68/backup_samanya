CREATE OR REPLACE PACKAGE PKGSMY_SOLICITUD_ADM_CONTACTOS_DAO 
AS
    /*
    || =========================================================================
    || Paquete: PKGSMY_SOLICITUD_ADM_CONTACTOS_DAO
    || Propósito: Capa de acceso a datos exclusiva para la tabla SMY_SOLICITUD_ADM_CONTACTOS
    || Estándar: Plantilla oficial DAO PL/SQL Oracle
    || =========================================================================
    */

    -- Tipo de colección estándar para registros de la tabla
    TYPE ta_smy_solicitud_adm_contactos IS TABLE OF smy_solicitud_adm_contactos%ROWTYPE INDEX BY BINARY_INTEGER;

    -- 1. Insertar registro
    PROCEDURE p_insertar (
        pro_smy_solicitud_adm_contactos IN smy_solicitud_adm_contactos%ROWTYPE
    );

    -- 2. Traer registro por PK
    FUNCTION f_traer (
        pty_id IN smy_solicitud_adm_contactos.id%TYPE
    ) RETURN smy_solicitud_adm_contactos%ROWTYPE;

    -- 3. Consultar todos los registros
    PROCEDURE p_consultar_registros (
        pta_smy_solicitud_adm_contactos OUT PKGSMY_SOLICITUD_ADM_CONTACTOS_DAO.ta_smy_solicitud_adm_contactos
    );

    -- 4. Eliminar por ROWID
    PROCEDURE p_eliminar_rowid (
        p_rowid IN VARCHAR2
    );

    -- 5. Eliminar por PK
    PROCEDURE p_eliminar (
        pty_id IN smy_solicitud_adm_contactos.id%TYPE
    );

    -- 6. Eliminar todos los registros
    PROCEDURE p_eliminar_registros;

    -- 7. Verificar existencia por PK
    FUNCTION f_existe (
        pty_id IN smy_solicitud_adm_contactos.id%TYPE
    ) RETURN BOOLEAN;

    -- 8. Verificar existencia y retornar registro
    FUNCTION f_existe (
        pty_id       IN  smy_solicitud_adm_contactos.id%TYPE,
        pro_smy_solicitud_adm_contactos  OUT smy_solicitud_adm_contactos%ROWTYPE
    ) RETURN BOOLEAN;

    -- 9. Verificar existencia, retornar registro y ROWID
    FUNCTION f_existe (
        pty_id       IN  smy_solicitud_adm_contactos.id%TYPE,
        pro_smy_solicitud_adm_contactos  OUT smy_solicitud_adm_contactos%ROWTYPE,
        p_rowid      OUT VARCHAR2
    ) RETURN BOOLEAN;

    -- 10. Verificar existencia por ROWID
    FUNCTION f_existe_rowid (
        p_rowid IN VARCHAR2
    ) RETURN BOOLEAN;

    -- 11. Verificar existencia por ROWID y retornar registro
    FUNCTION f_existe_rowid (
        p_rowid      IN  VARCHAR2,
        pro_smy_solicitud_adm_contactos  OUT smy_solicitud_adm_contactos%ROWTYPE
    ) RETURN BOOLEAN;

    -- 12. Actualizar por registro
    PROCEDURE p_actualizar (
        pro_smy_solicitud_adm_contactos IN smy_solicitud_adm_contactos%ROWTYPE
    );

    -- 13. Actualizar indicando PK
    PROCEDURE p_actualizar (
        pro_smy_solicitud_adm_contactos IN smy_solicitud_adm_contactos%ROWTYPE,
        pty_id      IN smy_solicitud_adm_contactos.id%TYPE
    );

    -- 14. Actualizar por ROWID
    PROCEDURE p_actualizar_rowid (
        pro_smy_solicitud_adm_contactos IN smy_solicitud_adm_contactos%ROWTYPE,
        p_rowid     IN VARCHAR2
    );

    -- 15. Actualizar todos los registros
    PROCEDURE p_actualizar_registros (
        pro_smy_solicitud_adm_contactos IN smy_solicitud_adm_contactos%ROWTYPE
    );

    -- 16. Obtener valores por defecto
    PROCEDURE p_valores_defecto (
        pro_smy_solicitud_adm_contactos IN OUT smy_solicitud_adm_contactos%ROWTYPE
    );

    -- 17. Verificar existencia y retornar JSON
    FUNCTION f_existe_json (
        p_id            IN  smy_solicitud_adm_contactos.id%TYPE,
        p_json_smy_solicitud_adm_contactos  OUT CLOB
    ) RETURN NUMBER;

    -- 18. Obtener JSON por PK (Retorna CLOB nativo)
    FUNCTION f_json (
        p_id IN smy_solicitud_adm_contactos.id%TYPE
    ) RETURN CLOB;

END PKGSMY_SOLICITUD_ADM_CONTACTOS_DAO;
/
