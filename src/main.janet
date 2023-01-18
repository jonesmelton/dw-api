(import circlet)
(import sqlite3 :as sql)
(import spork/http :as http)
(import suresql :as sure)
(import ./index :as index)

(def head (file/open "assets/head.html"))
(def template (file/read head :all))
(file/close head)

(defn params
  "parses query string"
  [next]
  (fn [req]
    (let [params (first (peg/match
                          http/query-string-grammar
                          (req :query-string)))]
      (next (merge req {:params params})))))

(defn render [view]
  (string template
          "<body>"
          view
          "</body>"
          "</html>"))

(defn default-handler
  "A simple HTTP server"
  [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "nothin"})

(def routes (circlet/router
              {"/test" {:status 200
                        :body (render index/search)}
               "/fly" index/handle-search
               "/css/main.css" {:kind :file :file "assets/css/main.css" :mime "text/css"}
               "/js/htmx.js" {:kind :file :file "assets/htmx.min.js" :mime "application/javascript"}
               :default default-handler}))

(defn dyn_mw
  `circlet wipes dyns and suresql only sets fns as global dyns.
   ridiculous hack, consider PR to suresql to return locals also/instead`
  [next]
  (sure/defqueries "db/fly.sql"
                   {:connection (sql/open "db/world.db")})

  (def find-in-all ((dyn 'find-in-all) :value))
  (def dyns {:context find-in-all})
  (fn [req]
    (next (merge req dyns))))

(defn main [&opt args]
  (circlet/server (->
                    routes
                    dyn_mw
                    params
                    circlet/logger) 8080 "0.0.0.0"))
