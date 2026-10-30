CREATE OR REPLACE PACKAGE BODY PKGCN_CONSENTIMIENTOS 
AS

    PROCEDURE pr_anular_destinatarios_por_consentimiento (
        p_id_consentimiento IN smy_consentimientos.id%TYPE,
        p_id_estado_anulado IN NUMBER,
        p_id_usuario        IN smy_usuarios.id%TYPE
    ) IS
    BEGIN
        -- Sentencia DML única que involucra como mínimo dos tablas: SMY_CONSENTIMIENTO_DESTINATARIOS y SMY_CONSENTIMIENTOS
        UPDATE smy_consentimiento_destinatarios d
           SET d.id_estado_firma_cons           = p_id_estado_anulado,
               d.id_usuario_ultima_modificacion = p_id_usuario,
               d.fecha_accion                   = f_fecha_actual
         WHERE EXISTS (
             SELECT 1
               FROM smy_consentimientos c
              WHERE c.id = d.id_consentimiento
                AND c.id = p_id_consentimiento
                AND c.id_estado_consentimiento = 3 -- Cancelado / Vencido
         );
        -- Sin COMMIT; el commit pertenece al orquestador pkgln_
    END pr_anular_destinatarios_por_consentimiento;

END PKGCN_CONSENTIMIENTOS;
/
