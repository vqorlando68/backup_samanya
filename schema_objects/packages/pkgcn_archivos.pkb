CREATE OR REPLACE PACKAGE BODY PKGCN_ARCHIVOS 
AS

    PROCEDURE pr_desvincular_archivos_doc (
        p_id_documento_clinico IN smy_documentos_clinicos.id%TYPE,
        p_id_usuario           IN smy_usuarios.id%TYPE
    ) IS
    BEGIN
        -- Sentencia DML única que involucra como mínimo dos tablas: SMY_ARCHIVOS y SMY_DOCUMENTOS_CLINICOS
        UPDATE smy_archivos a
           SET a.id_estado_archivo              = 2,
               a.fecha_eliminacion              = f_fecha_actual,
               a.id_usuario_eliminacion         = p_id_usuario,
               a.fecha_ultima_modificacion      = f_fecha_actual,
               a.id_usuario_ultima_modificacion = p_id_usuario
         WHERE EXISTS (
             SELECT 1
               FROM smy_documentos_clinicos d
              WHERE d.id = p_id_documento_clinico
                AND a.tabla_origen = 'SMY_DOCUMENTOS_CLINICOS'
                AND a.id_registro_origen = d.id
         );
        -- Sin COMMIT; el commit pertenece al orquestador pkgln_
    END pr_desvincular_archivos_doc;

END PKGCN_ARCHIVOS;
/
