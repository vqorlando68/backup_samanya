CREATE OR REPLACE FUNCTION F_FECHA_ACTUAL 
    RETURN DATE
IS
    l_date      date;
BEGIN
    SELECT (SYSTIMESTAMP AT TIME ZONE 'America/Bogota') INTO l_date
      FROM DUAL;
    RETURN l_date;
END f_fecha_actual;
/
