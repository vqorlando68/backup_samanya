CREATE OR REPLACE PACKAGE BODY PKGCA_SMY_RESIDENTE_ACUDIENTE 
AS

    PROCEDURE pr_eliminar_por_acudiente (
        pcl_json IN CLOB
    ) IS
        v_id_acudiente smy_residente_acudiente.id_acudiente%TYPE;
    BEGIN
        v_id_acudiente := TO_NUMBER(JSON_VALUE(pcl_json, '$.idAcudiente'));

        IF v_id_acudiente IS NOT NULL THEN
            DELETE FROM smy_residente_acudiente
             WHERE id_acudiente = v_id_acudiente;
        END IF;
    END pr_eliminar_por_acudiente;

END PKGCA_SMY_RESIDENTE_ACUDIENTE;
/
