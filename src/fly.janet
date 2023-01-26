(import suresql :as sure)

(defn search-bar [request]
  [:div {:id "page-container"}
   [:div {:id "search-container"}
   [:div {:class "search-bar"}
    [:img {:class "htmx-indicator" :id "load-indicator"
             :height "40px" :width "40px"
             :src "/images/puff.svg"}]
    [:label {:for "q"} "flyable npc search"]
     [:input {:type "text" :name "q"
              :hx-get "/npcs/fly"
              :hx-trigger "keyup delay:80ms changed"
              :hx-select "#npc-search-results"
              :hx-target "#npc-search-results"
              :hx-swap "outerHTML"
              :placeholder "npc"}]]]
   [:div {:id "npc-search-results"}]])

(defn handle-search [req]
  (def qfns (sure/defqueries "src/sql/fly.sql"
                             {:connection (dyn :db/connection)}))
  (let [q (get-in req [:query-string :q] nil)
        finder (qfns :find-in-all)]
    (def npcs (or (finder {:term q}) []))
    [:div {:id "npc-search-results"}
     [:table {}
      [:tr [:th "short name"] [:th "location"] [:th "full name"]]
      (map (fn [npc] [:tr [:td (npc :short_name)] [:td (npc :location)] [:td (npc :full_name)]]) npcs)]]))
