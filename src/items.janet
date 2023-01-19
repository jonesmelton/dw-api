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
    [:table {}
     [:tr [:th "item"]]
     (map (fn [item] [:tr [:td (item :item_name)]]) items)]))
