CREATE OR REPLACE PACKAGE PKGCN_SUPERADMIN 
AS
    /*
    || =========================================================================
    || Paquete: PKGCN_SUPERADMIN
    || Propósito: Sentencias SQL multi-tabla y generación de JSON CLOB
    ||            para el módulo de Superusuario Principal de Samanya OS.
    ||            Sintaxis SQL tradicional sin JOIN.
    || Estándar: oracle-plsql-architecture (Familia pkgcn_)
    || =========================================================================
    */

    -- 1. Obtener datos de usuario para login en JSON CLOB
    FUNCTION fn_obtener_usuario_login_json (
        p_json IN CLOB
    ) RETURN CLOB;

    -- 2. Listar organizaciones con conteo de sedes en JSON CLOB
    FUNCTION fn_listar_organizaciones_json (
        p_json IN CLOB DEFAULT NULL
    ) RETURN CLOB;

    -- 3. Listar centros/sedes en JSON CLOB
    FUNCTION fn_listar_centros_json (
        p_json IN CLOB DEFAULT NULL
    ) RETURN CLOB;

    -- 4. Listar usuarios con roles y tipos en JSON CLOB
    FUNCTION fn_listar_usuarios_json (
        p_json IN CLOB DEFAULT NULL
    ) RETURN CLOB;

    -- 5. Listar parámetros globales filtrados en JSON CLOB
    FUNCTION fn_listar_parametros_json (
        p_json IN CLOB DEFAULT NULL
    ) RETURN CLOB;

    -- 6. Listar catálogo de tablas maestras dinámico en JSON CLOB
    FUNCTION fn_listar_catalogo_json (
        p_json IN CLOB
    ) RETURN CLOB;

    -- 7. Métricas del Dashboard y registros de auditoría en JSON CLOB
    FUNCTION fn_obtener_metricas_dashboard_json (
        p_json IN CLOB DEFAULT NULL
    ) RETURN CLOB;

END PKGCN_SUPERADMIN;
/
