CREATE OR REPLACE PACKAGE PKGCA_SMY_ARCHIVOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGCA_SMY_ARCHIVOS
    || Propósito: Consultas, filtros multi-criterio y representación JSON para SMY_ARCHIVOS.
    || Estándar: oracle-plsql-architecture (Familia pkgca_)
    || =========================================================================
    */

    -- Retorna cursor SYS_REFCURSOR con los archivos de un residente filtrando por estado visible
    FUNCTION fn_consultar_archivos_residente (
        p_id_residente  IN smy_residentes.id%TYPE,
        p_solo_visibles IN NUMBER DEFAULT 1
    ) RETURN SYS_REFCURSOR;

    -- Retorna la ficha completa del archivo en formato JSON nativo CLOB
    FUNCTION fn_obtener_archivo_json (
        p_id_archivo IN smy_archivos.id%TYPE
    ) RETURN CLOB;

    -- Busca el ID de un archivo a partir del nombre_archivo_almacenado para evitar colisiones UQ
    FUNCTION fn_obtener_id_por_almacenado (
        pcl_json IN CLOB
    ) RETURN NUMBER;

END PKGCA_SMY_ARCHIVOS;
/
