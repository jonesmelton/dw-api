(import suresql :as sure)

(defn search-bar [request]
  [:div
   [:div {:class "search-bar"}
    [:p "item search:"]
    [:input {:type "text" :name "q"
             :hx-get "/items/search"
             :hx-trigger "keyup delay:80ms changed"
             :hx-target "#search-results"
             :hx-swap "innerHTML"
             :placeholder "item"}]]
   [:div {:id "search-results"}]])

(defn handle-search [request]

  (def qfns (sure/defqueries "db/items.sql"
                             {:connection (dyn :db/connection)}))

  (let [q (get-in request [:query-string :q])
        items ((qfns :find-gatherable) {:term q})]
    (def counts (->> items
                     (reduce
                       (fn [acc el]
                         (put acc (string/ascii-lower (el :domain))
                              (el :area_count))) @{})
                     (pairs)
                     (sorted-by (fn [[area _]] area))))

    [:div
     [:div {:class "location-counts"}
      (map (fn [[area count]] [:div [:p area] [:p count]]) counts)]
     [:table {}
      [:tr [:th "item"] [:th "room"] [:th "map"] [:th "area"]]

      (map (fn [item] [:tr
                       [:td (item :item_name)]
                       [:td (item :room_short)]
                       [:td (item :display_name)]
                       [:td (item :domain)]])
           items)]]))
