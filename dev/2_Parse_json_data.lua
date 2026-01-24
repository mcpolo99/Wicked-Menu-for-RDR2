

--[[

    -------------- Longitude/Lng: Direction: East or West. / left or right , Horizontal , X direction --------------
    -------------- Latitude/Lat: Direction: North or South. / up  or down , Vertical , Y direction --------------

    this is taken from website
    { "text": "fasttravel.annesburg", "x": -43.4814, "y": 156.7450 }, where as X need to switch with Y and Y with X so:  {"x": 156.7450 ,  "y":-43.4814}
    Game to map 

    the swithc was done in the port to webpage "port-source-coords-to-website-coords.js"
    latY: (0.01552 * item.lngX + -63.6).toFixed(4),
    lngX: (0.01552 * item.latY + 111.294).toFixed(4)  
--]]


--- This function rounds a number to a specified amount of decimal places
--- Input `value` and number of `decimals`
--- Returns the rounded number
---@param value number
---@param decimals number
---@return number
function round(value, decimals)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    return math.floor(value * factor + 0.5) / factor
end

--- This function is for Ingame position to interactive Map position
--- Input `posX` & `posY` 
--- Returns the converted numbers `posX`  and `posY` 
---@param posXLng number
---@param posYLat number
---@return table {posXLng , posYLat}
function GameToMapInteractive(posXLng, posYLat)
    assert(posXLng ~= nil and posYLat ~= nil,"[MapGameToMapInteractive] posXLng posYLat values not provided")
    -- posX = 0.01552 * posX + 111.294
    -- posY = 0.01552 * posY - 63.6
    posXLng = round((0.01552 * posXLng) + 111.294 , 4) 
    posYLat = round((0.01552 * posYLat) + (-63.6) , 4)
    return posXLng, posYLat
end

--- This function is for interactive Map position to Ingame position 
--- Input `posX` & `posY` 
--- Returns the converted numbers `posX`  and `posY` 
---@param posXLng number
---@param posYLat number
---@return table {posXLng , posYLat}
function MapInteractiveToGame(posXLng, posYLat)
    assert(posXLng ~= nil and posYLat ~= nil,"[MapInteractiveToMapGame] posXLng posYLat values not provided")
    posXLng = round((posXLng - 111.294) / 0.01552 , 4)
    posYLat = round((posYLat + 63.6)    / 0.01552 , 4)
    return posXLng, posYLat
end

local function sample_func()
    -- ingame { ["x"] = 2928.543814433 ,["y"] = 1296.3015463918 , ["text"] = "annesburg" ,}
    local a,b = GameToMapInteractive(2928.543814433, 1296.3015463918 )
    print("ingame > interactive :",a,b)
    --ingame > interactive : 156.745 -43.4814 

    -- interactive { "x": -43.4814, "y": 156.7450 , "text": "fasttravel.annesburg" ,},  X = Y and Y = X , they have been switched
    local c,d = MapInteractiveToGame( 156.7450 ,-43.4814)
    print("interactive > ingame :",c,d) -- OK when input X and Y is switched before call
    --interactive > ingame : 2928.5438 1296.3015 
end

--- inputs table `t` checks whenever `t.x` and `t.y` exsist.
--- if they do, run converter function on x / y values 
--- Returns nothing. since base table has been modified 
---@param t table
--
local function convertInteractiveMapXY(t)
    -- Check if this table has both x and y
    if type(t) == "table" and t.x ~= nil and t.y ~= nil then
        t.x, t.y = MapInteractiveToGame(t.y, t.x)
    end

    -- Now recurse for all child tables
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                convertInteractiveMapXY(v) -- recursive call
            end
        end
    end
end



--- inputs table `t` checks whenever `t.lat` and `t.lng` exsist.
--- the thing with this is that the map maker has confused lat and lng in source json file.
--- so we need to consider this 
--- Returns nothing. since base table has been modified 
---@param t table
--
local function convertInteractiveMapLatLng(t)
    -- Check if this table has both x and y
    if type(t) == "table" and t.lat ~= nil and t.lng ~= nil then

        t.x, t.y = MapInteractiveToGame(t.lat, t.lng)
    end
    -- Now recurse for all child tables
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                convertInteractiveMapLatLng(v) -- recursive call
            end
        end
    end
end

