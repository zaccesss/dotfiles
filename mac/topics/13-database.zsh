# =============================================================================
# Database CLI shortcuts
# Quick connect aliases and common operations for every database I use.
# Connection strings read from environment variables where possible so
# credentials never live in this file.
# =============================================================================

# PostgreSQL
# pgconn: connect to a local or remote Postgres instance
# Usage: pgconn mydb  or  pgconn mydb user@host
pgconn() {
    local db="${1:-postgres}"
    local host="${2:-localhost}"
    psql -h "$host" -d "$db"
}
alias pgls="psql -l"                          # list all databases
alias pgdump="pg_dump"                        # dump a database
alias pgrestore="pg_restore"                  # restore from a dump
alias pgusers="psql -c '\du'"                 # list all users/roles
alias pgsize="psql -c '\l+'"                  # list databases with sizes
# pgkill: terminate all other connections to a db - needed before a drop or restore,
# Postgres refuses both while any other session still holds the database open
pgkill() {
    local db="${1:?Usage: pgkill <db>}"
    psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db' AND pid <> pg_backend_pid();"
}

# MySQL / MariaDB
# myconn: connect to a local MySQL instance
myconn() {
    local db="${1:-}"
    local user="${2:-root}"
    mysql -u "$user" -p ${db:+-D "$db"}
}
alias myls="mysql -e 'SHOW DATABASES;'"
alias mydump="mysqldump"
# myrestore: restore a database from a mysqldump file
# Usage: myrestore mydb dump.sql
myrestore() {
    local db="${1:?Usage: myrestore <db> <dump.sql>}"
    local file="${2:?Usage: myrestore <db> <dump.sql>}"
    mysql -u root -p "$db" < "$file"
}

# SQLite
alias sq="sqlite3"
# sqnew: create and open a new SQLite database
sqnew() { sqlite3 "${1:?Usage: sqnew <filename.db}"; }
# sqls: list all tables in a SQLite database
sqls() { sqlite3 "${1:?Usage: sqls <file.db>}" ".tables"; }
# sqschema: show schema of a SQLite database
sqschema() { sqlite3 "${1:?Usage: sqschema <file.db>}" ".schema"; }
# sqdump: export a SQLite database to a plain-text .sql file
sqdump() { sqlite3 "${1:?Usage: sqdump <file.db> [out.sql]}" ".dump" > "${2:-${1%.db}.sql}"; }

# Redis
alias rcli="redis-cli"
alias rping="redis-cli ping"
alias rflush="redis-cli FLUSHALL"
alias rmon="redis-cli MONITOR"
alias rkeys="redis-cli KEYS '*'"
alias rinfo="redis-cli INFO"
alias rsize="redis-cli DBSIZE"
rdel() { redis-cli DEL "${1:?Usage: rdel <key>}"; }

# MongoDB (mongosh)
alias mconn="mongosh"
alias mdbs="mongosh --eval 'db.adminCommand({listDatabases: 1})'"
# mdump: dump a database with mongodump (writes to ./dump by default)
mdump() { mongodump --db "${1:?Usage: mdump <db>}"; }
# mrestoredb: restore a database from a mongodump directory
mrestoredb() { mongorestore --db "${1:?Usage: mrestoredb <db> <dump-dir>}" "${2:?}"; }

# InfluxDB (useful for time-series data from hardware/IoT sensors)
