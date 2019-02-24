DROP TABLE attr_binds;
DROP TABLE attributes;
DROP TABLE attr_groups;
DROP TABLE attr_types;
DROP TABLE referencess;
DROP TABLE params;
DROP TABLE objects;
DROP TABLE object_types;

/

/*
  Скрипты для создания всех таблиц и добавления в них запесей
*/

CREATE TABLE object_types (
  object_type_id NUMBER PRIMARY KEY,
  parent_id      NUMBER,
  name           VARCHAR2(50) UNIQUE,
  description    VARCHAR2(50),
  properties     VARCHAR2(50),
  FOREIGN KEY (parent_id)
  REFERENCES object_types (object_type_id)
);

insert into object_types
values (1, null, 'Computer', 'Обычный компьютер', 'Настольный');
insert into object_types
values (2, null, 'Printer', 'Принтер', 'Обычный');
insert into object_types
values (3, 2, 'Inkjet Printer', 'Струйный принтер', 'Новый');
insert into object_types
values (4, null, 'Head', 'Головка принтера', 'Стандартная');
insert into object_types
values (5, null, 'ImageSetter', 'Фотонаборный автомат', 'Стандартный');

CREATE TABLE objects (
  object_id      NUMBER PRIMARY KEY,
  parent_id      NUMBER,
  object_type_id NUMBER,
  name           VARCHAR2(50),
  description    VARCHAR2(50),
  order_number   NUMBER,
  FOREIGN KEY (parent_id)
  REFERENCES objects (object_id),
  FOREIGN KEY (object_type_id)
  REFERENCES object_types (object_type_id)
);

insert into objects
values (1, null, 1, 'MyComp', 'HP ENVY_15', 1);
insert into objects
values (2, null, 3, 'MypRrinter', 'HP ENVY_15', 4);
insert into objects
values (3, null, 4, 'Head1', 'RW0354', 2);
insert into objects
values (4, null, 4, 'Head2', 'RW0355', 3);

CREATE TABLE attr_types (
  attr_type_id NUMBER PRIMARY KEY,
  name         VARCHAR2(50),
  properties   VARCHAR2(50)
);

insert into attr_types
values (1, 'Dots per Inch', '');
insert into attr_types
values (2, 'Pages per Minute', '');
insert into attr_types
values (3, 'Name', '');
insert into attr_types
values (4, 'Number of Colors', '');
insert into attr_types
values (5, 'Object reference', '');

CREATE TABLE attr_groups (
  attr_group_id NUMBER PRIMARY KEY,
  name          VARCHAR2(50),
  properties    VARCHAR2(50)
);

insert into attr_groups
values (1, 'General attributes', '');
insert into attr_groups
values (2, 'Printers attributes', '');
insert into attr_groups
values (3, 'References', '');

CREATE TABLE attributes (
  attr_id       NUMBER PRIMARY KEY,
  attr_type_id  NUMBER,
  attr_group_id NUMBER,
  name          VARCHAR2(50),
  description   VARCHAR2(50),
  ismultiple    NUMBER(1),
  properties    VARCHAR2(50),
  UNIQUE (attr_id,
          name),
  FOREIGN KEY (attr_type_id)
  REFERENCES attr_types (attr_type_id),
  FOREIGN KEY (attr_group_id)
  REFERENCES attr_groups (attr_group_id)
);

insert into attributes
values (1, 1, 1, 'dpi', 'Dots per Inch in the screen or image', 0, '');
insert into attributes
values (2, 2, 2, 'ppm', 'Pages per Minute', 0, '');
insert into attributes
values (3, 3, 1, 'networkName', 'Name of a network', 0, '');
insert into attributes
values (4, 5, 3, 'Computer-Printer', 'Link', 0, '');
insert into attributes
values (5, 4, 2, 'colorsCount', 'num of colors', 0, '');

CREATE TABLE params (
  attr_id    NUMBER NOT NULL,
  object_id  NUMBER NOT NULL,
  value      VARCHAR2(50),
  date_value DATE,
  show_order NUMBER,
  FOREIGN KEY (attr_id)
  REFERENCES attributes (attr_id)
  ON DELETE CASCADE,
  FOREIGN KEY (object_id)
  REFERENCES objects (object_id)
  ON DELETE CASCADE
);

insert into params
values (3, 1, 'MyComp', null, 1);
insert into params
values (3, 1, 'Ivanov', null, 3);
insert into params
values (1, 2, '600', null, 2);
insert into params
values (2, 2, '12', null, 4);
insert into params
values (5, 3, '256', null, 5);

CREATE TABLE referencess (
  attr_id    NUMBER,
  object_id  NUMBER,
  reference  NUMBER,
  show_order NUMBER,
  FOREIGN KEY (attr_id)
  REFERENCES attributes (attr_id),
  FOREIGN KEY (object_id)
  REFERENCES objects (object_id),
  FOREIGN KEY (reference)
  REFERENCES objects (object_id)
);

insert into referencess
values (4, 1, 2, 1);

CREATE TABLE attr_binds (
  object_type_id NUMBER,
  attr_id        NUMBER,
  options        VARCHAR2(50),
  isrequired     NUMBER(1),
  default_value  VARCHAR2(50),
  PRIMARY KEY (object_type_id,
               attr_id),
  FOREIGN KEY (object_type_id)
  REFERENCES object_types (object_type_id),
  FOREIGN KEY (attr_id)
  REFERENCES attributes (attr_id)
);