local function serializeTable(t, indent)
    indent = indent or 0
    local sp = string.rep("  ", indent)
    local s = "{\n"
    local isArray = true

    -- detect if table is array-like
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
        if type(k) ~= "number" then
            isArray = false
        end
    end

    local idx = 1
    for k, v in pairs(t) do
        local key
        if isArray then
            key = "" -- array keys not written
        else
            key = type(k) == "string" and '["' .. k .. '"]' or "[" .. k .. "]"
            key = key .. " = "
        end

        local val
        if type(v) == "table" then
            val = serializeTable(v, indent + 1)
        elseif type(v) == "string" then
            val = '"' .. v .. '"'
        elseif type(v) == "boolean" then
            val = v and "true" or "false"
        elseif type(v) == "number" then
            val = tostring(v)
        else
            val = 'nil'
        end

        s = s .. sp .. "  " .. key .. val .. ",\n"
        idx = idx + 1
    end

    s = s .. sp .. "}"
    return s
end







local TableStructure = [[


    HeadGroups = {"Collector","Encounters","Locations","Naturalist","Treasures"}
    SubGroup1 = Subgroup of items. The groups i consider is:
    {
        Collector = {"arrowheads","bottles/alcohol","cards","coins","eggs","flowers","heirlooms","jewelry"}
    }


    SubGroup2 - some groups can be divided into subgroups for easier category
    {
        cards = Type of colors {"cups","swords","pentacles","wands"}
        jewelry = Type of jewelry {"bracelet","earring","necklace","ring","jewelry_random?"}
        flowers = Type of flower {"agarita","bitterweed","blue_bonnet","blood_flower","cardinal_flower","chocolate_daisy","creek_plum","wild_rhubarb","wisteria"}

    }

    I have used many data from: 
    https://github.com/jeanropke/RDR2CollectorsMap (https://jeanropke.github.io/)
    https://github.com/jeanropke/RDOMap (https://jeanropke.github.io/RDOMap/)




    cycle 1 = array 1


    MapData_Array = {
        ["HeadGroup"] = {
            ["SubGroup1"] = {
                [autoid]{

                    ["text"]="Cycle Num OR like ",
                    ["locations"] = {
                        [autoid]{
                            ["x"]=0,
                            ["y"]=0,
                            ["z"]=0,
                            ["text"] = "name of the item - will be used as display."
                        },
                        [autoid]{
                            ["x"]=0,
                            ["y"]=0,
                            ["z"]=0,
                            ["text"] = "name of the item - will be used as display."
                        },
                    },
                    ["any additional data"] = "",
                },
            },
        },
    }




                    
    
    
    
    
    
    
]]





