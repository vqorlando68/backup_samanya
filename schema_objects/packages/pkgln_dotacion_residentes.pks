CREATE OR REPLACE PACKAGE PKGLN_DOTACION_RESIDENTES 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_DOTACION_RESIDENTES
    || Propósito: Gestionar el flujo de negocio para entrega de dotación en el
    ||            momento del ingreso del residente (usando catálogo sugerido,
    ||            con opción de excluir o aumentar artículos), control de
    ||            fechas de cambio/reposición con cálculo automático, y registro
    ||            de historial de renovaciones periódicas.
    || Estándar: Sin sentencias DML directas, interacción vía DAOs por PK,
    ||           consultas vía pkgca_, commit controlado vía p_do_commit.
    || =========================================================================
    */

    /**
     * Consulta el catálogo de dotación disponible para configuración o selección
     */
    PROCEDURE pr_consultar_catalogo (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * Crea o actualiza un elemento del catálogo maestro de dotación
     */
    PROCEDURE pr_guardar_articulo_catalogo (
        pcl_json IN CLOB
    );

    /**
     * Consulta la dotación asignada a un residente específico con su semáforo de cambio
     */
    PROCEDURE pr_consultar_dotacion_residente (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    /**
     * Registra la entrega inicial o paquete de dotación al ingresar el residente
     */
    PROCEDURE pr_registrar_entrega_ingreso (
        pcl_json IN CLOB
    );

    /**
     * Agrega un artículo adicional o personalizado a la dotación de un residente
     */
    PROCEDURE pr_agregar_articulo_residente (
        pcl_json IN CLOB
    );

    /**
     * Registra el recambio o renovación periódica de un artículo de dotación
     */
    PROCEDURE pr_registrar_recambio (
        pcl_json IN CLOB
    );

    /**
     * Registra una solicitud de dotación para un residente (estado inicial SOLICITADO)
     */
    PROCEDURE pr_solicitar_dotacion_residente (
        pcl_json IN CLOB
    );

    /**
     * Registra la entrega efectiva de una dotación previamente solicitada
     */
    PROCEDURE pr_entregar_dotacion_solicitada (
        pcl_json IN CLOB
    );

END PKGLN_DOTACION_RESIDENTES;
/
