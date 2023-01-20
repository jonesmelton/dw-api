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
