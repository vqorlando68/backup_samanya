CREATE OR REPLACE PACKAGE BODY PKGCA_SMY_TAREA_RESIDENTES 
AS

    PROCEDURE p_eliminar_por_tarea (
        pcl_json IN CLOB
    ) IS
        v_id_tarea smy_tarea_residentes.id_tarea_operativa%TYPE;
    BEGIN
        -- Extracción obligatoria mediante JSON_VALUE
        v_id_tarea := TO_NUMBER(JSON_VALUE(pcl_json, '$.idTareaOperativa'));

        -- Sentencia DML mono-tabla cuando NO es por el ID (PK)
        DELETE FROM smy_tarea_residentes
         WHERE id_tarea_operativa = v_id_tarea;
    END p_eliminar_por_tarea;

END PKGCA_SMY_TAREA_RESIDENTES;
/
