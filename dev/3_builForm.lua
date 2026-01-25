
--[[
TODO:
--  Add option we can update Z cordinate in game.
--  Add so we can add new values in the properties window., pretty much like "save pos" and it creates a new entry somewehre.
--

]]
Logger.currentLevel = Logger.Level.DEBUG
Navigator = {}
Navigator.selectedItem = nil -- The item to be used for teleport
Navigator.listLocations = {} -- a cahce for current cycle or list of avaiable teleport locations, used in load_mapdata etc
Navigator.target = nil --a copy of the teleport target name/control
Navigator.selectednodeindex = nil



nameOfPanel = "CEPanel_NavigatorSelection"
local mainForm = _G.CETrainer.CEPanel_DynamicControls
local _ref_tree_view = nil


-- =====================
-- reset mechanism
-- =====================

if _G.CETrainer.CEPanel_DynamicControls[nameOfPanel] then
    _G.CETrainer.CEPanel_DynamicControls[nameOfPanel]:destroy()
end
-- =====================
-- Global vars
-- =====================
local props = nil
debugpanel = nil

testsender1 = nil -- USed for updating cordinates outside of this script -- DONT REMOVE 
testsender2 = nil --debbugging
testsender3 = nil -- debuging
cacheTree = nil
-- NodeData = setmetatable({}, { __mode = "k" }) -- weak keys
NodeData = {} -- global or upvalue


-- =====================
-- local helpers
-- =====================

local function hasXY(data)
    return type(data.x) == "number" and type(data.y) == "number"
end

local function hasXYZ(data)
    return hasXY(data) and type(data.z) == "number"
end
local function isNumArray(t)
    return type(t) == "table" and t[1] ~= nil
end
local function getItemsCount(t)
    if type(t) ~= "table" then return 0 end

    -- array-style
    if isNumArray(t) then
        return #t
    else
        -- map-style
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        return count
    end
end

local function getNodeByData(data)
    for nodeIdx, d in pairs(NodeData) do
        if d == data then
            return _ref_tree_view.Items[nodeIdx] -- get the node by index
        end
    end
    return nil
end

local function runTeleport(selectedItem)
    Navigator.selecteditem = selectedItem
    --Logger.debug(selectedItem.x,selectedItem.y,selectedItem.z)
    target = "_navigator1_"
    local mr = getAddressList().GetMemoryRecordByDescription(target)
    mr.active=true
end
local function nodeKey(node)
    return tostring(node):gsub("[: ]", "_"):gsub("_+", "_") -- includes pointer address
end
local function test(str)
    print(str)
end
local function getPlayerPos()

    local x=readFloat("[coord2]+80")
    local y=readFloat("[coord2]+84")
    local z=readFloat("[coord2]+88")
    return x , y , z
end


local function serializeTable(t, indent, noChildren)
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
      if noChildren then
        val = "{...}"  -- indicate child table exists but don't serialize
      else
        val = serializeTable(v, indent + 1)
      end
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

local _selectedNodeIndex = nil -- or just use selected index as ref?
local function getSelectedNodeAndData()
    local node = _ref_tree_view.Selected
    if not node then return nil, nil end
    return node, NodeData[node.AbsoluteIndex]
end


-- =====================
--  helper Build Tree view
-- =====================
local function addTreeNodes(parentNode, t)
    if type(t) ~= "table" then return end


    if isNumArray(t) then
        --Logger.debug("array parser ")
        for i, item in ipairs(t) do
            --Logger.debug("array.parsing: ", i)


            local display = item.text or ("item " .. i)
            local node = nil
            if item.text then
                --print(item.text)
            end
            node = parentNode.Add(display,parentNode)

            NodeData[node.AbsoluteIndex] = item

            -- recurse if nested tables exist
            for k,v in pairs(item) do

                if type(v) == "table" and k ~= "text" and k ~= "cycles" then
                    addTreeNodes(node, v)

                elseif type(v) == "table" and k ~= "text" and k == "cycles" then

                    -- this will "catch" the Collector Cycles
                    for k1,v1 in pairs(v) do
                        --print(k1)
                        local node2 = node.Add(k1,node)
                        NodeData[node2.AbsoluteIndex] = v1
                        addTreeNodes(node2, v1)
                    end
                end
            end

            -- add backreference
            item.nodeindex = node.AbsoluteIndex
        end
    else -- map style
        --Logger.debug("map parser ")

        --for some reason all cycle end upp running here.
        --print(temp_display)
        for key, value in pairs(t) do

            --Logger.debug("Map.parsing: ", key)
            local node = nil

            if tostring(parentNode.ClassName) == "TCETreeview" then
                node = parentNode.Items.Add(key,parentNode)
            else
                node = parentNode.Add(key,parentNode)
            end
            --node.Data = value --does not work
            --value.nodeindex = node.AbsoluteIndex
            NodeData[node.AbsoluteIndex] = value



            addTreeNodes(node, value)
        end
    end
