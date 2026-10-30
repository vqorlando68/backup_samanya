CREATE OR REPLACE PACKAGE BODY PKGCN_OPERACION_MOVIL 
AS

    FUNCTION fn_obtener_estado_movil_json (
        pcl_json IN CLOB
    ) RETURN CLOB
    IS
        v_id_centro      smy_centros.id%TYPE;
        v_id_usuario     smy_usuarios.id%TYPE;
        vcl_sedes        CLOB;
        vcl_residentes   CLOB;
        vcl_trabajadores CLOB;
        vcl_turnos       CLOB;
        vcl_tareas       CLOB;
        vcl_bitacora     CLOB;
        vcl_signos       CLOB;
        vcl_incidentes   CLOB;
        vcl_consentim    CLOB;
        vcl_suministros  CLOB;
        vcl_docs_clin    CLOB;
        vcl_docs_elim    CLOB;
        vcl_notifs       CLOB;
        vcl_resultado    CLOB;
    BEGIN
        -- Extracción obligatoria mediante JSON_VALUE
        v_id_centro  := TO_NUMBER(JSON_VALUE(pcl_json, '$.idCentro'));
        v_id_usuario := TO_NUMBER(JSON_VALUE(pcl_json, '$.idUsuario'));

        -- 1. Proyección multi-tabla de Sedes (SMY_CENTROS + SMY_ORGANIZACIONES)
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'                VALUE TO_CHAR(c.id),
                    'name'              VALUE c.nombre_centro,
                    'shortName'         VALUE SUBSTR(c.nombre_centro, 1, 22),
                    'city'              VALUE NVL(c.ciudad, 'Bogotá D.C.'),
                    'address'           VALUE NVL(c.direccion, 'Dirección principal'),
                    'residentCount'     VALUE (
                        SELECT COUNT(*)
                          FROM smy_residentes r
                         WHERE r.id_centro = c.id
                           AND r.id_estado_residente = 1
                    ),
                    'activeShiftsCount' VALUE (
                        SELECT COUNT(DISTINCT ta.id_plantilla_turno)
                          FROM smy_turnos_asignados ta,
                               smy_empleados emp
                         WHERE ta.id_empleado = emp.id
                           AND emp.id_centro = c.id
                    ),
                    'totalWorkers'      VALUE (
                        SELECT COUNT(*)
                          FROM smy_empleados e
                         WHERE e.id_centro = c.id
                           AND e.id_estado_empleado = 1
                    )
                    RETURNING CLOB
                )
                ORDER BY c.id
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_sedes
        FROM smy_centros c,
             smy_organizaciones o
       WHERE c.id_organizacion = o.id(+);

        -- 2. Proyección multi-tabla de Residentes con Medicamentos y Responsables (FORMAT JSON)
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'        VALUE TO_CHAR(r.id),
                    'idCentro'  VALUE r.id_centro,
                    'name'      VALUE (r.nombres || ' ' || r.apellidos),
                    'room'      VALUE 'Habitación ' || NVL(r.habitacion, '101'),
                    'floor'     VALUE 'Piso 1',
                    'bed'       VALUE 'Cama ' || NVL(r.cama, 'A'),
                    'birthDate' VALUE TO_CHAR(r.fecha_nacimiento, 'YYYY-MM-DD'),
                    'age'       VALUE NVL(TRUNC(MONTHS_BETWEEN(f_fecha_actual, r.fecha_nacimiento) / 12), 78),
                    'avatar'    VALUE CASE
                                        WHEN arc.ruta_completa_almacenamiento LIKE 'http%' OR arc.ruta_completa_almacenamiento LIKE '/uploads/%'
                                        THEN arc.ruta_completa_almacenamiento
                                        ELSE 'https://ui-avatars.com/api/?background=0D9488&color=fff&bold=true&name=' || REPLACE(r.nombres || '+' || r.apellidos, ' ', '+')
                                      END,
                    'diet'      VALUE NVL(d.nombre_tipo_dieta, 'Normal / General'),
                    'mobility'  VALUE NVL(m.nombre_nivel_movilidad, 'Independiente'),
                    'alertsRaw' VALUE r.alertas_clinicas,
                    'medications' VALUE (
                        SELECT NVL(
                            JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'id'       VALUE TO_CHAR(mp.id),
                                    'drugName' VALUE mp.nombre_medicamento,
                                    'time'     VALUE NVL(SUBSTR(mp.horarios_fijos, 1, 5), '08:00'),
                                    'dose'     VALUE NVL(mp.dosis, '1 dosis'),
                                    'quantity' VALUE NVL(mp.cantidad, '1 unidad'),
                                    'route'    VALUE NVL(va.nombre_via_administracion, 'Oral'),
                                    'details'  VALUE mp.indicaciones,
                                    'status'   VALUE CASE
                                                       WHEN EXISTS (
                                                           SELECT 1
                                                             FROM smy_registros_admin_med ram
                                                            WHERE ram.id_medicamento_prescrito = mp.id
                                                              AND ram.id_estado_admin_med = 2
                                                       ) THEN 'administrado'
                                                       ELSE 'pendiente'
                                                     END
                                    RETURNING CLOB
                                )
                                ORDER BY mp.id
                                RETURNING CLOB
                            ),
                            TO_CLOB('[]')
                        )
                        FROM smy_medicamentos_prescritos mp,
                             smy_vias_administracion va
                       WHERE mp.id_via_administracion = va.id(+)
                         AND mp.id_residente = r.id
                    ) FORMAT JSON,
                    'responsibleList' VALUE (
                        SELECT NVL(
                            JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'id'           VALUE TO_CHAR(a.id),
                                    'idUsuario'    VALUE a.id_usuario,
                                    'name'         VALUE (a.nombres || ' ' || a.apellidos),
                                    'relationship' VALUE NVL(p.nombre_parentesco, 'Familiar'),
                                    'phone'        VALUE a.telefono_principal,
                                    'email'        VALUE a.email
                                    RETURNING CLOB
                                )
                                ORDER BY ra.id
                                RETURNING CLOB
                            ),
                            TO_CLOB('[]')
                        )
                        FROM smy_residente_acudiente ra,
                             smy_acudientes a,
                             smy_parentescos p
                       WHERE ra.id_acudiente = a.id
                         AND ra.id_parentesco = p.id(+)
                         AND ra.id_residente = r.id
                    ) FORMAT JSON
                    RETURNING CLOB
                )
                ORDER BY r.id
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_residentes
        FROM smy_residentes r,
             smy_estados_residentes e,
             smy_niveles_movilidad m,
             smy_tipos_dietas d,
             smy_archivos arc
       WHERE r.id_estado_residente = e.id
         AND r.id_nivel_movilidad = m.id(+)
         AND r.id_tipo_dieta = d.id(+)
         AND r.id_archivo_foto_perfil = arc.id(+)
         AND (v_id_centro IS NULL OR r.id_centro = v_id_centro);

        -- 3. Proyección multi-tabla de Trabajadores / Personal Asistencial
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'     VALUE TO_CHAR(emp.id),
                    'name'   VALUE (emp.nombres || ' ' || emp.apellidos),
                    'role'   VALUE NVL(ca.nombre_cargo_empleado, 'Cuidador(a)'),
                    'avatar' VALUE CASE
                                     WHEN arc.ruta_completa_almacenamiento LIKE 'http%' OR arc.ruta_completa_almacenamiento LIKE '/uploads/%'
                                     THEN arc.ruta_completa_almacenamiento
                                     ELSE 'https://ui-avatars.com/api/?background=0F766E&color=fff&bold=true&name=' || REPLACE(emp.nombres || '+' || emp.apellidos, ' ', '+')
                                   END,
                    'unit'   VALUE NVL(emp.unidad_asignada, 'Unidad Asistencial')
                    RETURNING CLOB
                )
                ORDER BY emp.id
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_trabajadores
        FROM smy_empleados emp,
             smy_cargos_empleados ca,
             smy_usuarios u,
             smy_archivos arc
       WHERE emp.id_cargo_empleado = ca.id(+)
         AND emp.id_usuario = u.id(+)
         AND u.id_archivo_foto_perfil = arc.id(+)
         AND (v_id_centro IS NULL OR emp.id_centro = v_id_centro);

        -- 4. Proyección multi-tabla de Turnos y Plantillas (FORMAT JSON)
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'                    VALUE 'sh-' || TO_CHAR(pt.id),
                    'templateId'            VALUE pt.id,
                    'sedeId'                VALUE TO_CHAR(NVL(v_id_centro, 1)),
                    'name'                  VALUE pt.nombre,
                    'timeRange'             VALUE (pt.hora_inicio || ' - ' || pt.hora_fin),
                    'status'                VALUE CASE
                                                    WHEN pt.id = 1 THEN 'cerrado'
                                                    WHEN pt.id = 2 THEN 'activo'
                                                    ELSE 'futuro'
                                                  END,
                    'coveredResidentsCount' VALUE (
                        SELECT COUNT(*)
                          FROM smy_residentes r
                         WHERE (v_id_centro IS NULL OR r.id_centro = v_id_centro)
                           AND r.id_estado_residente = 1
                    ),
                    'completionRate'        VALUE CASE WHEN pt.id = 1 THEN 100 ELSE 67 END,
                    'pendingTasksCount'     VALUE CASE WHEN pt.id = 1 THEN 0 ELSE 1 END,
                    'incidentsCount'        VALUE (
                        SELECT COUNT(*)
                          FROM smy_incidentes inc
                    ),
                    'assignedWorkers'       VALUE (
                        SELECT NVL(
                            JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'id'             VALUE TO_CHAR(emp.id),
                                    'name'           VALUE (emp.nombres || ' ' || emp.apellidos),
                                    'role'           VALUE NVL(ca.nombre_cargo_empleado, 'Cuidador(a)'),
                                    'avatar'         VALUE 'https://ui-avatars.com/api/?background=0F766E&color=fff&bold=true&name=' || REPLACE(emp.nombres || '+' || emp.apellidos, ' ', '+'),
                                    'scheduledHours' VALUE (pt.hora_inicio || ' - ' || pt.hora_fin),
                                    'fechaTurno'     VALUE TO_CHAR(ta.fecha_turno, 'YYYY-MM-DD')
                                    RETURNING CLOB
                                )
                                ORDER BY ta.id
                                RETURNING CLOB
                            ),
                            TO_CLOB('[]')
                        )
                        FROM smy_turnos_asignados ta,
                             smy_empleados emp,
                             smy_cargos_empleados ca
                       WHERE ta.id_empleado = emp.id
                         AND emp.id_cargo_empleado = ca.id(+)
                         AND ta.id_plantilla_turno = pt.id
                         AND (v_id_centro IS NULL OR emp.id_centro = v_id_centro)
                    ) FORMAT JSON
                    RETURNING CLOB
                )
                ORDER BY pt.id
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_turnos
        FROM smy_plantillas_turno pt,
             smy_organizaciones o
       WHERE pt.id_organizacion = o.id(+);

        -- 5. Proyección multi-tabla de Tareas Operativas + Registros de Administración de Medicamentos
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'                    VALUE tarea_item.id_str,
                    'date'                  VALUE tarea_item.fecha_str,
                    'time'                  VALUE tarea_item.hora_str,
                    'title'                 VALUE tarea_item.titulo,
                    'type'                  VALUE tarea_item.tipo,
                    'scope'                 VALUE tarea_item.alcance,
                    'status'                VALUE tarea_item.estado,
                    'residentCount'         VALUE tarea_item.cant_res,
                    'residentId'            VALUE tarea_item.id_res_str,
                    'residentName'          VALUE tarea_item.nom_res,
                    'description'           VALUE tarea_item.descripcion,
                    'assignedWorkerId'      VALUE tarea_item.id_usr_asig,
                    'assignedWorkerName'    VALUE tarea_item.nom_usr_asig,
                    'completedByWorkerName' VALUE tarea_item.nom_usr_comp,
                    'completedAtTime'       VALUE tarea_item.hora_comp,
                    'dose'                  VALUE tarea_item.dosis_med,
                    'instructions'          VALUE tarea_item.indicaciones_med
                    RETURNING CLOB
                )
                ORDER BY tarea_item.hora_str, tarea_item.id_str
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_tareas
        FROM (
            SELECT TO_CHAR(t.id) AS id_str,
                   TO_CHAR(NVL(t.fecha_programada, f_fecha_actual), 'YYYY-MM-DD') AS fecha_str,
                   NVL(t.hora_programada, '08:00') AS hora_str,
                   t.titulo AS titulo,
                   LOWER(NVL(tt.nombre_tipo_tarea, 'actividad')) AS tipo,
                   LOWER(NVL(at.nombre_alcance_tarea, 'individual')) AS alcance,
                   CASE
                     WHEN LOWER(NVL(et.nombre_estado_tarea, 'pendiente')) = 'completada' THEN 'completada'
                     ELSE 'pendiente'
                   END AS estado,
                   NVL(t.cantidad_residentes, 1) AS cant_res,
                   CASE WHEN t.id_residente IS NOT NULL THEN TO_CHAR(t.id_residente) ELSE NULL END AS id_res_str,
                   CASE WHEN r.id IS NOT NULL THEN (r.nombres || ' ' || r.apellidos) ELSE NULL END AS nom_res,
                   NVL(t.descripcion, t.titulo) AS descripcion,
                   CASE WHEN t.id_usuario_asignado IS NOT NULL THEN TO_CHAR(t.id_usuario_asignado) ELSE NULL END AS id_usr_asig,
                   ua.nombre_completo AS nom_usr_asig,
                   uc.nombre_completo AS nom_usr_comp,
                   CASE WHEN t.completado_el IS NOT NULL THEN TO_CHAR(t.completado_el, 'HH24:MI') ELSE NULL END AS hora_comp,
                   CAST(NULL AS VARCHAR2(100)) AS dosis_med,
                   t.descripcion AS indicaciones_med
              FROM smy_tareas_operativas t,
                   smy_tipos_tareas tt,
                   smy_alcances_tareas at,
                   smy_estados_tareas et,
                   smy_residentes r,
                   smy_usuarios ua,
                   smy_usuarios uc
             WHERE t.id_tipo_tarea = tt.id(+)
               AND t.id_alcance_tarea = at.id(+)
               AND t.id_estado_tarea = et.id(+)
               AND t.id_residente = r.id(+)
               AND t.id_usuario_asignado = ua.id(+)
               AND t.id_usuario_completo = uc.id(+)
               AND (v_id_centro IS NULL OR r.id_centro IS NULL OR r.id_centro = v_id_centro)
            UNION ALL
            SELECT 'med-adm-' || TO_CHAR(ram.id) AS id_str,
                   TO_CHAR(NVL(ram.fecha_programada, f_fecha_actual), 'YYYY-MM-DD') AS fecha_str,
                   NVL(ram.hora_programada, '08:00') AS hora_str,
                   'Administrar ' || mp.nombre_medicamento || ' — ' || r.nombres || ' ' || r.apellidos AS titulo,
                   'medicacion' AS tipo,
                   'individual' AS alcance,
                   CASE WHEN ram.id_estado_admin_med = 2 THEN 'completada' ELSE 'pendiente' END AS estado,
                   1 AS cant_res,
                   TO_CHAR(r.id) AS id_res_str,
                   (r.nombres || ' ' || r.apellidos) AS nom_res,
                   NVL(ram.notas, mp.indicaciones) AS descripcion,
                   TO_CHAR(ram.id_usuario_administro) AS id_usr_asig,
                   u.nombre_completo AS nom_usr_asig,
                   CASE WHEN ram.id_estado_admin_med = 2 THEN u.nombre_completo ELSE NULL END AS nom_usr_comp,
                   ram.hora_administrada AS hora_comp,
                   mp.dosis AS dosis_med,
                   mp.indicaciones AS indicaciones_med
              FROM smy_registros_admin_med ram,
                   smy_medicamentos_prescritos mp,
                   smy_residentes r,
                   smy_usuarios u
             WHERE ram.id_medicamento_prescrito = mp.id
               AND ram.id_residente = r.id
               AND ram.id_usuario_administro = u.id(+)
               AND (v_id_centro IS NULL OR r.id_centro = v_id_centro)
        ) tarea_item;

        -- 6. Proyección multi-tabla de Bitácora Diaria
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'              VALUE TO_CHAR(b.id),
                    'residentId'      VALUE TO_CHAR(b.id_residente),
                    'residentName'    VALUE (r.nombres || ' ' || r.apellidos),
                    'date'            VALUE TO_CHAR(NVL(b.fecha, f_fecha_actual), 'YYYY-MM-DD'),
                    'time'            VALUE NVL(b.hora, '08:00'),
                    'category'        VALUE NVL(cat.nombre_categoria_bitacora, 'Rutina'),
                    'text'            VALUE DBMS_LOB.SUBSTR(b.contenido, 2000, 1),
                    'recordedByVoice' VALUE CASE WHEN b.grabado_por_voz = 'S' THEN 'true' ELSE 'false' END,
                    'author'          VALUE NVL(u.nombre_completo, NVL(emp.nombres || ' ' || emp.apellidos, 'Personal de Turno'))
                    RETURNING CLOB
                )
                ORDER BY b.fecha DESC, b.hora DESC, b.id DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_bitacora
        FROM smy_bitacora_residente b,
             smy_residentes r,
             smy_categorias_bitacora cat,
             smy_usuarios u,
             smy_empleados emp
       WHERE b.id_residente = r.id
         AND b.id_categoria_bitacora = cat.id(+)
         AND b.id_usuario = u.id(+)
         AND b.id_empleado = emp.id(+)
         AND (v_id_centro IS NULL OR r.id_centro = v_id_centro);

        -- 7. Proyección multi-tabla de Signos Vitales
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'           VALUE TO_CHAR(sv.id),
                    'residentId'   VALUE TO_CHAR(sv.id_residente),
                    'residentName' VALUE (r.nombres || ' ' || r.apellidos),
                    'date'         VALUE TO_CHAR(NVL(sv.fecha, f_fecha_actual), 'YYYY-MM-DD'),
                    'time'         VALUE NVL(sv.hora, '08:00'),
                    'systolic'     VALUE NVL(sv.presion_sistolica, 120),
                    'diastolic'    VALUE NVL(sv.presion_diastolica, 80),
                    'heartRate'    VALUE NVL(sv.frecuencia_cardiaca, 72),
                    'spO2'         VALUE NVL(sv.saturacion_oxigeno, 96),
                    'temperature'  VALUE NVL(sv.temperatura, 36.5),
                    'glucose'      VALUE sv.glucometria,
                    'notes'        VALUE sv.observaciones,
                    'takenBy'      VALUE NVL(u.nombre_completo, 'Personal Asistencial')
                    RETURNING CLOB
                )
                ORDER BY sv.fecha DESC, sv.hora DESC, sv.id DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_signos
        FROM smy_signos_vitales sv,
             smy_residentes r,
             smy_usuarios u
       WHERE sv.id_residente = r.id
         AND sv.id_usuario_registro = u.id(+)
         AND (v_id_centro IS NULL OR r.id_centro = v_id_centro);

        -- 8. Proyección multi-tabla de Incidentes (FORMAT JSON)
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'           VALUE TO_CHAR(inc.id),
                    'incidentType' VALUE LOWER(NVL(ti.nombre_tipo_incidente, 'otro')),
                    'severity'     VALUE LOWER(NVL(si.nombre_severidad_incidente, 'leve')),
                    'dateTime'     VALUE TO_CHAR(NVL(inc.fecha_hora_evento, f_fecha_actual), 'YYYY-MM-DD HH24:MI'),
                    'description'  VALUE DBMS_LOB.SUBSTR(inc.descripcion, 2000, 1),
                    'reportedBy'   VALUE NVL(u.nombre_completo, 'Personal Asistencial'),
                    'status'       VALUE LOWER(NVL(ei.nombre_estado_incidente, 'recibido')),
                    'residents'    VALUE (
                        SELECT NVL(
                            JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'id'   VALUE TO_CHAR(r.id),
                                    'name' VALUE (r.nombres || ' ' || r.apellidos)
                                    RETURNING CLOB
                                )
                                RETURNING CLOB
                            ),
                            TO_CLOB('[]')
                        )
                        FROM smy_incidente_residentes ir,
                             smy_residentes r
                       WHERE ir.id_residente = r.id
                         AND ir.id_incidente = inc.id
                    ) FORMAT JSON
                    RETURNING CLOB
                )
                ORDER BY inc.fecha_hora_evento DESC, inc.id DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_incidentes
        FROM smy_incidentes inc,
             smy_tipos_incidentes ti,
             smy_severidades_incidentes si,
             smy_estados_incidentes ei,
             smy_usuarios u
       WHERE inc.id_tipo_incidente = ti.id(+)
         AND inc.id_severidad_incidente = si.id(+)
         AND inc.id_estado_incidente = ei.id(+)
         AND inc.id_usuario_reporto = u.id(+);

        -- 9. Proyección multi-tabla de Consentimientos Informados (FORMAT JSON)
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'           VALUE TO_CHAR(co.id),
                    'residentId'   VALUE TO_CHAR(co.id_residente),
                    'residentName' VALUE (r.nombres || ' ' || r.apellidos),
                    'room'         VALUE 'Habitación ' || NVL(r.habitacion, '101'),
                    'type'         VALUE NVL(tc.nombre_tipo_consentimiento, 'Tratamiento médico'),
                    'status'       VALUE LOWER(NVL(ec.nombre_estado_consentimiento, 'pendiente')),
                    'sentDate'     VALUE TO_CHAR(NVL(co.fecha_envio, f_fecha_actual), 'YYYY-MM-DD HH24:MI'),
                    'responseDate' VALUE CASE WHEN co.fecha_respuesta IS NOT NULL THEN TO_CHAR(co.fecha_respuesta, 'YYYY-MM-DD HH24:MI') ELSE NULL END,
                    'description'  VALUE DBMS_LOB.SUBSTR(co.descripcion, 2000, 1),
                    'documentName' VALUE 'Consentimiento_' || TO_CHAR(co.id) || '.pdf',
                    'documentSize' VALUE '420 KB',
                    'recipients'   VALUE (
                        SELECT NVL(
                            JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'id'           VALUE TO_CHAR(cd.id),
                                    'name'         VALUE NVL(cd.nombre_destinatario, 'Familiar Autorizado'),
                                    'relationship' VALUE NVL(p.nombre_parentesco, 'Familiar'),
                                    'email'        VALUE NVL(cd.email, 'familiar@com.co'),
                                    'status'       VALUE LOWER(NVL(ef.nombre_estado_firma_cons, 'enviado')),
                                    'rejectReason' VALUE cd.motivo_rechazo
                                    RETURNING CLOB
                                )
                                ORDER BY cd.id
                                RETURNING CLOB
                            ),
                            TO_CLOB('[]')
                        )
                        FROM smy_consentimiento_destinatarios cd,
                             smy_parentescos p,
                             smy_estados_firmas_cons ef
                       WHERE cd.id_parentesco = p.id(+)
                         AND cd.id_estado_firma_cons = ef.id(+)
                         AND cd.id_consentimiento = co.id
                    ) FORMAT JSON
                    RETURNING CLOB
                )
                ORDER BY co.id DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_consentim
        FROM smy_consentimientos co,
             smy_residentes r,
             smy_tipos_consentimientos tc,
             smy_estados_consentimientos ec
       WHERE co.id_residente = r.id
         AND co.id_tipo_consentimiento = tc.id(+)
         AND co.id_estado_consentimiento = ec.id(+)
         AND (v_id_centro IS NULL OR r.id_centro = v_id_centro);

        -- 10. Proyección multi-tabla de Suministros y Dotación de Residentes
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'             VALUE sum_item.id_str,
                    'residentId'     VALUE sum_item.id_res_str,
                    'residentName'   VALUE sum_item.nom_res,
                    'type'           VALUE sum_item.tipo_sum,
                    'description'    VALUE sum_item.descripcion,
                    'quantity'       VALUE sum_item.cantidad,
                    'date'           VALUE sum_item.fecha_str,
                    'time'           VALUE sum_item.hora_str,
                    'cost'           VALUE sum_item.costo,
                    'paymentStatus'  VALUE sum_item.estado_pago,
                    'paidBy'         VALUE sum_item.pagado_por,
                    'paidAt'         VALUE sum_item.fecha_pago,
                    'deliveredBy'    VALUE sum_item.entregado_por,
                    'recordedByName' VALUE sum_item.reg_nom,
                    'recordedByRole' VALUE sum_item.reg_rol,
                    'notes'          VALUE sum_item.notas
                    RETURNING CLOB
                )
                ORDER BY sum_item.fecha_str DESC, sum_item.id_str DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_suministros
        FROM (
            SELECT TO_CHAR(sr.id) AS id_str,
                   TO_CHAR(sr.id_residente) AS id_res_str,
                   (r.nombres || ' ' || r.apellidos) AS nom_res,
                   LOWER(NVL(ts.nombre_tipo_suministro, 'recepcion')) AS tipo_sum,
                   sr.descripcion AS descripcion,
                   NVL(sr.cantidad, '1 unidad') AS cantidad,
                   TO_CHAR(NVL(sr.fecha, f_fecha_actual), 'YYYY-MM-DD') AS fecha_str,
                   NVL(sr.hora, '10:00') AS hora_str,
                   sr.costo AS costo,
                   LOWER(NVL(ep.nombre_estado_pago, 'pendiente')) AS estado_pago,
                   sr.pagado_por AS pagado_por,
                   CASE WHEN sr.fecha_pago IS NOT NULL THEN TO_CHAR(sr.fecha_pago, 'DD/MM/YYYY HH24:MI') ELSE NULL END AS fecha_pago,
                   sr.entregado_por AS entregado_por,
                   NVL(sr.registrado_por_nom, 'Personal Samanya') AS reg_nom,
                   NVL(sr.registrado_por_rol, 'cuidador') AS reg_rol,
                   sr.notas AS notas
              FROM smy_suministros_registro sr,
                   smy_residentes r,
                   smy_tipos_suministros ts,
                   smy_estados_pagos ep
             WHERE sr.id_residente = r.id
               AND sr.id_tipo_suministro = ts.id(+)
               AND sr.id_estado_pago = ep.id(+)
               AND (v_id_centro IS NULL OR r.id_centro = v_id_centro)
            UNION ALL
            SELECT 'dot-' || TO_CHAR(dr.id) AS id_str,
                   TO_CHAR(dr.id_residente) AS id_res_str,
                   (r.nombres || ' ' || r.apellidos) AS nom_res,
                   'recepcion' AS tipo_sum,
                   dr.nombre_elemento || ' (' || NVL(dr.categoria, 'Dotación') || ')' AS descripcion,
                   TO_CHAR(NVL(dr.cantidad, 1)) || ' unidad(es)' AS cantidad,
                   TO_CHAR(NVL(dr.fecha_entrega, dr.fecha_creacion), 'YYYY-MM-DD') AS fecha_str,
                   TO_CHAR(NVL(dr.fecha_creacion, f_fecha_actual), 'HH24:MI') AS hora_str,
                   CAST(NULL AS NUMBER) AS costo,
                   'pagado' AS estado_pago,
                   CAST(NULL AS VARCHAR2(100)) AS pagado_por,
                   CAST(NULL AS VARCHAR2(30)) AS fecha_pago,
                   'Familiar / Admisión' AS entregado_por,
                   NVL(u.nombre_completo, 'Administración Samanya') AS reg_nom,
                   'admin' AS reg_rol,
                   dr.notas AS notas
              FROM smy_dotacion_residentes dr,
                   smy_residentes r,
                   smy_usuarios u
             WHERE dr.id_residente = r.id
               AND dr.id_usuario_entrega = u.id(+)
               AND (v_id_centro IS NULL OR r.id_centro = v_id_centro)
        ) sum_item;

        -- 11. Proyección multi-tabla de Documentos Clínicos + Historias Clínicas Base
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'             VALUE doc_item.id_str,
                    'residentId'     VALUE doc_item.id_res_str,
                    'residentName'   VALUE doc_item.nom_res,
                    'title'          VALUE doc_item.titulo,
                    'category'       VALUE doc_item.categoria,
                    'categoryLabel'  VALUE doc_item.cat_label,
                    'description'    VALUE doc_item.descripcion,
                    'entryType'      VALUE doc_item.tipo_entrada,
                    'fileType'       VALUE doc_item.tipo_archivo,
                    'fileName'       VALUE doc_item.nom_archivo,
                    'fileUrl'        VALUE doc_item.url_archivo,
                    'uploadedByRole' VALUE doc_item.rol_subio,
                    'uploadedByName' VALUE doc_item.nom_subio,
                    'createdAt'      VALUE doc_item.creado_str,
                    'date'           VALUE doc_item.fecha_str,
                    'time'           VALUE doc_item.hora_str
                    RETURNING CLOB
                )
                ORDER BY doc_item.creado_str DESC, doc_item.id_str DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_docs_clin
        FROM (
            SELECT TO_CHAR(dc.id) AS id_str,
                   TO_CHAR(dc.id_residente) AS id_res_str,
                   (r.nombres || ' ' || r.apellidos) AS nom_res,
                   dc.titulo AS titulo,
                   LOWER(NVL(cat.nombre_categoria_doc_clinico, 'otro')) AS categoria,
                   INITCAP(REPLACE(NVL(cat.nombre_categoria_doc_clinico, 'Otro'), '_', ' ')) AS cat_label,
                   dc.descripcion AS descripcion,
                   LOWER(NVL(te.nombre_tipo_entrada_doc, 'nota_texto')) AS tipo_entrada,
                   LOWER(NVL(ta.nombre_tipo_archivo_doc, 'pdf')) AS tipo_archivo,
                   arc.nombre_archivo AS nom_archivo,
                   arc.ruta_completa_almacenamiento AS url_archivo,
                   LOWER(NVL(dc.subido_por_rol, 'cuidador')) AS rol_subio,
                   NVL(dc.subido_por_nombre, 'Personal Asistencial') AS nom_subio,
                   TO_CHAR(NVL(dc.fecha_creacion, f_fecha_actual), 'YYYY-MM-DD"T"HH24:MI:SS') AS creado_str,
                   TO_CHAR(NVL(dc.fecha_documento, f_fecha_actual), 'YYYY-MM-DD') AS fecha_str,
                   TO_CHAR(NVL(dc.fecha_creacion, f_fecha_actual), 'HH24:MI') AS hora_str
              FROM smy_documentos_clinicos dc,
                   smy_residentes r,
                   smy_categorias_doc_clinicos cat,
                   smy_tipos_entradas_doc te,
                   smy_tipos_archivos_doc ta,
                   smy_archivos arc
             WHERE dc.id_residente = r.id
               AND dc.id_categoria_doc_clinico = cat.id(+)
               AND dc.id_tipo_entrada_doc = te.id(+)
               AND dc.id_tipo_archivo_doc = ta.id(+)
               AND dc.id_archivo_clinico = arc.id(+)
               AND NVL(dc.id_estado_doc_clinico, 1) = 1
               AND (v_id_centro IS NULL OR r.id_centro = v_id_centro)
            UNION ALL
            SELECT 'hc-' || TO_CHAR(hc.id) AS id_str,
                   TO_CHAR(hc.id_residente) AS id_res_str,
                   (r.nombres || ' ' || r.apellidos) AS nom_res,
                   'Valoración Médica Integral — ' || NVL(hc.medico_tratante, 'Médico Tratante') AS titulo,
                   'informe_evolucion' AS categoria,
                   'Historia Clínica Base' AS cat_label,
                   'Diagnósticos: ' || DBMS_LOB.SUBSTR(hc.diagnosticos_base, 600, 1) ||
                   ' | Antecedentes Quirúrgicos: ' || NVL(DBMS_LOB.SUBSTR(hc.antecedentes_quirur, 400, 1), 'N/A') ||
                   ' | Alergias Medicamentosas: ' || NVL(DBMS_LOB.SUBSTR(hc.alergias_medicament, 300, 1), 'Ninguna') AS descripcion,
                   'nota_texto' AS tipo_entrada,
                   CAST(NULL AS VARCHAR2(20)) AS tipo_archivo,
                   CAST(NULL AS VARCHAR2(200)) AS nom_archivo,
                   CAST(NULL AS VARCHAR2(500)) AS url_archivo,
                   'cuidador' AS rol_subio,
                   NVL(hc.medico_tratante, 'Dirección Médica Samanya') AS nom_subio,
                   TO_CHAR(NVL(hc.fecha_creacion, f_fecha_actual), 'YYYY-MM-DD"T"HH24:MI:SS') AS creado_str,
                   TO_CHAR(NVL(hc.fecha_creacion, f_fecha_actual), 'YYYY-MM-DD') AS fecha_str,
                   TO_CHAR(NVL(hc.fecha_creacion, f_fecha_actual), 'HH24:MI') AS hora_str
              FROM smy_historias_clinicas hc,
                   smy_residentes r
             WHERE hc.id_residente = r.id
               AND (v_id_centro IS NULL OR r.id_centro = v_id_centro)
        ) doc_item;

        -- 12. Proyección multi-tabla de Historial de Documentos Eliminados
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'             VALUE TO_CHAR(dl.id),
                    'recordId'       VALUE TO_CHAR(dl.id_documento_clinico),
                    'residentId'     VALUE TO_CHAR(dl.id_residente),
                    'residentName'   VALUE (r.nombres || ' ' || r.apellidos),
                    'title'          VALUE dl.titulo,
                    'category'       VALUE NVL(cat.nombre_categoria_doc_clinico, 'otro'),
                    'categoryLabel'  VALUE INITCAP(REPLACE(NVL(cat.nombre_categoria_doc_clinico, 'Otro'), '_', ' ')),
                    'uploadedByName' VALUE dl.subido_por_nombre,
                    'deletedAt'      VALUE TO_CHAR(NVL(dl.fecha_eliminacion, f_fecha_actual), 'DD/MM/YYYY HH24:MI')
                    RETURNING CLOB
                )
                ORDER BY dl.fecha_eliminacion DESC, dl.id DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_docs_elim
        FROM smy_documentos_eliminados_log dl,
             smy_residentes r,
             smy_categorias_doc_clinicos cat
       WHERE dl.id_residente = r.id
         AND dl.id_categoria_doc_clinico = cat.id(+)
         AND (v_id_centro IS NULL OR r.id_centro = v_id_centro);

        -- 13. Proyección multi-tabla de Notificaciones del Sistema
        SELECT NVL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id'           VALUE TO_CHAR(ns.id),
                    'title'        VALUE ns.titulo,
                    'message'      VALUE ns.mensaje,
                    'timestamp'    VALUE TO_CHAR(NVL(ns.fecha_creacion, f_fecha_actual), 'DD/MM/YYYY HH24:MI'),
                    'isRead'       VALUE CASE WHEN ns.leido = 'S' THEN 'true' ELSE 'false' END,
                    'type'         VALUE LOWER(NVL(tn.nombre_tipo_notificacion, 'aviso')),
                    'targetScreen' VALUE ns.pantalla_destino,
                    'targetId'     VALUE CASE WHEN ns.id_objeto_destino IS NOT NULL THEN TO_CHAR(ns.id_objeto_destino) ELSE NULL END
                    RETURNING CLOB
                )
                ORDER BY ns.fecha_creacion DESC, ns.id DESC
                RETURNING CLOB
            ),
            TO_CLOB('[]')
        )
        INTO vcl_notifs
        FROM smy_notificaciones_sistema ns,
             smy_tipos_notificaciones tn,
             smy_usuarios u
       WHERE ns.id_tipo_notificacion = tn.id(+)
         AND ns.id_usuario_destino = u.id(+)
         AND (
             v_id_usuario IS NULL
             OR ns.id_usuario_destino IS NULL
             OR ns.id_usuario_destino = v_id_usuario
             OR EXISTS (
                 SELECT 1
                   FROM smy_usuarios u_act
                  WHERE u_act.id = v_id_usuario
                    AND u_act.id_rol IN (1, 2)
             )
         );

        -- Ensamblaje de documento JSON maestro
        SELECT JSON_OBJECT(
            'sedes'                  VALUE vcl_sedes        FORMAT JSON,
            'residents'              VALUE vcl_residentes   FORMAT JSON,
            'staffWorkers'           VALUE vcl_trabajadores FORMAT JSON,
            'shifts'                 VALUE vcl_turnos       FORMAT JSON,
            'tasks'                  VALUE vcl_tareas       FORMAT JSON,
            'bitacoraEntries'        VALUE vcl_bitacora     FORMAT JSON,
            'vitalSigns'             VALUE vcl_signos       FORMAT JSON,
            'incidents'              VALUE vcl_incidentes   FORMAT JSON,
            'consents'               VALUE vcl_consentim    FORMAT JSON,
            'supplies'               VALUE vcl_suministros  FORMAT JSON,
            'clinicalRecords'        VALUE vcl_docs_clin    FORMAT JSON,
            'deletedClinicalRecords' VALUE vcl_docs_elim    FORMAT JSON,
            'notifications'          VALUE vcl_notifs       FORMAT JSON,
            'timestampBogota'        VALUE TO_CHAR(f_fecha_actual, 'YYYY-MM-DD"T"HH24:MI:SS')
            RETURNING CLOB
        )
        INTO vcl_resultado
        FROM smy_organizaciones o
       WHERE ROWNUM = 1;

        RETURN vcl_resultado;
    END fn_obtener_estado_movil_json;

END PKGCN_OPERACION_MOVIL;
/
