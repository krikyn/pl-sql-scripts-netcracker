create TABLE users
(
  id   integer primary key,
  first_name varchar2(20),
  second_name varchar2(20)
);
/
create SEQUENCE user_sequence
    MINVALUE 10
    MAXVALUE 100000
    START WITH 10
    INCREMENT BY 10
    CACHE 20;
/
create or replace TRIGGER users_trigger
  BEFORE INSERT
  ON users
  FOR EACH ROW
  DECLARE
  BEGIN
    :new.id := user_sequence.nextval;
  END users_trigger;
/
insert into users (first_name, second_name) values ('Kirill', 'Vakhrushev');
insert into users (first_name, second_name) values ('Oleg', 'Ergaev');
insert into users (first_name, second_name) values ('Alexander', 'Glomozda');
/
select * from users;