end
local function rebuildTree(parent)
    local tree = _ref_tree_view
    if not tree then return end

    tree.beginUpdate()
    tree.Items.Clear()
    NodeData = {}   -- IMPORTANT
    addTreeNodes(tree, MapData_Array)
    tree.endUpdate()
end


local function showProperties(panel, data)
    -- TO AVOID MASSIVE DUPLICATES
    if panel.getComponentCount() > 0 then
        for i = panel.getComponentCount()-1, 0, -1 do
            panel.Component[i]:destroy()
        end
    end

    -- print(debugpanel.getComponentCount())

    if not data then
        return
    end
    local str = serializeTable(data,4,true)
    local memo = createMemo(panel)
    memo.Align = alClient
    memo.ScrollBars = ssVertical
    memo.ReadOnly = true
    memo.SelText = str
end
local function showPropertyEditor(panel, data)
    -- clear previous children
    if panel.getComponentCount() > 0 then
        for i = panel.getComponentCount()-1, 0, -1 do
            panel.Component[i]:destroy()
        end
    end

    if not data then return end

    local y = 5
    local spacing = 24
    local margin = 5
    local lblWidth = 100
    

    local _rPanel = createPanel(panel)
    _rPanel.Align = alClient

    local _lPanel = createPanel(panel)
    _lPanel.Align = alLeft


    local readOnlyFields = { ["nodeindex"] = true, ["nodeRef"] = true }

    for k,v in pairs(data) do
        if type(v) ~= "table" then
            -- label
            local lbl = createLabel(_lPanel)
            lbl.Caption = tostring(k)
            lbl.Top = y
            -- lbl.Layout = tlCenter
            -- lbl.Left = margin
            -- lbl.Height = spacing
            lbl.Align = alTop
            -- lbl.AutoSize = false
            lbl.Constraints.MinHeight =spacing


            local editable = (type(data) == "table" and data.x ~= nil and data.y ~= nil)
            if readOnlyFields[k] then
                editable = false
            end


            -- edit box
            local edit = createEdit(_rPanel)
            edit.Top = y
            edit.Align = alTop
            edit.Height = spacing
            edit.Text = tostring(v)
            edit.ReadOnly = not editable
            -- live update the table when editing
            edit.OnChange = function(sender)
                local val = sender.Text
                local originalType = type(v)

                if originalType == "number" then
                    local n = tonumber(val)
                    if n ~= nil then
                        data[k] = n
                    else
                        -- invalid input, revert to previous
                        sender.Text = tostring(data[k])
                    end
                elseif originalType == "boolean" then
                    if val == "true" or val == 1 then
                        data[k] = true
                    elseif val == "false" or val == 0 then
                        data[k] = false
                    else
                        -- invalid input, revert to previous
                        sender.Text = tostring(data[k])
                    end
                else
                    -- string or other types: accept anything
                    data[k] = val

                end

                if k == "text" then
                    local node = getNodeByData(data)
                    if node then
                        node.Text = data.text
                    end
                end


            end
            edit.OnExit = function(sender)

            end

            y = y + spacing
        end
    end
end

