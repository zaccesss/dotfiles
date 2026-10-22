# =============================================================================
# Database CLI shortcuts - Windows PowerShell
# =============================================================================

# $Host is a reserved PowerShell automatic variable (the host application) - the param
# is named $PgHost instead so it doesn't shadow it inside this function's scope
function pgconn {
    param([string]$Db = "postgres", [string]$PgHost = "localhost")
    psql -h $PgHost -d $Db
}
function pgls      { psql -l }
function pgdump    { pg_dump @args }
function pgrestore { pg_restore @args }
function pgusers   { psql -c '\du' }
function pgsize    { psql -c '\l+' }
# pgkill: terminate all other connections to a db - needed before a drop or restore,
# Postgres refuses both while any other session still holds the database open
function pgkill {
    param([string]$Db)
    psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$Db' AND pid <> pg_backend_pid();"
}

function myconn {
    param([string]$Db = "", [string]$User = "root")
    if ($Db) { mysql -u $User -p -D $Db } else { mysql -u $User -p }
}
function myls      { mysql -e "SHOW DATABASES;" }
function mydump    { mysqldump @args }
function myrestore {
    param([string]$Db, [string]$File)
    Get-Content $File | mysql -u root -p $Db
}

function sq        { param([string]$File) sqlite3 $File }
function sqnew     { param([string]$File) sqlite3 $File }
function sqls      { param([string]$File) sqlite3 $File ".tables" }
function sqschema  { param([string]$File) sqlite3 $File ".schema" }
function sqdump {
    param([string]$File, [string]$Out = ($File -replace '\.db$', '.sql'))
    sqlite3 $File ".dump" | Out-File $Out
}

function rcli      { redis-cli @args }
function rping     { redis-cli ping }
function rflush    { redis-cli FLUSHALL }
function rmon      { redis-cli MONITOR }
function rkeys     { redis-cli KEYS '*' }
function rinfo     { redis-cli INFO }
function rsize     { redis-cli DBSIZE }
function rdel      { param([string]$Key) redis-cli DEL $Key }

function mconn     { mongosh @args }
function mdbs      { mongosh --eval 'db.adminCommand({listDatabases: 1})' }
function mdump     { param([string]$Db) mongodump --db $Db }
function mrestoredb { param([string]$Db, [string]$Dir) mongorestore --db $Db $Dir }

function influx    { influx.exe @args }
