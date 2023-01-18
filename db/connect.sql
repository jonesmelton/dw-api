-- name: attach-quow
begin transaction;
attach 'db/quow.db' as quow;
pragma cache_size = 20000;
commit;

-- name: set-journal
pragma journal_mode = wal

-- name: set-safety
pragma synchronous = normal