local draggingNode = nil
local function dragAndDrop(parent)

    parent.DragCursor = crDrag
    parent.AllowDrop = True

    parent.DragMode = dmAutomatic
    parent.DragKind = dkDrag
    parent.ReadOnly = true
    parent.AllowDrop = true
    -- parent.OnMouseDown = function(sender, button, x, y)
    --     --this is registerd and working. 
    --     print("OnMouseDown")
    --     testsender2 = sender
    --     if button == mbLeft then
    --         draggingNode = sender
    --     end
    -- end

    parent.OnEndDrag = function(sender, target, x, y)
        Logger.debug("OnEndDrag")
        draggingNode = nil
    end
    -- OnEndDrag
    -- OnDragDrop
    -- OnDragOver
    -- OnStartDrag

    parent.OnDragOver = function(sender, source, x, y, state, accept)
        Logger.debug("OnDragOver", x, y)
        accept = true
    end
    parent.OnDragDrop = function(sender, source, x, y)
        Logger.debug("OnDragDrop fired")
        draggingNode = nil
        -- local target = sender.GetNodeAt(x, y)
        -- local dragged = sender.Selected

        -- if not target or not dragged then return end
        -- if dragged.Parent ~= target.Parent then return end

        -- local parentNode = dragged.Parent
        -- local parentData = NodeData[parentNode.AbsoluteIndex]

        -- if not parentData or not parentData.children then return end

        -- local list = parentData.items

        -- -- find indices
        -- local fromIdx, toIdx
        -- for i, v in ipairs(list) do
        --     if NodeData[dragged.AbsoluteIndex] == v then
        --         fromIdx = i
        --     end
        --     if NodeData[target.AbsoluteIndex] == v then
        --         toIdx = i
        --     end
        -- end

        -- if not fromIdx or not toIdx or fromIdx == toIdx then return end

        -- -- move in data
        -- local item = table.remove(list, fromIdx)
        -- table.insert(list, toIdx, item)

        -- -- move visually
        -- dragged.MoveTo(target, naInsert)
    end

end


local function tree_view_popup(parent)

    local popup_01 = createPopupMenu(parent)
    parent.PopupMenu = popup_01
    testsender3 = popup_01

    popup_01.OnPopup = function()
        local node, data = getSelectedNodeAndData()
        local allow = ( node ~= nil and type(data) == "table" and data.custom == true )

    end
    parent.OnMouseDown = function(sender, button, x, y)
        if button == mbRight then
            local node, data = getSelectedNodeAndData()
            local allow = ( node ~= nil and type(data) == "table" and data.custom == true )
            popup_01.AutoPopup = allow

        end
    end
    


    local _add_new_item = createMenuItem(popup_01)
    -- “Add location here” (uses current player coords) ?? 
    _add_new_item.Caption = "Add location"
    

    _add_new_item.OnClick = function()
        Logger.debug("_add_new_item")
        local node, data = getSelectedNodeAndData()
        if not node or type(data) ~= "table" then return end
        if data.custom ~= true then return end
        if not data.locations then return end

        local _x, _y, _z = getPlayerPos()

        -- create new item
        local newItem = { text = "new pos",  x = _x,     y=_y , z = _z}
        table.insert(data.locations, newItem)

        -- visual node
        local newNode = node.Add(newItem.text, node) -- Create the vvisual node 
        NodeData[newNode.AbsoluteIndex] = newItem -- store the node ref 
        node.Expanded = true
        parent.Selected = newNode
    end
    

    local _add_new_group = createMenuItem(popup_01)
    _add_new_group.Caption = "Add New Group"
    _add_new_group.OnClick = function()
        Logger.debug("_add_new_group")
        local node, data = getSelectedNodeAndData()

        data.locations = data.locations or {}


        -- create new item
        local newItem = { text = "newGroupName", locations = {} , custom = true}

        table.insert(data.locations, newItem) -- insert to MapData_Array

        -- visual node
        local newNode = node.Add(newItem.text, node) -- Create the node 
        NodeData[newNode.AbsoluteIndex] = newItem -- store the node ref 

        node.Expanded = true
        parent.Selected = newNode

    end



    local _delete_item = createMenuItem(popup_01)
    _delete_item.Caption = "Delete item"
    
    _delete_item.OnClick = function()
            Logger.debug("_delete_item")

    end

    popup_01.Items.add(_add_new_item)
    popup_01.Items.add(_delete_item)
    popup_01.Items.add(_add_new_group)

end




