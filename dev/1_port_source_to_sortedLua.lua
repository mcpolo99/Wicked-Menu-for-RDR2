
local function serializeTable(t, indent)
  indent = indent or 0
  local sp = string.rep("  ", indent)
  local s = "{\n"
  local isArray = true

  -- detect if table is array-like
  local count = 0
  for k,v in pairs(t) do
    count = count + 1
    if type(k) ~= "number" then isArray = false end
  end

  local idx = 1
  for k,v in pairs(t) do
    local key
    if isArray then
      key = ""  -- array keys not written
    else
      key = type(k) == "string" and '["'..k..'"]' or "["..k.."]"
      key = key.." = "
    end

    local val
    if type(v) == "table" then
      val = serializeTable(v, indent + 1)
    elseif type(v) == "string" then
      val = '"'..v..'"'
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


local newItems ={}

local function convertJsonToLua(json_lua_array)

    local function formatItem(curItem, itemKey, itemNum ,cycle)
        itemNum = itemNum or 1  -- default to 1 if not provided
        --Logger.debug("formatItem: ",curItem.x,tostring(itemKey),itemNum)
        local te
        if type(itemKey) == "string" then
            te = itemKey:gsub("_%.name", "_" .. itemNum)
        else
            te = itemKey:gsub("_%.name", "_" .. itemNum).."_"..itemNum 
        end
          

        return {
            text =  te,
            tool = 0,
            x = curItem.x,
            y = curItem.y,
            z = curItem.z
        }
    end
    local function correctDay(category, day)
        local correctedDay = day -- default

        if day == 1 then
            correctedDay = 2

        elseif day == 2 then
            correctedDay = 3

        elseif day == 3 then
            correctedDay = 1

        elseif day == 4 then
            correctedDay = 4

            if category == "arrowhead" then
                correctedDay = 6
            end

            if category == "bottle" then
                correctedDay = 6
            end

            if category == "bracelet"
            or category == "earring"
            or category == "necklace"
            or category == "ring" then
                correctedDay = 6
            end

            if category == "egg" then
                correctedDay = 6
            end

            if category == "heirlooms" then
                correctedDay = 6
            end

        elseif day == 5 then
            correctedDay = 5

            if category == "arrowhead" then
                correctedDay = 4
            end

            if category == "bottle" then
                correctedDay = 4
            end

            if category == "coin" then
                correctedDay = 6
            end

            if category == "bracelet"
            or category == "earring"
            or category == "necklace"
            or category == "ring" then
                correctedDay = 4
            end

        elseif day == 6 then
            correctedDay = 6

            if category == "arrowhead" then
                correctedDay = 5
            end

            if category == "bottle" then
                correctedDay = 5
            end

            if category == "egg" then
                correctedDay = 4
            end

            if category == "heirlooms" then
                correctedDay = 4
            end

            if category == "coin" then
                correctedDay = 5
            end

            if category == "bracelet"
            or category == "earring"
            or category == "necklace"
            or category == "ring" then
                correctedDay = 5
            end

        else
            correctedDay = -1
        end

        return correctedDay
    end


    --[[

    MapData_Array = {
        ["HeadGroup"] = {
            ["SubGroup1"] = {
                [auto]{

                    ["text"]="Cycle Num OR like ",
                    ["locations"] = {
                        [auto]{
                            ["x"]=0,
                            ["y"]=0,
                            ["z"]=0,
                            ["text"] = "name of the item - will be used as display."
                        },
                        [auto]{
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


    --]]

    local items = json_lua_array
    for catKey, catValue in pairs(items) do
        Logger.debug("catKey ",tostring(catKey))

        newItems[catKey] = {} -- creates new SubGroup1 (since this parser only do collectors items. )
        for dayIndex = 1, 6 do
            newItems[catKey][dayIndex] = {}
            newItems[catKey][dayIndex].cycle = dayIndex
            newItems[catKey][dayIndex].locations = {}
        end

        for itemKey, itemValue in pairs(items[catKey]) do


            --Logger.debug(tostring(catKey))
            --Logger.debug(tostring(itemKey))
            if (catKey == "egg" and #items[catKey][itemKey] == 12) then
                Logger.debug("  |--FLOWERS egg  ")
                for dayIndex = 0, 5 do
                    --Logger.debug("   |--itemKey ",tostring(itemKey))
                    local curItem1 = items[catKey][itemKey][1 + (dayIndex * 2)]
                    local curItem2 = items[catKey][itemKey][2 + (dayIndex * 2)]

                    local dayKey = correctDay(catKey, dayIndex + 1)
                    --Logger.debug(" dayKey ",tostring(dayKey))
                    
                    local itemFormatted1 = formatItem(curItem1,itemKey,1,dayKey)
                    local itemFormatted2 = formatItem(curItem2,itemKey,2,dayKey)

                    table.insert(newItems[catKey][dayKey].locations, itemFormatted1)
                    table.insert(newItems[catKey][dayKey].locations, itemFormatted2)
                end
            elseif (catKey == "flower") then

                --ok
                for dayIndex = 0, 5 do
                    if (#items[catKey][itemKey] == 18) then
                        Logger.debug("  |--FLOWERS 18  ")
                        --Logger.debug("   |--itemKey ",tostring(itemKey))
                        local curItem1 = items[catKey][itemKey][1 + (dayIndex * 3)]
                        local curItem2 = items[catKey][itemKey][2 + (dayIndex * 3)]
                        local curItem3 = items[catKey][itemKey][3 + (dayIndex * 3)]

                        local dayKey = correctDay(catKey, dayIndex + 1)
                        --Logger.debug(" dayKey ",tostring(dayKey))

                        local itemFormatted1 = formatItem(curItem1,itemKey,1)
                        local itemFormatted2 = formatItem(curItem2,itemKey,2)
                        local itemFormatted3 = formatItem(curItem3,itemKey,3)

                        table.insert(newItems[catKey][dayKey].locations, itemFormatted1)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted2)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted3)

                    elseif (#items[catKey][itemKey] == 36) then
                        Logger.debug("  |--FLOWERS 36 ")
                        local curItem1 = items[catKey][itemKey][1 + (dayIndex * 6)]
                        local curItem2 = items[catKey][itemKey][2 + (dayIndex * 6)]
                        local curItem3 = items[catKey][itemKey][3 + (dayIndex * 6)]
                        local curItem4 = items[catKey][itemKey][4 + (dayIndex * 6)]
                        local curItem5 = items[catKey][itemKey][5 + (dayIndex * 6)]
                        local curItem6 = items[catKey][itemKey][6 + (dayIndex * 6)]
                        local dayKey = correctDay(catKey, dayIndex + 1)

                        local itemFormatted1 = formatItem(curItem1,itemKey,1)
                        local itemFormatted2 = formatItem(curItem2,itemKey,2)
                        local itemFormatted3 = formatItem(curItem3,itemKey,3)
                        local itemFormatted4 = formatItem(curItem4,itemKey,4)
                        local itemFormatted5 = formatItem(curItem5,itemKey,5)
                        local itemFormatted6 = formatItem(curItem6,itemKey,6)

                        table.insert(newItems[catKey][dayKey].locations, itemFormatted1)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted2)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted3)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted4)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted5)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted6)

                    elseif (#items[catKey][itemKey] == 54) then
                        Logger.debug("  |--FLOWERS 54 ")
                        local curItem1 = items[catKey][itemKey][1 + (dayIndex * 9)]
                        local curItem2 = items[catKey][itemKey][2 + (dayIndex * 9)]
                        local curItem3 = items[catKey][itemKey][3 + (dayIndex * 9)]
                        local curItem4 = items[catKey][itemKey][4 + (dayIndex * 9)]
                        local curItem5 = items[catKey][itemKey][5 + (dayIndex * 9)]
                        local curItem6 = items[catKey][itemKey][6 + (dayIndex * 9)]
                        local curItem7 = items[catKey][itemKey][7 + (dayIndex * 9)]
                        local curItem8 = items[catKey][itemKey][8 + (dayIndex * 9)]
                        local curItem9 = items[catKey][itemKey][9 + (dayIndex * 9)]
                        local dayKey = correctDay(catKey, dayIndex + 1)

                        local itemFormatted1 = formatItem(curItem1,itemKey,1)
                        local itemFormatted2 = formatItem(curItem2,itemKey,2)
                        local itemFormatted3 = formatItem(curItem3,itemKey,3)
                        local itemFormatted4 = formatItem(curItem4,itemKey,4)
                        local itemFormatted5 = formatItem(curItem5,itemKey,5)
                        local itemFormatted6 = formatItem(curItem6,itemKey,6)
                        local itemFormatted7 = formatItem(curItem7,itemKey,7)
                        local itemFormatted8 = formatItem(curItem8,itemKey,8)
                        local itemFormatted9 = formatItem(curItem9,itemKey,9)


                        table.insert(newItems[catKey][dayKey].locations, itemFormatted1)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted2)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted3)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted4)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted5)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted6)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted7)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted8)
                        table.insert(newItems[catKey][dayKey].locations, itemFormatted9)
                    end
                end
            else
                local dayIndex = 1
                for _, item in ipairs(items[catKey][itemKey]) do
                    Logger.debug("   |--itemKey ",tostring(itemKey))
                    local dayKey = correctDay(catKey, dayIndex);

                    local itemFormatted = formatItem(item,itemKey,"")
        
                    
                    if not newItems[catKey][dayKey] then
                        newItems[catKey][dayKey] = {}
                    end
                    table.insert(newItems[catKey][dayKey].locations, itemFormatted)
                    dayIndex = dayIndex + 1
                end
            end
        end
    end
    return true

end


local p = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\Collector_item-cordinates-in-game_raw.json]])
print(p:info())
local data = p:read_file()
--_G.showMessage(data)
local decoded_json = _G.dkjson.decode(data)
print(type(decoded_json))
assert(convertJsonToLua(decoded_json),"coverting failed somewhere! ! ")




print(p())
local savepath2 = p:parent() / "ported_collector_array_type2.lua"
--print(savepath:info())
print(savepath2:info())




savepath2:write_file(serializeTable(newItems))
savepath2:exportLua()

print("finished writing file")
--savepath:write_file(encoded_json)
local encoded_json = _G.dkjson.encode(newItems)
local p = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\Array\item-cordinates-in-game_converted.json]])
p:write_file(encoded_json)




local p = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\lua\pathlib.lua]])
-- local p = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\ported_collector_array_type2.lua]])
p:exportLua()

