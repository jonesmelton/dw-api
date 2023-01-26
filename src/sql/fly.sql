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
     , area
  from flyable_npcs
 where full_name
       like '%' || :term || '%';

--name: find-by-any
  select highlight(flyable_fts, 0, '<span class=highlight>', '</span>')
      as short_name
       , highlight(flyable_fts, 1, '<span class=highlight>', '</span>')
      as full_name
       , highlight(flyable_fts, 2, '<span class=highlight>', '</span>')
      as location
       , area
       , rank
    from flyable_fts
   where flyable_fts
   match :term
     and rank
   match 'bm25(3.0, 2.0)'
order by rank;
