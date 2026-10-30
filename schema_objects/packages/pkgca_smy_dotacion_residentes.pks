CREATE OR REPLACE PACKAGE PKGCA_SMY_DOTACION_RESIDENTES 
AS
    /**
     * Retorna cursor multi-fila con los elementos de dotación asignados a un residente
     * Parámetro pcl_json: { "idResidente": 1, "estadoElemento": "ENTREGADO" }
     */
    PROCEDURE p_consultar_por_residente (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Retorna cursor multi-fila con las alertas de recambio de dotación (vencidos o próximos a vencer)
     * Parámetro pcl_json: { "idCentro": 1, "diasAnticipacion": 30 }
     */
    PROCEDURE p_consultar_alertas_recambio (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Retorna cursor multi-fila con el historial de renovaciones/cambios de un elemento de dotación
     * Parámetro pcl_json: { "idDotacionResidente": 10 }
     */
    PROCEDURE p_consultar_historial (
        pcl_json    IN  CLOB,
        p_cursor    OUT SYS_REFCURSOR
    );

    /**
     * Sentencia DML mono-tabla no-PK: Actualiza el estado de toda la dotación de un residente
     * Parámetro pcl_json: { "idResidente": 1, "nuevoEstado": "RETIRADO", "idUsuario": 2 }
     */
    PROCEDURE p_actualizar_estado_por_residente (
        pcl_json    IN  CLOB
    );

END PKGCA_SMY_DOTACION_RESIDENTES;
/
