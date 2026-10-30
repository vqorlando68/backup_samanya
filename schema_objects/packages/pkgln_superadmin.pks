CREATE OR REPLACE PACKAGE PKGLN_SUPERADMIN 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_SUPERADMIN
    || Propósito: Orquestación de Lógica de Negocio para el Superusuario Principal.
    ||            Maneja entrada/salida 100% JSON en parámetros CLOB y delega
    ||            las consultas multi-tabla a PKGCN_SUPERADMIN y el acceso a datos
    ||            mono-tabla por PK a los paquetes DAO.
    || Estándar: oracle-plsql-architecture (Familia pkgln_)
    || =========================================================================
    */

    -- 1. Autenticación y validación de Superusuario (ID_TIPO_USUARIO = 1)
    PROCEDURE pr_login (
        p_json IN OUT NOCOPY CLOB
    );

    -- 2. Registrar auditoría de accesos
    PROCEDURE pr_registrar_auditoria (
        p_json IN OUT NOCOPY CLOB
    );

    -- 3. Organizaciones (Listar y Guardar/Actualizar)
    PROCEDURE pr_listar_organizaciones (
        p_json IN OUT NOCOPY CLOB
    );

    PROCEDURE pr_guardar_organizacion (
        p_json IN OUT NOCOPY CLOB
    );

    -- 4. Centros / Sedes (Listar y Guardar/Actualizar)
    PROCEDURE pr_listar_centros (
        p_json IN OUT NOCOPY CLOB
    );

    PROCEDURE pr_guardar_centro (
        p_json IN OUT NOCOPY CLOB
    );

    -- 5. Directorio de Usuarios (Listar y Guardar/Actualizar)
    PROCEDURE pr_listar_usuarios (
        p_json IN OUT NOCOPY CLOB
    );

    PROCEDURE pr_guardar_usuario (
        p_json IN OUT NOCOPY CLOB
    );

    -- 6. Parámetros Globales (Listar y Guardar/Actualizar)
    PROCEDURE pr_listar_parametros (
        p_json IN OUT NOCOPY CLOB
    );

    PROCEDURE pr_guardar_parametro (
        p_json IN OUT NOCOPY CLOB
    );

    -- 7. Editor de Tablas Maestras (Catálogos)
    PROCEDURE pr_listar_catalogo (
        p_json IN OUT NOCOPY CLOB
    );

    PROCEDURE pr_guardar_catalogo (
        p_json IN OUT NOCOPY CLOB
    );

    -- 8. Dashboard y Métricas Ejecutivas
    PROCEDURE pr_obtener_metricas_dashboard (
        p_json IN OUT NOCOPY CLOB
    );

END PKGLN_SUPERADMIN;
/
