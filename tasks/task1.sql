DROP FUNCTION findemployeesbydepartmentid;
/
DROP FUNCTION findemployeesbydepartmentidimplicitcursor;
/
DROP TYPE arrayofnames;
/
CREATE OR REPLACE TYPE arrayofnames IS TABLE OF VARCHAR2(20)
/
--explicit cursor
CREATE OR REPLACE FUNCTION findemployeesbydepartmentid (dep_id IN   NUMBER) RETURN arrayofnames
IS
    names arrayofnames;
    CURSOR crsr IS SELECT first_name FROM employees WHERE department_id = dep_id;
    EXCEPTION_NOT_FOUND_DEPARTMENT EXCEPTION;
BEGIN
    OPEN crsr;
    FETCH crsr BULK COLLECT INTO names;
    IF crsr%rowcount = 0 THEN
      RAISE EXCEPTION_NOT_FOUND_DEPARTMENT;
    END IF;
    CLOSE crsr;
    RETURN names;
EXCEPTION
    WHEN EXCEPTION_NOT_FOUND_DEPARTMENT THEN
        raise_application_error (-20000,'THIS DEPARTMENT DOES NOT EXIST');
END;
/
--implicit cursor
CREATE OR REPLACE FUNCTION findemplbydepartidimplcursor (dep_id IN   NUMBER) RETURN arrayofnames
IS
    names arrayofnames := arrayofnames();
    last_num NUMBER := 1;
    EXCEPTION_NOT_FOUND_DEPARTMENT EXCEPTION;
BEGIN
    FOR cur_line IN (SELECT first_name FROM employees WHERE department_id = dep_id)
    LOOP
        names.extend;
        names(last_num) := cur_line.first_name;
        last_num := last_num + 1;
    END LOOP;
    
    IF last_num = 1 THEN
      RAISE EXCEPTION_NOT_FOUND_DEPARTMENT;
    END IF;
    
    RETURN names;
EXCEPTION
    WHEN EXCEPTION_NOT_FOUND_DEPARTMENT THEN
        raise_application_error (-20000,'THIS DEPARTMENT DOES NOT EXIST');
END;
/ 
SET SERVEROUTPUT ON
BEGIN
	DBMS_OUTPUT.enable;
    FOR t IN (SELECT * FROM table(findemployeesbydepartmentid(60)))
    LOOP
        dbms_output.put_line(t.COLUMN_VALUE);
    END LOOP;
END;
/
select * from table(findemployeesbydepartmentid(60));
/
--test with nonexistent department
select * from table(findemployeesbydepartmentid(1));
/
--another implementation
select * from table(findemplbydepartidimplcursor(60));
/
--another implementation with nonexistent department
select * from table(findemplbydepartidimplcursor(1));
/