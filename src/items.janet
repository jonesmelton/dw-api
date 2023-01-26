(import suresql :as sure)

(defn search [request]
  (def qfns (sure/defqueries "src/sql/items.sql"
                             {:connection (dyn :db/connection)}))

  (let [q (get-in request [:query-string :q] "")
        items ((qfns :find-gatherable) {:term q})
        counts (->> items
                    (reduce
                      (fn [acc el]
                        (put acc (string/ascii-lower (el :domain))
                             (el :area_count))) @{})
                    (pairs)
                    (sorted-by (fn [[area _]] area)))]

    (def location-count-results [:div {:id "location-counts"}
                                 (map (fn [[area count]]
                                        [:div [:p area] [:p count]])
                                      counts)])

    (def item-search-results [:div {:id "search-results"}
                              [:table {}
                               [:tr [:th "item"] [:th "room"] [:th "map"] [:th "area"]]
                               (map (fn [item] [:tr
                                                [:td (item :item_name)]
                                                [:td {:class "roominfo" :id (item :room_id)
                                                      :hx-get (string "/rooms/" (item :room_id))
                                                      :hx-trigger "click" :hx-swap "none"
                                                      :hx-filter "#map-container"
                                                      :hx-select-oob "#map-container"}
                                                 (item :room_short)]
                                                [:td (item :display_name)]
                                                [:td (item :domain)]])
                                    items)]])
    [location-count-results item-search-results]))

(defn maps-by-id [request]
  (defn offset-style [x-pos y-pos]
    `calculates position based on offset\
   then returns the styles for the image`
    (let [x (+ (- x-pos) 250)
          y (+ (- y-pos) 250)]
      (string/format `object-fit: none;
                      object-position: %dpx %dpx;`
                     x y)))

  (def qfns (sure/defqueries "src/sql/maps.sql"
                             {:connection (dyn :db/connection)}))

  (let [id (get-in request [:params :id])
        room ((qfns :find-room) {:id id})
        {:display_name name
         :domain region
         :filename filename
         :room_short desc
         :xpos x :ypos y} room
        url (string "/maps/" filename)
        style (offset-style x y)]

    [:div {:id "map-container"}
     [:figure
      [:span {:id "heredot"}]
      [:figcaption
       [:p {:id "room-short"} desc]
       [:p {:id "map-name"} name]]
      [:img {:src url :alt name
             :height 500 :width 500
             :style style}]]]))

(defn search-field [request]
  [:div {:id "page-container"}
   [:div {:id "search-container"}

    [:div {:class "search-bar"}

     [:label {:for "q"} "gatherable item search"
      [:img {:class "htmx-indicator" :id "load-indicator"
             :height "40px" :width "40px"
             :src "/images/puff.svg"}]]

     [:input {:type "text" :name "q"
              :id "search-input"
              :hx-get "/items/search" :hx-swap "outerHTML"
              :hx-trigger "keyup delay:80ms changed"
              :hx-select "#search-results"
              :hx-target "#search-results"
              :hx-select-oob "#location-counts"
              :hx-indicator "#load-indicator"
              :placeholder "item"}]
     [:div {:id "location-counts"}]]
    (maps-by-id {:params {:id "4b11616f93c94e3c766bb5ad9cba3b61dcc73979"}})]

   [:div {:id "search-results"}]])
