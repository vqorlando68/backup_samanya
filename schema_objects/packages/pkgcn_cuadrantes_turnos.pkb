CREATE OR REPLACE PACKAGE BODY PKGCN_CUADRANTES_TURNOS 
AS

    FUNCTION fn_validar_cobertura_json (
        pcl_json IN CLOB
    ) RETURN CLOB
    IS
        vcl_resultado CLOB;
    BEGIN
        -- Sentencia SELECT ÚNICA multi-tabla sobre solamente JSON nativo (RETURNING CLOB)
        SELECT JSON_OBJECT(
                   'idTurno'          VALUE pt.id,
                   'idPlantillaTurno' VALUE pt.id,
                   'codigoTurno'      VALUE pt.codigo,
                   'nombreTurno'      VALUE pt.nombre,
                   'horaInicio'       VALUE pt.hora_inicio,
                   'horaFin'          VALUE pt.hora_fin,
                   'fecha'            VALUE NVL(JSON_VALUE(pcl_json, '$.fecha'), TO_CHAR(f_fecha_actual, 'YYYY-MM-DD')),
                   'personalAsignado' VALUE COUNT(ta.id),
                   'minimoRequerido'  VALUE 3,
                   'cumpleCobertura'  VALUE CASE WHEN COUNT(ta.id) >= 3 THEN 'SI' ELSE 'NO' END
                   RETURNING CLOB
               )
          INTO vcl_resultado
          FROM smy_plantillas_turno pt,
               smy_turnos_asignados ta
         WHERE pt.id = ta.id_plantilla_turno(+)
           AND pt.id = NVL(TO_NUMBER(JSON_VALUE(pcl_json, '$.idTurno')), TO_NUMBER(JSON_VALUE(pcl_json, '$.idPlantillaTurno')))
           AND TRUNC(ta.fecha_turno(+)) = TRUNC(NVL(TO_DATE(SUBSTR(JSON_VALUE(pcl_json, '$.fecha'), 1, 10), 'YYYY-MM-DD'), f_fecha_actual))
         GROUP BY pt.id, pt.codigo, pt.nombre, pt.hora_inicio, pt.hora_fin;

        RETURN vcl_resultado;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END fn_validar_cobertura_json;

END PKGCN_CUADRANTES_TURNOS;
/
