(declare-project
  :name "dw-api"
  :description "api for basic info about discworld mud"
  :source ["src"]
  :dependencies [
                 "https://github.com/janet-lang/spork"
                 "https://github.com/jonesmelton/sqlite3"
                 "https://github.com/joy-framework/suresql"
                 "https://github.com/pyrmont/testament"
                 "https://github.com/janet-lang/circlet"
                 ])

(task "dev" []
      (os/shell "find src assets | entr -r janet src/main.janet"))

(task "docker:build" []
      (os/shell `
    docker build \
    --build-arg USER=$(whoami) \
    --build-arg UID=1001 \
    --build-arg GID=1001 \
    -t dw-api .`
                ))

(task "docker:run" []
      (os/shell "docker run -dp 31311:80 dw-api"))

(task "docker:shell" []
      (os/shell "docker exec -it dw-api bash"))

(declare-executable
  :name "serve"
  :entry "src/main.janet")
