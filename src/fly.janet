(import spork/htmlgen :prefix "")
(import suresql :as sure)

(defn search-bar [request]
  [:div
   [:div {:class "search-bar"}
    [:p "flyable npc search:"]
    [:input {:type "text" :name "q"
             :hx-get "/npcs/fly"
             :hx-trigger "keyup delay:80ms changed"
             :hx-target "#search-results"
             :hx-swap "innerHTML"
             :placeholder "npc"}]]
   [:div {:id "search-results"}]])

(defn handle-search [req]
  (def qfns (sure/defqueries "db/fly.sql"
                             {:connection (dyn :db/connection)}))
  (let [q (get-in req [:query-string :q] nil)
        finder (qfns :find-in-all)]
    (def npcs (or (finder {:term q}) []))
    [:table {}
     [:tr [:th "short name"] [:th "location"] [:th "full name"]]
     (map (fn [npc] [:tr [:td (npc :short_name)] [:td (npc :location)] [:td (npc :full_name)]]) npcs)]))
