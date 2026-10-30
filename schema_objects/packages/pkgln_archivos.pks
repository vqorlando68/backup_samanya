CREATE OR REPLACE PACKAGE PKGLN_ARCHIVOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_ARCHIVOS
    || Propósito: Lógica de negocio integral para la gestión y administración de
    ||            archivos y documentos del sistema SAMANYA (Google Drive / Storage).
    || Estándar: oracle-plsql-architecture (Familia pkgln_)
    || =========================================================================
    */

    -- -------------------------------------------------------------------------
    -- 1. Utilidades de cálculo, formateo y hashing
    -- -------------------------------------------------------------------------
    FUNCTION fn_generar_nombre_almacenado (
        p_id        IN NUMBER,
        p_extension IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_sanitizar_cadena (
        p_cadena IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_normalizar_extension (
        p_nombre_o_ext IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_construir_ruta_sede (
        p_id_sede     IN NUMBER,
        p_nombre_sede IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_construir_ruta_residente (
        p_id_residente   IN NUMBER,
        p_identificacion IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_construir_ruta_documentos (
        p_id_sede        IN NUMBER,
        p_nombre_sede    IN VARCHAR2,
        p_id_residente   IN NUMBER,
        p_identificacion IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_construir_ruta_talento_humano (
        p_id_usuario     IN NUMBER,
        p_identificacion IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_resolver_mime_type (
        p_extension IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_validar_extension (
        p_extension         IN VARCHAR2,
        p_lista_permitidas  IN VARCHAR2 DEFAULT 'pdf,jpg,jpeg,png,docx,xlsx,txt'
    ) RETURN BOOLEAN;

    -- -------------------------------------------------------------------------
    -- 2. Lógica de negocio y orquestación transaccional (con COMMIT)
    -- -------------------------------------------------------------------------
    PROCEDURE pr_preparar_carga_archivo (
        p_id_centro                  IN  smy_centros.id%TYPE,
        p_id_residente               IN  smy_residentes.id%TYPE,
        p_nombre_original            IN  VARCHAR2,
        p_id_clase_archivo           IN  smy_clases_archivos.id%TYPE,
        p_id_reserva                 OUT smy_archivos.id%TYPE,
        p_nombre_almacenado          OUT VARCHAR2,
        p_nombre_carpeta_sede        OUT VARCHAR2,
        p_nombre_carpeta_residente   OUT VARCHAR2,
        p_ruta_relativa              OUT VARCHAR2,
        p_extension                  OUT VARCHAR2,
        p_tipo_mime                  OUT VARCHAR2
    );

    PROCEDURE pr_registrar_archivo (
        p_id                         IN  smy_archivos.id%TYPE,
        p_nombre_archivo             IN  smy_archivos.nombre_archivo%TYPE,
        p_nombre_archivo_almacenado  IN  smy_archivos.nombre_archivo_almacenado%TYPE,
        p_hash_archivo               IN  smy_archivos.hash_archivo%TYPE,
        p_ruta_relativa              IN  smy_archivos.ruta_relativa%TYPE,
        p_ruta_completa_almacenamiento IN smy_archivos.ruta_completa_almacenamiento%TYPE,
        p_extension                  IN  smy_archivos.extension%TYPE,
        p_tipo_mime                  IN  smy_archivos.tipo_mime%TYPE,
        p_tamano_bytes               IN  smy_archivos.tamano_bytes%TYPE,
        p_id_clase_archivo           IN  smy_archivos.id_clase_archivo%TYPE,
        p_id_centro                  IN  smy_archivos.id_centro%TYPE,
        p_id_residente               IN  smy_archivos.id_residente%TYPE,
        p_tabla_origen               IN  smy_archivos.tabla_origen%TYPE DEFAULT NULL,
        p_id_registro_origen         IN  smy_archivos.id_registro_origen%TYPE DEFAULT NULL,
        p_metadatos_json             IN  CLOB DEFAULT NULL,
        p_id_usuario_creacion        IN  smy_usuarios.id%TYPE,
        p_mensaje_resultado          OUT VARCHAR2
    );

    PROCEDURE pr_borrar_archivo (
        p_id_archivo        IN  smy_archivos.id%TYPE,
        p_id_usuario        IN  smy_usuarios.id%TYPE,
        p_motivo            IN  VARCHAR2 DEFAULT NULL,
        p_mensaje_resultado OUT VARCHAR2
    );

    PROCEDURE pr_renombrar_archivo (
        p_id_archivo        IN  smy_archivos.id%TYPE,
        p_nuevo_nombre      IN  smy_archivos.nombre_archivo%TYPE,
        p_id_usuario        IN  smy_usuarios.id%TYPE,
        p_mensaje_resultado OUT VARCHAR2
    );

    PROCEDURE pr_copiar_archivo (
        p_id_archivo_origen  IN  smy_archivos.id%TYPE,
        p_nuevo_id_residente IN  smy_residentes.id%TYPE DEFAULT NULL,
        p_nuevo_id_centro    IN  smy_centros.id%TYPE DEFAULT NULL,
        p_nuevo_nombre       IN  smy_archivos.nombre_archivo%TYPE DEFAULT NULL,
        p_id_usuario         IN  smy_usuarios.id%TYPE,
        p_id_nuevo_archivo   OUT smy_archivos.id%TYPE,
        p_mensaje_resultado  OUT VARCHAR2
    );

    PROCEDURE pr_restaurar_archivo (
        p_id_archivo        IN  smy_archivos.id%TYPE,
        p_id_usuario        IN  smy_usuarios.id%TYPE,
        p_mensaje_resultado OUT VARCHAR2
    );

    PROCEDURE pr_preparar_carga_foto_talento (
        pcl_json      IN  CLOB,
        p_json_salida OUT CLOB
    );

    PROCEDURE pr_registrar_foto_talento_humano (
        pcl_json IN CLOB
    );

    PROCEDURE pr_registrar_soporte_talento_humano (
        pcl_json IN CLOB
    );

    PROCEDURE pr_subir_foto_talento_humano (
        pcl_json IN CLOB
    );

    -- -------------------------------------------------------------------------
    -- 3. Consultas y representación de datos
    -- -------------------------------------------------------------------------
    FUNCTION fn_consultar_archivos_residente (
        p_id_residente  IN smy_residentes.id%TYPE,
        p_solo_visibles IN NUMBER DEFAULT 1
    ) RETURN SYS_REFCURSOR;

    FUNCTION fn_obtener_archivo_json (
        p_id_archivo IN smy_archivos.id%TYPE
    ) RETURN CLOB;

    -- -------------------------------------------------------------------------
    -- 4. Procesos multi-entidad de documentos clínicos (vía DAOs con COMMIT)
    -- -------------------------------------------------------------------------
    PROCEDURE pr_vincular_archivo_doc_clinico (
        pro_archivo            IN  smy_archivos%ROWTYPE,
        p_id_documento_clinico IN  smy_documentos_clinicos.id%TYPE,
        p_id_usuario           IN  smy_usuarios.id%TYPE
    );

    PROCEDURE pr_desvincular_archivo_doc_clinico (
        p_id_archivo           IN  smy_archivos.id%TYPE,
        p_id_documento_clinico IN  smy_documentos_clinicos.id%TYPE,
        p_id_usuario           IN  smy_usuarios.id%TYPE
    );

END PKGLN_ARCHIVOS;
/
