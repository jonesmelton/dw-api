--name: create-flyable_npcs
      create table if not exists
      flyable_npcs (
         full_name text
       ,short_name text
         ,location text
       ,stationary boolean
             ,area text
             ,note text
                   );

--name: create-maps
 create table if not exists
        maps (
       map_id integer
    ,filename text
,display_name text
      ,domain text
              );

--name: find-in-all
select location
     , short_name
     , full_name
  from flyable_npcs
 where full_name
       like '%' || :term || '%';
