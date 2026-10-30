CREATE OR REPLACE PACKAGE PKGLN_GESTION_FAMILIARES 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_GESTION_FAMILIARES
    || Propósito: Gestionar el ciclo de vida de los acudientes y familiares de
    ||            los residentes, administración de canales de notificación
    ||            y permisos de autorización de firmas y salidas.
    || Estándar: Sin DML directos, parámetros CLOB JSON, uso exclusivo de DAOs
    ||           y p_do_commit para control transaccional.
    || =========================================================================
    */

    /**
     * Registra un nuevo familiar / acudiente en el sistema y opcionalmente lo vincula a un residente
     * Parámetro pcl_json:
     * {
     *   "tipoIdentificacion": "CC",
     *   "identificacion": "79.345.889",
     *   "nombres": "Mauricio Andrés",
     *   "apellidos": "Restrepo Gómez",
     *   "telefonoPrincipal": "3156781234",
     *   "telefonoSecundario": "3001234567",
     *   "email": "mauricio@empresa.com",
     *   "direccion": "Calle 134 # 9-45",
     *   "ciudad": "Bogota D.C.",
     *   "idCanalNotifPref": 1,
     *   "idResidente": 1,
     *   "idParentesco": 2,
     *   "esPrincipal": 1,
     *   "autorizadoSalidas": 1,
     *   "responsablePago": 0
     * }
     */
    PROCEDURE pr_registrar_familiar (
        pcl_json IN CLOB
    );

    /**
     * Vincula un familiar existente con otro residente
     * Parámetro pcl_json:
     * {
     *   "idAcudiente": 102,
     *   "idResidente": 2,
     *   "idParentesco": 3,
     *   "esPrincipal": 0,
     *   "autorizadoSalidas": 1,
     *   "responsablePago": 0
     * }
     */
    PROCEDURE pr_vincular_familiar_residente (
        pcl_json IN CLOB
    );

    /**
     * Actualiza la información personal, de contacto o dirección de un familiar / acudiente
     * Parámetro pcl_json:
     * {
     *   "idAcudiente": 102,
     *   "nombres": "Mauricio Andrés",
     *   "apellidos": "Restrepo Gómez",
     *   "identificacion": "79.345.889",
     *   "idTipoIdentificacion": 1,
     *   "telefonoPrincipal": "3156781234",
     *   "telefonoSecundario": "3001234567",
     *   "email": "mauricio@empresa.com",
     *   "direccion": "Calle 134 # 9-45",
     *   "ciudad": "Bogota D.C.",
     *   "idCanalNotifPref": 2
     * }
     */
    PROCEDURE pr_actualizar_familiar (
        pcl_json IN CLOB
    );

    /**
     * Elimina un familiar / acudiente y sus relaciones con residentes
     * Parámetro pcl_json:
     * {
     *   "idAcudiente": 102
     * }
     */
    PROCEDURE pr_eliminar_familiar (
        pcl_json IN CLOB
    );

END PKGLN_GESTION_FAMILIARES;
/
