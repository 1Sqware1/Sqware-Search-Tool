local home = os.getenv("HOME")
local config_dir = home .. "/.config/sqs"
local db_path = config_dir .. "/sqs_index.db"

local function get_arg_value(flag)
	for i = 1, #arg do
		if arg[1] == flag then
			return arg[i+1]
		end
	end
	return nil
end


-- index flag (-- index)
if arg[1] == "--index" or #arg == 0 then
	print("SQS: Scan directories...")
	os.execute("mkdir -p " .. config_dir)


	local index_file = io.open(db_path, "w")
	local p = io.popen("find " .. home .. " -type f 2>/dev/null")

	local count = 0
	for file_path in p:lines() do
		index_file:write(file_path .. "\n")
		count = count + 1
	end

	p:close()
	index_file:close()
	print("Index updated! :P Total files: " .. count)
	os.exit()
end


-- search logic 
local search_name = get_arg_value("-s")
local search_type = get_arg_value("-t")


if arg[1] == "-s" then
    local search_name = arg[2]     
    if not search_name then
        print("T_T Error: Please specify a name. Example: sqs -s firefox. or type --help.")
        os.exit(1)
    end
    
    local index_file = io.open(db_path, "r")
    if not index_file then
        print("T_T Error: Database not found. Run with --index first.")
        os.exit(1)
    end
    
    print("SQS: Searching for '" .. search_name .. "'...")
    local matches = 0
    
    for line in index_file:lines() do 
        if line:find(search_name, 1, true) then
            print("\27[32mFound:\27[0m " .. line)
            matches = matches + 1
        end
    end
    
    index_file:close()
    print("SQS: Search finished :P. Total: " .. matches)
end


-- info
if arg[1] == "--info" or #arg == 0 then
	print("SQS (Sqware Search Tool). By 1Sqware1. written on LUA. version 0.1.")
	print("\27]8;;https://Github.com/1Sqware1/Sqware-Search-Tool\27\\Github\27]8;;\27\\")

end


-- help
if arg[1] == "--help" or #arg == 0 then
	print("Usage: lua sqs.lua -s <name> [-t <extension>]. --info, --index")
end


