-- Dex++ companion plugin: "Important Data" report panel.
-- Collects gameplay-relevant data that Dex++ has already indexed (hitboxes, attack/skill setup,
-- remotes, animations, tools, character stats, config values, prompts) and lets you copy it.
-- Read-only: it only reads client-visible Instance properties. It never fires or hooks remotes,
-- never decompiles scripts and never bypasses permissions.
local pluginData = {
    Name = "DexImportantData",
    FriendlyName = "Dex Important Data",
}

local Main, Lib, Apps, Settings
local API, RMD, env, service, plr, create, createSimple
local Explorer
local ScriptViewer

local function initDeps(data)
    Main, Lib, Apps, Settings = data.Main, data.Lib, data.Apps, data.Settings
    API, RMD, env, service, plr = data.API, data.RMD, data.env, data.service, data.plr
    create, createSimple = data.create, data.createSimple
    Explorer = Apps and Apps.Explorer
    ScriptViewer = Apps and Apps.ScriptViewer
end

local function initAfterMain()
    Explorer = Apps and Apps.Explorer
    ScriptViewer = Apps and Apps.ScriptViewer
end

local function main()
    local Panel = {}
    local window, root
    local statusLabel, listFrame, searchBox, countLabel
    local setStatus -- forward declaration used by the row-click handler
    local tabButtons = {}

    local sectionRows = {}   -- [sectionKey] = sorted array of grouped rows
    local sectionTotals = {} -- [sectionKey] = number of real instances (before grouping)
    local scannedCount = 0
    local activeTab = "All"
    local query = ""
    local scanning = false
    local scannedOnce = false

    local MAX_LIST_ROWS = 200
    local MAX_ALL_ROWS_PER_SECTION = 20
    local MAX_REPORT_ROWS = 500
    local MAX_CLIPBOARD_CHARS = 400000
    local SAVE_FOLDER = "dex/saved"

    -- Category catalog over Dex++'s existing Explorer index. Each row keeps the real Instance.
    local SECTIONS = {
        { Key = "Hitboxes", Label = "Hitboxes / Hurtboxes", Short = "Hitboxes" },
        { Key = "Scripts", Label = "Scripts / Modules", Short = "Scripts" },
        { Key = "Models", Label = "Models", Short = "Models" },
        { Key = "Other", Label = "Other (unclassified objects)", Short = "Other" },
    }
    local sectionByKey = {}
    for _, sec in ipairs(SECTIONS) do sectionByKey[sec.Key] = sec end

    ---------------------------------------------------------------------------
    -- Name heuristics
    ---------------------------------------------------------------------------
    local hitTerms = {
        "hitbox", "hit_box", "hit-box", "hit box", "hurtbox", "hurt_box", "hurt-box", "hurt box",
        "damagebox", "damage_box", "attackbox", "attack_box", "hitarea", "hit_area", "hitzone",
        "hit_zone", "hurtzone", "hurt_zone", "hitregion", "hitvolume", "hurtvolume", "hurtarea",
        "meleearea", "slashbox", "swingbox",
    }
    local combatStrong = {
        "attack", "damage", "combo", "swing", "slash", "punch", "strike", "skill", "abilit",
        "parry", "dodge", "dash", "stun", "knockback", "cooldown", "projectile", "bullet",
        "missile", "weapon", "combat", "ultimate", "moveset", "blocking", "evade", "ragdoll",
        "critical", "fireball", "melee", "hurt", "aoe", "iframe", "invincib", "invuln",
        "spell", "magic", "cast", "slam", "swipe", "kick", "shoot", "gun", "sword", "blade", "knife",
        "arrow", "grab", "throw", "counter", "guard", "poise", "stagger", "launch", "windup",
        "endlag", "hitstun", "startup", "heavy", "charge", "stamina", "posture", "shockwave",
        "beam", "laser", "rocket", "grenade", "bomb", "trap", "heal", "buff", "debuff", "burn",
        "poison", "bleed", "freeze", "shock", "lifesteal", "execute", "finisher",
    }
    local partWeak = { "hit", "hits", "atk", "dmg", "kb", "m1", "m2", "m3", "m4", "hurt", "dmgpart" }
    local combatWeak = { "m1", "m2", "m3", "m4", "hit", "hits", "kb", "crit", "ult", "block",
        "move", "moves", "special", "cd", "atk", "dmg" }
    local importantStrong = {
        "health", "maxhealth", "walkspeed", "jumppower", "jumpheight", "stamina", "mana", "ammo",
        "reload", "recoil", "armor", "defense", "defence", "shield", "firerate", "regen",
        "lifesteal", "radius", "duration", "config", "stats",
    }
    local importantWeak = { "speed", "range", "reach", "power", "rate", "delay", "level", "energy",
        "stat", "hp", "charge" }

    local function buildWeakPatterns(list)
        local patterns = {}
        for i, term in ipairs(list) do
            patterns[i] = "%f[%a]" .. term .. "%f[%A]"
        end
        return patterns
    end
    local combatWeakPatterns = buildWeakPatterns(combatWeak)
    local partWeakPatterns = buildWeakPatterns(partWeak)
    local importantWeakPatterns = buildWeakPatterns(importantWeak)

    local function anyPlain(text, list)
        for i = 1, #list do
            if string.find(text, list[i], 1, true) then return true end
        end
        return false
    end

    local function anyPattern(text, patterns)
        for i = 1, #patterns do
            if string.find(text, patterns[i]) then return true end
        end
        return false
    end

    local nameCache = {}
    -- returns: isHitboxName, isStrongCombat, isWeakCombat, isImportant
    local function classifyName(name)
        local cached = nameCache[name]
        if cached then return cached[1], cached[2], cached[3], cached[4], cached[5] end
        local lname = string.lower(name)
        local spaced = string.gsub(name, "(%l)(%u)", "%1 %2")
        local tname = string.lower(spaced)
        local hit = anyPlain(lname, hitTerms)
        local strongC = hit or anyPlain(lname, combatStrong)
        local weakC = anyPattern(tname, combatWeakPatterns)
        local imp = strongC or weakC or anyPlain(lname, importantStrong) or anyPattern(tname, importantWeakPatterns)
        local partW = anyPattern(tname, partWeakPatterns)
        nameCache[name] = { hit, strongC, weakC, imp, partW }
        return hit, strongC, weakC, imp, partW
    end

    ---------------------------------------------------------------------------
    -- Safe readers and formatting
    ---------------------------------------------------------------------------
    local function index(obj, prop) return obj[prop] end

    local function read(obj, prop)
        local ok, value = pcall(index, obj, prop)
        if ok then return value end
        return nil
    end

    local function isA(obj, className)
        local ok, result = pcall(obj.IsA, obj, className)
        return ok and result == true
    end

    -- Audio objects are deliberately excluded from the catalog and every recursive export.
    local audioClasses = {
        Sound = true, AudioPlayer = true, AudioEmitter = true, AudioListener = true,
        AudioDeviceInput = true, AudioDeviceOutput = true, AudioFader = true,
        AudioAnalyzer = true, Wire = true,
    }
    local function isAudioObject(obj)
        local class = tostring(read(obj, "ClassName") or "")
        if audioClasses[class] then return true end
        -- Future/related audio classes are also omitted when Roblox exposes them.
        return string.find(class, "Audio", 1, true) == 1
    end

    local function pathPart(name)
        if string.match(name, "^[%a_][%w_]*$") then return "." .. name end
        return "[" .. string.format("%q", name) .. "]"
    end

    local function getPath(obj)
        local parts = {}
        local current = obj
        local depth = 0
        while current and current ~= game and depth < 50 do
            local okName, name = pcall(index, current, "Name")
            if not okName then break end
            table.insert(parts, 1, pathPart(tostring(name)))
            local okParent, parent = pcall(index, current, "Parent")
            if not okParent then
                current = nil
                break
            end
            current = parent
            depth = depth + 1
        end
        local prefix = (current == game) and "game" or "<detached>"
        return prefix .. table.concat(parts)
    end

    local function fmtNum(n)
        if n ~= n then return "nan" end
        if n == math.huge then return "inf" end
        if n == -math.huge then return "-inf" end
        if n == math.floor(n) and math.abs(n) < 1e9 then return tostring(n) end
        local s = string.format("%.3f", n)
        s = string.gsub(s, "0+$", "")
        s = string.gsub(s, "%.$", "")
        return s
    end

    local function fmtValue(v)
        local t = typeof(v)
        if t == "number" then
            return fmtNum(v)
        elseif t == "string" then
            local s = string.gsub(v, "\r", " ")
            s = string.gsub(s, "\n", " ")
            if #s > 80 then s = string.sub(s, 1, 77) .. "..." end
            return "\"" .. s .. "\""
        elseif t == "boolean" then
            return tostring(v)
        elseif t == "Vector3" then
            return fmtNum(v.X) .. ", " .. fmtNum(v.Y) .. ", " .. fmtNum(v.Z)
        elseif t == "Vector2" then
            return fmtNum(v.X) .. ", " .. fmtNum(v.Y)
        elseif t == "Color3" then
            return string.format("Color3(%d,%d,%d)", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
        elseif t == "EnumItem" then
            return v.Name
        elseif t == "Instance" then
            return getPath(v)
        elseif t == "nil" then
            return "nil"
        end
        local s = tostring(v)
        if #s > 80 then s = string.sub(s, 1, 77) .. "..." end
        return s
    end

    local function add(list, label, value)
        if value ~= nil then list[#list + 1] = label .. "=" .. fmtValue(value) end
    end

    local function parentTag(obj)
        local parent = read(obj, "Parent")
        if parent == nil then return nil end
        return tostring(read(parent, "Name")) .. "(" .. tostring(read(parent, "ClassName")) .. ")"
    end

    local function sortedKeys(t)
        local keys = {}
        for k in pairs(t) do keys[#keys + 1] = tostring(k) end
        table.sort(keys, function(a, b) return string.lower(a) < string.lower(b) end)
        return keys
    end

    -- returns text ("" if none), number of important attributes, total attributes
    local function attributeBits(obj, onlyImportant, limit)
        local ok, attrs = pcall(obj.GetAttributes, obj)
        if not ok or type(attrs) ~= "table" then return "", 0, 0 end
        local keys = sortedKeys(attrs)
        local total = #keys
        local matched = 0
        local bits = {}
        for _, key in ipairs(keys) do
            local _, _, _, imp = classifyName(key)
            if imp then matched = matched + 1 end
            if (not onlyImportant) or imp then
                if #bits < limit then
                    bits[#bits + 1] = "Attr." .. key .. "=" .. fmtValue(attrs[key])
                end
            end
        end
        local base = onlyImportant and matched or total
        if #bits > 0 and base > #bits then
            bits[#bits + 1] = string.format("(+%d attrs)", base - #bits)
        end
        return table.concat(bits, " | "), matched, total
    end

    local valueClass = {
        NumberValue = true, IntValue = true, StringValue = true, BoolValue = true, ObjectValue = true,
        Vector3Value = true, CFrameValue = true, Color3Value = true, BrickColorValue = true, RayValue = true,
    }

    local function childSummary(obj, nameLimit, valueLimit)
        local ok, children = pcall(obj.GetChildren, obj)
        if not ok or type(children) ~= "table" then return "" end
        local names, values = {}, {}
        local visibleChildCount = 0
        for _, child in ipairs(children) do
            if not isAudioObject(child) then
                visibleChildCount = visibleChildCount + 1
                local okN, cName = pcall(index, child, "Name")
                local okC, cClass = pcall(index, child, "ClassName")
                if okN and okC then
                    if #names < nameLimit then names[#names + 1] = tostring(cName) .. ":" .. tostring(cClass) end
                    if valueClass[cClass] and #values < valueLimit then
                        local okV, v = pcall(index, child, "Value")
                        if okV then values[#values + 1] = tostring(cName) .. "=" .. fmtValue(v) end
                    end
                end
            end
        end
        local text = string.format("Children(%d): %s%s", visibleChildCount, table.concat(names, ", "), (visibleChildCount > #names) and ", ..." or "")
        if #values > 0 then text = text .. " | Values: " .. table.concat(values, ", ") end
        return text
    end

    ---------------------------------------------------------------------------
    -- Collection
    ---------------------------------------------------------------------------
    local ctx = { rows = {}, groups = {}, totals = {}, count = 0 }
    local coreGui = nil
    pcall(function() coreGui = game:GetService("CoreGui") end)

    -- Identical-looking objects (same name + same data) are merged into one row with a count.
    local function addRow(sectionKey, obj, name, details, score, sig)
        if coreGui then
            local okD, inCore = pcall(obj.IsDescendantOf, obj, coreGui)
            if okD and inCore then return end
        end
        ctx.totals[sectionKey] = (ctx.totals[sectionKey] or 0) + 1
        -- Keep every script path as its own row; duplicate names must not hide other scripts.
        local groupKey = sectionKey .. "|" .. name .. "|" .. (sectionKey == "Scripts" and getPath(obj) or (sig or details))
        local row = ctx.groups[groupKey]
        if row then
            row.Count = row.Count + 1
            return
        end
        row = {
            Section = sectionKey,
            Object = obj,
            Name = name,
            Path = getPath(obj),
            Details = details,
            Count = 1,
            Score = score or 0,
        }
        ctx.groups[groupKey] = row
        local list = ctx.rows[sectionKey]
        if not list then
            list = {}
            ctx.rows[sectionKey] = list
        end
        list[#list + 1] = row
    end

    local remoteClass = { RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true }
    local bindableClass = { BindableEvent = true, BindableFunction = true }
    local scriptClass = { Script = true, LocalScript = true, ModuleScript = true }
    local containerClass = { Folder = true, Configuration = true, Model = true }
    local physicsClass = {
        BodyVelocity = true, BodyForce = true, BodyPosition = true, BodyGyro = true, BodyThrust = true,
        BodyAngularVelocity = true, LinearVelocity = true, VectorForce = true, AlignPosition = true,
        AlignOrientation = true, AngularVelocity = true, Torque = true,
    }
    local physicsProps = { "Velocity", "VectorVelocity", "MaxForce", "Force", "MaxAxesForce", "Position",
        "MaxTorque", "AngularVelocity", "Torque", "P", "D", "Responsiveness", "MaxVelocity", "Enabled" }
    local partClass = {
        Part = true, MeshPart = true, UnionOperation = true, NegateOperation = true, WedgePart = true,
        CornerWedgePart = true, TrussPart = true, SpawnLocation = true, Seat = true, VehicleSeat = true,
    }

    local function partDetails(obj, class)
        local d = { class }
        add(d, "Shape", read(obj, "Shape"))
        add(d, "Size", read(obj, "Size"))
        add(d, "Transparency", read(obj, "Transparency"))
        add(d, "CanCollide", read(obj, "CanCollide"))
        add(d, "CanTouch", read(obj, "CanTouch"))
        add(d, "CanQuery", read(obj, "CanQuery"))
        add(d, "Massless", read(obj, "Massless"))
        add(d, "Anchored", read(obj, "Anchored"))
        local okTI, ti = pcall(obj.FindFirstChildOfClass, obj, "TouchInterest")
        local hasTouch = okTI and ti ~= nil
        if hasTouch then d[#d + 1] = "TouchInterest=true" end
        local pt = parentTag(obj)
        if pt then d[#d + 1] = "Parent=" .. pt end
        local attrText = attributeBits(obj, false, 10)
        if attrText ~= "" then d[#d + 1] = attrText end
        return d, hasTouch
    end

    local function isScriptObject(obj)
        if not obj then return false end
        local ok, class = pcall(function() return obj.ClassName end)
        return ok and (class == "Script" or class == "LocalScript" or class == "ModuleScript")
    end

    local function classifyObject(obj)
        local class = tostring(read(obj, "ClassName") or "Unknown")
        local name = string.lower(tostring(read(obj, "Name") or ""))
        if isAudioObject(obj) then return nil end
        if isScriptObject(obj) then return "Scripts" end
        if class == "Model" then return "Models" end
        local isBasePart = isA(obj, "BasePart")
        if isBasePart then
            local hitName = anyPlain(name, hitTerms) or anyPlain(name, {"hitpart", "hurtpart", "damagepart", "attackpart", "collisionbox"})
            if hitName then return "Hitboxes" end
            -- Heuristic catch for unnamed/poorly named hit volumes; category is explicitly approximate.
            local transparency = read(obj, "Transparency")
            local collide, touch, query = read(obj, "CanCollide"), read(obj, "CanTouch"), read(obj, "CanQuery")
            local size = read(obj, "Size")
            if transparency and transparency >= 0.85 and collide == false and (touch == true or query == false) and size and math.max(size.X, size.Y, size.Z) <= 12 then
                return "Hitboxes"
            end
            return "Other"
        end
        return "Other"
    end

    local function processObject(obj)
        if not obj or typeof(obj) ~= "Instance" or isAudioObject(obj) then return false end
        local class = tostring(read(obj, "ClassName") or "Unknown")
        local name = tostring(read(obj, "Name") or "<unnamed>")
        local category = classifyObject(obj)
        if not category then return false end
        local details = { class }
        add(details, "Path", getPath(obj))
        add(details, "Parent", parentTag(obj))
        if isA(obj, "BasePart") then
            add(details, "Size", read(obj, "Size"))
            add(details, "Transparency", read(obj, "Transparency"))
            add(details, "CanCollide", read(obj, "CanCollide"))
            add(details, "CanTouch", read(obj, "CanTouch"))
            add(details, "CanQuery", read(obj, "CanQuery"))
        elseif isScriptObject(obj) then
            if class ~= "ModuleScript" then add(details, "Disabled", read(obj, "Disabled")) end
            if class == "Script" then add(details, "RunContext", read(obj, "RunContext")) end
        elseif class == "RemoteEvent" or class == "RemoteFunction" or class == "UnreliableRemoteEvent" then
            add(details, "RemoteClass", class)
        elseif isA(obj, "ValueBase") then
            add(details, "Value", read(obj, "Value"))
        end
        local attrText = attributeBits(obj, false, 8)
        if attrText ~= "" then details[#details + 1] = attrText end
        local children = childSummary(obj, 8, 5)
        if children ~= "" then details[#details + 1] = children end
        addRow(category, obj, name, table.concat(details, " | "), 1, getPath(obj))
        return true
    end

    ---------------------------------------------------------------------------
    -- Read the objects already indexed by Dex++ Explorer. Fallback is used only
    -- if an older Dex++ build does not expose the index API.
    ---------------------------------------------------------------------------
    local function getIndexedObjects()
        local list, seen = {}, {}
        local fromDex = false
        local function addObjects(objects)
            if type(objects) ~= "table" then return end
            for _, entry in pairs(objects) do
                local obj = entry
                -- Support either a flat Instance list or Dex++'s object -> node map.
                if typeof(obj) ~= "Instance" and type(entry) == "table" then
                    obj = entry.Object or entry.Obj or entry.Instance
                end
                if typeof(obj) == "Instance" and not seen[obj] then
                    local ok, parent = pcall(function() return obj.Parent end)
                    if ok and (parent ~= nil or obj == game) then
                        seen[obj] = true
                        list[#list + 1] = obj
                    end
                end
            end
        end
        if Explorer and type(Explorer.GetIndexedObjects) == "function" then
            local ok, objects = pcall(Explorer.GetIndexedObjects)
            if ok and type(objects) == "table" then
                fromDex = true
                addObjects(objects)
            end
        end
        if not fromDex then
            local ok, descendants = pcall(function() return game:GetDescendants() end)
            if ok then addObjects(descendants) end
        end
        return list, fromDex
    end

    local function selectRow(row)
        local obj = row and row.Object
        if not obj then return end
        local okView, errView = pcall(function()
            if Explorer and type(Explorer.ViewObj) == "function" then
                Explorer.ViewObj(obj)
            elseif Explorer and type(Explorer.ViewNode) == "function" and type(Explorer.GetNodeForObject) == "function" then
                Explorer.ViewNode(Explorer.GetNodeForObject(obj))
            end
            if Explorer and Explorer.Window and type(Explorer.Window.Show) == "function" then Explorer.Window:Show() end
        end)
        if isScriptObject(obj) and ScriptViewer and type(ScriptViewer.ViewScript) == "function" then
            local ok, err = pcall(function() ScriptViewer.ViewScript(obj) end)
            if ok then setStatus("Opened script in Dex++ Viewer: " .. tostring(obj.Name))
            else setStatus("Viewer error: " .. string.sub(tostring(err), 1, 90)) end
        elseif okView then
            setStatus("Selected in Dex++ Explorer: " .. tostring(obj.Name) .. " [" .. tostring(obj.ClassName) .. "]")
        else
            setStatus("Explorer selection failed: " .. string.sub(tostring(errView), 1, 90))
        end
    end

    ---------------------------------------------------------------------------
    -- Report + export
    ---------------------------------------------------------------------------
    setStatus = function(text)
        if statusLabel and statusLabel.Parent then statusLabel.Text = text end
    end

    local function rowLine(row)
        local s = row.Path
        if row.Details ~= "" then s = s .. " | " .. row.Details end
        if row.Count > 1 then s = s .. " | x" .. tostring(row.Count) end
        return s
    end

    local function rowMatches(row)
        if query == "" then return true end
        if not row.Hay then row.Hay = string.lower(row.Path .. " " .. row.Details) end
        return string.find(row.Hay, query, 1, true) ~= nil
    end

    local function collectRows(sectionKey, useFilter)
        local out = {}
        for _, row in ipairs(sectionRows[sectionKey] or {}) do
            if (not useFilter) or rowMatches(row) then out[#out + 1] = row end
        end
        return out
    end

    local function buildReport(keys, useFilter)
        local lines = {}
        local dateText = "?"
        local okDate, d = pcall(os.date, "%Y-%m-%d %H:%M:%S")
        if okDate then dateText = tostring(d) end
        lines[#lines + 1] = "=== DEX++ CATEGORY CATALOG ==="
        lines[#lines + 1] = string.format("PlaceId: %s | Indexed objects: %d | %s", tostring(game.PlaceId), scannedCount, dateText)
        lines[#lines + 1] = "Rows retain real Instance references in the UI. Audio/sound objects are excluded, including from nested exports."
        for _, key in ipairs(keys) do
            local rows = collectRows(key, useFilter)
            lines[#lines + 1] = ""
            lines[#lines + 1] = string.format("--- %s (%d matched rows, %d categorized objects) ---", string.upper(sectionByKey[key].Label), #rows, sectionTotals[key] or 0)
            local seenObjects, written = {}, 0
            local function appendObject(obj, depth)
                if not obj or isAudioObject(obj) or seenObjects[obj] or written >= MAX_REPORT_ROWS then return end
                seenObjects[obj] = true
                written = written + 1
                local indent = string.rep("  ", math.min(depth, 12))
                local name = tostring(read(obj, "Name") or "<unnamed>")
                local class = tostring(read(obj, "ClassName") or "Unknown")
                lines[#lines + 1] = indent .. name .. " [" .. class .. "] | " .. getPath(obj)
                local okChildren, children = pcall(obj.GetChildren, obj)
                if okChildren and type(children) == "table" then
                    table.sort(children, function(a, b) return tostring(read(a, "Name") or "") < tostring(read(b, "Name") or "") end)
                    for _, child in ipairs(children) do appendObject(child, depth + 1) end
                end
            end
            for _, row in ipairs(rows) do
                if row.Object and not seenObjects[row.Object] then
                    seenObjects[row.Object] = true
                    lines[#lines + 1] = rowLine(row)
                    written = written + 1
                    -- Tree-style categories export every nested non-audio child. Other exports
                    -- include only matching objects to avoid dumping unrelated service trees.
                    if key == "Hitboxes" or key == "Models" then
                        local okChildren, children = pcall(row.Object.GetChildren, row.Object)
                        if okChildren and type(children) == "table" then
                            table.sort(children, function(a, b) return tostring(read(a, "Name") or "") < tostring(read(b, "Name") or "") end)
                            for _, child in ipairs(children) do appendObject(child, 1) end
                        end
                    end
                end
                if written >= MAX_REPORT_ROWS then break end
            end
            if written >= MAX_REPORT_ROWS then lines[#lines + 1] = "... output limit reached; narrow the category/search to export more." end
        end
        return table.concat(lines, "\n")
    end

    local function getClipboardFn()
        local fn = env and env.setclipboard
        if type(fn) ~= "function" and type(setclipboard) == "function" then fn = setclipboard end
        if type(fn) == "function" then return fn end
        return nil
    end

    local function getWriteFn()
        local fn = env and env.writefile
        if type(fn) ~= "function" and type(writefile) == "function" then fn = writefile end
        if type(fn) == "function" then return fn end
        return nil
    end

    local function ensureSaveFolder()
        local make = env and env.makefolder
        if type(make) ~= "function" and type(makefolder) == "function" then make = makefolder end
        if type(make) == "function" then
            pcall(make, "dex")
            pcall(make, SAVE_FOLDER)
        end
    end

    local function exportText(text, label, fileName)
        local clip = getClipboardFn()
        if clip and #text <= MAX_CLIPBOARD_CHARS then
            local ok, err = pcall(clip, text)
            if ok then
                setStatus(string.format("Copied %s (%d characters).", label, #text))
                return true
            end
            setStatus("Clipboard failed: " .. string.sub(tostring(err), 1, 80))
        end
        local write = getWriteFn()
        if write then
            ensureSaveFolder()
            local path = SAVE_FOLDER .. "/" .. fileName
            local ok, err = pcall(write, path, text)
            if ok then
                setStatus(string.format("%s saved to %s (%d characters).", label, path, #text))
                return true
            end
            setStatus("File save failed: " .. string.sub(tostring(err), 1, 80))
            return false
        end
        if clip then
            setStatus(string.format("%d characters is too large for the clipboard and no file API exists. Use the search box to narrow it.", #text))
        else
            setStatus("Copy failed: this executor has no setclipboard/writefile.")
        end
        return false
    end

    local function allKeys()
        local keys = {}
        for _, sec in ipairs(SECTIONS) do keys[#keys + 1] = sec.Key end
        return keys
    end

    local function copyAll()
        if not scannedOnce or scanning then
            setStatus("Scan first (or wait for the scan to finish).")
            return
        end
        exportText(buildReport(allKeys(), false), "all sections", "DexPlusPlus_Catalog_All.txt")
    end

    local function copyTab()
        if not scannedOnce or scanning then
            setStatus("Scan first (or wait for the scan to finish).")
            return
        end
        if activeTab == "All" then
            exportText(buildReport(allKeys(), true), "all sections", "DexPlusPlus_Catalog_All.txt")
        else
            local sec = sectionByKey[activeTab]
            exportText(buildReport({ activeTab }, true), sec.Label, "DexPlusPlus_Catalog_" .. activeTab .. ".txt")
        end
    end

    ---------------------------------------------------------------------------
    -- Scan + UI refresh
    ---------------------------------------------------------------------------
    local refreshList
    local updateTabs

    local function sortRows(rows)
        table.sort(rows, function(a, b)
            if a.Score ~= b.Score then return a.Score > b.Score end
            if a.Count ~= b.Count then return a.Count > b.Count end
            local an, bn = string.lower(a.Name), string.lower(b.Name)
            if an ~= bn then return an < bn end
            return a.Path < b.Path
        end)
    end

    local function scan()
        if scanning or not statusLabel then return end
        scanning = true
        scannedOnce = true
        setStatus("Reading all objects already indexed by Dex++...")
        task.spawn(function()
            local ok, err = pcall(function()
                local objects, fromDex = getIndexedObjects()
                nameCache = {}
                ctx = { rows = {}, groups = {}, totals = {}, count = 0 }
                local total = #objects
                for i = 1, total do
                    local obj = objects[i]
                    local okObj, accepted = pcall(processObject, obj)
                    if okObj and accepted then ctx.count = ctx.count + 1 end
                    if i % 500 == 0 then
                        task.wait()
                        setStatus(string.format("Indexing objects... %d / %d", i, total))
                    end
                end
                for _, rows in pairs(ctx.rows) do sortRows(rows) end
                sectionRows = ctx.rows
                sectionTotals = ctx.totals
                scannedCount = ctx.count
                ctx = { rows = {}, groups = {}, totals = {}, count = 0 }
                nameCache = {}
                setStatus(string.format("Done: %d objects from %s. Choose a category; Copy exports the whole category and nested descendants.", scannedCount, fromDex and "Dex++ index" or "visible game descendants (fallback)"))
            end)
            scanning = false
            if not ok then setStatus("Scan failed: " .. string.sub(tostring(err), 1, 100)) end
            if updateTabs then updateTabs() end
            if refreshList then refreshList() end
        end)
    end

    local function clearList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
        end
    end

    refreshList = function()
        if not listFrame or not listFrame.Parent then return end
        clearList()
        local shown, matched = 0, 0

        local function addButton(row, showTag)
            shown = shown + 1
            local button = Instance.new("TextButton")
            button.Name = "Row" .. tostring(shown)
            button.LayoutOrder = shown
            button.BackgroundColor3 = Color3.fromRGB(38, 42, 50)
            button.BorderSizePixel = 0
            button.TextColor3 = Color3.fromRGB(235, 238, 245)
            button.TextXAlignment = Enum.TextXAlignment.Left
            button.TextYAlignment = Enum.TextYAlignment.Top
            button.TextWrapped = true
            button.TextTruncate = Enum.TextTruncate.AtEnd
            button.TextSize = 11
            button.Font = Enum.Font.Code
            button.Size = UDim2.new(1, -8, 0, 46)
            local tag = showTag and ("[" .. sectionByKey[row.Section].Short .. "] ") or ""
            local count = (row.Count > 1) and ("x" .. tostring(row.Count) .. " ") or ""
            button.Text = tag .. count .. row.Name .. "\n" .. row.Details
            button.Parent = listFrame
            button.MouseButton1Click:Connect(function()
                selectRow(row)
            end)
        end

        if activeTab == "All" then
            for _, sec in ipairs(SECTIONS) do
                local rows = collectRows(sec.Key, true)
                matched = matched + #rows
                for i = 1, math.min(#rows, MAX_ALL_ROWS_PER_SECTION) do addButton(rows[i], true) end
            end
        else
            local rows = collectRows(activeTab, true)
            matched = #rows
            for i = 1, math.min(#rows, MAX_LIST_ROWS) do addButton(rows[i], false) end
        end

        if not scannedOnce then
            countLabel.Text = "Not scanned yet."
        elseif matched > shown then
            countLabel.Text = string.format("%d unique rows (showing %d; Copy has all)", matched, shown)
        else
            countLabel.Text = string.format("%d unique rows", matched)
        end
    end

    updateTabs = function()
        for key, btn in pairs(tabButtons) do
            if btn and btn.Parent then
                local sec = sectionByKey[key]
                if sec then
                    btn.Text = string.format("%s %d", sec.Short, #(sectionRows[key] or {}))
                else
                    btn.Text = "All"
                end
                btn.BackgroundColor3 = (key == activeTab) and Color3.fromRGB(58, 92, 145) or Color3.fromRGB(48, 53, 63)
            end
        end
    end

    ---------------------------------------------------------------------------
    -- UI
    ---------------------------------------------------------------------------
    local function makeButton(parent, text, color, size, position)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 12
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Size = size
        btn.Position = position
        btn.Parent = parent
        return btn
    end

    Panel.Init = function()
        window = Lib.Window.new()
        window:SetTitle("Dex++ Object Catalog")
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local w = math.max(300, math.min(430, viewport.X - 24))
        local h = math.max(260, math.min(400, viewport.Y - 40))
        window:Resize(w, h)
        window.MinX = 280
        window.MinY = 240
        window.Draggable = true
        window.Resizable = true
        window.PosX = math.max(8, math.floor((viewport.X - w) / 2))
        window.PosY = math.max(8, math.floor((viewport.Y - h) / 2))
        Panel.Window = window

        root = Instance.new("Frame")
        root.Name = "DexImportantDataRoot"
        root.BackgroundTransparency = 1
        root.Size = UDim2.new(1, 0, 1, 0)
        root.Parent = window.GuiElems.Content

        local scanButton = makeButton(root, "Refresh Index", Color3.fromRGB(58, 92, 145), UDim2.new(1 / 3, -5, 0, 28), UDim2.new(0, 4, 0, 4))
        local copyAllButton = makeButton(root, "Copy All Categories", Color3.fromRGB(46, 125, 80), UDim2.new(1 / 3, -5, 0, 28), UDim2.new(1 / 3, 2, 0, 4))
        local copyTabButton = makeButton(root, "Copy Filtered", Color3.fromRGB(46, 125, 80), UDim2.new(1 / 3, -5, 0, 28), UDim2.new(2 / 3, 0, 0, 4))
        scanButton.MouseButton1Click:Connect(scan)
        copyAllButton.MouseButton1Click:Connect(copyAll)
        copyTabButton.MouseButton1Click:Connect(copyTab)

        searchBox = Instance.new("TextBox")
        searchBox.Name = "Filter"
        searchBox.PlaceholderText = "Search objects, classes, paths..."
        searchBox.Text = ""
        searchBox.ClearTextOnFocus = false
        searchBox.BackgroundColor3 = Color3.fromRGB(35, 39, 46)
        searchBox.BorderSizePixel = 0
        searchBox.TextColor3 = Color3.new(1, 1, 1)
        searchBox.PlaceholderColor3 = Color3.fromRGB(160, 165, 175)
        searchBox.TextSize = 13
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.Size = UDim2.new(1, -8, 0, 26)
        searchBox.Position = UDim2.new(0, 4, 0, 36)
        searchBox.Parent = root
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            query = string.lower(searchBox.Text)
            refreshList()
        end)

        local tabBar = Instance.new("Frame")
        tabBar.BackgroundTransparency = 1
        tabBar.Size = UDim2.new(1, -8, 0, 48)
        tabBar.Position = UDim2.new(0, 4, 0, 66)
        tabBar.Parent = root

        local tabKeys = { "All" }
        for _, sec in ipairs(SECTIONS) do tabKeys[#tabKeys + 1] = sec.Key end
        local columns = 6
        for i, key in ipairs(tabKeys) do
            local row = math.floor((i - 1) / columns)
            local column = (i - 1) % columns
            local btn = makeButton(tabBar, key, Color3.fromRGB(48, 53, 63), UDim2.new(1 / columns, -3, 0, 22), UDim2.new(column / columns, 0, 0, row * 24))
            btn.TextSize = 11
            tabButtons[key] = btn
            btn.MouseButton1Click:Connect(function()
                activeTab = key
                updateTabs()
                refreshList()
            end)
        end
        updateTabs()

        countLabel = Instance.new("TextLabel")
        countLabel.BackgroundTransparency = 1
        countLabel.Text = "Not scanned yet."
        countLabel.TextColor3 = Color3.fromRGB(210, 215, 225)
        countLabel.TextXAlignment = Enum.TextXAlignment.Left
        countLabel.TextSize = 12
        countLabel.Size = UDim2.new(1, -8, 0, 18)
        countLabel.Position = UDim2.new(0, 6, 0, 116)
        countLabel.Parent = root

        listFrame = Instance.new("ScrollingFrame")
        listFrame.Name = "Results"
        listFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
        listFrame.BorderSizePixel = 0
        listFrame.Position = UDim2.new(0, 4, 0, 136)
        listFrame.Size = UDim2.new(1, -8, 1, -162)
        listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        listFrame.ScrollBarThickness = 7
        listFrame.Parent = root

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 3)
        layout.Parent = listFrame

        statusLabel = Instance.new("TextLabel")
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Hitboxes, Scripts, Models, Other. Audio/sound objects are excluded. Tap a result to select it in Explorer."
        statusLabel.TextColor3 = Color3.fromRGB(180, 190, 205)
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
        statusLabel.TextSize = 11
        statusLabel.Size = UDim2.new(1, -8, 0, 22)
        statusLabel.Position = UDim2.new(0, 6, 1, -24)
        statusLabel.Parent = root

        -- First scan happens when the window is opened for the first time (keeps Dex start-up light).
        task.spawn(function()
            while not scannedOnce do
                if not root or not root.Parent then return end
                if window and not window.Closed then
                    scan()
                    return
                end
                task.wait(0.5)
            end
        end)
    end

    return Panel
end

return {
    InitDeps = initDeps,
    InitAfterMain = initAfterMain,
    Main = main,
    PluginData = pluginData,
}
