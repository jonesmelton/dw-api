-- name: find-gatherable
   select i.item_name
        , i.room_id
        , r.room_short
        , m.display_name
        , m.domain
        , count(*)
          over (partition by domain)
          as area_count
     from rooms r
left join shop_items i
    using (room_id)
left join maps m
    using (map_id)
    where sale_price is 'gather'
      and i.item_name
          like '%'|| :term ||'%'
 order by i.item_name, domain;

-- name: create-index-gatherable-items
create index
       if not exists
       gatherable_items
    on shop_items
       (item_name)
 where sale_price
       is 'gather';
