-- name: find-gatherable
select item_name
  from quow.shop_items
 where sale_price
       is 'gather'
   and item_name
       like '%' || :term || '%';
