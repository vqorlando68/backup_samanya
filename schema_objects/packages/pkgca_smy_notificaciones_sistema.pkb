CREATE OR REPLACE PACKAGE BODY PKGCA_SMY_NOTIFICACIONES_SISTEMA 
AS

    PROCEDURE p_marcar_todas_leidas_usuario (
        pcl_json IN CLOB
    ) IS
        v_id_usuario smy_notificaciones_sistema.id_usuario_destino%TYPE;
    BEGIN
        -- Extracción obligatoria mediante JSON_VALUE
        v_id_usuario := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        -- Sentencia DML mono-tabla cuando NO es por el ID (PK)
        UPDATE smy_notificaciones_sistema
           SET leido                          = 'S',
               fecha_leido                    = f_fecha_actual,
               id_usuario_ultima_modificacion = v_id_usuario
         WHERE (v_id_usuario IS NULL OR id_usuario_destino = v_id_usuario)
           AND NVL(leido, 'N') <> 'S';
    END p_marcar_todas_leidas_usuario;

END PKGCA_SMY_NOTIFICACIONES_SISTEMA;
/
