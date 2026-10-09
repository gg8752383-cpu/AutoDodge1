-- Dex++ companion plugin: searchable view of objects already indexed by Explorer.
-- This plugin only reads client-visible Instances. It does not invoke remotes or bypass permissions.
local pluginData = {
    Name = "DexSearchPanel",
    FriendlyName = "Dex Object Search",
}

local Main, Lib, Apps, Settings
local API, RMD, env, service, plr, create, createSimple
local Explorer

local function initDeps(data)
    Main, Lib, Apps, Settings = data.Main, data.Lib, data.Apps, data.Settings
    API, RMD, env, service, plr = data.API, data.RMD, data.env, data.service, data.plr
    create, createSimple = data.create, data.createSimple
    Explorer = Apps and Apps.Explorer
end

local function initAfterMain()
    Explorer = Apps and Apps.Explorer
end

local function main()
    local Panel = {}
    local window
    local rows = {}
    local query = ""
    local category = "All"
    local statusLabel
    local listFrame
    local searchBox
    local countLabel
    local copyButton
    local categoryButtons = {}
    local scanning = false

    local function classify(obj)
        local name = string.lower(obj.Name or "")
        local class = obj.ClassName or "Unknown"
        if class == "RemoteEvent" or class == "RemoteFunction" or class == "UnreliableRemoteEvent" or name:find("remote", 1, true) then
            return "Remotes"
        elseif class == "ModuleScript" then
            return "Modules"
        elseif class == "Script" or class == "LocalScript" then
            return "Scripts"
        elseif obj:IsA("BasePart") then
            local hasBox = name:find("box", 1, true) ~= nil
            local hasHitOrHurt = name:find("hit", 1, true) ~= nil or name:find("hurt", 1, true) ~= nil
            if (hasBox and hasHitOrHurt)
                or name:find("hitpart", 1, true)
                or name:find("hurtpart", 1, true) then
                return "Hitboxes"
            end
            return "Parts"
        elseif class == "BindableEvent" or class == "BindableFunction" then
            return "Bindable"
        end
        return "Other"
    end

    local function getPath(obj)
        local pathParts = {}
        local current = obj
        local depth = 0
        while current and current ~= game and depth < 40 do
            local okName, name = pcall(function() return current.Name end)
            if not okName then break end
            table.insert(pathParts, 1, tostring(name))
            local okParent, parent = pcall(function() return current.Parent end)
            if not okParent then
                current = nil
                break
            end
            current = parent
            depth = depth + 1
        end
        local prefix = (current == game) and "game." or "<detached>."
        return prefix .. table.concat(pathParts, ".")
    end

    local function getIndexedObjects()
        if Explorer and type(Explorer.GetIndexedObjects) == "function" then
            local ok, objects = pcall(Explorer.GetIndexedObjects)
            if ok and type(objects) == "table" then
                return objects, true
            end
        end
        -- Compatibility fallback for an unpatched Dex++ build.
        local ok, objects = pcall(function() return game:GetDescendants() end)
        if ok and type(objects) == "table" then
            return objects, false
        end
        return {}, false
    end

    local function isStillIndexed(obj)
        if not obj then return false end
        if Explorer and type(Explorer.GetNodeForObject) == "function" then
            local ok, node = pcall(Explorer.GetNodeForObject, obj)
            return ok and node ~= nil
        end
        local ok, parent = pcall(function() return obj.Parent end)
        return ok and parent ~= nil
    end

    local function clearRows()
        if not listFrame then return end
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end

    local function refreshList()
        if not listFrame then return end
        clearRows()
        local shown, matched = 0, 0
        local y = 0
        for _, item in ipairs(rows) do
            local obj = item.Object
            if isStillIndexed(obj) then
                local text = string.lower(item.Path .. " " .. item.Class .. " " .. item.Name .. " " .. item.Category)
                local matchesQuery = query == "" or text:find(string.lower(query), 1, true) ~= nil
                local matchesCategory = category == "All" or item.Category == category
                if matchesQuery and matchesCategory then
                    matched = matched + 1
                    if shown < 220 then
                        local button = Instance.new("TextButton")
                        button.Name = "Result_" .. tostring(shown + 1)
                        button.BackgroundColor3 = Color3.fromRGB(38, 42, 50)
                        button.BorderSizePixel = 0
                        button.TextColor3 = Color3.fromRGB(235, 238, 245)
                        button.TextXAlignment = Enum.TextXAlignment.Left
                        button.TextSize = 12
                        button.Font = Enum.Font.Code
                        button.Size = UDim2.new(1, -8, 0, 25)
                        button.Position = UDim2.new(0, 4, 0, y)
                        button.Text = string.format("[%s] %s  —  %s", item.Category, item.Name, item.Class)
                        button.Parent = listFrame
                        button.MouseButton1Click:Connect(function()
                            if not isStillIndexed(obj) then
                                statusLabel.Text = "Object is no longer indexed. Press Refresh scan."
                                return
                            end
                            if Explorer then
                                pcall(function()
                                    local node = Explorer.GetNodeForObject and Explorer.GetNodeForObject(obj)
                                    if node and Explorer.Selection then
                                        Explorer.Selection:Set(node)
                                    end
                                    if Explorer.ViewObj then
                                        Explorer.ViewObj(obj)
                                    end
                                end)
                            end
                            local clipboard = env and env.setclipboard
                            if type(clipboard) == "function" then
                                pcall(clipboard, item.Path)
                            end
                            statusLabel.Text = item.Path .. "  (opened in Explorer; copied if supported)"
                        end)
                        y = y + 28
                        shown = shown + 1
                    end
                end
            end
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, y)
        countLabel.Text = string.format("%d results%s", matched, matched > shown and (" (showing " .. shown .. ")") or "")
    end

    -- Copies only the currently selected category, never the entire scan by accident.
    local function copySelectedCategory()
        if category == "All" then
            statusLabel.Text = "Choose a category first (for example Hitboxes or Remotes)."
            return
        end
        if scanning then
            statusLabel.Text = "Wait for the scan to finish before copying."
            return
        end
        if not copyButton then return end

        local selectedCategory = category
        copyButton.Active = false
        copyButton.AutoButtonColor = false
        copyButton.Text = "Copying..."
        statusLabel.Text = "Preparing " .. selectedCategory .. " category..."

        task.spawn(function()
            local lines = {"-- " .. selectedCategory .. " category"}
            local count = 0
            for i, item in ipairs(rows) do
                if item.Category == selectedCategory and isStillIndexed(item.Object) then
                    lines[#lines + 1] = string.format("[%s] %s | %s", item.Class, item.Name, item.Path)
                    count = count + 1
                end
                if i % 400 == 0 then task.wait() end
            end

            if count == 0 then
                statusLabel.Text = "No indexed objects found in " .. selectedCategory .. "."
            else
                local output = table.concat(lines, "\n")
                local clipboard = env and env.setclipboard
                if type(clipboard) ~= "function" then
                    local ok, globalClipboard = pcall(function() return setclipboard end)
                    if ok and type(globalClipboard) == "function" then
                        clipboard = globalClipboard
                    end
                end

                if type(clipboard) ~= "function" then
                    statusLabel.Text = "Clipboard API unavailable. Found " .. count .. " " .. selectedCategory .. " objects."
                else
                    local ok, err = pcall(clipboard, output)
                    if ok then
                        statusLabel.Text = string.format("Copied %d %s objects (%d characters).", count, selectedCategory, #output)
                    else
                        statusLabel.Text = "Copy failed: " .. tostring(err)
                    end
                end
            end

            if copyButton and copyButton.Parent then
                copyButton.Active = true
                copyButton.AutoButtonColor = true
                copyButton.Text = "Copy category"
            end
        end)
    end

    local function scan()
        if scanning or not statusLabel then return end
        scanning = true
        statusLabel.Text = "Reading objects indexed by Dex++..."
        task.spawn(function()
            local objects, fromDex = getIndexedObjects()
            local newRows = {}
            for i, obj in ipairs(objects) do
                if obj and typeof(obj) == "Instance" then
                    local ok, item = pcall(function()
                        return {
                            Object = obj,
                            Name = obj.Name,
                            Class = obj.ClassName,
                            Category = classify(obj),
                            Path = getPath(obj),
                        }
                    end)
                    if ok and item then
                        newRows[#newRows + 1] = item
                    end
                end
                if i % 400 == 0 then task.wait() end
            end
            rows = newRows
            scanning = false
            statusLabel.Text = string.format(
                "Scan complete: %d objects %s.",
                #rows,
                fromDex and "indexed by Dex++" or "visible to the client (fallback mode)"
            )
            refreshList()
        end)
    end

    Panel.Init = function()
        window = Lib.Window.new()
        window:SetTitle("Dex Object Search")
        window:Resize(560, 420)
        window.Draggable = true
        Panel.Window = window

        local root = Instance.new("Frame")
        root.Name = "DexObjectSearchRoot"
        root.BackgroundTransparency = 1
        root.Size = UDim2.new(1, 0, 1, 0)
        root.Parent = window.GuiElems.Content

        searchBox = Instance.new("TextBox")
        searchBox.Name = "Search"
        searchBox.PlaceholderText = "Search names, paths, classes..."
        searchBox.Text = ""
        searchBox.ClearTextOnFocus = false
        searchBox.BackgroundColor3 = Color3.fromRGB(35, 39, 46)
        searchBox.BorderSizePixel = 0
        searchBox.TextColor3 = Color3.new(1, 1, 1)
        searchBox.PlaceholderColor3 = Color3.fromRGB(160, 165, 175)
        searchBox.TextSize = 14
        searchBox.Size = UDim2.new(1, -150, 0, 30)
        searchBox.Position = UDim2.new(0, 5, 0, 5)
        searchBox.Parent = root
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            query = searchBox.Text
            refreshList()
        end)

        local scanButton = Instance.new("TextButton")
        scanButton.Text = "Refresh scan"
        scanButton.TextColor3 = Color3.new(1, 1, 1)
        scanButton.TextSize = 13
        scanButton.BackgroundColor3 = Color3.fromRGB(58, 92, 145)
        scanButton.BorderSizePixel = 0
        scanButton.Size = UDim2.new(0, 130, 0, 30)
        scanButton.Position = UDim2.new(1, -135, 0, 5)
        scanButton.Parent = root
        scanButton.MouseButton1Click:Connect(scan)

        local categoryBar = Instance.new("Frame")
        categoryBar.BackgroundTransparency = 1
        categoryBar.Size = UDim2.new(1, -10, 0, 28)
        categoryBar.Position = UDim2.new(0, 5, 0, 40)
        categoryBar.Parent = root
        local categories = {"All", "Remotes", "Hitboxes", "Scripts", "Modules", "Bindable", "Parts", "Other"}
        for i, cat in ipairs(categories) do
            local btn = Instance.new("TextButton")
            btn.Text = cat
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 11
            btn.BackgroundColor3 = (cat == category) and Color3.fromRGB(58, 92, 145) or Color3.fromRGB(48, 53, 63)
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1 / #categories, -3, 1, 0)
            btn.Position = UDim2.new((i - 1) / #categories, 0, 0, 0)
            btn.Parent = categoryBar
            categoryButtons[cat] = btn
            btn.MouseButton1Click:Connect(function()
                category = cat
                for buttonCategory, categoryButton in pairs(categoryButtons) do
                    categoryButton.BackgroundColor3 = (buttonCategory == category)
                        and Color3.fromRGB(58, 92, 145) or Color3.fromRGB(48, 53, 63)
                end
                refreshList()
            end)
        end

        countLabel = Instance.new("TextLabel")
        countLabel.BackgroundTransparency = 1
        countLabel.TextColor3 = Color3.fromRGB(210, 215, 225)
        countLabel.TextXAlignment = Enum.TextXAlignment.Left
        countLabel.TextSize = 12
        countLabel.Size = UDim2.new(1, -150, 0, 22)
        countLabel.Position = UDim2.new(0, 5, 0, 70)
        countLabel.Parent = root

        copyButton = Instance.new("TextButton")
        copyButton.Name = "CopyCategory"
        copyButton.Text = "Copy category"
        copyButton.TextColor3 = Color3.new(1, 1, 1)
        copyButton.TextSize = 12
        copyButton.BackgroundColor3 = Color3.fromRGB(58, 120, 86)
        copyButton.BorderSizePixel = 0
        copyButton.Size = UDim2.new(0, 135, 0, 24)
        copyButton.Position = UDim2.new(1, -140, 0, 68)
        copyButton.Parent = root
        copyButton.MouseButton1Click:Connect(copySelectedCategory)

        listFrame = Instance.new("ScrollingFrame")
        listFrame.Name = "Results"
        listFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
        listFrame.BorderSizePixel = 0
        listFrame.Position = UDim2.new(0, 5, 0, 96)
        listFrame.Size = UDim2.new(1, -10, 1, -128)
        listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        listFrame.ScrollBarThickness = 7
        listFrame.Parent = root

        statusLabel = Instance.new("TextLabel")
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Ready. Press Refresh scan."
        statusLabel.TextColor3 = Color3.fromRGB(180, 190, 205)
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
        statusLabel.TextSize = 11
        statusLabel.Size = UDim2.new(1, -10, 0, 22)
        statusLabel.Position = UDim2.new(0, 5, 1, -25)
        statusLabel.Parent = root

        scan()
    end

    return Panel
end

return {
    InitDeps = initDeps,
    InitAfterMain = initAfterMain,
    Main = main,
    PluginData = pluginData,
}
