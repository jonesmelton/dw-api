(import circlet)
(import sqlite3 :as sql)
(import spork/json :as json)

(defn handler
 "A simple HTTP server"
  [request]
  (def conn (sql/open "db/world.db"))
  (def npcs (sql/eval conn `select * from flyable_npcs`))
  (def template "<!doctype html><html><body><h1>%s</h1></body></html>")
 {:status 200
  :headers {"Content-Type" "text/html"}
  :body (string/format template (json/encode npcs))})

(defn main [&opt args]
  (circlet/server handler 3000 "0.0.0.0"))
