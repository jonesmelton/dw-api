(declare-project
  :name "dw-api"
  :description "api for basic info about discworld mud"
  :source ["src"]
  :dependencies [
                 "https://github.com/janet-lang/spork"
                 "https://github.com/joy-framework/joy"
                 "https://github.com/jonesmelton/suresql"
                 "https://github.com/jonesmelton/sqlite3"
                 "https://github.com/pyrmont/testament"
                 ])

(task "format" []
      (os/shell "./scripts/janet-format src/*.janet"))

(task "dev" []
      (os/shell "find src public | entr -r janet src/main.janet"))

(task "repl:start" []
      (os/shell "scripts/janet-netrepl src/main.janet"))

(task "repl:connect" []
      (os/shell "scripts/janet-netrepl -c"))

(task "docker:build" []
      (os/shell `
    docker build \
    --build-arg USER=$(whoami) \
    --build-arg UID=1001 \
    --build-arg GID=1001 \
    -t dw-api .`
                ))

(task "docker:run" []
      (os/shell "docker run -dp 31311:8080 dw-api"))

(task "docker:shell" []
      (os/shell "docker exec -it dw-api bash"))

(task "mudclient:run" []
      (os/shell "npx parcel public/client.html"))

(declare-executable
  :name "serve"
  :entry "src/main.janet")