-- =====================
-- Build the Tree view
-- =====================
local function build_tree_view(parent , array)
        -- tree_01.Name =
    local tree_01 = createTreeView(parent)
    _ref_tree_view = tree_01 -- add for referense elsewhere where i need it in some way 
    tree_01.Align = alClient
    tree_01.ReadOnly = true -- not to modify texts-
    tree_01.DragMode = dmAutomatic
    tree_01.DragKind = dkDrag
    tree_01.Items.Clear()
    tree_01.ShowButtons=true
    tree_01.RightClickSelect=true
    tree_01.RowSelect=true

    tree_01.OnClick = function(sender) -- sends 1 arg
        --Logger.debug("OnClick")

    end
    tree_01.OnCollapsing = function(sender, node)  -- sends 2 args
    end

    -- TELEPORT ON DUBBLE CLICK ITEM ! 
    tree_01.OnDblClick = function(sender) -- sends 1 arg
        local node = sender.Selected
        if not node then return end
        local data = NodeData[node.AbsoluteIndex]
        if not data then return end

        ----------------------------------------------------------------
        -- CASE 2: Single item but missing coordinates → NO teleport
        ----------------------------------------------------------------
        if not hasXY(data) then
            Logger.debug(
                "No teleport (missing coordinates):",
                data.text or "<no text>"
            )
            Navigator.selecteditem = nil
            return
        end

        ----------------------------------------------------------------
        -- CASE 3: Valid single-location teleport
        ----------------------------------------------------------------
        Logger.debug(
            "Teleporting to:",
            data.text,
            "x:", data.x,
            "y:", data.y,
            "z:", data.z
        )

        Navigator.selecteditem = data
        Navigator.selectednodeindex = node.AbsoluteIndex

        local target = "_navigator1_"
        local mr = getAddressList().GetMemoryRecordByDescription(target)
        if mr then
            mr.Active = true
        end


    end
    tree_01.OnNodeChange = function(sender, node, allowChange) -- no event
    end

    -- FOR NAVIGATOR ROTATION 
    tree_01.OnSelectionChanged = function(sender)
        local node = sender.Selected
        if not node then return end

        local data = NodeData[node.AbsoluteIndex]
        if not data then return end

        -- Always update property panel
        showPropertyEditor(props, data)

        Logger.debug("numitems:", getItemsCount(data))

        --print(GF.serializeTable(data,2,true))

        ----------------------------------------------------------------
        -- CASE 1: Item has child locations → list mode ONLY
        ----------------------------------------------------------------
        Navigator.selectednodeindex = node.AbsoluteIndex
        if type(data.locations) == "table" then
            Navigator.selectednodeindex = node.AbsoluteIndex
            Logger.debug("Setting listLocations",getItemsCount(data.locations))
            Navigator.listLocations = data.locations
            Navigator.selecteditem = nil
            return
        end

    end
    tree_01.OnExpanding = function(sender, node) -- sends 2 arg
    end

    tree_01.beginUpdate()
    addTreeNodes(tree_01, array)
    tree_01.endUpdate()
    tree_view_popup(tree_01)
    dragAndDrop(tree_01)
    testsender1 = tree_01 -- referense for outside access.

end




-- =====================
-- building the form
-- =====================
local function buildForm(form, name ,dataArray)
    local array = dataArray

    if not mainForm.DFE then
        mainForm.DFE = {} -- incase it does not existing, add it. This is our custom cache
    elseif mainForm.DFE[name] then
        -- if controloo already exsist destroy it and recreate
        mainForm.DFE[name]:destroy()
        --mainForm[name]:destroy()
        --_G.CETrainer.CEPanel_NavigatorSelection_test2:destroy()
        mainForm.DFE[name] = nil
    end

    local panel_01 = createPanel(form)
    panel_01.name = name
    panel_01.BorderSpacing.Left = 10
    panel_01.BorderSpacing.Top = 10
    panel_01.BorderSpacing.Bottom = 10
    panel_01.BorderSpacing.Right = 10
    panel_01.BorderStyle = bsSizeable
    panel_01.Align = alClient
    panel_01.Width = 200


    local topPanel = createPanel(panel_01)
    topPanel.Align = alTop
    topPanel.top = 1
    topPanel.parent = panel_01
    topPanel.Height = 450


    local splitter = createSplitter(panel_01)
    splitter.Align = alTop
    splitter.top = 500
    splitter.Height = 20
    splitter.ResizeStyle = rsLine
    splitter.MinSize = 100

    local bottomPanel = createPanel(panel_01)
    bottomPanel.Align = alClient
    props = bottomPanel

    debugpanel = props

    build_tree_view(topPanel,array)





    -- splitter.OnMoved = function()
    --     print(topPanel.Height)
    -- end

    mainForm.DFE[panel_01.name] = panel_01
    --debugpanel = panel_01

    return
end


-- print(panel.Align)
-- print(panel.Anchors)
buildForm(mainForm, nameOfPanel,MapData_Array)










