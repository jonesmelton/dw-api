(import spork/htmlgen :prefix "")
(import suresql :as sure)
(import sqlite3 :as sql)

(sure/defqueries "db/fly.sql"
                 {:connection (sql/open "db/world.db")})

(def search
  (html
    [:div
     [:div {:class "search-bar"}
      [:p "flyable npc search:"]
      [:input {:type "text" :name "q"
               :hx-get "/fly"
               :hx-trigger "keyup delay:80ms changed"
               :hx-target "#search-results"
               :hx-swap "innerHTML"
               :placeholder "npc"}]]
     [:div {:id "search-results"}]]))

(defn handle-search [req]
  (let [params (req :params)
        q (params "q")
        npcs (find-in-all {:term q})]

    {:status 200
     :body
     (html
       [:table {}
        [:tr [:th "short name"] [:th "location"] [:th "full name"]]
        (map (fn [npc] [:tr [:td (npc :short_name)] [:td (npc :location)] [:td (npc :full_name)]]) npcs)])}))
