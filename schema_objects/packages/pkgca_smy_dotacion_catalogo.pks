CREATE OR REPLACE PACKAGE PKGCA_SMY_DOTACION_CATALOGO 
AS
    /**
     * Retorna cursor multi-fila con los elementos del catálogo general de dotación
     * Parámetro pcl_json: Documento JSON con filtros opcionales:
     * { "idOrganizacion": 1, "categoria": "Lencería", "estado": "ACTIVO", "esSugeridoIngreso": 1 }
     */
    PROCEDURE p_consultar_catalogo (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Retorna el catálogo sugerido para ingreso en formato JSON nativo (CLOB)
     * Parámetro pcl_json: { "idOrganizacion": 1 }
     */
    FUNCTION f_obtener_catalogo_json (
        pcl_json    IN  CLOB
    ) RETURN CLOB;

END PKGCA_SMY_DOTACION_CATALOGO;
/
