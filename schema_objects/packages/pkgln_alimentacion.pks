CREATE OR REPLACE PACKAGE PKGLN_ALIMENTACION 
AS
    /*
    || =========================================================================
    || Paquete: PKGLN_ALIMENTACION
    || Propósito: Orquestación de lógica de negocio del módulo de alimentación,
    ||           planes nutricionales, menús semanales, control de ingesta y
    ||           asistencia a comedores.
    || Estándar: Sin DML directos, validación con DAOs/pkgca/pkgcn, transacciones con
    ||           p_do_commit, captura WHEN OTHERS con uti_ge_excepciones_pkg.p_grabar_log.
    || =========================================================================
    */

    /**
     * Habilita o deshabilita el módulo de alimentación para una sede
     * Parámetro pcl_json:
     * {
     *   "idCentro": 1,
     *   "manejaAlimentacion": "S",
     *   "actualizadoPor": "ADMIN"
     * }
     */
    PROCEDURE pr_configurar_modulo_alimentacion (
        pcl_json IN CLOB
    );

    /**
     * Registra o actualiza el plan nutricional individual de un residente
     * Parámetro pcl_json:
     * {
     *   "id": 1,
     *   "idCentro": 1,
     *   "idResidente": 5,
     *   "idTipoDieta": 2,
     *   "idConsistencia": 1,
     *   "idNivelEspesante": 3,
     *   "requerimientoCaloricoKcal": 1800,
     *   "restriccionesAlergias": "Sin mariscos ni lácteos enteros",
     *   "alimentosPreferidos": "Frutas suaves, pescado",
     *   "alimentosRechazados": "Brócoli, coliflor",
     *   "requiereAsistencia": "S",
     *   "suplementoNutricional": "Ensure Advance 1 toma a las 16:00",
     *   "observaciones": "Comer en posición fowler 90 grados",
     *   "usuario": "NUTRICIONISTA_ANA"
     * }
     */
    PROCEDURE pr_guardar_plan_nutricional (
        pcl_json IN CLOB
    );

    /**
     * Registra o actualiza la cabecera de una minuta semanal
     * Parámetro pcl_json:
     * {
     *   "id": 1,
     *   "idCentro": 1,
     *   "nombre": "Menú Semana 41 - Salud Cardiovascular",
     *   "descripcion": "Menú balanceado bajo en sodio",
     *   "fechaInicio": "2026-10-05",
     *   "fechaFin": "2026-10-11",
     *   "estado": "ACTIVO",
     *   "usuario": "CHEF_CARLOS"
     * }
     */
    PROCEDURE pr_guardar_minuta_semanal (
        pcl_json IN CLOB
    );

    /**
     * Registra o actualiza un plato en la minuta semanal
     * Parámetro pcl_json:
     * {
     *   "id": 1,
     *   "idMinuta": 1,
     *   "diaSemana": 1,
     *   "idTiempoComida": 3,
     *   "platoPrincipal": "Pechuga a la plancha con finas hierbas",
     *   "acompanamiento": "Arroz integral y ensalada de verduras al vapor",
     *   "bebida": "Jugo de guanábana sin azúcar",
     *   "postre": "Papaya picada",
     *   "caloriasEstimadas": 550,
     *   "observacionesDietas": "Adaptar consistencia para papilla a residentes con disfagia",
     *   "usuario": "CHEF_CARLOS"
     * }
     */
    PROCEDURE pr_guardar_item_minuta (
        pcl_json IN CLOB
    );

    /**
     * Registra o actualiza la ingesta de un residente en el comedor
     * Parámetro pcl_json:
     * {
     *   "id": 10,
     *   "idCentro": 1,
     *   "idResidente": 5,
     *   "fecha": "2026-10-04",
     *   "idTiempoComida": 3,
     *   "porcentajeIngesta": 40,
     *   "liquidosMl": 150,
     *   "tolerancia": "REGULAR",
     *   "asistio": "S",
     *   "observaciones": "Rechazó la proteína, refiere inapetencia",
     *   "idEmpleadoRegistra": 2,
     *   "usuario": "AUX_ENFERMERIA_LAURA"
     * }
     */
    PROCEDURE pr_registrar_ingesta_comedor (
        pcl_json IN CLOB
    );

    /**
     * Precarga los registros de comedor del día para un tiempo de comida específico
     */
    PROCEDURE pr_precargar_asistencia_dia (
        pcl_json IN CLOB
    );

    /**
     * Consultas operativas que delegan a paquetes pkgca_ / pkgcn_
     */
    PROCEDURE pr_consultar_planes_centro (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE pr_consultar_minutas_centro (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    PROCEDURE pr_consultar_comedor_dia (
        pcl_json IN  CLOB,
        p_cursor OUT SYS_REFCURSOR
    );

    FUNCTION fn_resumen_comedor_dia_json (
        pcl_json IN CLOB
    ) RETURN CLOB;

END PKGLN_ALIMENTACION;
/
