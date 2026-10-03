local home = os.getenv("HOME")
local config_dir = home .. "/.config/sqs"
local db_path = config_dir .. "/sqs_index.db"
math.randomseed(os.time())

local function get_arg_value(flag)
    for i = 1, #arg do
        if arg[i] == flag then
            return arg[i + 1]
        end
    end
    return nil
end

local function list_files_by_type(search_type)
    local index_file = io.open(db_path, "r")
    if not index_file then
        print("T_T Error: Database not found. Run with --index first.")
        return
    end

    local target = (search_type or ""):lower():gsub("^%.", "")
    local matches = 0

    for line in index_file:lines() do
        local ext = line:match("%.([%w%-]+)$") or ""
        if ext:lower() == target then
            print("\27[32mFound:\27[0m " .. line)
            matches = matches + 1
        end
    end

    index_file:close()
    print("SQS: Type filter finished :P. Total: " .. matches)
end

local function search_by_name(search_name, search_type)
    local index_file = io.open(db_path, "r")
    if not index_file then
        print("T_T Error: Database not found. Run with --index first.")
        return
    end

    print("SQS: Searching for '" .. search_name .. "'...")
    local matches = 0
    local target_type = search_type and search_type:lower():gsub("^%.", "") or nil

    for line in index_file:lines() do
        if target_type then
            local ext = line:match("%.([%w%-]+)$") or ""
            if ext:lower() ~= target_type then
                goto continue
            end
        end

        if line:lower():find(search_name:lower(), 1, true) then
            print("\27[32mFound:\27[0m " .. line)
            matches = matches + 1
        end

        ::continue::
    end

    index_file:close()
    print("SQS: Search finished :P. Total: " .. matches)
end

if arg[1] == "--index" then
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

if arg[1] == "-t" then
    local type_name = arg[2]
    if not type_name then
        print("T_T Error: Please specify a file type. Example: sqs -t mp3")
        os.exit(1)
    end

    list_files_by_type(type_name)
    os.exit()
end

if arg[1] == "--im-feeling-lucky" then
    local index_file = io.open(db_path, "r")
    if not index_file then
        print("T_T Error: Database not found. Run with --index first.")
        os.exit(1)
    end

    local total_lines = 0
    for _ in index_file:lines() do
        total_lines = total_lines + 1
    end
    index_file:close()

    if total_lines == 0 then
        print("T_T Error: Database is empty. Run with --index first.")
        os.exit(1)
    end

    local lucky_number = math.random(1, total_lines)
    index_file = io.open(db_path, "r")

    local current_line = 0
    for line in index_file:lines() do
        current_line = current_line + 1
        if current_line == lucky_number then
            print("\27[35mYou are lucky :3 Found:\27[0m " .. line)
            break
        end
    end

    index_file:close()
    os.exit()
end

local search_name = get_arg_value("-s")
local search_type = get_arg_value("-t")

if search_name then
    search_by_name(search_name, search_type)
    os.exit()
end

if arg[1] == "--info" then
    print("SQS (Sqware Search Tool). By 1Sqware1. written on LUA. version 0.1.")
    print("\27]8;;https://Github.com/1Sqware1/Sqware-Search-Tool\27\\Github\27]8;;\27\\")
    os.exit()
end

if arg[1] == "--help" or #arg == 0 then
    print("Usage: lua sqs.lua --index | -s <name> [-t <extension>] | -t <extension> | --info | --im-feeling-lucky | --help")
    os.exit()
end