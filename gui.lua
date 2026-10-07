-- Rivals Skin Changer - Matcha built-in menu GUI
-- A "Rivals Changer" tab in Matcha's own menu. It edits rivals_config.lua and
-- runs the skin changer. Long lists are button lists in fixed-height sections
-- (those scroll; Matcha's dropdowns don't), one step at a time.
--
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/Martinikaws/MatchaBuiltInGui/main/gui.lua"))()

local FILE = "rivals_config.lua"
local SETTINGS = "rivals_gui_settings.txt"
local BACKUP = "rivals_config.backup.lua"
local SCRIPT_FILES = {"RivalsSkinSwapper.lua", "workspace/RivalsSkinSwapper.lua", "scripts/RivalsSkinSwapper.lua"}
local SCRIPT_URL = "https://raw.githubusercontent.com/Martinikaws/RivalsSkinChangerFULLMATCHA/refs/heads/main/main.lua"
local SITE = "https://martinikaws.github.io/rivals-skins/"
local TAB = "Rivals Changer"
local RIVALS_GAME_ID = 6035872082
local LIST_HEIGHT = 420

assert(UI and type(UI.AddTab) == "function", "Matcha's UI binding is required.")
assert(type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function",
    "Matcha file functions are required.")

-- A second run replaces the first. The drawn GUI is left alone: it has its
-- own session, and the two share only the busy lock and the auto-apply mark.
if _G.__MatchaBuiltInGui then pcall(_G.__MatchaBuiltInGui.stop) end
local session = {}
_G.RivalsGuiState = _G.RivalsGuiState or {busy = false}
local shared = _G.RivalsGuiState

-- Lists that don't come from the game

