create or replace view calendar as
  select
    case 
        when dimen = 0 then to_char(d1, 'DY') 
        when trunc(sysdate, 'mm') <> trunc(d1, 'mm')then to_char(d1, '/' || 'dd' || '/')
        when trunc(sysdate) = d1 then '[' || to_char(d1, 'dd') || ']'
            else to_char(d1, ' dd')
    end d1,
    case 
        when dimen = 0 then to_char(d2, ' DY')
        when trunc(sysdate, 'mm') <> trunc(d2, 'mm') then to_char(d2, '/' || 'dd' || '/')
        when trunc(sysdate) = d2 then '[' || to_char(d2, 'dd') || ']'
            else to_char(d2, 'dd')
    end d2,
    case 
        when dimen = 0 then to_char(d3, ' DY')
        when trunc(sysdate, 'mm') <> trunc(d3, 'mm') then to_char(d3, '/' || 'dd' || '/')
        when trunc(sysdate) = d3 then '[' || to_char(d3, 'dd') || ']'
            else to_char(d3, ' dd')
    end d3,
    case 
        when dimen = 0 then to_char(d4, ' DY')
        when trunc(sysdate, 'mm') <> trunc(d4, 'mm') then to_char(d4, '/' || 'dd' || '/')
        when trunc(sysdate) = d4 then '[' || to_char(d4, 'dd') || ']'
            else to_char(d4, ' dd')
    end d4,
    case 
        when dimen = 0 then to_char(d5, ' DY')
        when trunc(sysdate, 'mm') <> trunc(d5, 'mm') then to_char(d5, '/' || 'dd' || '/')
        when trunc(sysdate) = d5 then '[' || to_char(d5, 'dd') || ']'
            else to_char(d5, ' dd')
    end d5,
    case 
        when dimen = 0 then to_char(d6, ' DY')
        when trunc(sysdate, 'mm') <> trunc(d6, 'mm') then to_char(d6, '/' || 'dd' || '/')
        when trunc(sysdate) = d6 then '[' || to_char(d6, 'dd') || ']'
            else to_char(d6, ' dd')
    end d6,
    case 
        when dimen = 0 then to_char(d7, ' DY')
        when trunc(sysdate, 'mm') <> trunc(d7, 'mm') then to_char(d7, '/' || 'dd' || '/')
        when trunc(sysdate) = d7 then '[' || to_char(d7, 'dd') || ']'
            else to_char(d7, ' dd')
    end d7
  from dual
  model
  dimension by (0 dimen)
  measures (cast(null as date) d1, cast(null as date) d2, cast(null as date) d3, cast(null as date) d4, cast(null as date) d5,
    cast(null as date) d6, cast(null as date) d7) rules iterate (7) until (d7[iteration_number] > last_day(sysdate))
    (d1[iteration_number]=trunc(sysdate, 'mm') - to_char(trunc(sysdate, 'mm'), 'd') + 1 + 7 * (iteration_number - 1),
    
    d2[iteration_number]=d1[CV()] + 1,
    d3[iteration_number]=d1[CV()] + 2,
    d4[iteration_number]=d1[CV()] + 3,
    d5[iteration_number]=d1[CV()] + 4,
    d6[iteration_number]=d1[CV()] + 5,
    d7[iteration_number]=d1[CV()] + 6)
/
select * from calendar;