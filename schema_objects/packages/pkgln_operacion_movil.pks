CREATE OR REPLACE PACKAGE PKGLN_OPERACION_MOVIL 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_OPERACION_MOVIL
    || Propósito: Orquestar los casos de uso móviles de Samanya Celular para
    ||            Cuidadores, Familiares/Acudientes y Administradores de Sede.
    || Estándar: oracle-plsql-architecture (Familia pkgln_)
    || =========================================================================
    */

    -- 1. Obtener estado consolidado móvil en formato JSON nativo
    FUNCTION f_obtener_estado_movil_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

    -- 2. Registrar entrada en la bitácora asistencial del residente
    PROCEDURE pr_registrar_bitacora (
        pcl_json IN CLOB
    );

    -- 3. Registrar toma de signos vitales del residente
    PROCEDURE pr_registrar_signos_vitales (
        pcl_json IN CLOB
    );

    -- 4. Registrar reporte de incidente o evento adverso
    PROCEDURE pr_registrar_incidente (
        pcl_json IN CLOB
    );

    -- 5. Crear o actualizar tarea operativa asistencial
    PROCEDURE pr_guardar_tarea_operativa (
        pcl_json IN CLOB
    );

    -- 6. Cambiar estado de tarea operativa (pendiente / en_curso / completada)
    PROCEDURE pr_cambiar_estado_tarea (
        pcl_json IN CLOB
    );

    -- 7. Eliminar tarea operativa asistencial
    PROCEDURE pr_eliminar_tarea_operativa (
        pcl_json IN CLOB
    );

    -- 8. Crear solicitud de consentimiento informado con destinatarios
    PROCEDURE pr_crear_consentimiento (
        pcl_json IN CLOB
    );

    -- 9. Responder (firmar o rechazar) consentimiento informado
    PROCEDURE pr_responder_consentimiento (
        pcl_json IN CLOB
    );

    -- 10. Registrar entrega de insumo o gasto adicional de residente
    PROCEDURE pr_registrar_suministro (
        pcl_json IN CLOB
    );

    -- 11. Registrar pago de suministro / gasto adicional
    PROCEDURE pr_pagar_suministro (
        pcl_json IN CLOB
    );

    -- 12. Registrar documento o nota en la historia clínica del residente
    PROCEDURE pr_registrar_documento_clinico (
        pcl_json IN CLOB
    );

    -- 13. Eliminar documento clínico con trazabilidad en log de auditoría
    PROCEDURE pr_eliminar_documento_clinico (
        pcl_json IN CLOB
    );

    -- 14. Marcar notificación individual o todas como leídas
    PROCEDURE pr_marcar_notificacion_leida (
        pcl_json IN CLOB
    );

END PKGLN_OPERACION_MOVIL;
/
