(import circlet)
(import sqlite3 :as sql)
(import spork/http :as http)

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

(defn main [&opt args]
  (circlet/server (->
                    routes
                    params
                    circlet/logger) 8080 "0.0.0.0"))
