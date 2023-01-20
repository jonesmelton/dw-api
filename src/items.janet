(import suresql :as sure)

(defn search [request]
  (def qfns (sure/defqueries "db/items.sql"
                             {:connection (dyn :db/connection)}))

  (def q (get-in request [:query-string :q] ""))
  (def items ((qfns :find-gatherable) {:term q}))
  (def counts (->> items
                   (reduce
                     (fn [acc el]
                       (put acc (string/ascii-lower (el :domain))
                            (el :area_count))) @{})
                   (pairs)
                   (sorted-by (fn [[area _]] area))))

  [:div {:id "page-container"}
   [:div {:id "search-container"}
    [:div {:class "location-counts"}
     (when q
       (map (fn [[area count]] [:div [:p area] [:p count]]) counts))]
    [:div {:class "search-bar"}
     [:label {:for "q"} "item search:"]
     [:div {:id "load-indicator"}
      [:img {:class "htmx-indicator" :src "/images/puff.svg"}]]
     [:input {:type "text" :name "q"
              :id "search-input" :value (or q "")
              :hx-get "/items/search" :hx-swap "outerHTML"
              :hx-trigger "keyup delay:80ms changed"
              :hx-target "#page-container"
              :hx-indicator "#load-indicator"
              :placeholder " item"}]]]

   (when q [:div {:id "search-results"}
            [:table {}
             [:tr [:th "item"] [:th "room"] [:th "map"] [:th "area"]]
             (map (fn [item] [:tr
                              [:td (item :item_name)]
                              [:td {:class "roominfo"
                                    :hx-get (string "/rooms/" (item :room_id))
                                    :hx-trigger "click"}
                               (item :room_short)]
                              [:td (item :display_name)]
                              [:td (item :domain)]])
                  items)]])])

(defn maps-by-id [request]
  (def qfns (sure/defqueries "db/maps.sql"
                             {:connection (dyn :db/connection)}))
  (let [id (get-in request [:params :id])]
    (def room ((qfns :find-room) {:id id}))
    [:div (string ;(kvs room))]))
