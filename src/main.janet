(use joy)
(import sqlite3 :as sql)
(import suresql :as sure)
(import ./fly)

(defn app-layout [{:body body :request request}]
  (pp request)
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "joy-server"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (csrf-token-value request)}]
      [:link {:href "/css/main.css" :rel "stylesheet"}]
      [:script {:src "/htmx.min.js" :defer ""}]]
     [:body
      body]]))

(defroutes app-routes
  [:get "/npcs" fly/search-bar]
  [:get "/npcs/fly" fly/handle-search])

(def app (-> (handler app-routes)
             (layout app-layout)
             (with-csrf-token)
             (with-session)
             (extra-methods)
             (query-string)
             (body-parser)
             (json-body-parser)
             (server-error)
             (x-headers)
             (static-files)
             (not-found)
             (logger)))

(defn main [& args]
  (db/connect)
  (def qfns (sure/defqueries "db/connect.sql"
                             {:connection (dyn :db/connection)}))
  ((qfns :attach-quow))
  ((qfns :set-journal))
  ((qfns :set-safety))

  (server app 8080 "0.0.0.0")
  (db/disconnect))
