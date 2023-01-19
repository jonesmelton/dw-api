-- name: find-room
-- fn: first
   select room_short
        , map_id
        , xpos
        , ypos
        , filename
        , display_name
        , domain
     from rooms
left join maps
    using (map_id)
    where room_id
          is :id;
