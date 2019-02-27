create or replace package PKG_OPERATIONS IS

    procedure make(table_name varchar2, row_name varchar2);

    procedure add_row(table_name VARCHAR2, row_values VARCHAR2, cols VARCHAR2 := null);

    procedure update_row(table_name VARCHAR2, new_name VARCHAR2, row_id VARCHAR2);

    procedure delete_row(table_name VARCHAR2, row_name VARCHAR2);

    procedure remove(table_name VARCHAR2);

end PKG_OPERATIONS;
/
create or replace PACKAGE BODY PKG_OPERATIONS IS

    procedure make(table_name varchar2, row_name varchar2) IS
        BEGIN
        execute immediate 'CREATE TABLE ' || table_name || '(' || row_name || ')';
    end make;
    
    procedure add_row(table_name VARCHAR2, row_values VARCHAR2, cols VARCHAR2 := null) 
        IS
        BEGIN
            execute immediate 'INSERT into ' || table_name || '(' || cols || ') VALUES' || '(' || row_values || ')';
            commit;
        END add_row;
    
    procedure update_row(table_name VARCHAR2, new_name VARCHAR2, row_id VARCHAR2) 
        IS
        BEGIN
            execute immediate 'UPDATE '|| table_name || ' SET ' || new_name || ' WHERE ' || row_id;
            commit;
        END update_row;
        
    procedure delete_row(table_name VARCHAR2, row_name VARCHAR2)
        IS
        BEGIN
            execute immediate 'DELETE from ' || table_name || ' WHERE ' || row_name;
        commit;
        END delete_row;
    
    procedure remove(table_name VARCHAR2)
        IS
        BEGIN
            execute immediate 'DROP TABLE ' || table_name;
        END remove;
END PKG_OPERATIONS;
/
BEGIN    
  PKG_OPERATIONS.make('my_contacts', 'id number(4), name varchar2(40)');
  PKG_OPERATIONS.add_row('my_contacts', '1,''Andrey Gavrilov''', 'id, name');
  PKG_OPERATIONS.update_row('my_contacts', 'name = ''Andrey A. Gavrilov''', 'id = 1');
  PKG_OPERATIONS.delete_row('my_contacts', 'name = ''Andrey A. Gavrilov''');
  PKG_OPERATIONS.remove('my_contacts');
END;