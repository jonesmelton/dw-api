(import joy)
(import suresql :as sure)
(import ./fly)
(import ./items)

(defn app-layout [{:body body :request request}]
  (joy/text/html
    (joy/doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "joy-server"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (joy/csrf-token-value request)}]
      [:link {:href "/css/main.css" :rel "stylesheet"}]
      [:script {:src "/js/hyperscript.js" :defer ""}]
      [:script {:src "/js/htmx.min.js" :defer ""}]
      [:script {:src "/js/app.js" :defer ""}]]
     [:body body]]))

(import spork/json :as json)

(defn index [request]
  [:div {:id "page-container"} [:h1 "witch stuff"]
   [:ul
    [:li [:a {:href "/items"} [:h2 "gatherable item search"]]]
    [:li [:a {:href "/npcs"} [:h2 "flyable npc search"]]]]])

(joy/defroutes app-routes
               [:get "/" index]
               [:get "/npcs" fly/search-bar]
               [:get "/npcs/fly" fly/handle-search]
               [:get "/items" items/search-field]
               [:get "/items/search" items/search]
               [:get "/rooms/:id" items/maps-by-id])

(def app (-> (joy/handler app-routes)
             (joy/layout app-layout)
             (joy/with-csrf-token)
             (joy/with-session)
             (joy/extra-methods)
             (joy/query-string)
             (joy/body-parser)
             (joy/json-body-parser)
             (joy/server-error)
             (joy/x-headers)
             (joy/static-files)
             (joy/not-found)
             (joy/logger)))

(defn main [& args]
  (setdyn :pretty-format "%.4Q")
  (joy/db/connect)
  (def qfns (sure/defqueries "src/sql/connect.sql"
                             {:connection (dyn :db/connection)}))
  ((qfns :attach-quow))
  ((qfns :set-journal))
  ((qfns :set-safety))

  (joy/server app 8080 "0.0.0.0")
  (joy/db/disconnect))
