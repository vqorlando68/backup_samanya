CREATE OR REPLACE PACKAGE UTI_GE_EXCEPCIONES_PKG 
AS
    PROCEDURE p_grabar_log (pro_smy_errores IN OUT smy_errores%ROWTYPE);
END uti_ge_excepciones_pkg;
/
