
## this is not working. file is corrupt after download
dbfile <- reproducible::preProcess(url = "https://drive.google.com/file/d/1-2POunzC7aFbkKK5LeBJNsFYMBBY8dNx/view?usp=sharing",
                                   targetFile = "stsm_compare_noroads_noblocks_2024_castordb.sqlite",
                                   destinationPath = "scenarios/comparison_stsm/inputs",
                                   fun = NA)

## workaround with manual download
# srcDb <- dbConnect(RSQLite::SQLite(), dbfile$targetFilePath)
srcDb <- dbConnect(RSQLite::SQLite(), "~/Downloads/stsm_compare_noroads_noblocks_2024_castordb.sqlite")

## Fix database -- this Db is from 2024 and is missing some fields/columns
## create a copy, renamed to the correct db name and edit the copied db
newDbPath <- sub("_2024(_castordb.sqlite)", "\\1", dbfile$targetFilePath)
newDb <- dbConnect(RSQLite::SQLite(), newDbPath)   # new, empty file

RSQLite::sqliteCopyDatabase(srcDb, newDb)
dbDisconnect(srcDb)

dbExecute(newDb, "ALTER TABLE blocks ADD COLUMN culvar NUMERIC;")
dbExecute(newDb, "ALTER TABLE pixels ADD COLUMN silvsystem NUMERIC;")

## add the default silvicutural system table
silvSystem <- rbindlist(list(
  data.table(silvsystem = 0, entry_var = 'age', entry_req = 0, reset_age = 1, transition_silv =0, description = "clearcut, then plant then clearcut", start = 0, stop = 500),
  data.table(silvsystem = 1, entry_var = 'age', entry_req = 0, reset_age = 1, transition_silv =0, description = "stand replacing fire, then natural regen then clearcut", start = 0, stop = 500),
  data.table(silvsystem = 2, entry_var = 'age', entry_req = 70, reset_age = 0, transition_silv =0, description = "partial-cut at 80 years, then advanced regen then clearcut", start = 0, stop = 500),
  data.table(silvsystem = 3, entry_var = 'height', entry_req = 19, reset_age = 0, transition_silv =0, description = "partial-cut at 19 metres, then advanced regen then clearcut", start = 0, stop = 500),
  data.table(silvsystem = 4, entry_var = 'basalarea', entry_req = 24, reset_age = 0,transition_silv =4, description = "partial-cut when basal area >= 24 m2/ha, then advanced regen then partial-cut when basal area >= 24 m2/ha", start = 0, stop = 500)
))

dbExecute(newDb, "CREATE TABLE IF NOT EXISTS silvSystem ( id integer PRIMARY KEY, silvsystem integer, entry_var text, entry_req numeric, transition_silv integer, reset_age integer, description text,start integer default 0, stop integer default 500);")
dbBegin(newDb)
rs <- dbSendQuery(newDb, "INSERT INTO silvSystem (silvsystem, entry_var, entry_req, transition_silv, reset_age, description, start, stop) values (:silvsystem, :entry_var, :entry_req, :transition_silv, :reset_age, :description, :start, :stop)", silvSystem)
dbClearResult(rs)
dbCommit(newDb)

dbDisconnect(newDb)

