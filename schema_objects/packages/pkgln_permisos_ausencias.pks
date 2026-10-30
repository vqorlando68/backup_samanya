CREATE OR REPLACE PACKAGE PKGLN_PERMISOS_AUSENCIAS 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_PERMISOS_AUSENCIAS
    || Propósito: Gestionar el flujo de aprobación o rechazo de solicitudes de
    ||            ausencias, vacaciones e incapacidades médicas del personal.
    || Estándar: Sin DML directos, parámetros CLOB JSON, uso exclusivo de DAOs
    ||           y p_do_commit para control transaccional.
    || =========================================================================
    */

    /**
     * Registra una nueva solicitud o novedad de permiso / incapacidad para talento humano.
     * Parámetro pcl_json:
     * {
     *   "idTrabajador": 204,
     *   "idTipoPermiso": 2, // 1 = Vacaciones, 2 = Incapacidad Médica, 3 = Permiso Personal, 5 = Licencia
     *   "fechaInicio": "2025-02-18",
     *   "fechaFin": "2025-02-21",
     *   "motivo": "Cuadro gripal certificado por EPS.",
     *   "urlSoporte": "incapacidad.pdf",
     *   "idEstadoPermiso": 1, // 1 = Pendiente, 2 = Aprobado
     *   "observacionesAdmin": "Aprobado por administración."
     * }
     */
    PROCEDURE pr_registrar_permiso (
        pcl_json IN CLOB
    );

    /**
     * Aprueba o rechaza una solicitud de permiso y actualiza el estado del colaborador
     * Parámetro pcl_json:
     * {
     *   "idSolicitud": 401,
     *   "idEstadoPermiso": 2, // 2 = Aprobado, 3 = Rechazado
     *   "comentariosAdmin": "Aprobada incapacidad médica por 3 días."
     * }
     */
    PROCEDURE pr_gestionar_solicitud_permiso (
        pcl_json IN CLOB
    );

END PKGLN_PERMISOS_AUSENCIAS;
/