function runImpoortParse_NewJsonFiles(filepath,files)
    local new_array = {}
    new_array["Locations"] = {} -- nazar , fasttravels ,treasures
    new_array["Naturalist"] = {} -- animal_legendary
    new_array["Collector"] = {} -- collectibles    
    
    for k, value in pairs(files) do
        local running_file = tostring(value)
        assert(Logger, "please add loggerlib")


        Logger.info("--->>> start process file: \'" .. value .. "\' <<<---")


        assert(Path.version, "pathlib not loaded")
        local p = Path(filepath,value..".json") 
        assert(p:is_file(), "either files dont exsist or path is incorrect: \'" .. p.path .. "\'")
        local json_data = p:read_file()
        
        assert(type(json_data) == "string",
            "-->>File not loaded properly: \'" .. value .. "\' .\nPlease check the file exsist and is not damaged!<<--")
        assert(_G.dkjson.version,
            "-->> Json plugin not found, please install and register to \'_G.\' :\n \'https://raw.githubusercontent.com/LuaDist/dkjson/refs/heads/master/dkjson.lua\' to path: \'" ..
                getCheatEngineDir() .. "autorun\\custom\\\' <<--")
        local json_decoded = _G.dkjson.decode(json_data)

        if file == "collectibles" then
            convertInteractiveMapLatLng(json_decoded)
        else
            convertInteractiveMapXY(json_decoded)
        end

        local i_1 = 1





        -- for each group add to head group
        for k, v in pairs(json_decoded) do
            local name_1 = tostring(k)
            -- Logger.info("----->>>>>".."\nparsing file:\'",running_file ,"\',\nchilditem:\'",name_1 .. "\',\ncurrent loopindex:"..i_1)
            


            if type(v) == "table" and running_file == "collectibles" then
                Logger.currentLevel = Logger.Level.DEBUG
                new_array["Collector"][k] = {}

                --
                local index_2 = 1
                local new_item_groups = {}
                -- new_item_groups[name_1]={}


                for key2, cycle in pairs(v) do -- for each cycle add to new_item_groups
                    local int1 = tonumber(key2) -- seems to be working fine. is cycle number.
                    new_array["Collector"][k][tonumber(key2)] = {}
                    new_array["Collector"][k][tonumber(key2)].cycle = tonumber(key2)
                    new_array["Collector"][k][tonumber(key2)].locations = {}

                    
                    -- new_array["Collector"][name_1]={}

                    -- Logger.debug("cycle: ",tostring(key2))

                    -- for each location clean and add to "new_item_locations"
                    if type(cycle) == "table" then
                        local i_3 = 1
                        -- for each cycle,
                        local location_Group = {}

                        for key3, location in pairs(cycle) do

                            Logger.debug("location", tostring(key3))
                            -- print(tostring(v.text))

                            -- location.x = location.lng
                            -- location.y = location.lat
                            -- location.z = -250
                            -- location.lat = nil
                            -- location.lng = nil
                            location["video_zh-Hans"] = nil
                            location.video = nil
                            location.cycle = tonumber(int1)

                            -- table.insert(cycle_group[int1], v) --add locations to array
                            i_3 = i_3 + 1
                            -- new_array["Collector"][name_1][key3] = location
                            -- table.insert(new_item_groups[int1],cycle_group)
                            location_Group[key3] = location
                            table.insert(new_array["Collector"][k][int1].locations, location)

                        end
                        -- Logger.debug(#location_Group)

                        -- new_item_groups[int1]=location_Group

                    end

                    -- table.insert(new_array["Collector"], {text = name_1,  cycles = new_item_groups})
                    -- new_item_groups=cycle_group
                    -- table.insert(new_item_groups[int1],new_item_groups)

                    index_2 = index_2 + 1
                end
                -- --table.insert(new_array["Collector"], {text = name_1,  cycles = cycle_group})
                -- -- insert final
                -- table.insert(new_array["Collector"], {text = name_1,  cycles = new_item_groups})

            elseif type(v) == "table" and running_file == "animal_legendary" then

                if not new_array["Naturalist"][running_file] then
                    new_array["Naturalist"][running_file] = {} -- if no array present we need to create it.
                end


                Logger.currentLevel = Logger.Level.INFO
                Logger.debug(tostring(v.animal_name))

                v.cx = v.x
                v.x = nil
                v.cy = v.y
                v.y = nil
                v.animal_id = v.text
                v.text = v.animal_name
                v.animal_name = nil
                for k1, v1 in pairs(v["locations"]) do
                    -- print(v1)
                    v1.z = 250 -- JUST SET A VALUE!

                end

                table.insert(new_array["Naturalist"][running_file], v)

            elseif type(v) == "table" and (running_file == "nazar" or running_file == "fasttravels") then
                if not new_array["Locations"][running_file] then
                    new_array["Locations"][running_file] = {} -- if no array present we need to create it.
                end
                -- this is pretty mych flat arrays handling
                Logger.currentLevel = Logger.Level.INFO
                Logger.debug(tostring(v.text) or rtostring(v.id))
                if running_file == "nazar" then -- handle nazar json 
                    v.text = v.id
                    v.id = nil
                elseif running_file == "fasttravels" then -- handle fasttravels json
                    v.text = v.text:gsub("^fasttravel%.", "")
                end

                table.insert(new_array["Locations"][running_file], v)

            elseif type(v) == "table" and (running_file == "treasures") then
                if not new_array[running_file] then
                    new_array[running_file] = {} -- if no array present we need to create it.
                end
                v.text = v.text:gsub("^map%_", "")
                v.cx = v.x
                v.x = nil
                v.cy = v.y
                v.y = nil
                for k1, v1 in pairs(v["locations"]) do
                    -- print(v1)
                    v1.z = 250 -- JUST SET A VALUE!
                end

                table.insert(new_array[running_file], v)

            elseif type(v) == "table" and running_file == "encounters" then
                if not new_array[running_file] then
                    new_array[running_file] = {} -- if no array present we need to create it.
                end
                v.text = v.key

                v.key = nil
                v.color = nil
                for k1, v1 in pairs(v["locations"]) do
                    -- print(v1)
                    v1.z = 250 -- JUST SET A VALUE!
                end

                table.insert(new_array[running_file], v)
            end
            i_1 = i_1 + 1
        end
    end

    Logger.debug(#new_array["Collector"])
    Logger.debug(#new_array["Naturalist"])
    Logger.debug(#new_array["Locations"])
    return new_array
end
local files_to_load = {"treasures", "nazar", "fasttravels", "collectibles", "animal_legendary", "encounters"}
local file_path = [[G:\Cheats\Tables\Wicked-Menu-for-RDR2\Array\json]]

local temparray = runImpoortParse_NewJsonFiles(file_path,files_to_load)




local finished_array_as_string = "MapData_Array =" .. serializeTable(temparray)

local savepath = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\Array\]],"MapData_Array--.lua")
savepath:info()
savepath:write_file(finished_array_as_string)
savepath:exportLua(true)

-- use later for loading and saving the array if updated.
local local_savepath = Path(getCheatEngineDir(),"cheat_tables",RDRTEMP,"MapData_Array---.lua")
local_savepath:info()
local_savepath:write_file(finished_array_as_string)





