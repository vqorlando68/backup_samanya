CREATE OR REPLACE PACKAGE PKGCA_RESIDENTES 
AS
    /**
     * Retorna cursor multi-fila con censo de residentes activos filtrados por centro, estado o texto
     * Parámetro pcl_json: Documento JSON con filtros: { "idCentro": 1, "idEstado": 1, "filtroTexto": "Gomez" }
     */
    PROCEDURE p_consultar_censo (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Retorna detalle clínico y general de un residente en formato JSON nativo (CLOB)
     * Parámetro pcl_json: Documento JSON con el ID del residente: { "idResidente": 1 }
     */
    FUNCTION f_obtener_ficha_json (
        pcl_json    IN  CLOB
    ) RETURN CLOB;

END PKGCA_RESIDENTES;
/
