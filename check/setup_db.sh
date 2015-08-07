sqlite3 ./disk.db "CREATE TABLE IF NOT EXISTS log(sent datetime default current_timestamp);"
sqlite3 ./mem.db "CREATE TABLE IF NOT EXISTS log(sent datetime default current_timestamp);"