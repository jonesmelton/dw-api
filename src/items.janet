(import joy/html :as html)
(import suresql :as sure)

(defn search [request]
  (def qfns (sure/defqueries "src/sql/items.sql"
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
    [:div {:id "area-results"}
     [:div {:class "location-counts"}
      (when q
        (map (fn [[area count]] [:div [:p area] [:p count]]) counts))]

     [:div {:id "map-container"} [:div]]]

    [:div {:class "search-bar"}
     [:label {:for "q"} "item search:"]

     [:input {:type "text" :name "q"
              :id "search-input" :value (or q "")
              :hx-get "/items/search" :hx-swap "outerHTML"
              :hx-trigger "keyup delay:80ms changed"
              :hx-target "#page-container"
              :hx-indicator "#load-indicator"
              :placeholder " item"}]
     [:div {:id "load-indicator"}
      [:img {:class "htmx-indicator" :src "/images/puff.svg"}]]]]

   (when q [:div {:id "search-results"}
            [:table {}
             [:tr [:th "item"] [:th "room"] [:th "map"] [:th "area"]]
             (map (fn [item] [:tr
                              [:td (item :item_name)]
                              [:td {:class "roominfo"
                                    :hx-get (string "/rooms/" (item :room_id))
                                    :hx-trigger "click" :hx-swap "outerHTML"
                                    :hx-target "#map-container"}
                               (item :room_short)]
                              [:td (item :display_name)]
                              [:td (item :domain)]])
                  items)]])])

(defn maps-by-id [request]
  #(html/raw `<div style="background-color:blue;"></div>`)])
  (defn offset-style [x-pos y-pos]
    `calculates position based on offset\
   then returns the styles for the image`
    (let [x (+ (- x-pos) 200)
          y (+ (- y-pos) 200)]
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

    (print style)
    (pp room)
    [:div {:id "map-container"}
     [:figure
      [:figcaption
       [:p {:id "room-short"} desc]
       [:p {:id "map-name"} name]]
      [:img {:src url :alt name
             :height 400 :width 400
             :style style}]]]))