local function numbered(prefix, from, to)
    local out = {}
    for n = from, to do out[#out + 1] = string.format("%s %02d", prefix, n) end
    return out
end
local SKIES = {"blue", "space", "graveyard", "sudden death", "station", "westown", "black", "gray", "classic",
    "galaxy", "blue nebula", "gold nebula"}
for _, s in ipairs(numbered("cloudy", 1, 25)) do SKIES[#SKIES + 1] = s end
for _, s in ipairs({"aurora", "beautiful", "black hole", "blue sky", "broken sky", "castle grounds", "chill gray",
    "chill pink", "chroma key", "clear skies", "cyan", "dead star forest", "disaster", "elegant morning", "emo",
    "fade blue", "forest", "goodnight", "grimnight", "hades", "hazy", "jungle", "light blue", "light pink",
    "minecraft", "minecraft end", "moonlight", "neon sky", "neon sky 2", "nibiru", "night", "night sky moon",
    "northern lights", "oblivion", "orange", "overcast", "pandora", "peaceful morning", "pink sunrise",
    "pumpkin hill", "purple nebula", "red", "setting sun", "sfoth", "shiverfrost", "sky 05", "sky 13", "sky 2006",
    "sky 22", "sky 31", "sky 38", "sky 47", "sky purple", "sky sunset", "space blue", "spooky", "sunny sky",
    "universe", "utter east", "whomp fortress", "winterness", "xen", "zen end"}) do
    SKIES[#SKIES + 1] = s
end
-- Sound library. Rivals and Roblox sounds always play; community uploads
-- are public but their owners can remove them.
local SOUND_LIBRARY = {
    {name = "Rivals", sounds = {
        {"Hitmarker tick", "13110130082"}, {"Headshot crack", "16537449730"}, {"Elimination 1", "16530229616"},
        {"Elimination 2", "16530229541"}, {"Elimination 3", "16530229695"}, {"Target shatter", "14441658101"},
        {"RPG explosion", "13455969017"}, {"Equip click", "13158735106"}, {"Landing", "16736552001"},
        {"Jump", "16736552098"}, {"Duel timer tick", "17826390328"}, {"Click", "177266782"},
    }},
    {name = "Roblox", sounds = {
        {"Classic hit", "12222046"}, {"Button", "12221967"}, {"Electronic ping", "12221990"},
        {"Glass break", "12222005"}, {"Kerplunk", "12222054"}, {"Fast click", "12221976"},
        {"Bright click", "15675059323"}, {"Cute pop", "15675055424"}, {"Notification", "17208361335"},
        {"Coin", "127645268874265"}, {"Pinball bell", "16480570986"}, {"8-bit blip", "16480580213"},
        {"Metal click", "16480551554"}, {"Sparkle ding", "9126073001"}, {"Cannon blast", "3149249837"},
    }},
    {name = "Hit sounds", sounds = {
        {"Undertale critical hit", "140181868959125"}, {"Hit sound", "139520673393967"},
        {"Undertale attack hit", "140721035016341"}, {"Fist hit", "140604838213617"},
        {"TF2 critical hit", "137392628136734"}, {"AvA punch", "138208560796742"}, {"Rock hit", "82708037443413"},
        {"Spear hit", "135278368445325"}, {"Persona 5 hit", "140706017778464"},
        {"Energy sword hit", "139503070303020"}, {"Stone hit", "3581383408"}, {"8-bit impact", "109598434966968"},
        {"Minecraft hit", "73369656122118"}, {"Car hit", "1897654568"}, {"Beam hit", "103134129110384"},
    }},
    {name = "Your pack", sounds = {
        {"agpa 1", "102651850556408"}, {"agpa 2", "132463144859699"}, {"Huhh", "115574480250251"},
        {"Minecraft hurt", "127059326655954"}, {"msfrs.hit", "138523457528846"}, {"neverlose.cc", "139452805868562"},
        {"Rust headshot 2", "138750331387064"}, {"skeet (louder)", "140247876667835"},
        {"Taco Bell bong", "128327858093323"}, {"Bubble pop", "121434237134952"},
        {"Windows XP error", "95509039020568"}, {"My name is Jeff", "2867856238"}, {"HL2 crowbar", "73268721537561"},
        {"DSR-1", "93739917036633"}, {"Fatality", "97439296876895"}, {"Bepis", "1921494658"},
        {"Burp", "130147881880627"}, {"Duck quack", "140601322851309"}, {"Computer beep", "2626561747"},
        {"MGS alert", "139345986070502"}, {"Doom shotgun", "15120932483"}, {"Cash register", "120891770644830"},
        {"Cowbell", "9125935023"}, {"Winner FX", "1841267764"}, {"Cartoon bubble", "5852470908"},
    }},
    {name = "Community", sounds = {
        {"CoD hitmarker", "138832207290954"}, {"Quake hitmarker", "1455817260"},
        {"GameSense hitmarker", "4817809188"}, {"Minecraft hitmarker", "127091812835195"},
        {"Minecraft bow ding", "135478009117226"}, {"MLG hitmarker", "121351852050830"},
        {"Head hitmarker", "17724154662"}, {"TF2 hitsound", "138901307926331"}, {"osu! hitsound", "123941247147792"},
        {"Bubble pop", "119697580657161"}, {"CS:GO headshot", "133002449941130"}, {"Arsenal headshot", "18513634637"},
        {"Fortnite headshot", "2513174484"}, {"Rust headshot", "128633263668964"},
        {"Battlefield headshot", "70528023820006"}, {"PHIGHTING headshot", "138549196892842"},
        {"TF2 kill", "124543461907751"}, {"Among Us kill", "130456049552264"}, {"MM2 knife kill", "97347330766907"},
        {"Double kill", "116907610084760"},
    }},
    {name = "Kenney (CC0)", sounds = {
        {"Punch heavy", "107508753428253"}, {"Punch", "76122581259100"}, {"Metal tap", "138075431083492"},
        {"Metal clang", "133464625805308"}, {"Glass tap", "138936753289661"}, {"Glass smash", "75898126734535"},
        {"Bell hit", "126126591991039"}, {"Plate tap", "117110797440641"}, {"Tin hit", "135391446483517"},
        {"Soft thud", "95039951320381"}, {"Click", "127906824435990"}, {"Tick", "130702709867354"},
        {"Confirm", "112196335049721"}, {"Glass ding", "127490438798725"}, {"Pluck", "72021613097471"},
        {"Bong", "117732813936667"}, {"Drop", "128207733490113"}, {"Glitch", "131159017045649"},
        {"Zap", "136683295906047"}, {"Zap two-tone", "132620272525127"}, {"Pep", "70583920911483"},
        {"High up", "117530563976701"}, {"Phaser up", "104765335548518"}, {"Power up", "105788477038167"},
        {"Three-tone", "70578968807464"}, {"Small laser", "91301983822305"}, {"Retro laser", "118116613865507"},
        {"Explosion crunch", "82931503751689"},
    }},
}
local SOUND_SLOTS = {{"Hit", "Body hit"}, {"Critical", "Headshot"}, {"Kill", "Kill"}}
local DEFAULT_SOUNDS = {Hit = "13110130082", Critical = "16537449730", Kill = "16530229616"}
local RANKS = {"Archnemesis", "Nemesis", "Onyx 3", "Onyx 2", "Onyx 1", "Diamond 3", "Diamond 2", "Diamond 1",
    "Platinum 3", "Platinum 2", "Platinum 1", "Gold 3", "Gold 2", "Gold 1", "Silver 3", "Silver 2", "Silver 1",
    "Bronze 3", "Bronze 2", "Bronze 1", "Unranked"}
local TRACER_COLORS = {
    {"Red", "ff2d2d"}, {"Orange", "ff7a00"}, {"Gold", "ffc400"}, {"Yellow", "ffee00"}, {"Lime", "a6ff00"},
    {"Green", "2dff5a"}, {"Mint", "00ffa6"}, {"Cyan", "00e5ff"}, {"Blue", "2d6bff"}, {"Purple", "8a2dff"},
    {"Pink", "ff4fd8"}, {"White", "ffffff"},
}
local TRACER_SPEEDS = {{"Game's own (100%)", nil}, {"Keyper-like (20%)", "20"}, {"Slow (35%)", "35"},
    {"50%", "50"}, {"75%", "75"}, {"Fast (150%)", "150"}, {"Very fast (200%)", "200"}}
-- Guns that fire tracers; the site's weapon list adds any new ones.
local GUNS = {"Assault Rifle", "Burst Rifle", "Distortion", "Energy Rifle", "Minigun", "Permafrost", "Shotgun",
    "Sniper", "Energy Pistols", "Exogun", "Handgun", "Revolver", "Shorty", "Uzi"}
local SPOOF_FIELDS = {
    {key = "Name", label = "Display name"},
    {key = "Username", label = "@Username (not longer than yours)"},
    {key = "Level", label = "Level", number = true},
    {key = "Streak", label = "Win streak", number = true},
    {key = "ELO", label = "ELO", number = true},
}
local SPOOF_BADGES = {{"Influencer", "Influencer badge"}, {"Employee", "Roblox employee badge"}, {"Trustworthy", "Trustworthy"}}
local DEVICES = {{"Real", nil}, {"PC", "MouseKeyboard"}, {"Mobile", "Touch"}, {"Controller", "Gamepad"}, {"VR", "VR"}}

local state = {
    status = "Loading...", lines = {}, values = {}, swaps = {}, readable = false, dirty = false,
    listStatus = "Loading the item lists...",
    -- Where each page is: the thing picked in step 1 (nil = still choosing).
    weapon = nil, swapWeapon = nil, swapOwned = nil, owned = {}, tracerFor = nil,
    soundSlot = 1, search = {}, typed = {}, rank = {},
    itemsView = 1, extrasView = 1,
    -- "You own" lists show only what you own (when the inventory can be read).
    ownedOnly = true,
    -- Bumped when a job starts or ends: the tab is rebuilt to show it. Plain
    -- edits don't bump it, so typing in a box is never interrupted.
    announce = 0,
}
local catalog = {weapons = {}, wraps = {}, finishers = {}, charms = {}, skies = {}}

local function trim(s) return (tostring(s or "")):match("^%s*(.-)%s*$") end

-- Config file

local function header(line)
    local s = line:match("^%s*%[%s*(.-)%s*%]%s*$")
    return s and s:lower() or nil
end
local function pair(line)
    if line:match("^%s*%-%-") then return nil end
    local k, v = line:match("^%s*([^=]-)%s*=%s*(.-)%s*$")
    if k and trim(k) ~= "" then return trim(k), v end
end
local function swapLine(line)
    local w, owned, target = line:match("^%s*([^|]-)%s*|%s*([^>]-)%s*>%s*(.-)%s*$")
    if w and owned and target and w ~= "" and owned ~= "" and target ~= "" then return w, owned, target end
end
local function configText()
    if #state.lines == 0 then return "-- Rivals config\n" end
    return table.concat(state.lines, "\n") .. "\n"
end
local function indexConfig()
    state.values = {skins = {}, wraps = {}, finishers = {}, charms = {}, skybox = {}, lighting = {}, sounds = {},
        spoof = {}, tracers = {}}
    state.swaps = {}
    local section = "skins"
    for _, line in ipairs(state.lines) do
        local h = header(line)
        if h then
            section = h
        elseif section == "skins" and not line:match("^%s*%-%-") and swapLine(line) then
            local w, owned, target = swapLine(line)
            state.swaps[w] = state.swaps[w] or {}
            state.swaps[w][owned] = target
        else
            local k, v = pair(line)
            if k then
                state.values[section] = state.values[section] or {}
                state.values[section][k] = v
            end
        end
    end
end
local function markChanged()
    state.dirty = configText() ~= state.cleanText
    state.status = state.dirty and "Changed - press Save & Apply." or "No changes."
end
-- The changer trades two models for each line, so a skin, finisher or charm
-- can only be in one line: it skips a second line that uses one again.
-- Returns those lines, in the order the changer would skip them.
local function configClashes()
    local out, section, touched, used, swaps = {}, "skins", {}, {}, {}
    for _, line in ipairs(state.lines) do
        local h = header(line)
        if h then
            section = h
        elseif section == "skins" then
            local w, o, t = swapLine(line)
            if w then
                swaps[#swaps + 1] = {o, t}
            else
                local k, v = pair(line)
                local low = v and v:lower()
                if k and v and low ~= "default" and low ~= "standard" then
                    if touched[v] or touched[k] then
                        out[#out + 1] = k .. " -> " .. v
                    else
                        touched[v], touched[k] = true, true
                    end
                end
            end
        elseif section == "finishers" or section == "charms" then
            local k, v = pair(line)
            if k and v then
                -- Every rank of a season charm is the same model.
                local model = section == "charms" and (v:match("^(Season %d+)%s") or v) or v
                used[section] = used[section] or {}
                local u = used[section]
                if u[k] or u[model] then out[#out + 1] = k .. " -> " .. v else u[k], u[model] = true, true end
            end
        end
    end
    -- The changer runs the swaps after the Weapon=Skin lines.
    for _, sw in ipairs(swaps) do
        if touched[sw[2]] or touched[sw[1]] then
            out[#out + 1] = sw[1] .. " -> " .. sw[2]
        else
            touched[sw[2]], touched[sw[1]] = true, true
        end
    end
    return out
end
local function clashWarning()
    local bad = configClashes()
    if #bad == 0 then return nil end
    return "Two lines use the same item - the changer skips: " .. table.concat(bad, ", ")
end
local function loadConfig()
    local raw = isfile(FILE) and readfile(FILE) or nil
    local content = (raw or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
    if content:sub(1, 3) == string.char(239, 187, 191) then content = content:sub(4) end
    local lines = {}
    for line in (content .. "\n"):gmatch("(.-)\n") do lines[#lines + 1] = line end
    while lines[#lines] == "" do table.remove(lines) end
    -- "X=X" lines would swap an item with itself; drop them.
    local cleaned = {}
    for _, line in ipairs(lines) do
        local k, v = pair(line)
        if not (k and v and k == v) then cleaned[#cleaned + 1] = line end
    end
    state.lines, state.baseline = cleaned, raw
    indexConfig()
    state.readable = true
    state.cleanText, state.dirty = configText(), false
    state.status = clashWarning() or (raw and "Loaded your configuration." or "Nothing saved yet - pick something.")
end
-- One key per section. nil removes the line; a missing section gets a new
-- [Header] at the end. Lines this GUI doesn't know are kept as they are.
local function setMapping(section, key, value)
    if shared.busy or not state.readable then return end
    local output, current, found = {}, "skins", false
    for _, line in ipairs(state.lines) do
        local h = header(line)
        if h then current = h end
        local k = not h and pair(line) or nil
        if current == section and k == key then
            if not found and value then output[#output + 1] = key .. "=" .. value end
            found = true
        else
            output[#output + 1] = line
        end
    end
    if not found and value then
        local position = section == "skins" and 1 or nil
        current = "skins"
        for i, line in ipairs(output) do
            local h = header(line)
            if h then current = h end
            if current == section then position = i + 1 end
        end
        if not position then
            output[#output + 1] = ""
            output[#output + 1] = "[" .. section:sub(1, 1):upper() .. section:sub(2) .. "]"
            position = #output + 1
        end
        table.insert(output, position, key .. "=" .. value)
    end
    state.lines = output
    indexConfig()
    markChanged()
end
-- "Weapon | Owned > Target" lines sit after the Weapon=Skin lines. nil removes.
local function setSwap(weapon, owned, target)
    if shared.busy or not state.readable then return end
    local output, section, lastSkinLine = {}, "skins", 0
    for _, line in ipairs(state.lines) do
        local h = header(line)
        if h then section = h end
        local keep = true
        if section == "skins" and not h then
            local w, o = swapLine(line)
            if w == weapon and o == owned then keep = false end
        end
        if keep then
            output[#output + 1] = line
            if section == "skins" and not h then lastSkinLine = #output end
        end
    end
    if target then table.insert(output, lastSkinLine + 1, weapon .. " | " .. owned .. " > " .. target) end
    state.lines = output
    indexConfig()
    markChanged()
end
-- No hands: [NoHands] has Weapon=true lines, and All=true for every weapon
-- (a Weapon=false line then keeps that one's arms).
local function handsHidden(weapon)
    local v = state.values.nohands or {}
    local own = v[weapon] and tostring(v[weapon]):lower()
    if own == "true" then return true elseif own == "false" then return false end
    return tostring(v.All or ""):lower() == "true"
end
local function toggleHands(weapon)
    local all = tostring((state.values.nohands or {}).All or ""):lower() == "true"
    if handsHidden(weapon) then
        setMapping("nohands", weapon, all and "false" or nil)
    else
        setMapping("nohands", weapon, (not all) and "true" or nil)
    end
end
-- Makes a pick, then takes it back if it would put one item in two lines.
local function guarded(change, target)
    local before, was = state.lines, #configClashes()
    change()
    if #configClashes() > was then
        state.lines = before
        indexConfig()
        markChanged()
        state.status = target .. " is already used by another line. Two can't look like the same one - change that line first."
        if type(notify) == "function" then pcall(notify, TAB, state.status, 6) end
    end
end
local function saveConfig()
    assert(state.readable, "Reload the configuration before saving.")
    local current = isfile(FILE) and readfile(FILE) or nil
    assert(current == state.baseline,
        "The config changed outside this tab (the site or the other GUI?). Press Reload config; your file was not overwritten.")
    local content = configText()
    if current == content then return end
    if current then
        writefile(BACKUP, current)
        assert(readfile(BACKUP) == current, "Could not verify the backup; save cancelled.")
    end
    writefile(FILE, content)
    assert(readfile(FILE) == content, "Could not verify the save. Your previous config is in " .. BACKUP)
    state.baseline = content
    state.cleanText, state.dirty = configText(), false
end

-- Settings: auto-apply is shared with the drawn GUI (same file, same key).
local function loadSettings()
    local okRead, body = pcall(readfile, SETTINGS)
    local auto
    if okRead and type(body) == "string" then
        state.settingsRead = true
        local value = body:match("autoapply%s*=%s*(%w+)")
        if value then auto = (value == "1" or value == "true" or value == "on") end
        state.ownedOnly = body:match("ownedonly%s*=%s*(%d)") ~= "0"
        state.noticeSeen = body:match("noticeseen%s*=%s*(%d)") == "1"
    end
    state.autoApply = auto or false
end
-- Rewrites only this GUI's lines, so the drawn GUI's settings stay.
local function saveSettings()
    local okRead, body = pcall(readfile, SETTINGS)
    body = (okRead and type(body) == "string") and body or ""
    for key, on in pairs({autoapply = state.autoApply, ownedonly = state.ownedOnly, noticeseen = state.noticeSeen}) do
        local line = key .. "=" .. (on and "1" or "0")
        if body:find(key .. "%s*=") then
            body = body:gsub(key .. "%s*=%s*%w*", line, 1)
        else
            body = body .. ((body == "" or body:sub(-1) == "\n") and "" or "\n") .. line .. "\n"
        end
    end
    pcall(writefile, SETTINGS, body)
end

-- What you own
--
-- Your player data has a CosmeticInventory table: a cosmetic's name maps to
-- true, or to a table of the weapons you own it for ({IsUniversal = true} for
-- all of them). It sits at PlayerDataController.CurrentData.Data, all Lua
-- tables, read from memory through the registry like the changer reads the
-- item libraries. nil when it can't be read; the lists then show everything.
local inventory = nil
local readInventory
do
    local mrd = memory_read
    local function rd(a) local ok, v = pcall(mrd, "uintptr_t", a) return ok and v or nil end
    local function rint(a) local ok, v = pcall(mrd, "int", a) return ok and v or nil end
    local function rbyte(a) local ok, v = pcall(mrd, "byte", a) return ok and v or nil end
    -- Roblox moves Luau's layout between builds: the header byte with an
    -- object's type (+1 in build 02c37bc, +0 in cec3ad5), the one with a
    -- table's lsizenode, and the thread's global state. The changer finds
    -- them and shares them as _G.__RSC_LAYOUT; until it has, this checks
    -- the thread's header and the known global-state offsets itself.
    local TAG_TABLE, TAG_THREAD = 7, 10
    local L = {tt = 1, lsize = 4}
    local function isTable(t) return t and t > 0x10000 and rbyte(t + L.tt) == TAG_TABLE end
    local function moduleTable(ms)
        local thread = ms and ms.Address and rd(ms.Address + 0x170)
        if not thread or thread < 0x10000 then return nil end
        local shared = _G.__RSC_LAYOUT
        if shared then L.tt, L.lsize = shared.tt, shared.lsize end
        if rbyte(thread + L.tt) ~= TAG_THREAD then
            for b = 0, 3 do
                if rbyte(thread + b) == TAG_THREAD then L.tt, L.lsize = b, (b == 0 and 6 or 4) break end
            end
        end
        if rbyte(thread + L.tt) ~= TAG_THREAD then return nil end
        local reg
        for _, x in ipairs({shared and shared.globalState or 0x68, 0x68, 0x18}) do
            local g = rd(thread + x)
            local r = g and g > 0x10000 and rd(g + (shared and shared.registry or 0x620))
            if isTable(r) then reg = r break end
        end
        if not reg then return nil end
        local slot, size, arr = rint(ms.Address + 0x178), rint(reg + 8), rd(reg + 0x20)
        if not slot or not size or not arr or slot < 1 or slot > size then return nil end
        local t = rd(arr + (slot - 1) * 16)
        return isTable(t) and t or nil
    end
    -- Every string key of a table: key -> {value, type tag}
    local function fields(t)
        local out = {}
        if not isTable(t) then return out end
        local base, l = rd(t + 0x18), rbyte(t + L.lsize)
        if not base or base < 0x10000 or not l or l > 16 then return out end
        for i = 0, 2 ^ l - 1 do
            local node = base + i * 32
            local tt, kp = rint(node + 12), rd(node + 16)
            if tt and tt ~= 0 and kp and kp > 0x10000 then
                local ok, key = pcall(mrd, "string", kp + 24)
                if ok and type(key) == "string" and #key > 0 and #key < 80 then out[key] = {rd(node), tt} end
            end
        end
        return out
    end
    readInventory = function()
        local ok, result = pcall(function()
            local ps = game:GetService("Players").LocalPlayer.PlayerScripts
            local ctl = moduleTable(ps.Controllers.PlayerDataController)
            local cur = ctl and fields(ctl).CurrentData
            local data = cur and fields(cur[1]).Data
            local inv = data and fields(data[1]).CosmeticInventory
            if not inv or not isTable(inv[1]) then return nil end
            local out, n = {}, 0
            for name, v in pairs(fields(inv[1])) do
                n = n + 1
                if v[2] == TAG_TABLE then
                    local on = {}
                    for weapon in pairs(fields(v[1])) do on[weapon] = true end
                    out[name] = on
                else
                    out[name] = true
                end
            end
            return n > 0 and out or nil
        end)
        inventory = ok and result or nil
        return inventory ~= nil
    end
end
-- Owned at all, or (for a skin) owned for that weapon.
local function owns(name, weapon)
    local e = inventory and inventory[name]
    if e == true then return true end
    if type(e) ~= "table" then return false end
    return weapon == nil or e.IsUniversal == true or e[weapon] == true
end
-- Whether the "you own" lists are cut down to what you own.
local function ownedOnly() return state.ownedOnly and inventory ~= nil end

-- Item lists: the site's (weapons and their skins, wraps, finishers, charms,
-- uploaded skies) plus anything the running game has that the site lacks.

local function fetch(url)
    local body = (type(httpget) == "function") and httpget(url) or game:HttpGet(url)
    assert(type(body) == "string" and #body > 0, "Download failed: " .. url)
    return body
end
local function decode(text) return game:GetService("HttpService"):JSONDecode(text) end
local function jsAssignment(source, name)
    local encoded = source:match("window%." .. name .. "%s*=%s*(%b[])")
    return encoded and decode(encoded) or nil
end
local function sortedNames(set)
    local out = {}
    for name in pairs(set) do out[#out + 1] = name end
    table.sort(out)
    return out
end

local function loadCatalog()
    readInventory()
    local out = {weapons = {}, wraps = {}, finishers = {}, charms = {}, skies = {}}
    local byName = {}
    local okMap, map = pcall(function() return decode(fetch(SITE .. "skin_icon_map.json")) end)
    if okMap and type(map) == "table" then
        map.Unobtainable = nil
        for weapon, skins in pairs(map) do
            local entry = {name = weapon, skins = {}}
            for skin in pairs(skins) do
                if skin ~= "Standard" and skin ~= "Default" then entry.skins[#entry.skins + 1] = skin end
            end
            table.sort(entry.skins)
            byName[weapon] = entry
        end
    end
    pcall(function()
        local weapons = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels.Weapons
        for _, w in ipairs(weapons:GetChildren()) do
            if w.Name ~= "Unobtainable" then byName[w.Name] = byName[w.Name] or {name = w.Name, skins = {}} end
        end
    end)
    -- Guns from the site's weapon list (primary and secondary) for Tracers.
    local guns = {}
    for _, g in ipairs(GUNS) do guns[g] = true end
    pcall(function()
        local encoded = fetch(SITE):match("const%s+OFFICIAL_WEAPON_DATA%s*=%s*(%b[])%s*;")
        for _, w in ipairs(encoded and decode(encoded) or {}) do
            if type(w.name) == "string" and (w.category == "Primary" or w.category == "Secondary") then guns[w.name] = true end
        end
    end)
    out.guns = sortedNames(guns)
    for _, w in pairs(byName) do out.weapons[#out.weapons + 1] = w end
    table.sort(out.weapons, function(a, b) return a.name < b.name end)

    local okWraps, wrapsJs = pcall(fetch, SITE .. "assets/wraps.js")
    local wraps = {}
    for _, row in ipairs(okWraps and jsAssignment(wrapsJs, "WRAPS") or {}) do
        if type(row[1]) == "string" and not row[1]:find("MISSING_", 1, true) then wraps[row[1]] = true end
    end
    out.wraps = sortedNames(wraps)

    local okCos, cosJs = pcall(fetch, SITE .. "assets/cosmetics.js")
    for _, kind in ipairs({{"finishers", "FINISHERS"}, {"charms", "CHARMS"}}) do
        local set = {}
        for _, row in ipairs(okCos and jsAssignment(cosJs, kind[2]) or {}) do
            if type(row[1]) == "string" and not row[1]:find("MISSING_", 1, true) then set[row[1]] = true end
        end
        pcall(function()
            local folder = kind[1] == "finishers"
                and game:GetService("ReplicatedStorage").Modules.Finishers
                or game:GetService("Players").LocalPlayer.PlayerScripts.Assets.Charms
            for _, m in ipairs(folder:GetChildren()) do
                if not m.Name:find("MISSING_", 1, true) then set[m.Name] = true end
            end
        end)
        out[kind[1]] = sortedNames(set)
    end

    local skies, seen = {}, {}
    for _, s in ipairs(SKIES) do skies[#skies + 1], seen[s] = s, true end
    pcall(function()
        for _, sky in ipairs(decode(fetch(SITE .. "assets/skyboxes.json")).skyboxes or {}) do
            local name = type(sky.name) == "string" and sky.name:lower()
            if name and not seen[name] then skies[#skies + 1], seen[name] = name, true end
        end
    end)
    out.skies = skies

    catalog = out
    state.listStatus = (#out.weapons > 0)
        and string.format("Lists: %d weapons, %d wraps, %d finishers, %d charms", #out.weapons, #out.wraps, #out.finishers, #out.charms)
        or "The site is unreachable - press Reload lists."
    if #out.weapons > 0 and not inventory then
        state.listStatus = state.listStatus .. " (inventory not read - lists show everything)"
    end
end

-- Running the changer

local function currentContext()
    local ok, result = pcall(function()
        if tonumber(game.GameId) ~= RIVALS_GAME_ID or not game:IsLoaded() then return nil end
        local jobId = game.JobId
        if type(jobId) ~= "string" or jobId == "" then return nil end
        local weapons = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels.Weapons
        if not weapons or not weapons.Address or #weapons:GetChildren() == 0 then return nil end
        return {key = jobId .. ":" .. tostring(weapons.Address), wf = weapons.Address}
    end)
    return ok and result or nil
end
local function upstreamBusy()
    local stamp = _G.__RIVALS_SKIN_CHANGER_BUSY
    return type(stamp) == "number" and tick() - stamp < 180
end
-- The local copy first: that is the one autoexec runs.
local function changerSource()
    for _, p in ipairs(SCRIPT_FILES) do
        local ok, exists = pcall(isfile, p)
        if ok and exists then
            local okRead, body = pcall(readfile, p)
            if okRead and type(body) == "string" and #body > 0 then return body, p end
        end
    end
    return fetch(SCRIPT_URL), "GitHub"
end
local function apply()
    local context = currentContext()
    assert(context, "Wait for Rivals and its weapons to finish loading.")
    assert(not upstreamBusy(), "The changer is already running.")
    saveConfig()
    state.status = "Applying..."
    local source, from = changerSource()
    local fn, err = loadstring(source)
    assert(type(fn) == "function", err or "Could not compile the changer.")
    local before = _G.__RIVALS_SKIN_CHANGER_STATE
    fn()
    -- Matcha returns from the call once the changer yields; wait for its
    -- completion record and for the run lock to clear.
    local deadline = tick() + 150
    while tick() < deadline do
        local now = currentContext()
        if not now or now.key ~= context.key then
            state.status = "The server changed while applying - apply again."
            return
        end
        local finished = _G.__RIVALS_SKIN_CHANGER_STATE
        if type(finished) == "table" and finished ~= before and finished.wfAddr == context.wf and not upstreamBusy() then
            state.status = "Applied (" .. from .. "). Respawn to see new effects."
            return
        end
        task.wait(0.5)
    end
    error("The changer did not finish within 150s. Check the Matcha console.")
end
local function job(label, fn)
    if shared.busy then
        state.status = "Busy - wait for the current job."
        return
    end
    shared.busy, state.status = true, label
    state.announce = state.announce + 1
    task.spawn(function()
        local ok, err = pcall(fn)
        shared.busy = false
        state.announce = state.announce + 1
        if not ok then
            state.status = "Error: " .. tostring(err):gsub("^.-:%d+: ", ""):sub(1, 100)
            print("[Rivals Changer tab] " .. tostring(err))
            if type(notify) == "function" then pcall(notify, TAB, state.status, 6) end
        end
    end)
end

-- Sound preview: for a few seconds the equip sounds become the picked sound,
-- so switching weapons plays it. They are Luau strings in SoundLibrary's
-- table, reached through the registry, rewritten in place and put back.
local PREVIEW_SECONDS = 10
local previewing = false
local function rdq(a) local ok, v = pcall(memory_read, "uintptr_t", a) return ok and v or nil end
local function rdi(a) local ok, v = pcall(memory_read, "int", a) return ok and v or nil end
local function readLuaString(ts) local ok, v = pcall(memory_read, "string", ts + 24) return ok and v or nil end
local function writeLuaString(ts, text)
    for i = 1, #text do memory_write("byte", ts + 24 + i - 1, string.byte(text, i)) end
    memory_write("byte", ts + 24 + #text, 0)
    memory_write("int", ts + 20, #text)
end
local function equipSoundStrings()
    local modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
    local ms = modules and modules:FindFirstChild("SoundLibrary")
    local thread = ms and rdq(ms.Address + 0x170)
    local g = thread and rdq(thread + ((_G.__RSC_LAYOUT or {}).globalState or 0x68))
    local reg = g and rdq(g + ((_G.__RSC_LAYOUT or {}).registry or 0x620))
    local slot, arr = ms and rdi(ms.Address + 0x178), reg and rdq(reg + 0x20)
    local t = arr and slot and slot > 0 and rdq(arr + (slot - 1) * 16)
    if not t then return {} end
    local base = rdq(t + 0x18)
    local okL, l = pcall(memory_read, "byte", t + ((_G.__RSC_LAYOUT or {}).lsize or 4))
    if not base or not okL or not l or l > 12 then return {} end
    for i = 0, 2 ^ l - 1 do
        local node = base + i * 32
        local key = rdq(node + 16)
        if key and readLuaString(key) == "EquipSounds" then
            local list = rdq(node)
            local size, items = list and rdi(list + 8), list and rdq(list + 0x20)
            local out = {}
            for j = 0, (size or 0) - 1 do
                local ts = items and rdq(items + j * 16)
                local text = ts and readLuaString(ts)
                if text and text:find("^rbxassetid://%d+$") then out[#out + 1] = ts end
            end
            return out
        end
    end
    return {}
end
local function previewSound(id)
    if previewing then return "Already on - switch weapons to hear it." end
    if not currentContext() then return "Join a Rivals match first." end
    local digits = id and tostring(id):match("(%d+)$")
    if not digits then return "That one is muted - nothing to play." end
    local text = "rbxassetid://" .. digits
    if #text > 31 then return "That id is too long to preview." end
    local strings = equipSoundStrings()
    if #strings == 0 then return "Preview not available right now." end
    local saved = {}
    for _, ts in ipairs(strings) do
        saved[#saved + 1] = {ts, readLuaString(ts)}
        writeLuaString(ts, text)
    end
    previewing = true
    task.spawn(function()
        task.wait(PREVIEW_SECONDS)
        for _, s in ipairs(saved) do
            if readLuaString(s[1]) == text then writeLuaString(s[1], s[2]) end
        end
        previewing = false
    end)
    return "Switch weapons in the next " .. PREVIEW_SECONDS .. "s to hear it."
end

-- Drawing the tab
--
-- Matcha calls the tab function to build the tab. If it calls it again every
-- frame, the tab follows the state by itself; if it only calls it once, the
-- tab is rebuilt (removed and added) after each change. Which one it is gets
-- measured: a run of calls close together, with no rebuild, means every frame.

local drawTab
local draws, lastDraw, rebuiltAt, streak = 0, 0, 0, 0
local everyFrame = false
local wantRebuild = false
local function refresh() wantRebuild = true end

local function values(section) return state.values[section] or {} end
local function count(t) local n = 0 for _ in pairs(t or {}) do n = n + 1 end return n end

-- Button labels must be unique within a section, or two buttons would share one.
local used
local function label(sec, text)
    local mine = used[sec]
    if not mine then mine = {}; used[sec] = mine end
    local out, n = text, 1
    while mine[out] do n = n + 1; out = text .. " (" .. n .. ")" end
    mine[out] = true
    return out
end
local function button(sec, text, fn)
    sec:Button(label(sec, text), function()
        local ok, err = pcall(fn)
        if not ok then state.status = "Error: " .. tostring(err):sub(1, 90) end
        refresh()
    end)
end
-- A combo with a stable id; the shown choice always follows the state.
local function combo(sec, id, text, list, index, fn)
    id = "mbg." .. id
    pcall(UI.SetValue, id, index)
    sec:Combo(id, text, list, index, function(i)
        i = tonumber(i) or 0
        local ok, err = pcall(fn, i + 1, list[i + 1])
        if not ok then state.status = "Error: " .. tostring(err):sub(1, 90) end
        refresh()
    end)
end
-- Sliders, toggles and colour pickers came with newer Matcha builds.
local function has(sec, method)
    local ok, f = pcall(function() return sec[method] end)
    return ok and type(f) == "function"
end
-- Pushes the state into a widget only when it was changed somewhere else, so
-- a drag in progress is never overwritten.
local function follow(id, value, same)
    local ok, shown = pcall(UI.GetValue, id)
    if ok and shown ~= nil and not (same and same(shown) or shown == value) then pcall(UI.SetValue, id, value) end
end
local function hexOf(value) return value and tostring(value):lower():match("^%x%x%x%x%x%x$") or nil end
local function colorHex(c)
    local ok, r, g, b = pcall(function() return c.R, c.G, c.B end)
    if not ok or type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return nil end
    local function byte(v) return math.max(0, math.min(255, math.floor(v * 255 + 0.5))) end
    return string.format("%02x%02x%02x", byte(r), byte(g), byte(b))
end
-- A search box. When the tab redraws itself it filters as you type;
-- otherwise Find applies it (rebuilding while typing would drop the text box).
local function search(sec, key)
    local id = "mbg.find." .. key
    sec:InputText(id, "Search", state.typed[key] or "", function(text)
        if type(text) ~= "string" then return end
        state.typed[key] = text
        if everyFrame then state.search[key] = trim(text):lower() end
    end)
    if not everyFrame then
        button(sec, "Find", function() state.search[key] = trim(state.typed[key] or ""):lower() end)
    end
    if (state.search[key] or "") ~= "" then
        button(sec, "Clear search", function()
            state.search[key], state.typed[key] = "", ""
            pcall(UI.SetValue, id, "")
        end)
    end
end
local function matches(key, name)
    local q = state.search[key] or ""
    return q == "" or name:lower():find(q, 1, true) ~= nil
end
local function mark(selected, set) return (selected and "> " or (set and "* " or "   ")) end

-- Pages of the Items section

local function weaponEntry(name)
    for _, w in ipairs(catalog.weapons) do if w.name == name then return w end end
end

local function skinsPage(sec)
    local skins = values("skins")
    if not state.weapon then
        sec:Text("Pick a weapon, then the skin it shows. * = set")
        search(sec, "weapons")
        local shown = 0
        for _, w in ipairs(catalog.weapons) do
            local now = skins[w.name]
            if matches("weapons", w.name) or (now and matches("weapons", now)) then
                shown = shown + 1
                button(sec, mark(false, now) .. w.name .. (now and ("  -  " .. now) or ""), function()
                    state.weapon, state.search.skin, state.typed.skin = w.name, "", ""
                end)
            end
        end
        if shown == 0 then sec:Text(#catalog.weapons == 0 and "No weapon list yet - press Reload lists." or "Nothing matches.") end
        return
    end
    local weapon = weaponEntry(state.weapon) or {name = state.weapon, skins = {}}
    local now = skins[weapon.name]
    button(sec, "< All weapons", function() state.weapon = nil end)
    sec:Text(weapon.name .. "  -  now: " .. (now or "Default"))
    -- Your arms in first person, for this weapon.
    combo(sec, "hands." .. weapon.name, "Hands in first person", {"Shown", "Hidden"}, handsHidden(weapon.name) and 1 or 0, function(i)
        if (i == 2) ~= handsHidden(weapon.name) then toggleHands(weapon.name) end
    end)
    search(sec, "skin")
    button(sec, mark(now == nil) .. "Default", function() setMapping("skins", weapon.name, nil) end)
    for _, skin in ipairs(weapon.skins) do
        if matches("skin", skin) then
            button(sec, mark(now == skin) .. skin, function()
                guarded(function() setMapping("skins", weapon.name, skin) end, skin)
            end)
        end
    end
end

local function swapsPage(sec)
    sec:Text("Equip a skin you own and it looks like another one.")
    if not state.swapWeapon then
        search(sec, "swapWeapons")
        for _, w in ipairs(catalog.weapons) do
            if #w.skins > 0 and matches("swapWeapons", w.name) then
                local n = count(state.swaps[w.name])
                button(sec, mark(false, n > 0) .. w.name .. (n > 0 and ("  (" .. n .. " set)") or ""), function()
                    state.swapWeapon, state.swapOwned = w.name, nil
                end)
            end
        end
    else
        local weapon = weaponEntry(state.swapWeapon) or {name = state.swapWeapon, skins = {}}
        local set = state.swaps[weapon.name] or {}
        if not state.swapOwned then
            button(sec, "< All weapons", function() state.swapWeapon = nil end)
            sec:Text(weapon.name .. ": which skin do you own?")
            local shown = 0
            for _, skin in ipairs(weapon.skins) do
                local target = set[skin]
                if target or not ownedOnly() or owns(skin, weapon.name) then
                    shown = shown + 1
                    button(sec, mark(false, target) .. skin .. (target and ("  ->  " .. target) or ""), function()
                        state.swapOwned = skin
                    end)
                end
            end
            if shown == 0 then sec:Text("You own no skins for this weapon. (Changer > lists: Everything shows all.)") end
        else
            local owned = state.swapOwned
            local target = set[owned]
            button(sec, "< Back to " .. weapon.name, function() state.swapOwned = nil end)
            sec:Text(owned .. " looks like:")
            search(sec, "swapTarget")
            button(sec, mark(target == nil) .. "Itself (no swap)", function() setSwap(weapon.name, owned, nil) end)
            for _, skin in ipairs(weapon.skins) do
                if skin ~= owned and matches("swapTarget", skin) then
                    button(sec, mark(target == skin) .. skin, function()
                        guarded(function() setSwap(weapon.name, owned, skin) end, skin)
                    end)
                end
            end
        end
    end
    sec:Spacing()
    local any = false
    for w, list in pairs(state.swaps) do
        for owned, target in pairs(list) do
            if not any then sec:Text("Set (click to remove):") any = true end
            button(sec, "x  " .. w .. ": " .. owned .. " -> " .. target, function() setSwap(w, owned, nil) end)
        end
    end
end

-- Wraps, finishers and charms: the one you own, then what it looks like.
local function cosmeticPage(sec, kind, noun)
    local list, set = catalog[kind] or {}, values(kind)
    local owned = state.owned[kind]
    if not owned then
        sec:Text("Pick a " .. noun .. " you own. * = set")
        search(sec, kind .. "Own")
        local shown = 0
        for _, name in ipairs(list) do
            if matches(kind .. "Own", name) and (set[name] or not ownedOnly() or owns(name)) then
                shown = shown + 1
                button(sec, mark(false, set[name]) .. name .. (set[name] and ("  ->  " .. set[name]) or ""), function()
                    state.owned[kind] = name
                end)
            end
        end
        if shown == 0 then
            sec:Text(#list == 0 and "No list yet - press Reload lists."
                or (ownedOnly() and "Nothing you own matches. (Changer > lists: Everything shows all.)" or "Nothing matches."))
        end
        return
    end
    local target = set[owned]
    button(sec, "< All " .. noun .. "s", function() state.owned[kind] = nil end)
    sec:Text(owned .. " looks like: " .. (target or "itself"))
    local season = kind == "charms" and target and target:match("^(Season %d+)%s")
    if season then
        -- Season charms hold every rank; one has to be picked.
        local current = target:match("^Season %d+%s+(.+)$") or RANKS[1]
        local ri = 1
        for i, r in ipairs(RANKS) do if r == current then ri = i end end
        combo(sec, "rank." .. owned, "Rank", RANKS, ri - 1, function(i, rank)
            if rank then state.rank[owned] = rank; setMapping("charms", owned, season .. " " .. rank) end
        end)
    end
    search(sec, kind .. "Target")
    button(sec, mark(target == nil) .. "Unchanged", function() setMapping(kind, owned, nil) end)
    for _, name in ipairs(list) do
        if name ~= owned and matches(kind .. "Target", name) then
            local picked = target == name or (season ~= nil and name == season)
            button(sec, mark(picked) .. name, function()
                if kind == "charms" and name:match("^Season %d+$") then
                    guarded(function() setMapping("charms", owned, name .. " " .. (state.rank[owned] or RANKS[1])) end, name)
                else
                    guarded(function() setMapping(kind, owned, name) end, name)
                end
            end)
        end
    end
end

-- Pages of the Extras section

local function skyPage(sec)
    local skyNow = (values("skybox").Preset or ""):lower()
    local lightNow = (values("lighting").Preset or ""):lower()
    local li = lightNow == "dark" and 2 or (lightNow == "match" and 3 or 1)
    combo(sec, "lighting", "Lighting", {"Normal", "Dark", "Match the sky"}, li - 1, function(i)
        setMapping("lighting", "Preset", ({false, "dark", "match"})[i] or nil)
    end)
    sec:Text("Sky now: " .. (skyNow ~= "" and skyNow or "the game's own") .. " (shows on the next map load)")
    search(sec, "sky")
    local function setSky(value)
        -- Per-face ids from the site would win over the preset; drop them.
        for _, k in ipairs({"All", "BK", "DN", "FT", "LF", "RT", "UP"}) do setMapping("skybox", k, nil) end
        setMapping("skybox", "Preset", value)
    end
    button(sec, mark(skyNow == "") .. "Off (the game's sky)", function() setSky(nil) end)
    for _, s in ipairs(#catalog.skies > 0 and catalog.skies or SKIES) do
        if matches("sky", s) then button(sec, mark(s == skyNow) .. s, function() setSky(s) end) end
    end
end

-- The changer takes 5% to 300%; the slider moves in steps of 5.
local function snapSpeed(v) return math.max(5, math.min(300, math.floor((tonumber(v) or 100) / 5 + 0.5) * 5)) end

-- One gun's colour (or every gun's) as a switch with a colour picker.
local function tracerPicker(sec, target, hex)
    -- Matcha keeps the picker's colour under its id. A colour set some other
    -- way (a preset, the site) gets a new id, which starts at that colour;
    -- while the picker itself is dragged the id stays put.
    state.pickBase, state.picked, state.lastColor = state.pickBase or {}, state.picked or {}, state.lastColor or {}
    if hex ~= state.picked[target] then
        if hex then state.pickBase[target] = hex end
        state.picked[target] = hex
    end
    if hex then state.lastColor[target] = hex end
    local base = state.pickBase[target] or "ffffff"
    local function current() return hexOf(values("tracers")[target]) end

    local toggleId = "mbg.tracerCustom." .. target
    follow(toggleId, hex ~= nil)
    sec:Toggle(toggleId, "Custom colour", hex ~= nil, function(on)
        local cur = current()
        if on and not cur then
            setMapping("tracers", target, state.lastColor[target] or base)
        elseif not on and cur then
            setMapping("tracers", target, nil)
        end
        refresh()
    end)
    local r, g, b = tonumber(base:sub(1, 2), 16) / 255, tonumber(base:sub(3, 4), 16) / 255, tonumber(base:sub(5, 6), 16) / 255
    sec:ColorPicker("mbg.tracerPick." .. target .. "." .. base, r, g, b, 1, function(color)
        local h = colorHex(color)
        local cur = current()
        -- A picker reporting the colour it started with, while the switch is
        -- off, is not a pick.
        if not h or h == cur or (h == base and not cur) then return end
        state.picked[target] = h
        setMapping("tracers", target, h)
    end)
end

local function tracersPage(sec)
    local t = values("tracers")
    if has(sec, "SliderInt") then
        local speed = snapSpeed(t.Speed)
        local id = "mbg.tracerSpeedPct"
        follow(id, speed, function(shown) return snapSpeed(shown) == speed end)
        sec:SliderInt(id, "Speed % (every gun)", 5, 300, speed, function(v)
            local s = snapSpeed(v)
            if s ~= snapSpeed(values("tracers").Speed) then
                setMapping("tracers", "Speed", s ~= 100 and tostring(s) or nil)
            end
        end)
        sec:Text("100 is the game's own, 20 is like the Keyper.")
    else
        local speedNow = t.Speed
        local si = 1
        for i, s in ipairs(TRACER_SPEEDS) do if s[2] == speedNow then si = i end end
        local speedNames = {}
        for i, s in ipairs(TRACER_SPEEDS) do speedNames[i] = s[1] end
        if speedNow and si == 1 then speedNames[#speedNames + 1] = speedNow .. "% (from the site)"; si = #speedNames end
        combo(sec, "tracerSpeed", "Speed (every gun)", speedNames, si - 1, function(i)
            local s = TRACER_SPEEDS[i]
            if s then setMapping("tracers", "Speed", s[2]) end
        end)
    end
    -- The game draws no tracers for the Energy Pistols; this turns them on.
    local epOn = tostring(t.EnergyPistolsTracers or ""):lower() == "true"
    combo(sec, "epTracers", "Energy Pistols tracers (not recommended with 50% speed or under)", {"Off", "On"}, epOn and 1 or 0, function(i)
        setMapping("tracers", "EnergyPistolsTracers", i == 2 and "true" or nil)
    end)
    local target = state.tracerFor
    if not target then
        sec:Text("Tracer colour for: (only you see it)")
        local all = t.Color
        button(sec, mark(false, all) .. "All guns" .. (all and ("  -  " .. all) or ""), function() state.tracerFor = "Color" end)
        for _, g in ipairs(catalog.guns or GUNS) do
            button(sec, mark(false, t[g]) .. g .. (t[g] and ("  -  " .. t[g]) or ""), function() state.tracerFor = g end)
        end
        return
    end
    local now = t[target] and tostring(t[target]):lower()
    button(sec, "< All guns", function() state.tracerFor = nil end)
    sec:Text((target == "Color" and "Every gun" or target) .. "  -  now: " .. (now or (target == "Color" and "the game's own" or "same as all guns")))
    button(sec, mark(now == nil) .. (target == "Color" and "The game's own" or "Same as all guns"), function() setMapping("tracers", target, nil) end)
    button(sec, mark(now == "rainbow") .. "Rainbow", function() setMapping("tracers", target, "rainbow") end)
    if has(sec, "Toggle") and has(sec, "ColorPicker") then tracerPicker(sec, target, hexOf(now)) end
    for _, c in ipairs(TRACER_COLORS) do
        button(sec, mark(now == c[2]) .. c[1] .. "  (" .. c[2] .. ")", function() setMapping("tracers", target, c[2]) end)
    end
    sec:Spacing()
    sec:InputText("mbg.tracerHex", "Any colour (hex, like ff66cc)", state.typed.tracerHex or "", function(text)
        if type(text) == "string" then state.typed.tracerHex = text end
    end)
    button(sec, "Use this colour", function()
        local v = trim(state.typed.tracerHex or ""):gsub("^#", ""):lower()
        if v:match("^%x%x%x%x%x%x$") then setMapping("tracers", target, v) else state.status = "Colours are 6 hex digits, like ff66cc." end
    end)
end

-- Hands: your first-person arms, hidden on every weapon or one at a time.
local function handsPage(sec)
    local allOn = tostring(values("nohands").All or ""):lower() == "true"
    combo(sec, "handsAll", "Every weapon", {"Shown", "Hidden"}, allOn and 1 or 0, function(i)
        setMapping("nohands", "All", i == 2 and "true" or nil)
    end)
    sec:Text("Click a weapon to hide or show your arms on it. * = hidden")
    search(sec, "hands")
    for _, w in ipairs(catalog.weapons) do
        if matches("hands", w.name) then
            local hidden = handsHidden(w.name)
            button(sec, mark(false, hidden) .. w.name .. (hidden and "  -  hidden" or ""), function() toggleHands(w.name) end)
        end
    end
    if #catalog.weapons == 0 then sec:Text("No weapon list yet - press Reload lists.") end
end

local function soundsPage(sec)
    local names = {}
    for i, s in ipairs(SOUND_SLOTS) do names[i] = s[2] end
    combo(sec, "soundSlot", "Sound", names, state.soundSlot - 1, function(i) state.soundSlot = i end)
    local key = SOUND_SLOTS[state.soundSlot][1]
    local current = values("sounds")[key]
    local low = current and tostring(current):lower()
    sec:Text("Now: " .. (current or "the game's own"))
    button(sec, "Preview (then switch weapons)", function()
        state.previewNote = previewSound(current or DEFAULT_SOUNDS[key])
    end)
    if state.previewNote then sec:Text(state.previewNote) end
    sec:InputText("mbg.soundId", "Custom audio id", state.typed.soundId or "", function(text)
        if type(text) == "string" then state.typed.soundId = text end
    end)
    button(sec, "Use this id", function()
        local v = trim(state.typed.soundId or "")
        if v:match("^%d+$") then setMapping("sounds", key, v) else state.status = "Audio ids are numbers." end
    end)
    button(sec, mark(current == nil) .. "Game default", function() setMapping("sounds", key, nil) end)
    button(sec, mark(low == "none") .. "Mute", function() setMapping("sounds", key, "none") end)
    for _, group in ipairs(SOUND_LIBRARY) do
        sec:Text("- " .. group.name .. " -")
        for _, s in ipairs(group.sounds) do
            button(sec, mark(low == s[2]) .. s[1], function() setMapping("sounds", key, s[2]) end)
        end
    end
end

local function spoofPage(sec)
    local v = values("spoof")
    sec:Text("How your name and stats look to you. Empty = real.")
    for _, f in ipairs(SPOOF_FIELDS) do
        sec:InputText("mbg.spoof." .. f.key, f.label, v[f.key] or "", function(text)
            if type(text) ~= "string" then return end
            text = trim(text)
            if f.key == "Username" then text = text:gsub("^@", "") end
            if f.number and text ~= "" and not text:match("^%d+$") then return end
            if text ~= (values("spoof")[f.key] or "") then setMapping("spoof", f.key, text ~= "" and text or nil) end
        end)
    end
    -- The effect on your name: the game's gold (Prime) or purple (Contraband).
    local effectNow = (v.Effect or ""):lower()
    local ei = (effectNow == "none" and 2) or (effectNow == "prime" and 3) or (effectNow == "contraband" and 4) or 1
    combo(sec, "effect", "Name effect", {"Real", "None", "Prime (gold)", "Contraband (purple)"}, ei - 1, function(i)
        setMapping("spoof", "Effect", ({false, "none", "prime", "contraband"})[i] or nil)
    end)
    for _, b in ipairs(SPOOF_BADGES) do
        local now = (v[b[1]] or ""):lower()
        local idx = (now == "true" and 2) or (now == "false" and 3) or 1
        combo(sec, "badge." .. b[1], b[2], {"Real", "On", "Off"}, idx - 1, function(i)
            setMapping("spoof", b[1], ({false, "true", "false"})[i] or nil)
        end)
    end
    local di, names = 1, {}
    for i, d in ipairs(DEVICES) do
        names[i] = d[1]
        if d[2] and v.Device and d[2]:lower() == v.Device:lower() then di = i end
    end
    combo(sec, "device", "Device icon (everyone sees it)", names, di - 1, function(i)
        setMapping("spoof", "Device", DEVICES[i] and DEVICES[i][2] or nil)
    end)
    sec:Text("The device icon is sent to the server (needs Hybrid Mode).")
    button(sec, "Turn all spoofing off", function()
        for _, f in ipairs(SPOOF_FIELDS) do setMapping("spoof", f.key, nil); pcall(UI.SetValue, "mbg.spoof." .. f.key, "") end
        for _, b in ipairs(SPOOF_BADGES) do setMapping("spoof", b[1], nil) end
        setMapping("spoof", "Effect", nil)
        setMapping("spoof", "Device", nil)
    end)
end

-- The first-run notice: it has to be read before anything else shows, and its
-- button unlocks after a few seconds. Seen once, it is remembered in the
-- settings file (shared by both GUIs).
local NOTICE_SECONDS = 10
local NOTICE = {
    "All of the functions of the script are undetected. The only detectable way is to enable Device Spoof, "
        .. "but the chances of a ban by using it are extremely unlikely.",
    "You can swap between your own skins. Example: you own Event Horizon and set Event Horizon > Keyper. "
        .. "If you equip Event Horizon, it will show Keyper.",
    "Demanding questions about the mentioned stuff in this notice will get you blacklisted.",
    "The script gives this PC a support ID, made on your PC from Matcha's hardware ID and scrambled. "
        .. "It is not sent anywhere: it shows in the console, and a blacklisted ID can't run the script.",
}
local function drawNotice(tab)
    state.noticeStart = state.noticeStart or tick()
    local left = math.ceil(NOTICE_SECONDS - (tick() - state.noticeStart))
    local sec = tab:Section("NOTICE!", "Left")
    for _, para in ipairs(NOTICE) do
        -- The menu doesn't wrap text: break it at about 58 characters.
        local line = ""
        for word in para:gmatch("%S+") do
            if line ~= "" and #line + 1 + #word > 58 then
                sec:Text(line)
                line = word
            else
                line = line == "" and word or (line .. " " .. word)
            end
        end
        if line ~= "" then sec:Text(line) end
        sec:Spacing()
    end
    if left > 0 then
        sec:Text("You can confirm in " .. left .. "s...")
    else
        button(sec, "I've read and accept", function()
            state.noticeSeen = true
            saveSettings()
        end)
    end
end

-- Support ID: a short number for this PC, made here from Matcha's hardware ID
-- and scrambled so it can't be turned back into it. Nothing is sent anywhere;
-- it is printed so a log or screenshot says which copy it came from, and the
-- changer refuses to run for IDs listed in the repo's blacklist.txt.
local function supportId()
    local ok, hw = pcall(function() return gethwid() end)
    if not ok or type(hw) ~= "string" or hw == "" then return nil end
    local s = "rsc:" .. hw
    local h1, h2 = 7, 11
    for _ = 1, 3 do
        for i = 1, #s do
            local c = s:byte(i)
            h1 = (h1 * 131 + c + h2 % 251) % 999983
            h2 = (h2 * 65599 + c * 7 + i + h1 % 509) % 1000003
        end
    end
    return string.format("%04d-%04d", h1 % 10000, h2 % 10000)
end

local stop
drawTab = function(tab)
    local now = tick()
    if draws > 0 and now - lastDraw < 0.25 and now - rebuiltAt > 0.5 then streak = streak + 1 else streak = 0 end
    if streak >= 8 then everyFrame = true end
    draws, lastDraw = draws + 1, now
    used = {}

    if not state.noticeSeen then return drawNotice(tab) end

    local main = tab:Section("Changer", "Left")
    main:Button(label(main, state.dirty and "Save & Apply  (unsaved changes)" or "Save & Apply"), function()
        job("Applying...", apply)
        refresh()
    end)
    main:Text(shared.busy and ("Working: " .. tostring(state.status)) or tostring(state.status))
    main:Text(state.listStatus)
    combo(main, "autoApply", "Apply by itself on join", {"Off", "On"}, state.autoApply and 1 or 0, function(i)
        state.autoApply = i == 2
        saveSettings()
        state.status = state.autoApply and "Auto-apply on: it applies itself once per server." or "Auto-apply off."
    end)
    combo(main, "ownedOnly", "\"You own\" lists show", {"Everything", "Only what I own"}, state.ownedOnly and 1 or 0, function(i)
        state.ownedOnly = i == 2
        saveSettings()
    end)
    button(main, "Reload config (drop unsaved changes)", function()
        if shared.busy then return end
        loadConfig()
    end)
    button(main, "Reload lists", function() job("Loading the lists...", loadCatalog) end)
    button(main, "Unload this tab", function() stop() end)

    -- The lists live in fixed-height sections (those scroll). Which list shows
    -- is picked with a dropdown the script owns, not Matcha's page tabs.
    local itemViews = {"Skins", "Swaps", "Wraps", "Finishers", "Charms"}
    local items = tab:Section("Items", "Left", {"Items"}, LIST_HEIGHT)
    combo(items, "itemsView", "Show", itemViews, state.itemsView - 1, function(i) state.itemsView = i end)
    local page = itemViews[state.itemsView] or "Skins"
    if page == "Skins" then skinsPage(items)
    elseif page == "Swaps" then swapsPage(items)
    elseif page == "Wraps" then cosmeticPage(items, "wraps", "wrap")
    elseif page == "Finishers" then cosmeticPage(items, "finishers", "finisher")
    else cosmeticPage(items, "charms", "charm") end

    local extraViews = {"Sky and lighting", "Misc", "Sounds"}
    local extras = tab:Section("Extras", "Right", {"Extras"}, LIST_HEIGHT)
    combo(extras, "extrasView", "Show", extraViews, state.extrasView - 1, function(i) state.extrasView = i end)
    local extra = state.extrasView
    if extra == 1 then skyPage(extras)
    elseif extra == 2 then
        -- Misc holds the smaller features, picked with a second dropdown.
        combo(extras, "miscView", "Misc", {"Tracers", "Hands", "Spoof"}, (state.miscView or 1) - 1, function(i) state.miscView = i end)
        local misc = state.miscView or 1
        if misc == 1 then tracersPage(extras) elseif misc == 2 then handsPage(extras) else spoofPage(extras) end
    else soundsPage(extras) end

    local about = tab:Section("About", "Right")
    about:Text("Skin changer by Martini")
    about:Text("Contributor: dantekarati")
    about:Text("Main testers/supporters: choperr0333 aka @Giounis")
    about:Text("Only you see the skins; everyone else sees your real ones.")
    state.supportId = state.supportId or supportId() or "unavailable"
    about:Text("Support ID: " .. state.supportId)
end

-- Tab and background work

local tabShown = false
local function isRivals()
    local ok, id = pcall(function() return tonumber(game.GameId) end)
    return ok and id == RIVALS_GAME_ID
end
local function showTab()
    pcall(UI.RemoveTab, TAB)
    rebuiltAt = tick()
    local ok, err = pcall(UI.AddTab, TAB, drawTab)
    if not ok then print("[Rivals Changer tab] Could not add the tab: " .. tostring(err)) end
    tabShown = ok
end
local function hideTab()
    if tabShown then pcall(UI.RemoveTab, TAB) end
    tabShown = false
end

local alive = true
stop = function()
    alive = false
    hideTab()
    if _G.__MatchaBuiltInGui and _G.__MatchaBuiltInGui.session == session then _G.__MatchaBuiltInGui = nil end
end
_G.__MatchaBuiltInGui = {stop = stop, state = state, session = session, draw = function(tab) return drawTab(tab) end,
    info = function() return {draws = draws, everyFrame = everyFrame, tabShown = tabShown} end,
    setEveryFrame = function(v) everyFrame, streak = v, 0 end}

-- Auto-apply: once per server, shared with the drawn GUI through
-- _G.__RivalsGuiAutoApplied so the two never both apply.
local function autoApplyTick()
    if not state.settingsRead then
        local okFile, hasFile = pcall(isfile, SETTINGS)
        if okFile and hasFile then pcall(loadSettings) end
    end
    local context = state.autoApply and currentContext()
    local key = context and context.key
    if not key or _G.__RivalsGuiAutoApplied == key then return end
    local applied = _G.__RIVALS_SKIN_CHANGER_STATE
    if applied and applied.wfAddr == context.wf then
        _G.__RivalsGuiAutoApplied = key -- already applied here
    elseif not shared.busy and not upstreamBusy() then
        _G.__RivalsGuiAutoApplied = key
        if isfile(FILE) and readfile(FILE):find("%S") then
            if #catalog.weapons == 0 then pcall(loadCatalog) end
            job("Applying by itself (auto-apply)...", apply)
        end
    end
end

pcall(loadConfig)
pcall(loadSettings)

task.spawn(function()
    local shownAnnounce, sinceAuto, sinceGame = nil, 0, 0
    if isRivals() then showTab() end
    local okCat, errCat = pcall(loadCatalog)
    if not okCat then state.listStatus = "Lists failed: " .. tostring(errCat):sub(1, 80) end
    refresh()
    while alive and _G.__MatchaBuiltInGui and _G.__MatchaBuiltInGui.session == session do
        local dt = task.wait(0.1) or 0.1
        sinceAuto, sinceGame = sinceAuto + dt, sinceGame + dt
        -- Only in RIVALS: the tab comes and goes with the game (autoexec
        -- starts this in every game, and the menu outlives teleports).
        if sinceGame >= 1 then
            sinceGame = 0
            local here = isRivals()
            if here and not tabShown then showTab() elseif not here and tabShown then hideTab() end
        end
        if sinceAuto >= 2 then
            sinceAuto = 0
            pcall(autoApplyTick)
        end
        -- Text on the tab only changes when it is rebuilt (unless Matcha
        -- redraws it every frame), so rebuild when a job starts or ends.
        if state.announce ~= shownAnnounce then
            shownAnnounce = state.announce
            wantRebuild = true
        end
        -- The notice counts down: rebuild it each second until its button shows.
        if not state.noticeSeen and state.noticeStart and tabShown
            and tick() - state.noticeStart < NOTICE_SECONDS + 1.5 and tick() - (state.noticeTick or 0) >= 1 then
            state.noticeTick = tick()
            wantRebuild = true
        end
        if wantRebuild and tabShown then
            wantRebuild = false
            if not everyFrame then showTab() end
        end
    end
end)

print("[Rivals Changer tab] Ready - open the '" .. TAB .. "' tab in Matcha's menu."
    .. (state.autoApply and " Auto-apply is on." or "")
    .. (isRivals() and "" or " (It shows up once you're in RIVALS.)"))
