paths = {
    folder = nil,
    save = "saves/state",
    main = "main",
    temp = "temp",
    init = "init",
}

-- emulator compatibility

    emulator = 
        emu.read8 and "mgba" or
        memory and memory.read_u8 and "bizhawk" or
        memory and memory.readbyte and "vba"

    assert(emulator, "unrecognized emulator")

    if emulator == "mgba" then
        read8 = function(addr) emu:read8(addr) end
        read16 = function(addr) emu:read16(addr) end
        read32 = function(addr) emu:read32(addr) end
        write8 = function(addr, value) emu:write8(addr, value) end
        write16 = function(addr, value) emu:write16(addr, value) end
        write32 = function(addr, value) emu:write32(addr, value) end
        load = function(file) emu:loadStateFile(file) end
        print = function(...)
            local args = table.pack(...)
            local s = {}
            for i=1,args.n do
                s[i] = tostring(args[i])
            end
            console:log(table.concat(s, " "))
        end
        if not paths.folder then
            paths.folder = debug.getinfo(1).source:match("@?(.*)[\092/]")
        end
    elseif emulator == "bizhawk" then
        read8 = memory.read_u8
        write8 = memory.write_u8
        read16 = memory.read_u16_le
        write16 = memory.write_u16_le
        read32 = memory.read_u32_le
        write32 = memory.write_u32_le
        load = function(file) savestate.load(file) end
        if not paths.folder then
            local OS_name = os.getenv("OS")
            if OS_name and OS_name:match("Windows") then
                paths.folder = io.popen("cd"):read("*a"):gsub("\n","")
            else
                paths.folder = io.popen("pwd"):read("*a"):gsub("\n","")
            end
        end
    elseif emulator == "vba" then
        read8 = memory.readbyte
        write8 = memory.writebyte
        read16 = memory.readword
        write16 = memory.writeword
        read32 = memory.readdword
        write32 = memory.writedword
        if not paths.folder then
            paths.folder = debug.getinfo(1).source:match("@?(.*)[\092/]")
        end
    end

--

-- functions

    function readall(filename, mode)
        local f = io.open(filename, mode)
        local data = f:read("*a")
        f:close()
        return data
    end

    function set(...)
        local out = {}
        for i,v in ipairs{...} do
            out[v] = true
        end
        return out
    end

    function check_extensions(filename, ...)
        local arg = {"", ...}
        for i=1,#arg do
            local fullname = filename.."."..arg[i]
            local f = io.open(fullname)
            if f then
                f:close()
                return fullname
            end
        end
    end

    function add_extension(filename, ext)
        if not filename:match(ext.."$") then
            filename = filename.."."..ext
        end
        return filename
    end

    function pathjoin(...)
        local sep = package.config:match("[^\n]*")
        return table.concat({...}, sep)
    end

    function filecheck(filename, mode)
        if not filename then return nil end
        local f = io.open(filename, mode)
        if f then
            f:close()
            return filename
        end
    end

    function load_armips_output(tempfile) -- Use the armips tempfile to determine what files to open and where to write data
        local header = 0
        local prevpos, pos
        local position_setters = set("open", "create", "headersize", "org", "align", "skip")
        for line in io.lines(tempfile) do
            local addr, rest = line:match("^(%x+) (.-)%s*;")
            if addr then
                local directive, word, argstring = rest:match("(%.?)(%S+)%s?(%S*)")
                prevpos = pos
                pos = tonumber(addr, 16)
                if prevpos and prevpos < pos then
                    for i=prevpos,pos-1 do
                        write8(i, data:byte(i-header+1))
                    end
                end
                if directive and position_setters[word] then
                    local args = {}
                    for a in argstring:gmatch("[^,]+") do
                        table.insert(args, a)
                    end
                    if word == "create" or word == "open" then
                        header = tonumber(args[2])
                        pos = header
                        local filename = args[1]:gsub('"',""):gsub("^.[\092/]","")
                        local folder = tempfile:match("(.*[\092/]).+%..+$")
                        filename = filecheck(folder..filename) or filecheck(filename)
                        assert(filename, "could not find "..filename)
                        data = readall(filename, "rb")
                    elseif word == "headersize" then
                        header = tonumber(args[1])
                        pos = header
                    elseif word == "org" then
                        pos = tonumber(args[1])
                    elseif word == "align" then
                        if pos % 4 ~= 0 then
                            pos = pos + 4 - (pos % 4)
                        end
                    elseif word == "skip" then
                        pos = pos + tonumber(args[1])
                    end
                    pos = tonumber(args[position_setters[word]])
                    prevpos = pos
                end
            end
        end
    end

    function run(package_name)
        local init_file = filecheck(pathjoin(paths.folder, package_name, add_extension(paths.init, "lua")))
        if init_file then dofile(init_file) end
        local save_ext = 
            emulator == "mgba" and "ss0" or
            emulator == "bizhawk" and "State" or 
            emulator == "vba" and "sgm"
        local save = check_extensions(pathjoin(paths.folder, package_name, paths.save), save_ext)
        if filecheck(save) and load then load(save) end
        local temp = check_extensions(pathjoin(paths.folder, package_name, paths.temp), "txt")
        load_armips_output(temp)
    end

--

-- on_start

    if emulator == "vba" then
        require("widgets")
        interpreter = widgets.Interpreter{}
        while true do
            emu.frameadvance()
        end
    end

--