insert into attr_binds
values (1, 1, 'Sreen dpi', 0, null);
insert into attr_binds
values (2, 1, 'Printer dpi', 0, null);

/

--1) Получение информации обо всех атрибутах(учитывая только атрибутную группу и атрибутные типы)(attr_id, attr_name, attr_group_id, attr_group_name, attr_type_id, attr_type_name)
SELECT ATTRIBUTES.ATTR_ID        as attr_id,
       ATTRIBUTES.NAME           as attr_name,
       attr_groups.ATTR_GROUP_ID as attr_group_id,
       attr_groups.NAME          as attr_group_name,
       attr_types.ATTR_TYPE_ID   as attr_type_id,
       attr_types.NAME           as attr_type_name
FROM ATTRIBUTES
       JOIN ATTR_TYPES attr_types ON ATTRIBUTES.ATTR_TYPE_ID = attr_types.ATTR_TYPE_ID
       JOIN ATTR_GROUPS attr_groups ON ATTRIBUTES.ATTR_GROUP_ID = attr_groups.ATTR_GROUP_ID;

--2) Получение всех атрибутов для заданного объектного типа, без учета наследования(attr_id, attr_name )
select attr_id as attr_id, name as attr_name
from ATTRIBUTES
where ATTR_ID = (select ATTR_ID from ATTR_BINDS where OBJECT_TYPE_ID = :object_type_id);

--3) Получение иерархии ОТ(объектных типов)  для заданного объектного типа(нужно получить иерархию наследования) (ot_id, ot_name, level)
select OBJECT_TYPE_ID as ot_id, NAME as ot_name, level
from OBJECT_TYPES
start with object_type_id = :type_id
connect by prior object_type_id = parent_id;

--4) Получение вложенности объектов для заданного объекта(нужно получить иерархию вложенности)(obj_id, obj_name, level)
select OBJECT_ID as obj_id, NAME as obj_name, level
from OBJECTS
start with object_id = :type_id
connect by prior object_id = parent_id;

--5) Получение объектов заданного объектного типа(учитывая только наследование ОТ)(ot_id, ot_name, obj_id, obj_name)
select OBJECT_TYPES.OBJECT_TYPE_ID as ot_id, OBJECT_TYPES.NAME as ot_name, obj.OBJECT_ID as obj_id, obj.NAME as obj_name
from OBJECT_TYPES
       JOIN OBJECTS obj ON OBJECT_TYPES.OBJECT_TYPE_ID = obj.OBJECT_ID
start with OBJECT_TYPES.OBJECT_TYPE_ID = :type_id
connect by prior OBJECT_TYPES.OBJECT_TYPE_ID = OBJECT_TYPES.parent_id;

--6) Получение значений всех атрибутов(всех возможных типов) для заданного объекта(без учета наследования ОТ)(attr_id, attr_name, value)

select ATTR_ID as attr_id, name as attr_name, VALUE as value
from params
       join attributes using (attr_id)
where object_id = :object_id
union all
select attributes.ATTR_ID as attr_id, ATTRIBUTES.name as attr_name, cast(reference as varchar2(255)) as number_value
from referencess
       join attributes attributes on referencess.attr_id = attributes.attr_id
where object_id = :object_id;

--7) Получение ссылок на заданный объект(все объекты, которые ссылаются на текущий)(ref_id, ref_name)
select OBJECT_ID, NAME
from REFERENCESS
       join objects using (object_id)
where object_id = :object_id;

--8) Получение значений всех атрибутов(всех возможных типов, без повторяющихся атрибутов) для заданного объекта( с учетом наследования ОТ) Вывести в виде см. п.6

select DISTINCT PARAMS.ATTR_ID as attr_id,
                MIN(attr.NAME) as attr_name,
                MIN(PARAMS.VALUE) as value
from PARAMS
       JOIN ATTRIBUTES attr ON attr.ATTR_ID = PARAMS.ATTR_ID
where OBJECT_ID IN (select obj.OBJECT_ID
                    from OBJECT_TYPES
                           JOIN OBJECTS obj ON OBJECT_TYPES.OBJECT_TYPE_ID = obj.OBJECT_ID
                    start with OBJECT_TYPES.object_type_id =
                               (select OBJECT_ID from OBJECTS where OBJECT_ID = :object_id)
                    connect by prior OBJECT_TYPES.object_type_id = OBJECT_TYPES.parent_id)
GROUP BY PARAMS.ATTR_ID
union all
select DISTINCT referencess.attr_id as attr_id, MIN(name) as attr_name, cast(MIN(reference) as varchar2(255)) as value
from referencess
       JOIN ATTRIBUTES attr ON attr.ATTR_ID = referencess.ATTR_ID
where OBJECT_ID IN (select obj.OBJECT_ID
                    from OBJECT_TYPES
                           JOIN OBJECTS obj ON OBJECT_TYPES.OBJECT_TYPE_ID = obj.OBJECT_ID
                    start with OBJECT_TYPES.object_type_id =
                               (select OBJECT_ID from OBJECTS where OBJECT_ID = :object_id)
                    connect by prior OBJECT_TYPES.object_type_id = OBJECT_TYPES.parent_id)
GROUP BY referencess.attr_id;