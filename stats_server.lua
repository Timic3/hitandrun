
-- NOT FINISHED YET!

local statsEnabled = false -- Set this to true to enable it, false to disable.

if statsEnabled == false then
	return
end

local db = nil
local db_type = "sqlite"
local db_path = "stats.db"

if db_type == "mysql" then
	outputChatBox("MySQL isn't ready yet. Database saving option set to SQLite.", root, 255, 0, 0, true)
	db_type = "sqlite"
end

local db_host = "localhost"
local db_database = "gtx"
local db_username = "root"
local db_password = ""

function connectMySQL()
	if not db then
		if db_type == "sqlite" then
			db = dbConnect(db_type, db_path)
			outputDebugString("Connection to database was successful! (Option: SQLite)")
		elseif db_type == "mysql" then
			db = dbConnect(db_type, "dbname="..db_database..";host="..db_host, db_username, db_password)
			outputDebugString("Connection to database was successful! (Option: MySQL)")
		else
			outputChatBox("Database saving option is invalid!", root, 255, 0, 0, true)
		end
	end
	if db then
		if db_type == "sqlite" then
			if dbExec(db, "CREATE TABLE IF NOT EXISTS accounts (id INT, username TEXT, password TEXT, money INT, points INT, serial TEXT, joined TEXT)") then
				outputDebugString("Accounts table has been created.")
			end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, connectMySQL)


