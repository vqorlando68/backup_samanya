CREATE OR REPLACE PACKAGE PKGLN_TALENTO_HUMANO 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_TALENTO_HUMANO
    || Propósito: Gestionar la incorporación, contratación, áreas asistenciales
    ||            y cambios de estado del personal del centro médico.
    || Estándar: Sin DML directos, parámetros CLOB JSON, uso exclusivo de DAOs
    ||           y p_do_commit para control transaccional.
    || =========================================================================
    */

    /**
     * Registra un nuevo colaborador / trabajador en el centro médico
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "tipoIdentificacion": "CC",
     *   "identificacion": "1.020.789.456",
     *   "nombres": "Sandra Milena",
     *   "apellidos": "Torres Beltrán",
     *   "idCargoEmpleado": 2,
     *   "idAreaEmpleado": 1,
     *   "unidadAsignada": "Piso 1",
     *   "telefono": "3167890123",
     *   "emailCorp": "s.torres@samanyacare.com",
     *   "fechaContratacion": "2024-02-01",
     *   "idEstadoEmpleado": 1
     * }
     */
    PROCEDURE pr_registrar_trabajador (
        pcl_json IN CLOB
    );

    /**
     * Actualiza el estado operativo de un colaborador (Activo, En Permiso, Inactivo)
     * Parámetro pcl_json:
     * {
     *   "idTrabajador": 204,
     *   "idEstadoEmpleado": 3,
     *   "motivo": "Terminacion voluntaria de contrato"
     * }
     */
    PROCEDURE pr_actualizar_estado_trabajador (
        pcl_json IN CLOB
    );

    /**
     * Actualiza los datos laborales, personales y de contacto de un colaborador
     * Parámetro pcl_json:
     * {
     *   "idTrabajador": 204,
     *   "nombres": "Sandra Milena",
     *   "apellidos": "Torres Beltrán",
     *   "identificacion": "1.020.789.456",
     *   "idTipoIdentificacion": 1,
     *   "idCargoEmpleado": 2,
     *   "idAreaEmpleado": 1,
     *   "unidadAsignada": "Piso 2",
     *   "telefono": "3167890123",
     *   "emailCorp": "s.torres@samanyacare.com",
     *   "idEstadoEmpleado": 1
     * }
     */
    PROCEDURE pr_actualizar_trabajador (
        pcl_json IN CLOB
    );

END PKGLN_TALENTO_HUMANO;
/
