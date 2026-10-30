CREATE OR REPLACE PACKAGE PKGLN_ADMISION_RESIDENTE 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_ADMISION_RESIDENTE
    || Propósito: Gestionar el flujo de negocio de admisión de nuevos residentes,
    ||            validación de cupos y habitaciones, asignación de cuidados,
    ||            y vinculación con su acudiente responsable inicial.
    || Estándar: Sin sentencias DML directas, interacción vía DAOs por PK,
    ||           parámetros CLOB JSON, commit controlado vía p_do_commit.
    || =========================================================================
    */

    /**
     * Registra la admisión completa de un nuevo residente y su acudiente opcional
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "tipoIdentificacion": "CC",
     *   "identificacion": "24.312.890",
     *   "nombres": "Blanca",
     *   "apellidos": "Gomez de Restrepo",
     *   "fechaNacimiento": "1942-05-14",
     *   "genero": "F",
     *   "habitacion": "104",
     *   "cama": "104-A",
     *   "eps": "Sanitas EPS",
     *   "planComplementario": "Colmedica",
     *   "tipoSangre": "O+",
     *   "idNivelMovilidad": 2,
     *   "idTipoDieta": 3,
     *   "alertasClinicas": "Alergia a penicilina",
     *   "medicamentos": [
     *       {
     *           "medicamento": "Losartan 50mg",
     *           "cantidad": "1 tableta",
     *           "frecuencia": "Cada 12 horas",
     *           "fechaFin": "2026-12-31",
     *           "indicaciones": "Tomar con abundante agua"
     *       }
     *   ],
     *   "acudienteAsociado": {
     *       "nombres": "Claudia Patricia",
     *       "apellidos": "Restrepo Gomez",
     *       "identificacion": "52.489.120",
     *       "idParentesco": 1,
     *       "telefono": "3108459921",
     *       "email": "claudia@gmail.com"
     *   },
     *   "observaciones": "Residente ingresa orientado y colaborador en compañía de su hija. Trae pertenencias completas."
     * }
     */
    PROCEDURE pr_registrar_residente (
        pcl_json IN CLOB
    );

    /**
     * Actualiza la información personal, ubicación, dieta o consideraciones clínicas de un residente existente
     * Parámetro pcl_json:
     * {
     *   "idResidente": 105,
     *   "nombres": "Blanca Ines",
     *   "apellidos": "Gomez de Restrepo",
     *   "identificacion": "24.312.890",
     *   "idTipoIdentificacion": 1,
     *   "fechaNacimiento": "1942-05-14",
     *   "idGenero": 2,
     *   "eps": "Sanitas EPS",
     *   "planComplementario": "Colmedica",
     *   "tipoSangre": "O+",
     *   "habitacion": "108",
     *   "cama": "108-B",
     *   "idNivelMovilidad": 3,
     *   "idTipoDieta": 2,
     *   "alertasClinicas": "Nueva dieta blanda prescrita",
     *   "idEstadoResidente": 1
     * }
     */
    PROCEDURE pr_actualizar_residente (
        pcl_json IN CLOB
    );

    /**
     * Registra o actualiza la Ficha Técnica de Ingreso y Valoración Multidimensional Integral del Adulto Mayor
     */
    PROCEDURE pr_guardar_valoracion_ingreso (
        pcl_json IN CLOB
    );

END PKGLN_ADMISION_RESIDENTE;
/
