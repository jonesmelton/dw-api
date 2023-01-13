(declare-project
  :name "dw-api"
  :description "api for basic info about discworld mud"
  :source ["src"]
  :dependencies [
                 "https://github.com/janet-lang/spork"
                 "https://github.com/janet-lang/sqlite3"
                 "https://github.com/joy-framework/suresql"
                 "https://github.com/pyrmont/testament"
                 "https://github.com/janet-lang/circlet"
                 ])

(task "docker:build" []
      (os/shell `
    docker build \
    --build-arg USER=$(whoami) \
    --build-arg UID=1001 \
    --build-arg GID=1001 \
    -t dw-api .`
                ))

(task "docker:run" []
      (os/shell "docker run -dp 3000:3000 dw-api"))

(declare-executable
  :name "serve"
  :entry "src/main.janet")
