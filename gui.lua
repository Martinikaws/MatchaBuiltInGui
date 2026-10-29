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
local SKIES = {"blue", "space", "graveyard", "sudden death", "station", "westown", "black", "gray",
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
-- Config history: every save keeps the previous config (last 10), so one
-- can be put back. Share codes are the config's lines in base64, for the
-- site's import box or rivals_import.txt.
local history = {file = "rivals_config_history.txt", max = 10, SEP = "--@@ "}
function history.list()
    local ok, body = pcall(readfile, history.file)
    local out = {}
    if not ok or type(body) ~= "string" then return out end
    local cur
    for line in (body:gsub("\r", "") .. "\n"):gmatch("(.-)\n") do
        if line:sub(1, #history.SEP) == history.SEP then
            cur = {stamp = line:sub(#history.SEP + 1), lines = {}}
            out[#out + 1] = cur
        elseif cur then
            cur.lines[#cur.lines + 1] = line
        end
    end
    for _, e in ipairs(out) do
        while e.lines[#e.lines] == "" do table.remove(e.lines) end
        e.text, e.lines = table.concat(e.lines, "\n"), nil
    end
    return out
end
function history.push(text)
    if type(text) ~= "string" or text:gsub("%s+", "") == "" then return end
    local list = history.list()
    text = text:gsub("\r", ""):gsub("\n+$", "")
    if list[1] and list[1].text == text then return end
    local okT, stamp = pcall(os.date, "%Y-%m-%d %H:%M")
    table.insert(list, 1, {stamp = okT and stamp or "earlier", text = text})
    local out = {}
    for i = 1, math.min(#list, history.max) do
        out[#out + 1] = history.SEP .. list[i].stamp .. "\n" .. list[i].text:gsub("\n+$", "")
    end
    history.cached = nil
    pcall(writefile, history.file, table.concat(out, "\n") .. "\n")
end
-- Lines that changed between two configs: added and removed (blank lines and
-- comments don't count).
function history.diff(old, new)
    local function set(text)
        local out, order = {}, {}
        for line in ((text or ""):gsub("\r", "") .. "\n"):gmatch("(.-)\n") do
            line = trim(line)
            if line ~= "" and line:sub(1, 2) ~= "--" and not out[line] then out[line] = true; order[#order + 1] = line end
        end
        return out, order
    end
    local a, ao = set(old)
    local b, bo = set(new)
    local added, removed = {}, {}
    for _, l in ipairs(bo) do if not a[l] then added[#added + 1] = l end end
    for _, l in ipairs(ao) do if not b[l] then removed[#removed + 1] = l end end
    return added, removed
end
-- Whether going from one config to another needs only a quick apply: the
-- skin-side sections (weapon skins and swaps, wraps, finishers, charms) are
-- the same, so the changer can keep those and redo only the rest.
function history.quickable(old, new)
    local SKIN = {skins = true, wraps = true, finishers = true, charms = true}
    local function skinLines(text)
        local out, section = {}, "skins"
        for line in ((text or ""):gsub("\r", "") .. "\n"):gmatch("(.-)\n") do
            line = trim(line)
            local h = line:match("^%[%s*(.-)%s*%]$")
            if h then
                h = h:lower()
                section = h:find("wrap") and "wraps" or h:find("finisher") and "finishers" or h:find("charm") and "charms"
                    or h:find("skin") and "skins" or "other"
            elseif line ~= "" and line:sub(1, 2) ~= "--" and SKIN[section] then
                out[#out + 1] = section .. ":" .. line
            end
        end
        table.sort(out)
        return table.concat(out, "\n")
    end
    return old ~= nil and skinLines(old) == skinLines(new)
end
function history.code(text)
    local lines = {}
    for line in ((text or ""):gsub("\r", "") .. "\n"):gmatch("(.-)\n") do
        line = trim(line)
        if line ~= "" and line:sub(1, 2) ~= "--" then lines[#lines + 1] = line end
    end
    return "RSC1:" .. base64encode(table.concat(lines, "\n"))
end
-- A share code or a plain config, as config text.
function history.decode(text)
    text = trim(text or "")
    local code = text:match("^RSC1:([%w%+/=]+)$")
    if code then
        local ok, out = pcall(base64decode, code)
        return ok and type(out) == "string" and out or nil
    end
    return text ~= "" and text or nil
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
        history.push(current)
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
        state.safeMode = body:match("safemode%s*=%s*(%d)") == "1"
        state.fpsMode = body:match("fpsmode%s*=%s*(%d)") == "1"
        state.notify = tonumber(body:match("notify%s*=%s*(%d)")) or 1
        state.notifyStyle = tonumber(body:match("notifystyle%s*=%s*(%d)")) or 1
    end
    state.autoApply = auto or false
end
-- Rewrites only this GUI's lines, so the drawn GUI's settings stay.
local function saveSettings()
    local okRead, body = pcall(readfile, SETTINGS)
    body = (okRead and type(body) == "string") and body or ""
    for key, on in pairs({autoapply = state.autoApply, ownedonly = state.ownedOnly, noticeseen = state.noticeSeen,
        safemode = state.safeMode, fpsmode = state.fpsMode}) do
        local line = key .. "=" .. (on and "1" or "0")
        if body:find(key .. "%s*=") then
            body = body:gsub(key .. "%s*=%s*%w*", line, 1)
        else
            body = body .. ((body == "" or body:sub(-1) == "\n") and "" or "\n") .. line .. "\n"
        end
    end
    for key, n in pairs({notify = state.notify or 1, notifystyle = state.notifyStyle or 1}) do
        local line = key .. "=" .. tostring(n)
        if body:find("\n" .. key .. "%s*=") or body:find("^" .. key .. "%s*=") then
            body = body:gsub("(\n?)" .. key .. "%s*=%s*%d*", "%1" .. line, 1)
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
-- Where a ModuleScript keeps its thread and registry slot: the changer's
-- shared layout, else the known pair whose pointer leads to a thread
-- (+0x150/+0x170 on build 9ac8595, +0x170/+0x178 before).
local function modFields(ms)
    local L = _G.__RSC_LAYOUT
    if L and L.thread and L.slot then return L.thread, L.slot end
    for _, pair in ipairs({{0x168, 0x170}, {0x150, 0x170}, {0x170, 0x178}}) do
        local okP, p = pcall(memory_read, "uintptr_t", ms.Address + pair[1])
        if okP and p and p > 0x10000 and p < 0x7fffffffffff then
            for b = 0, 3 do
                local okB, v = pcall(memory_read, "byte", p + b)
                if okB and v == 10 then return pair[1], pair[2] end
            end
        end
    end
    return 0x150, 0x170
end
local function modThreadOff(ms) return (modFields(ms)) end
local function modSlotOff(ms) local _, s = modFields(ms) return s end
local detectLayout
do
    local mrd = memory_read
    local function rd(a) local ok, v = pcall(mrd, "uintptr_t", a) return ok and v or nil end
    local function rint(a) local ok, v = pcall(mrd, "int", a) return ok and v or nil end
    local function rbyte(a) local ok, v = pcall(mrd, "byte", a) return ok and v or nil end
    -- Finds tt, globalState, registry, lsizenode, array and node pointers
    -- dynamically at runtime across Roblox updates, falling back to known builds.
    local TAG_STRING, TAG_TABLE, TAG_THREAD = 6, 7, 10
    -- Known builds: 02c37bc (type byte +1) and cec3ad5 (type byte +0).
    local KNOWN = {[2] = {tt = 2, globalState = 0x78, registry = 0x618, lsize = 6, sizearray = 8, array = 0x18, node = 0x20},
        [1] = {tt = 1, globalState = 0x38, registry = 0x618, lsize = 4, sizearray = 8, array = 0x28, node = 0x18}, -- build 5a21b87
        [0] = {tt = 0, globalState = 0x18, registry = 0x620, lsize = 5, sizearray = 8, array = 0x18, node = 0x10}}
    local L = KNOWN[1]
    local function isTable(t) return t and t > 0x10000 and rbyte(t + L.tt) == TAG_TABLE end

    detectLayout = function(ms)
        if _G.__RSC_LAYOUT and _G.__RSC_LAYOUT.array then return _G.__RSC_LAYOUT end
        local thread = ms and ms.Address and rd(ms.Address + modThreadOff(ms))
        local slot = ms and ms.Address and rint(ms.Address + modSlotOff(ms))
        if not thread or thread < 0x10000 or not slot or slot < 1 then return nil end
        local tt
        for b = 0, 3 do if rbyte(thread + b) == TAG_THREAD then tt = b break end end
        if not tt then return nil end

        local function arrayOf(reg)
            for _, so in ipairs({8, 12, 4}) do
                local size = rint(reg + so)
                if size and size >= slot and size < 10000000 then
                    for _, ao in ipairs({0x20, 0x18, 0x28, 0x10}) do
                        local arr = rd(reg + ao)
                        if arr and arr > 0x10000 and arr < 0x7fffffffffff and rint(arr + (slot - 1) * 16 + 12) == TAG_TABLE then
                            local t = rd(arr + (slot - 1) * 16)
                            if t and t > 0x10000 and rbyte(t + tt) == TAG_TABLE then return t, so, ao end
                        end
                    end
                end
            end
        end

        local function nodesOfTable(t)
            -- A table's nodes: a pointer and a size byte (lsizenode) that lead to
            -- string keys. Its mask (2^l - 1) sat right after it until Roblox build
            -- 11f155f3 (Oct 2026) moved the two apart, so any other header byte may
            -- hold the mask. The pair whose nodes are well filled with string keys,
            -- and that finds the most, wins (walking too many nodes would read other
            -- tables' memory, which a fill check catches).
            local bestKeys, bestNo, bestB = 0, nil, nil
            for _, no in ipairs({0x18, 0x20, 0x10, 0x28}) do
                local base = rd(t + no)
                if base and base > 0x10000 and base < 0x7fffffffffff then
                    for _, b in ipairs({tt == 0 and 6 or 4, 3, 4, 6, 5, 7, 2}) do
                        local l = rbyte(t + b)
                        local masked = false
                        if l and l >= 1 and l <= 24 then
                            for mb = 1, 7 do
                                if mb ~= b and rbyte(t + mb) == (2 ^ l - 1) % 256 then masked = true break end
                            end
                        end
                        if masked then
                            local keys, count = 0, math.min(2 ^ l, 256)
                            for i = 0, count - 1 do
                                local n = base + i * 32
                                local kp = rd(n + 16)
                                if (rint(n + 28) or 0) % 16 == 6 and kp and kp > 0x10000 then
                                    local ok, k = pcall(mrd, "string", kp + 24)
                                    if ok and type(k) == "string" and #k > 0 and #k < 64 then keys = keys + 1 end
                                end
                            end
                            if keys > bestKeys and keys >= count / 4 then bestKeys, bestNo, bestB = keys, no, b end
                        end
                    end
                end
            end
            if bestNo then return bestNo, bestB end
        end

        local function tryAt(g, x, y)
            local reg = rd(g + y)
            if not reg or reg < 0x10000 or rint(g + y + 12) ~= TAG_TABLE or rbyte(reg + tt) ~= TAG_TABLE then return nil end
            local t, so, ao = arrayOf(reg)
            if not t then return nil end
            local no, lsize = nodesOfTable(t)
            if not no then return nil end
            local res = {tt = tt, globalState = x, registry = y, lsize = lsize, sizearray = so, array = ao, node = no}
            _G.__RSC_LAYOUT = res
            return res
        end

        local xs = {0x18, 0x68}
        for x = 0, 0x100, 8 do xs[#xs + 1] = x end
        for _, x in ipairs(xs) do
            local g = rd(thread + x)
            if g and g > 0x10000 and g < 0x7fffffffffff then
                local res = tryAt(g, x, 0x620)
                if res then return res end
            end
        end
        for _, x in ipairs(xs) do
            local g = rd(thread + x)
            if g and g > 0x10000 and g < 0x7fffffffffff then
                for y = 0, 0x1000, 8 do
                    local res = tryAt(g, x, y)
                    if res then return res end
                end
            end
        end
        local fb = KNOWN[tt] or KNOWN[1]
        _G.__RSC_LAYOUT = fb
        return fb
    end

    local function moduleTable(ms)
        local thread = ms and ms.Address and rd(ms.Address + modThreadOff(ms))
        if not thread or thread < 0x10000 then return nil end
        local shared = _G.__RSC_LAYOUT
        if shared and shared.array then
            L = shared
        else
            local detected = detectLayout(ms)
            if detected then L = detected end
        end
        if rbyte(thread + L.tt) ~= TAG_THREAD then return nil end
        local g = rd(thread + L.globalState)
        local reg = g and g > 0x10000 and rd(g + L.registry)
        if not isTable(reg) then return nil end
        local slot, size, arr = rint(ms.Address + modSlotOff(ms)), rint(reg + L.sizearray), rd(reg + L.array)
        if not slot or not size or not arr or slot < 1 or slot > size then return nil end
        local t = rd(arr + (slot - 1) * 16)
        return isTable(t) and t or nil
    end
    -- Every string key of a table: key -> {value, type tag}
    local function fields(t)
        local out = {}
        if not isTable(t) then return out end
        local base, l = rd(t + L.node), rbyte(t + L.lsize)
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
    -- The game's own item list (CosmeticLibrary.Cosmetics): name -> {type,
    -- weapon, rarity}. Used to add items the site doesn't list yet.
    catalog.readGame = function()
        local mods = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        local lib = moduleTable(mods and mods:FindFirstChild("CosmeticLibrary"))
        local cos = lib and fields(lib).Cosmetics
        if not cos or not isTable(cos[1]) then return nil end
        local function str(v)
            if not v or v[2] ~= TAG_STRING then return nil end
            local ok, x = pcall(mrd, "string", v[1] + 24)
            return ok and type(x) == "string" and x ~= "" and x or nil
        end
        local out = {}
        for name, v in pairs(fields(cos[1])) do
            local f = fields(v[1])
            out[name] = {type = str(f.Type), weapon = str(f.ItemName), rarity = str(f.Rarity)}
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
    local out = {weapons = {}, wraps = {}, finishers = {}, charms = {}, skies = {}, rarity = {}, new = {}}
    local byName = {}
    local okMap, map = pcall(function() return decode(fetch(SITE .. "skin_icon_map.json")) end)
    if okMap and type(map) == "table" then
        map.Unobtainable = nil
        for weapon, skins in pairs(map) do
            local entry = {name = weapon, skins = {}}
            for skin, data in pairs(skins) do
                if skin ~= "Standard" and skin ~= "Default" then entry.skins[#entry.skins + 1] = skin end
                if type(data) == "table" and type(data.rarity) == "string" then out.rarity[skin] = data.rarity end
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
    -- Skins straight from the game that the site doesn't list yet.
    local okGame, gameItems = pcall(catalog.readGame)
    gameItems = okGame and gameItems or {}
    local known = {}
    for _, w in pairs(byName) do for _, skin in ipairs(w.skins) do known[w.name .. "/" .. skin] = true end end
    for name, item in pairs(gameItems) do
        out.rarity[name] = out.rarity[name] or item.rarity
        local w = item.type == "Skin" and item.weapon and byName[item.weapon]
        if w and not known[w.name .. "/" .. name] then
            w.skins[#w.skins + 1] = name
            out.new[name] = true
        end
    end
    for _, w in pairs(byName) do table.sort(w.skins) end
    for _, w in pairs(byName) do out.weapons[#out.weapons + 1] = w end
    table.sort(out.weapons, function(a, b) return a.name < b.name end)

    local okWraps, wrapsJs = pcall(fetch, SITE .. "assets/wraps.js")
    local wraps = {}
    for _, row in ipairs(okWraps and jsAssignment(wrapsJs, "WRAPS") or {}) do
        if type(row[1]) == "string" and not row[1]:find("MISSING_", 1, true) then
            wraps[row[1]] = true
            out.rarity[row[1]] = WRAP_RARITY_NAMES[(tonumber(row[2]) or 0) + 1]
        end
    end
    for name, item in pairs(gameItems) do
        if item.type == "Wrap" and not wraps[name] then wraps[name], out.new[name] = true, true end
    end
    out.wraps = sortedNames(wraps)

    local okCos, cosJs = pcall(fetch, SITE .. "assets/cosmetics.js")
    for _, kind in ipairs({{"finishers", "FINISHERS"}, {"charms", "CHARMS"}}) do
        local set = {}
        for _, row in ipairs(okCos and jsAssignment(cosJs, kind[2]) or {}) do
            if type(row[1]) == "string" and not row[1]:find("MISSING_", 1, true) then
                set[row[1]] = true
                if type(row[2]) == "string" then out.rarity[row[1]] = row[2] end
            end
        end
        pcall(function()
            local folder = kind[1] == "finishers"
                and game:GetService("ReplicatedStorage").Modules.Finishers
                or game:GetService("Players").LocalPlayer.PlayerScripts.Assets.Charms
            for _, m in ipairs(folder:GetChildren()) do
                if not m.Name:find("MISSING_", 1, true) and not set[m.Name] then set[m.Name], out.new[m.Name] = true, true end
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

    out.readGame = catalog.readGame
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
-- panic: runs the changer on an empty config instead of the saved one, so
-- everything goes back to the game's own look; the config file is untouched.
local function apply(panic)
    local context = currentContext()
    assert(context, "Wait for Rivals and its weapons to finish loading.")
    assert(not upstreamBusy(), "The changer is already running.")
    if not panic then saveConfig() end
    state.status = panic and "Putting the game's look back..." or "Applying..."
    _G.__RSC_SAFE = state.safeMode or nil
    _G.__RSC_FPS = state.fpsMode or nil
    _G.__RSC_NOTIFY = ({"all", "errors", "off"})[state.notify or 1] or "all"
    _G.__RSC_NOTIFY_STYLE = ({"both", "matcha", "roblox"})[state.notifyStyle or 1] or "both"
    _G.__RSC_PROGRESS = {0, "Starting"}
    _G.__RSC_CONFIG_OVERRIDE = panic and "-- panic" or nil
    -- Quick apply when only non-skin sections changed since the last apply in
    -- this server (and safe mode is the same).
    local applying = state.readable and configText() or nil
    _G.__RSC_QUICK = (not panic and state.appliedKey == context.key and state.appliedSafe == state.safeMode
        and history.quickable(state.appliedText, applying)) or nil
    if _G.__RSC_QUICK then state.status = "Applying (quick: skins kept)..." end
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
            state.appliedKey, state.appliedText, state.appliedSafe = (not panic) and context.key or nil, applying, state.safeMode
            state.status = panic and "Game look restored. Save & Apply brings your changes back."
                or ("Applied (" .. from .. ")" .. (_G.__RSC_LAST_QUICK and ", quick" or "") .. ". Respawn to see new effects.")
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
    local thread = ms and rdq(ms.Address + modThreadOff(ms))
    -- The layout the changer found; without it, one of the two known builds,
    -- told apart by where the thread's type byte (10) sits.
    local lay = _G.__RSC_LAYOUT
    if not lay or not lay.array then
        if detectLayout and ms then lay = detectLayout(ms) end
    end
    if not lay or not lay.array then
        local okB, b0 = pcall(memory_read, "byte", thread or 0)
        local okB2, b2 = pcall(memory_read, "byte", (thread or 0) + 2)
        lay = (okB2 and b2 == 10) and {globalState = 0x78, registry = 0x618, lsize = 6, sizearray = 8, array = 0x18, node = 0x20}
            or (okB and b0 == 10) and {globalState = 0x18, registry = 0x620, lsize = 5, sizearray = 8, array = 0x18, node = 0x10}
            or {globalState = 0x68, registry = 0x620, lsize = 4, sizearray = 8, array = 0x20, node = 0x18}
    end
    local g = thread and rdq(thread + lay.globalState)
    local reg = g and rdq(g + lay.registry)
    local slot, arr = ms and rdi(ms.Address + modSlotOff(ms)), reg and rdq(reg + lay.array)
    local t = arr and slot and slot > 0 and rdq(arr + (slot - 1) * 16)
    if not t then return {} end
    local base = rdq(t + lay.node)
    local okL, l = pcall(memory_read, "byte", t + lay.lsize)
    if not base or not okL or not l or l > 12 then return {} end
    for i = 0, 2 ^ l - 1 do
        local node = base + i * 32
        local key = rdq(node + 16)
        if key and readLuaString(key) == "EquipSounds" then
            local list = rdq(node)
            local size, items = list and rdi(list + lay.sizearray), list and rdq(list + lay.array)
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

-- Favourites and recently used picks, shared with the drawn GUI's file, and
-- the order lists show in: favourites first, then the picked sort.
local prefs = {file = "rivals_gui_lists.txt", favs = {}, recent = {}, sort = 1, star = false,
    SORTS = {"Default", "A-Z", "Rarity", "Recent", "Favourites only"},
    RANK = {Common = 1, Rare = 2, Legendary = 3, Mythical = 4, Unique = 5, Genuine = 6}}
function prefs.load()
    local ok, body = pcall(readfile, prefs.file)
    if not ok or type(body) ~= "string" then return end
    for kind, name in body:gmatch("(%a+)=([^\r\n]+)") do
        if kind == "fav" then prefs.favs[name] = true
        elseif kind == "recent" and #prefs.recent < 12 then prefs.recent[#prefs.recent + 1] = name end
    end
end
function prefs.save()
    local out = {}
    for name in pairs(prefs.favs) do out[#out + 1] = "fav=" .. name end
    table.sort(out)
    for _, name in ipairs(prefs.recent) do out[#out + 1] = "recent=" .. name end
    pcall(writefile, prefs.file, table.concat(out, "\n") .. "\n")
end
-- A click on a list item: stars it in star mode, otherwise picks it.
function prefs.click(name, pick)
    return function()
        if prefs.star then
            prefs.favs[name] = (not prefs.favs[name]) or nil
        else
            pick()
            for i = #prefs.recent, 1, -1 do if prefs.recent[i] == name then table.remove(prefs.recent, i) end end
            table.insert(prefs.recent, 1, name)
            prefs.recent[13] = nil
        end
        prefs.save()
    end
end
function prefs.label(name)
    return name .. (prefs.favs[name] and "  (fav)" or "") .. (catalog.new and catalog.new[name] and "  NEW" or "")
end
function prefs.order(list)
    local recentAt, out = {}, {}
    for i, name in ipairs(prefs.recent) do recentAt[name] = i end
    local sort = prefs.SORTS[prefs.sort]
    for i, name in ipairs(list) do
        if sort ~= "Favourites only" or prefs.favs[name] then out[#out + 1] = {name, i} end
    end
    local rarity = catalog.rarity or {}
    table.sort(out, function(a, b)
        local fa, fb = prefs.favs[a[1]] and 1 or 0, prefs.favs[b[1]] and 1 or 0
        if fa ~= fb then return fa > fb end
        if sort == "A-Z" and a[1] ~= b[1] then return a[1]:lower() < b[1]:lower() end
        if sort == "Rarity" then
            local ra, rb = prefs.RANK[rarity[a[1]]] or 0, prefs.RANK[rarity[b[1]]] or 0
            if ra ~= rb then return ra > rb end
        end
        if sort == "Recent" then
            local ra, rb = recentAt[a[1]] or 99, recentAt[b[1]] or 99
            if ra ~= rb then return ra < rb end
        end
        return a[2] < b[2]
    end)
    for i, pair in ipairs(out) do out[i] = pair[1] end
    return out
end
-- The two controls above a list.
function prefs.controls(sec)
    combo(sec, "listSort", "Order", prefs.SORTS, prefs.sort - 1, function(i) prefs.sort = i end)
    combo(sec, "listClick", "Clicking an item", {"Picks it", "Stars / unstars it"}, prefs.star and 1 or 0, function(i)
        prefs.star = i == 2
    end)
end

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
    prefs.controls(sec)
    button(sec, mark(now == nil) .. "Default", function() setMapping("skins", weapon.name, nil) end)
    for _, skin in ipairs(prefs.order(weapon.skins)) do
        if matches("skin", skin) then
            button(sec, mark(now == skin) .. prefs.label(skin), prefs.click(skin, function()
                guarded(function() setMapping("skins", weapon.name, skin) end, skin)
            end))
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
            prefs.controls(sec)
            button(sec, mark(target == nil) .. "Itself (no swap)", function() setSwap(weapon.name, owned, nil) end)
            for _, skin in ipairs(prefs.order(weapon.skins)) do
                if skin ~= owned and matches("swapTarget", skin) then
                    button(sec, mark(target == skin) .. prefs.label(skin), prefs.click(skin, function()
                        guarded(function() setSwap(weapon.name, owned, skin) end, skin)
                    end))
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
    prefs.controls(sec)
    button(sec, mark(target == nil) .. "Unchanged", function() setMapping(kind, owned, nil) end)
    for _, name in ipairs(prefs.order(list)) do
        if name ~= owned and matches(kind .. "Target", name) then
            local picked = target == name or (season ~= nil and name == season)
            button(sec, mark(picked) .. prefs.label(name), prefs.click(name, function()
                if kind == "charms" and name:match("^Season %d+$") then
                    guarded(function() setMapping("charms", owned, name .. " " .. (state.rank[owned] or RANKS[1])) end, name)
                else
                    guarded(function() setMapping(kind, owned, name) end, name)
                end
            end))
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
    -- Fine-tuning over the preset: Brightness, Exposure, Ambient, Outdoor.
    local lv = values("lighting")
    if has(sec, "SliderInt") then
        for _, f in ipairs({{"Brightness", "Brightness x100 (0 = game's)", 0, 600}, {"Exposure", "Exposure x100 (0 = game's)", -300, 300}}) do
            local id = "mbg.light." .. f[1]
            local now = math.floor((tonumber(lv[f[1]]) or 0) * 100 + 0.5)
            follow(id, now)
            sec:SliderInt(id, f[2], f[3], f[4], now, function(n)
                n = tonumber(n) or 0
                local value = n ~= 0 and string.format("%.2f", n / 100) or nil -- 0 = leave it to the preset
                if value ~= values("lighting")[f[1]] then setMapping("lighting", f[1], value) end
            end)
        end
    end
    local shades = {{"Game's", nil}, {"Black", "000000"}, {"Dim", "1e1e24"}, {"Grey", "4c5058"}, {"Light", "8c96a8"}, {"White", "ffffff"}}
    for _, c in ipairs(TRACER_COLORS) do shades[#shades + 1] = {c[1], c[2]} end
    for _, key in ipairs({"Ambient", "Outdoor"}) do
        local names, at = {}, 0
        local now = tostring(lv[key] or ""):gsub("^#", ""):lower()
        for i, o in ipairs(shades) do names[i] = o[1]; if o[2] == now then at = i - 1 end end
        combo(sec, "light" .. key, key == "Ambient" and "Ambient (shadows)" or "Outdoor ambient", names, at, function(i)
            setMapping("lighting", key, shades[i][2])
        end)
    end
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
    button(sec, mark(now == "sky") .. "Match sky (your sky preset's colour)", function() setMapping("tracers", target, "sky") end)
    button(sec, mark(now == "wrap") .. "Match wrap (the colour of the weapon in your hands)", function() setMapping("tracers", target, "wrap") end)
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

-- Health bar: your own bar in the bottom HUD, saved as the [HealthBar]
-- section. Only you see it; the game draws it, so it doesn't lag.
local HP_STYLES = {{"Game's own", nil}, {"Color", "Color"}, {"Rainbow", "Rainbow"},
    {"Gradient (scrolling)", "Gradient"}, {"By health (full / half / low)", "Health"},
    {"Match sky (your sky preset's colours)", "Sky"}}
local function healthBarPage(sec)
    local v = values("healthbar")
    -- Extras for any style: shine, pulse at low health, the backing.
    combo(sec, "hpShine", "Shine along the bar", {"Off", "On"}, tostring(v.Shine or ""):lower() == "on" and 1 or 0, function(i)
        setMapping("healthbar", "Shine", i == 2 and "on" or nil)
    end)
    combo(sec, "hpPulse", "Pulse at low health", {"Off", "On"}, tostring(v.Pulse or ""):lower() == "on" and 1 or 0, function(i)
        setMapping("healthbar", "Pulse", i == 2 and "on" or nil)
    end)
    local bgNow = tostring(v.Background or ""):lower()
    local bgOpts = {{"Game's", nil}, {"Dark", "dark"}}
    for _, c in ipairs(TRACER_COLORS) do bgOpts[#bgOpts + 1] = {c[1], c[2]} end
    local bgNames, bgAt = {}, 0
    for i, o in ipairs(bgOpts) do bgNames[i] = o[1]; if o[2] == bgNow then bgAt = i - 1 end end
    combo(sec, "hpBacking", "Backing behind the bar", bgNames, bgAt, function(i) setMapping("healthbar", "Background", bgOpts[i][2]) end)
    local cur = tostring(v.Style or ""):lower()
    if cur == "cycle" then cur = "gradient" end
    local si = 1
    for i, s in ipairs(HP_STYLES) do if s[2] and s[2]:lower() == cur then si = i end end
    local names = {}
    for i, s in ipairs(HP_STYLES) do names[i] = s[1] end
    combo(sec, "hpStyle", "Health bar style (only you see it)", names, si - 1, function(i)
        local s = HP_STYLES[i]
        if s then setMapping("healthbar", "Style", s[2]) end
    end)
    local style = HP_STYLES[si][2]
    if not style then
        sec:Text("The game's green-to-red bar. Pick a style to change it.")
        return
    end

    -- One colour as a dropdown of the tracer colours, plus any hex set elsewhere.
    local function colorChoice(key, text, default, withRainbow)
        local raw = tostring(v[key] or ""):lower()
        local now = hexOf(raw) or (withRainbow and raw == "rainbow" and "rainbow") or nil
        local opts = {{"Default (" .. default .. ")", nil}}
        if withRainbow then opts[#opts + 1] = {"Rainbow (whole spectrum)", "rainbow"} end
        for _, c in ipairs(TRACER_COLORS) do opts[#opts + 1] = {c[1] .. "  (" .. c[2] .. ")", c[2]} end
        local index = 0
        for i, o in ipairs(opts) do if o[2] == now then index = i - 1 end end
        if now and index == 0 then opts[#opts + 1] = {now .. "  (your own)", now}; index = #opts - 1 end
        local list = {}
        for i, o in ipairs(opts) do list[i] = o[1] end
        combo(sec, "hp" .. key, text, list, index, function(i)
            local o = opts[i]
            if o then setMapping("healthbar", key, o[2]) end
        end)
    end
    local keys
    if style == "Color" then
        colorChoice("Color", "Colour", "9933ff")
        keys = {{"Color", "Use as colour"}}
    elseif style == "Gradient" then
        colorChoice("Color1", "Colour 1", "ff2bd6", true)
        if tostring(v.Color1 or ""):lower() ~= "rainbow" then colorChoice("Color2", "Colour 2", "3b5bff") end
        keys = {{"Color1", "Use as colour 1"}, {"Color2", "Use as colour 2"}}
    elseif style == "Health" then
        colorChoice("Full", "Full health", "64ff32")
        colorChoice("Mid", "Half health", "ffd700")
        colorChoice("Low", "Low health", "ff3232")
        keys = {{"Full", "Use for full"}, {"Mid", "Use for half"}, {"Low", "Use for low"}}
    end

    if style == "Sky" then
        local sky = values("skybox").Preset
        sec:Text(sky and ("Colours from your sky: " .. sky) or "Pick a sky preset under Sky and lighting first.")
    end
    -- Speed for Rainbow, Gradient and Sky; 0 holds a gradient still.
    if style == "Rainbow" or style == "Gradient" or style == "Sky" then
        local speed = math.max(0, math.min(300, tonumber(v.Speed) or 100))
        if has(sec, "SliderInt") then
            local id = "mbg.hpSpeedPct"
            follow(id, speed)
            sec:SliderInt(id, "Speed %", 0, 300, speed, function(n)
                local s = math.floor((tonumber(n) or 100) / 10 + 0.5) * 10
                if s ~= (tonumber(values("healthbar").Speed) or 100) then
                    setMapping("healthbar", "Speed", s ~= 100 and tostring(s) or nil)
                end
            end)
        else
            local speeds = {{"Normal (100%)", nil}, {"Still (0%)", "0"}, {"Slow (50%)", "50"}, {"Fast (200%)", "200"}}
            local index = 0
            for i, s in ipairs(speeds) do if s[2] == v.Speed then index = i - 1 end end
            local list = {}
            for i, s in ipairs(speeds) do list[i] = s[1] end
            combo(sec, "hpSpeed", "Speed", list, index, function(i)
                local s = speeds[i]
                if s then setMapping("healthbar", "Speed", s[2]) end
            end)
        end
    end

    if keys then
        sec:Spacing()
        sec:InputText("mbg.hpHex", "Any colour (hex, like ff66cc)", state.typed.hpHex or "", function(text)
            if type(text) == "string" then state.typed.hpHex = text end
        end)
        for _, k in ipairs(keys) do
            button(sec, k[2], function()
                local hex = trim(state.typed.hpHex or ""):gsub("^#", ""):lower()
                if hex:match("^%x%x%x%x%x%x$") then setMapping("healthbar", k[1], hex) else state.status = "Colours are 6 hex digits, like ff66cc." end
            end)
        end
    end
    sec:Text("Shows from the next Save & Apply.")
end

-- Buttons: the menu's coloured buttons, saved as the [Buttons] section.
-- Each style takes one colour, two (a gradient), sky or rainbow.
local BTN_STYLES = {{"Green", "Green buttons (Play, prices)"}, {"Blue", "Blue buttons (View)"},
    {"Yellow", "Yellow buttons (Buy, Free)"}, {"Gold", "Gold buttons (party leader)"}}
-- Theme ([Theme]): one look for the buttons, the health bar and the tracers;
-- what's set on their own pages wins.
local function themePage(sec)
    local v = values("theme")
    sec:Text("One look for buttons, health bar and tracers. Their own pages win. Shows from the next Save & Apply.")
    local presets = {{"None", nil}, {"Neon", "neon"}, {"Pastel", "pastel"}, {"Monochrome", "mono"}, {"Sunset", "sunset"},
        {"Ocean", "ocean"}, {"Halloween", "halloween"}, {"Christmas", "christmas"}}
    local names, at = {}, 0
    for i, t in ipairs(presets) do names[i] = t[1]; if t[2] == (v.Preset or ""):lower() then at = i - 1 end end
    combo(sec, "themePreset", "Preset", names, at, function(i) setMapping("theme", "Preset", presets[i][2]) end)
    local follows = {{"Nothing", nil}, {"Time of day", "time"}, {"Skin rarity (tracers)", "rarity"}, {"Wrap in hand (tracers)", "wrap"}}
    local fn, fat = {}, 0
    for i, t in ipairs(follows) do fn[i] = t[1]; if t[2] == (v.Follow or ""):lower() then fat = i - 1 end end
    combo(sec, "themeFollow", "Follow", fn, fat, function(i) setMapping("theme", "Follow", follows[i][2]) end)
end

local function buttonsPage(sec)
    local v = values("buttons")
    sec:Text("Menu button colours (only you see them). Shows from the next Save & Apply.")
    local function colourList(withExtras)
        local opts = {}
        if withExtras then
            opts[#opts + 1] = {"Game's own", nil}
            opts[#opts + 1] = {"Match sky", "sky"}
            opts[#opts + 1] = {"Rainbow", "rainbow"}
        else
            opts[#opts + 1] = {"None (one colour)", nil}
        end
        for _, c in ipairs(TRACER_COLORS) do opts[#opts + 1] = {c[1] .. "  (" .. c[2] .. ")", c[2]} end
        return opts
    end
    for _, st in ipairs(BTN_STYLES) do
        local key = st[1]
        local raw = tostring(v[key] or ""):lower()
        local c1, c2 = raw:match("^(%x%x%x%x%x%x)>(%x%x%x%x%x%x)$")
        if not c1 and raw:match("^%x%x%x%x%x%x$") then c1 = raw end
        local first = (raw == "sky" or raw == "rainbow") and raw or c1
        local function save(a, b)
            if a == "sky" or a == "rainbow" or not a then setMapping("buttons", key, a)
            else setMapping("buttons", key, b and (a .. ">" .. b) or a) end
        end
        local function choice(id, text, now, opts, onPick)
            local index = 0
            for i, o in ipairs(opts) do if o[2] == now then index = i - 1 end end
            if now and index == 0 then opts[#opts + 1] = {now .. "  (your own)", now}; index = #opts - 1 end
            local list = {}
            for i, o in ipairs(opts) do list[i] = o[1] end
            combo(sec, id, text, list, index, function(i) local o = opts[i]; if o then onPick(o[2]) end end)
        end
        choice("btn" .. key, st[2], first, colourList(true), function(val) save(val, c2) end)
        if c1 then
            choice("btn" .. key .. "2", "   gradient to", c2, colourList(false), function(val) save(c1, val) end)
        end
    end
    sec:Spacing()
    sec:InputText("mbg.btnHex", "Any colour (hex, like ff66cc)", state.typed.btnHex or "", function(text)
        if type(text) == "string" then state.typed.btnHex = text end
    end)
    for _, st in ipairs(BTN_STYLES) do
        button(sec, "Use for " .. st[1]:lower() .. " buttons", function()
            local hex = trim(state.typed.btnHex or ""):gsub("^#", ""):lower()
            if hex:match("^%x%x%x%x%x%x$") then setMapping("buttons", st[1], hex) else state.status = "Colours are 6 hex digits, like ff66cc." end
        end)
    end
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

-- Profile picture presets (same list as the drawn GUI): Roblox, the RIVALS
-- developers, the YouTubers with a charm (accounts from the RIVALS wiki's
-- charm list, checked with Roblox 2026-10-20) and the live Ranked top 20.
local AVATAR_PRESETS = {
    {"Roblox", {{"Roblox", 1}, {"builderman", 156}}},
    {"RIVALS devs", {{"Nosniy", 20349956}, {"SenseiWarrior", 15941965}, {"GreatGuyBoom", 8034104}, {"nekoanims", 780350915}}},
    {"YouTubers", {
        {"8sty", 172669397}, {"Applino", 1010680683}, {"atorix", 1212564846}, {"Bandites", 64516}, {"Blizmid", 266340204},
        {"BobbVX", 301707243}, {"Brian1KB", 1730213868}, {"CarbonMeister", 487532097}, {"Chex", 2528007458}, {"Cruz", 42306452},
        {"D_reamz", 42477697}, {"Darktru", 121130556}, {"DV", 964088769}, {"elixir", 147139016}, {"enriquebruv", 72777686},
        {"Hoopie", 264355696}, {"hoppy819", 15315966}, {"Incublox", 4323727470}, {"KaiM", 527669241}, {"Karful", 103070346},
        {"Kashy", 4378716640}, {"Kaye", 4891355965}, {"Khayri", 19737278}, {"Milo", 6114260623}, {"MiniBloxia", 52392831},
        {"Mixedify", 152334685}, {"Mud", 324386852}, {"oPixel", 341006533}, {"philhood", 3410760577}, {"RODNY", 317520373},
        {"ShadowTrojan", 13108868}, {"SharkTactics", 18394211}, {"SlingshotBwai", 719253194}, {"Stefan", 7474730049},
        {"TanqR", 84743203}, {"viecti", 68729698}, {"WE1RD", 2466113945}}},
    {"Ranked top 20", "live"},
}
-- The lobby's Ranked leaderboard, read at most every 30 s: {name, id}.
local rankedCache, rankedAt = nil, -100
local function liveRanked()
    if rankedCache and tick() - rankedAt < 30 then return rankedCache end
    rankedAt = tick()
    local out = {}
    pcall(function()
        for _, g in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
            if g.Name == "LeaderboardGui" then
                local title
                for _, d in ipairs(g:GetDescendants()) do if d.Name == "Title" then title = d break end end
                local okT, t = pcall(function() return title.Text end)
                if okT and type(t) == "string" and t:lower():find("ranked") then
                    local rows = {}
                    for _, d in ipairs(g:GetDescendants()) do
                        if d.Name == "UserID" then
                            local okI, id = pcall(function() return d.Text end)
                            local okR, rank = pcall(function() return d.Parent:FindFirstChild("Rank").Text end)
                            local okN, name = pcall(function() return d.Parent:FindFirstChild("DisplayName").Text end)
                            id = okI and tonumber(tostring(id):match("(%d+)"))
                            rank = okR and tonumber(tostring(rank):match("(%d+)"))
                            if id and rank and rank <= 20 then rows[#rows + 1] = {rank, okN and name or tostring(id), id} end
                        end
                    end
                    table.sort(rows, function(a, b) return a[1] < b[1] end)
                    for _, r in ipairs(rows) do out[#out + 1] = {"#" .. r[1] .. " " .. r[2], r[3]} end
                end
            end
        end
    end)
    rankedCache = out
    return out
end

-- A user's name for the picture line, looked up once in the background.
local avatarNames = {}
local function avatarName(id)
    local key = tostring(id)
    if avatarNames[key] then return avatarNames[key] end
    avatarNames[key] = "..."
    task.spawn(function()
        local ok, body = pcall(function() return game:HttpGet("https://users.roblox.com/v1/users/" .. key) end)
        local name = ok and type(body) == "string" and body:match('"name"%s*:%s*"(.-)"')
        local display = ok and type(body) == "string" and body:match('"displayName"%s*:%s*"(.-)"')
        avatarNames[key] = name and ("@" .. name .. ((display and display ~= name) and (" (" .. display .. ")") or "")) or "no such user"
        pcall(refresh)
    end)
    return avatarNames[key]
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
    -- Profile card: wins, win rate and picture. Wins and win rate can't be
    -- longer than the real ones (the card reuses its own letters).
    sec:Spacing()
    sec:Text("Profile card (only your own card):")
    local CARD = {{"Wins", "Casual wins", true}, {"WinRate", "Casual win rate %"}, {"RankedWins", "Ranked wins", true},
        {"RankedWinRate", "Ranked win rate %"}, {"Avatar", "Picture: user id (their avatar)", true}, {"Picture", "Picture: decal or image id", true}}
    for _, f in ipairs(CARD) do
        sec:InputText("mbg.spoof." .. f[1], f[2], v[f[1]] or "", function(text)
            if type(text) ~= "string" then return end
            text = trim(text):gsub("%%", "")
            if text ~= "" and not (f[3] and text:match("^%d+$") or (not f[3] and text:match("^%d+%.?%d*$"))) then return end
            if text ~= (values("spoof")[f[1]] or "") then setMapping("spoof", f[1], text ~= "" and text or nil) end
        end)
    end
    -- Presets: a group, then a person (sets the user id above).
    local groups = {}
    for i, g in ipairs(AVATAR_PRESETS) do groups[i] = g[1] end
    local gi = state.presetGroup or 1
    combo(sec, "presetGroup", "Picture presets", groups, gi - 1, function(i) state.presetGroup = i end)
    local list = AVATAR_PRESETS[gi][2]
    if list == "live" then list = liveRanked() end
    local names, index = {"(pick someone)"}, 0
    for i, p in ipairs(list) do
        names[#names + 1] = p[1]
        if tostring(p[2]) == tostring(v.Avatar or "") then index = i end
    end
    combo(sec, "presetPerson", "Person", names, index, function(i)
        local p = list[i - 1]
        if p then
            setMapping("spoof", "Avatar", tostring(p[2]))
            pcall(UI.SetValue, "mbg.spoof.Avatar", tostring(p[2]))
        end
    end)
    local avatarId = tonumber(v.Avatar)
    if avatarId then sec:Text("Picture of: " .. avatarName(avatarId)) end
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
    local prog = shared.busy and type(_G.__RSC_PROGRESS) == "table" and _G.__RSC_PROGRESS
    main:Text(prog and (prog[1] or 0) < 100 and string.format("Working: %s  %d%%", tostring(prog[2]), prog[1] or 0)
        or (shared.busy and ("Working: " .. tostring(state.status)) or tostring(state.status)))
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
    combo(main, "safeMode", "Safe mode (skins, wraps, finishers, charms only)", {"Off", "On"}, state.safeMode and 1 or 0, function(i)
        state.safeMode = i == 2
        saveSettings()
    end)
    combo(main, "fpsMode", "FPS-friendly mode (live effects update less)", {"Off", "On"}, state.fpsMode and 1 or 0, function(i)
        state.fpsMode = i == 2
        saveSettings()
    end)
    combo(main, "notify", "Changer notifications", {"All", "Errors only", "Off"}, (state.notify or 1) - 1, function(i)
        state.notify = i
        saveSettings()
    end)
    combo(main, "notifyStyle", "Notification style", {"Both", "Matcha", "Roblox"}, (state.notifyStyle or 1) - 1, function(i)
        state.notifyStyle = i
        saveSettings()
    end)
    button(main, "Panic: put the game's look back", function()
        job("Putting the game's look back...", function() apply(true) end)
    end)
    button(main, "Reload config (drop unsaved changes)", function()
        if shared.busy then return end
        loadConfig()
    end)
    button(main, "Reload lists", function() job("Loading the lists...", loadCatalog) end)
    button(main, "Unload this tab", function() stop() end)

    -- The changer's lines from this session, and a copy for support.
    local logSec = tab:Section("Changer log", "Left")
    local log = type(_G.__RSC_LOG) == "table" and _G.__RSC_LOG or {}
    if #log == 0 then logSec:Text("Empty - it fills when the changer runs.") end
    for i = math.max(1, #log - 11), #log do logSec:Text(tostring(log[i])) end
    button(logSec, "Copy output for support", function()
        local okV, rbx = pcall(getrbxversion)
        local out = {"Rivals Skin Changer - support output", "Support ID: " .. tostring(_G.__RIVALS_SUPPORT_ID or "unavailable"),
            "Roblox: " .. (okV and tostring(rbx) or "unknown"), ""}
        for _, l in ipairs(log) do out[#out + 1] = l end
        local ok = pcall(setclipboard, table.concat(out, "\n"))
        state.status = ok and "Copied - paste it to whoever is helping you." or "Copying isn't supported here."
    end)
    button(logSec, "Clear log", function() _G.__RSC_LOG = {} end)

    -- Config tools: copy, share codes, import by pasting, history, inventory.
    local cfg = tab:Section("Config tools", "Left")
    local saved = state.baseline or ""
    -- The tab can redraw every frame; the comparison runs at most once a second.
    if not state.diffAt or tick() - state.diffAt > 1 then
        state.diffAt = tick()
        state.diffAdded, state.diffRemoved = history.diff(saved, state.readable and configText() or saved)
    end
    local added, removed = state.diffAdded or {}, state.diffRemoved or {}
    cfg:Text(#added + #removed == 0 and "No unsaved changes."
        or string.format("Unsaved: %d added, %d removed (Save & Apply writes them)", #added, #removed))
    for i, l in ipairs(added) do if i <= 4 then cfg:Text("  + " .. l) end end
    for i, l in ipairs(removed) do if i <= 4 then cfg:Text("  - " .. l) end end
    button(cfg, "Copy config", function()
        local ok = pcall(setclipboard, saved)
        state.status = ok and "Copied your saved config." or "Copying isn't supported here."
    end)
    button(cfg, "Copy share code", function()
        local ok = pcall(setclipboard, history.code(saved))
        state.status = ok and "Share code copied." or "Copying isn't supported here."
    end)
    cfg:InputText("mbg.importText", "Paste a config or share code", state.importText or "", function(t)
        if type(t) == "string" then state.importText = t end
    end)
    button(cfg, "Import what's pasted", function()
        local textIn = history.decode(state.importText)
        assert(textIn, "Paste a config or a share code (RSC1:...) in the box first.")
        history.push(saved)
        writefile(FILE, textIn)
        loadConfig()
        state.importText = ""
        pcall(UI.SetValue, "mbg.importText", "")
        state.status = "Imported - your old config is in the history."
    end)
    -- The tab can redraw every frame; the file is read at most every 2 s.
    if not state.histList or tick() - (state.histAt or 0) > 2 then state.histList, state.histAt = history.list(), tick() end
    local list = state.histList
    if #list > 0 then
        local names = {}
        for i, e in ipairs(list) do names[i] = e.stamp end
        state.historyPick = math.min(state.historyPick or 1, #list)
        combo(cfg, "historyPick", "Earlier saves", names, state.historyPick - 1, function(i) state.historyPick = i end)
        button(cfg, "Put that one back", function()
            local e = list[state.historyPick]
            assert(e, "Pick a save first.")
            history.push(saved)
            writefile(FILE, e.text)
            loadConfig()
            state.status = "Restored the config from " .. e.stamp .. ". Save & Apply to use it."
        end)
    else
        cfg:Text("History: fills as you save.")
    end
    button(cfg, "Export inventory to rivals_inventory.txt", function()
        assert(inventory, "Your inventory couldn't be read - press Reload lists in a match.")
        local out = {}
        for name, e in pairs(inventory) do
            local on = {}
            if type(e) == "table" then for wpn in pairs(e) do on[#on + 1] = wpn end end
            table.sort(on)
            out[#out + 1] = name .. (#on > 0 and (" (" .. table.concat(on, ", ") .. ")") or "")
        end
        table.sort(out)
        writefile("rivals_inventory.txt", table.concat(out, "\n") .. "\n")
        state.status = "Saved " .. #out .. " items to rivals_inventory.txt."
    end)

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
        combo(extras, "miscView", "Misc", {"Tracers", "Hands", "Spoof", "Health bar", "Buttons", "Theme"}, (state.miscView or 1) - 1, function(i) state.miscView = i end)
        local misc = state.miscView or 1
        if misc == 1 then tracersPage(extras) elseif misc == 2 then handsPage(extras)
        elseif misc == 3 then spoofPage(extras) elseif misc == 4 then healthBarPage(extras) elseif misc == 5 then buttonsPage(extras) else themePage(extras) end
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
pcall(prefs.load)

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
