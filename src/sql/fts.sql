-- name: create-items-fts
begin transaction ;
create virtual table items_fts
               using fts5
                   ( item_name
                   , description
                   , special_find_note
                   , appraise_text
                   , content = items
                   , content_rowid = rowid
                   , tokenize = "trigram"
                   ) ;
insert into items_fts
          ( rowid
          , item_name
          , description
          , special_find_note
          , appraise_text
          )
     select rowid
          , item_name
          , description
          , special_find_note
          , appraise_text
       from items
      where true
          ;
commit;

-- name: create-flyable-fts
begin transaction;
create virtual table flyable_fts
               using fts5
                   ( short_name
                   , full_name
                   , location
                   , area
                   , note
                   , content = flyable_npcs
                   , content_rowid = rowid
                   , tokenize = "trigram"
                   ) ;
insert into flyable_fts
          ( rowid
          , short_name
          , full_name
          , location
          , area
          , note
          )
     select rowid
          , short_name
          , full_name
          , location
          , area
          , note
       from flyable_npcs
      where true
          ;
commit;
