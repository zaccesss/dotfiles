# =============================================================================
# Database CLI shortcuts
# =============================================================================

pgconn() {
    local db="${1:-postgres}"
    local host="${2:-localhost}"
    psql -h "$host" -d "$db"
}
alias pgls="psql -l"
alias pgdump="pg_dump"
alias pgrestore="pg_restore"
alias pgusers="psql -c '\du'"
alias pgsize="psql -c '\l+'"
# pgkill: terminate all other connections to a db - needed before a drop or restore,
# Postgres refuses both while any other session still holds the database open
pgkill() {
    local db="${1:?Usage: pgkill <db>}"
    psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db' AND pid <> pg_backend_pid();"
}

myconn() {
    local db="${1:-}"
    local user="${2:-root}"
    mysql -u "$user" -p ${db:+-D "$db"}
}
alias myls="mysql -e 'SHOW DATABASES;'"
alias mydump="mysqldump"
myrestore() {
    local db="${1:?Usage: myrestore <db> <dump.sql>}"
    local file="${2:?Usage: myrestore <db> <dump.sql>}"
    mysql -u root -p "$db" < "$file"
}

alias sq="sqlite3"
sqnew() { sqlite3 "${1:?Usage: sqnew <filename.db>}"; }
sqls() { sqlite3 "${1:?Usage: sqls <file.db>}" ".tables"; }
sqschema() { sqlite3 "${1:?Usage: sqschema <file.db>}" ".schema"; }
sqdump() { sqlite3 "${1:?Usage: sqdump <file.db> [out.sql]}" ".dump" > "${2:-${1%.db}.sql}"; }

alias rcli="redis-cli"
alias rping="redis-cli ping"
alias rflush="redis-cli FLUSHALL"
alias rmon="redis-cli MONITOR"
alias rkeys="redis-cli KEYS '*'"
alias rinfo="redis-cli INFO"
alias rsize="redis-cli DBSIZE"
rdel() { redis-cli DEL "${1:?Usage: rdel <key>}"; }

alias mconn="mongosh"
alias mdbs="mongosh --eval 'db.adminCommand({listDatabases: 1})'"
mdump() { mongodump --db "${1:?Usage: mdump <db>}"; }
mrestoredb() { mongorestore --db "${1:?Usage: mrestoredb <db> <dump-dir>}" "${2:?}"; }

