CREATE OR REPLACE PACKAGE PKGLN_CUADRANTES_TURNOS 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_CUADRANTES_TURNOS
    || Propósito: Gestionar la planificación de turnos de personal asistencial,
    ||            asignación de empleados por fecha y verificación de reglas de
    ||            cobertura mínima de cuidadores y enfermería.
    || REGLA ESTRICTA ARQUITECTÓNICA:
    || - CERO sentencias SELECT directas sobre tablas (se delegan en pkgca_ / DAOs).
    || - CERO sentencias DML directas (INSERT, UPDATE, DELETE).
    || - Control transaccional mediante p_do_commit al éxito y ROLLBACK al fallo.
    || =========================================================================
    */

    /**
     * Asigna un trabajador a una franja de turno en una fecha determinada
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idTrabajador": 202,
     *   "idTurno": 301,
     *   "fechaTurno": "2025-02-18",
     *   "observaciones": "Asignacion de guardia matutina"
     * }
     */
    PROCEDURE pr_asignar_turno_trabajador (
        pcl_json IN CLOB
    );

    /**
     * Retorna la validación de cobertura mínima para un turno en una fecha delegando en pkgca_
     * Parámetro pcl_json: { "idTurno": 301, "fecha": "2025-02-18" }
     */
    FUNCTION f_validar_cobertura_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

    /**
     * Programa turnos por rango de fechas para uno o varios colaboradores activos
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "idTurno": 301,
     *   "fechaInicio": "2026-09-24",
     *   "fechaFin": "2026-09-30",
     *   "colaboradores": [201, 202, 203],
     *   "observaciones": "Ronda programada"
     * }
     */
    PROCEDURE pr_programar_turnos_rango (
        pcl_json IN CLOB
    );

END PKGLN_CUADRANTES_TURNOS;
/
