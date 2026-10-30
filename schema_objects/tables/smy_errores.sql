CREATE TABLE SMY_ERRORES 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"TIPO" VARCHAR2(1) COLLATE "USING_NLS_COMP" DEFAULT 'E' NOT NULL ENABLE, 
	"NOMBRE_PROGRAMA" VARCHAR2(50) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"NOMBRE_METODO" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"PARAMETROS" CLOB COLLATE "USING_NLS_COMP", 
	"DIRECCION_IP" VARCHAR2(30) COLLATE "USING_NLS_COMP", 
	"USUARIO" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"CODIGO_ERROR" VARCHAR2(100) COLLATE "USING_NLS_COMP", 
	"TEXTO_ERROR" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"MENSAJE_ERROR" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"FECHA_CREACION" DATE DEFAULT CAST(systimestamp AT TIME ZONE '-05:00' AS DATE), 
	"ID_USUARIO_CREACION" NUMBER, 
	 CONSTRAINT "PK_SMY_ERRORES" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP" ;

COMMENT ON TABLE SMY_ERRORES IS 'Bitácora centralizada para captura, diagnóstico y auditoría forense de excepciones y errores del sistema.';
COMMENT ON COLUMN SMY_ERRORES.CODIGO_ERROR IS 'Código técnico de error retornado por la base de datos (ej. ORA-XXXXX) o aplicación.';
COMMENT ON COLUMN SMY_ERRORES.DIRECCION_IP IS 'Dirección IP del cliente, dispositivo o servidor solicitante.';
COMMENT ON COLUMN SMY_ERRORES.FECHA_CREACION IS 'Fecha y hora de registro en base de datos con zona horaria legal de Bogotá (UTC-5).';
COMMENT ON COLUMN SMY_ERRORES.ID IS 'Identificador único y clave primaria de la tabla SMY_ERRORES.';
COMMENT ON COLUMN SMY_ERRORES.ID_USUARIO_CREACION IS 'Identificador del usuario que originó o registró el evento.';
COMMENT ON COLUMN SMY_ERRORES.MENSAJE_ERROR IS 'Mensaje de error procesado y comprensible para el usuario o soporte funcional.';
COMMENT ON COLUMN SMY_ERRORES.NOMBRE_METODO IS 'Nombre descriptivo único correspondiente a: metodo.';
COMMENT ON COLUMN SMY_ERRORES.NOMBRE_PROGRAMA IS 'Nombre descriptivo único correspondiente a: programa.';
COMMENT ON COLUMN SMY_ERRORES.PARAMETROS IS 'Parámetros de entrada o payload serializado (JSON/texto) presente en la solicitud fallida.';
COMMENT ON COLUMN SMY_ERRORES.TEXTO_ERROR IS 'Traza técnica detallada del error, stack trace o mensaje técnico del motor/servidor.';
COMMENT ON COLUMN SMY_ERRORES.TIPO IS 'Tipo o severidad del registro (''E''=Error, ''W''=Advertencia, ''I''=Información).';
COMMENT ON COLUMN SMY_ERRORES.USUARIO IS 'Nombre de usuario o login de la cuenta activa al momento de la falla.';
