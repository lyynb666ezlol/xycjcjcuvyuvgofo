local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local VERSION = 10
local TAB_NAME = "GM"
local SWITCH_NAME = "Infinite Speed"
local STOMP_NAME = "Stomp Always-On"
local ANTIADMIN_NAME = "Anti Admin"
local TRANSLATE_NAME = "一键汉化"
local SKIN_NAME = "Unlock All Skins"
local SEARCH_NAME = "GM Search"
local GIVER_NAME = "GM Item Giver"
local JOIN_NAME = "GM Join"
local JOIN_HINT = "玩家名 / 数字ID"
local JOIN_GAP = 12
local HEADLESS_NAME = "GM Headless"
local AIM_NAME = "GM Aim Assist"
local AIM_PART_NAME = "GM Aim Part"
local AIM_FOVUSE_NAME = "GM Aim FovUse"
local AIM_FOV_NAME = "GM Aim Fov"
local AIM_SX_NAME = "GM Aim SpeedX"
local AIM_SY_NAME = "GM Aim SpeedY"
local AIM_PX_NAME = "GM Aim PredX"
local AIM_PY_NAME = "GM Aim PredY"
local AIM_RANGE_NAME = "GM Aim Range"
local LEGACY_NAMES = { "GM Print Item", "GM Switch" }

local ROW_H = 75
local ROW_GAP = 4
local SEARCH_H = 44
local BATCH = 30

local STOMP_ICON = "13187388396"

local EXTRA_WIDTH = 14
local PAD_OFFSET = 11

local COLOR_ON = Color3.fromRGB(74, 202, 86)
local COLOR_OFF = Color3.fromRGB(248, 81, 81)
local COLOR_IDLE = Color3.fromRGB(175, 175, 175)

local genv = (typeof(getgenv) == "function" and getgenv()) or _G
genv.__lyyloveGM = genv.__lyyloveGM or {}
local store = genv.__lyyloveGM
for _, c in ipairs(store.conns or {}) do pcall(function() c:Disconnect() end) end
store.conns = {}
store.runId = (store.runId or 0) + 1
local runId = store.runId
local function track(conn)
    if conn then table.insert(store.conns, conn) end
    return conn
end

local LocalPlayer = Players.LocalPlayer
local pg = LocalPlayer:FindFirstChild("PlayerGui")

local SPEED_MULT = 6

do
    local legacy = store.InfiniteCoffee
    if legacy then
        if legacy.Connection then pcall(function() legacy.Connection:Disconnect() end) end
        if legacy.Enabled then
            pcall(function()
                if LocalPlayer:GetAttribute("speedModifier") == SPEED_MULT then
                    LocalPlayer:SetAttribute("speedModifier", 1)
                end
            end)
        end
        store.InfiniteCoffee = nil
    end
end

local SpeedBoost = store.SpeedBoost
if type(SpeedBoost) ~= "table" then
    SpeedBoost = {}
    store.SpeedBoost = SpeedBoost
end
if SpeedBoost.Connection then
    pcall(function() SpeedBoost.Connection:Disconnect() end)
end
SpeedBoost.Connection = nil
SpeedBoost.Enabled = false
if not SpeedBoost.HasBase then
    SpeedBoost.Base = LocalPlayer:GetAttribute("speedModifier")
    SpeedBoost.HasBase = true
end

local function restoreSpeed()
    if SpeedBoost.Connection then
        pcall(function() SpeedBoost.Connection:Disconnect() end)
        SpeedBoost.Connection = nil
    end
    if not SpeedBoost.HasBase then return end
    if LocalPlayer:GetAttribute("speedModifier") ~= SpeedBoost.Base then
        pcall(function() LocalPlayer:SetAttribute("speedModifier", SpeedBoost.Base) end)
    end
end

local function applySpeed()
    if not SpeedBoost.Enabled then return end
    if LocalPlayer:GetAttribute("speedModifier") ~= SPEED_MULT then
        LocalPlayer:SetAttribute("speedModifier", SPEED_MULT)
    end
end

local function startSpeedBoost()
    if SpeedBoost.Connection then
        pcall(function() SpeedBoost.Connection:Disconnect() end)
        SpeedBoost.Connection = nil
    end
    applySpeed()
    SpeedBoost.Connection = LocalPlayer:GetAttributeChangedSignal("speedModifier"):Connect(function()
        if not SpeedBoost.Enabled then
            return
        end
        local value = LocalPlayer:GetAttribute("speedModifier")
        if value == nil or value < SPEED_MULT then
            LocalPlayer:SetAttribute("speedModifier", SPEED_MULT)
        end
    end)
end

local function setSpeedBoost(state)
    state = state == true
    if SpeedBoost.Enabled == state then
        if state then applySpeed() else restoreSpeed() end
        return
    end
    SpeedBoost.Enabled = state
    if state then
        startSpeedBoost()
    else
        restoreSpeed()
    end
end

restoreSpeed()

local Stomp = store.Stomp
if type(Stomp) ~= "table" then
    Stomp = { Enabled = false, Token = 0 }
    store.Stomp = Stomp
end
Stomp.Enabled = false
Stomp.Token = (Stomp.Token or 0) + 1

local function stompFindButton()
    if not pg then return nil end
    local touchGui = pg:FindFirstChild("TouchGui")
    local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
    local jump = frame and frame:FindFirstChild("JumpButton")
    if not jump then return nil end
    for _, btn in ipairs(jump:GetChildren()) do
        if btn:IsA("ImageButton") then
            local icon = btn:FindFirstChildOfClass("ImageLabel")
            if icon and string.find(tostring(icon.Image), STOMP_ICON, 1, true) then
                return btn, icon
            end
        end
    end
    return nil
end

local StompRefs = nil

local function resolveClient()
    local d = RS:FindFirstChild("devv")
    if not d then return nil end
    local c = d:FindFirstChild("client")
    if c then return c end
    local ok, mod = pcall(require, d)
    if ok and type(mod) == "table" then
        local mc = mod.client
        if typeof(mc) == "Instance" then return mc end
    end
    return nil
end

local function getStompRefs()
    if StompRefs then return StompRefs end
    local client = resolveClient()
    if not client then return nil end
    local handlers = client:FindFirstChild("Handlers")
    local indicies = client:FindFirstChild("Indicies")
    local shNode = handlers and handlers:FindFirstChild("StompHandler")
    local ihNode = handlers and handlers:FindFirstChild("InputHandler")
    if not shNode then
        shNode = client:FindFirstChild("StompHandler", true)
    end
    if not ihNode then
        ihNode = client:FindFirstChild("InputHandler", true)
    end
    if not (shNode and ihNode) then return nil end
    local ok1, sh = pcall(require, shNode)
    local ok2, ih = pcall(require, ihNode)
    if not (ok1 and ok2) then return nil end
    if type(sh) ~= "table" or type(ih) ~= "table" then return nil end
    local prio = nil
    local cpNode = indicies and indicies:FindFirstChild("CASPriorities")
    if cpNode then
        local ok3, cp = pcall(require, cpNode)
        if ok3 and type(cp) == "table" then
            prio = cp.stompPlayer
        end
    end
    if type(prio) ~= "number" then
        prio = 2000
    end
    StompRefs = { Stomp = sh, Input = ih, Prio = prio }
    return StompRefs
end

local function stopStompLabel()
    if Stomp.LabelConn then
        pcall(function()
            Stomp.LabelConn:Disconnect()
        end)
        Stomp.LabelConn = nil
    end
end

local function startStompLabel()
    stopStompLabel()
    task.spawn(function()
        if not pg then return end
        local hotbar = pg:FindFirstChild("Hotbar")
        local holder = hotbar and hotbar:FindFirstChild("Holder")
        local label = holder and holder:FindFirstChild("StompLabel")
        if not label then return end
        Stomp.LabelConn = RunService.RenderStepped:Connect(function()
            if not Stomp.Enabled then return end
            if not label.Visible then
                label.Visible = true
            end
            local want = UIS.GamepadEnabled and "DPad Down to stomp" or "Press E to stomp"
            if label.Text ~= want then
                label.Text = want
            end
        end)
    end)
end

local function installStompHooks(r)
    local IH = r.Input
    if Stomp.Orig then
        IH._unbindButton = Stomp.Orig.unbind
        IH._bindButton = Stomp.Orig.bind
    end
    Stomp.Orig = { unbind = IH._unbindButton, bind = IH._bindButton }
    IH._unbindButton = function(self, actionName)
        if actionName == "stomp" then
            return
        end
        if Stomp.Orig.unbind then
            return Stomp.Orig.unbind(self, actionName)
        end
    end
    IH._bindButton = function(self, actionName, fn)
        if actionName == "stomp" and stompFindButton() then
            return
        end
        if Stomp.Orig.bind then
            return Stomp.Orig.bind(self, actionName, fn)
        end
    end
    Stomp.HooksInstalled = true
end

local function startStomp()
    if Stomp.Enabled then return true end
    Stomp.Enabled = true
    Stomp.Token = (Stomp.Token or 0) + 1
    local token = Stomp.Token
    task.spawn(function()
        local r = getStompRefs()
        local tries = 0
        while not r and tries < 40 do
            if not Stomp.Enabled or Stomp.Token ~= token then return end
            tries = tries + 1
            task.wait(0.5)
            r = getStompRefs()
        end
        if not r or not Stomp.Enabled or Stomp.Token ~= token then return end
        installStompHooks(r)
        if UIS.TouchEnabled then
            if type(r.Stomp.stomp) == "function" then
                pcall(function()
                    r.Input:BindActionAtPriority("stomp", r.Stomp.stomp, true, r.Prio)
                end)
            end
            while Stomp.Enabled and Stomp.Token == token do
                local btn, icon = stompFindButton()
                if btn then
                    if not btn.Visible then
                        btn.Visible = true
                    end
                    local ok, target = pcall(r.Stomp.getPlayerToStomp)
                    if icon then
                        local want = (ok and target ~= nil) and 0 or 0.45
                        if math.abs(icon.ImageTransparency - want) > 0.01 then
                            icon.ImageTransparency = want
                        end
                    end
                end
                task.wait(0.2)
            end
        else
            startStompLabel()
        end
    end)
    return true
end

local function stopStomp()
    if not Stomp.Enabled then return end
    Stomp.Enabled = false
    Stomp.Token = (Stomp.Token or 0) + 1
    stopStompLabel()
    if Stomp.HooksInstalled then
        local r = getStompRefs()
        if r and Stomp.Orig then
            if Stomp.Orig.unbind then
                r.Input._unbindButton = Stomp.Orig.unbind
            end
            if Stomp.Orig.bind then
                r.Input._bindButton = Stomp.Orig.bind
            end
            pcall(function()
                r.Input:_unbindButton("stomp")
            end)
        end
        Stomp.HooksInstalled = false
    end
    local btn = stompFindButton()
    if btn then btn.Visible = false end
end

local function setStomp(state)
    state = state == true
    if state then
        startStomp()
    else
        stopStomp()
    end
    return Stomp.Enabled
end

if Stomp.HooksInstalled then
    local r = getStompRefs()
    if r and Stomp.Orig then
        if Stomp.Orig.unbind then
            r.Input._unbindButton = Stomp.Orig.unbind
        end
        if Stomp.Orig.bind then
            r.Input._bindButton = Stomp.Orig.bind
        end
        pcall(function()
            r.Input:_unbindButton("stomp")
        end)
        Stomp.HooksInstalled = false
    end
end

local AntiAdmin = store.AntiAdmin
if type(AntiAdmin) ~= "table" then
    AntiAdmin = { Enabled = false }
    store.AntiAdmin = AntiAdmin
end
if AntiAdmin.Conn then
    pcall(function()
        AntiAdmin.Conn:Disconnect()
    end)
    AntiAdmin.Conn = nil
end
AntiAdmin.Enabled = false

local function buildAdminSet()
    local roles = nil
    if typeof(getgenv) == "function" then
        local g = getgenv()
        roles = g.specialRoles
    end
    if type(roles) ~= "table" then
        roles = rawget(_G, "specialRoles")
    end
    if type(roles) ~= "table" then
        local ok, res = pcall(function()
            return loadstring("return specialRoles")()
        end)
        if ok and type(res) == "table" then
            roles = res
        end
    end
    local set = {}
    if type(roles) == "table" then
        for _, role in pairs(roles) do
            if type(role) == "table" and type(role.users) == "table" then
                for _, userId in pairs(role.users) do
                    set[tostring(userId)] = true
                end
            end
        end
    end
    return set
end

local function stopAntiAdmin()
    AntiAdmin.Enabled = false
    if AntiAdmin.Conn then
        pcall(function()
            AntiAdmin.Conn:Disconnect()
        end)
        AntiAdmin.Conn = nil
    end
end

local function startAntiAdmin()
    stopAntiAdmin()
    AntiAdmin.Enabled = true
    local adminSet = AntiAdmin.Set or buildAdminSet()
    AntiAdmin.Set = adminSet
    local function checkAdmin(player)
        if player and player ~= LocalPlayer and adminSet[tostring(player.UserId)] then
            pcall(function()
                LocalPlayer:Kick("[WOW]ANTI ADMIN " .. tostring(player.Name))
            end)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        checkAdmin(player)
    end
    AntiAdmin.Conn = Players.PlayerAdded:Connect(checkAdmin)
    track(AntiAdmin.Conn)
end

local function setAntiAdmin(state)
    state = state == true
    if state then
        startAntiAdmin()
    else
        stopAntiAdmin()
    end
    return AntiAdmin.Enabled
end

local Skins = store.Skins
if type(Skins) ~= "table" then
    Skins = { Enabled = false }
    store.Skins = Skins
end
Skins.Enabled = false

local SkinsRefs = nil

local function getSkinsRefs()
    if SkinsRefs then return SkinsRefs end
    local ok, dv = pcall(function()
        return require(RS.devv)
    end)
    if not ok or type(dv) ~= "table" or type(dv.load) ~= "function" then
        return nil
    end
    local ok1, skn = pcall(function()
        return dv.load("skins")
    end)
    local ok2, stt = pcall(function()
        return dv.load("state")
    end)
    local ok3, sg = pcall(function()
        return dv.load("Signal")
    end)
    if not (ok1 and ok2 and ok3) then return nil end
    if type(skn) ~= "table" or type(stt) ~= "table" or type(sg) ~= "table" then return nil end
    SkinsRefs = { skins = skn, state = stt, signal = sg }
    return SkinsRefs
end

local function applySkins()
    local r = getSkinsRefs()
    if not r then return false end
    local skn = r.skins
    local stt = r.state
    local ow = stt.data and stt.data.ownedSkins
    if type(ow) ~= "table" then return false end
    local function each(v)
        if type(v) == "function" then
            return v, nil, nil
        end
        if type(v) == "table" then
            return next, v, nil
        end
        return function()
            return nil
        end, nil, nil
    end
    local compatFn = skn.IsSkinCompatible
    local function isCompat(nm, sn)
        if type(compatFn) == "function" then
            local o, v = pcall(compatFn, nm, sn)
            if o then
                return v and true or false
            end
            return false
        end
        return true
    end
    local ok = pcall(function()
        for _, gp in each(skn.compatabilities) do
            for _, nm in each(gp) do
                if type(nm) == "string" then
                    if type(ow[nm]) ~= "table" then
                        ow[nm] = {}
                    end
                    for sn in each(skn.skinData) do
                        if isCompat(nm, sn) then
                            ow[nm][sn] = 999
                        end
                    end
                end
            end
        end
    end)
    return ok
end

local function installSkinHook()
    local r = getSkinsRefs()
    if not r then return false end
    local sg = r.signal
    if type(sg) ~= "table" then return false end
    if Skins.Hooked and Skins.TrueOrig then
        pcall(function()
            sg.InvokeServer = Skins.TrueOrig
        end)
        Skins.Hooked = false
    end
    local orig = sg.InvokeServer
    Skins.TrueOrig = orig
    local wrapper = function(ev, ...)
        if ev == "equipSkin" then
            return true
        end
        if orig then
            return orig(ev, ...)
        end
    end
    if type(newcclosure) == "function" then
        local ok, wrapped = pcall(newcclosure, wrapper)
        if ok and wrapped then
            wrapper = wrapped
        end
    end
    sg.InvokeServer = wrapper
    Skins.Hooked = true
    return true
end

local function removeSkinHook()
    if not Skins.Hooked then return end
    local r = getSkinsRefs()
    if r and type(r.signal) == "table" and Skins.TrueOrig then
        pcall(function()
            r.signal.InvokeServer = Skins.TrueOrig
        end)
    end
    Skins.Hooked = false
end

local function stopSkins()
    Skins.Enabled = false
    removeSkinHook()
end

local function startSkins()
    Skins.Enabled = true
    task.spawn(function()
        local tries = 0
        while Skins.Enabled and tries < 40 do
            if getSkinsRefs() then
                break
            end
            tries = tries + 1
            task.wait(0.5)
        end
        if not Skins.Enabled then return end
        pcall(applySkins)
        installSkinHook()
    end)
    return true
end

local function setSkins(state)
    state = state == true
    if state then
        startSkins()
    else
        stopSkins()
    end
    return Skins.Enabled
end

local Relabel = nil

local Tr = store.Translate
if type(Tr) ~= "table" then
    Tr = { Enabled = false, Speed = 2 }
    store.Translate = Tr
end
Tr.Enabled = false
Tr.Cache = (type(Tr.Cache) == "table" and Tr.Cache) or {}
Tr.Done = {}
Tr.Queue = {}
Tr.Queued = {}
Tr.Conns = {}
Tr.Speed = type(Tr.Speed) == "number" and Tr.Speed or 2

local HttpService = game:GetService("HttpService")
local CoreGuiSvc = nil
pcall(function()
    CoreGuiSvc = game:GetService("CoreGui")
end)

local TR_MAXLEN = 500
local TR_KEYWORDS = { "neon", "shine", "ghost", "gold", "spin", "bighead", "smallhead", "giant", "squash" }

local function trIsText(o)
    return o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")
end

local function trInChat(o)
    local ok, res = pcall(function()
        if o:FindFirstAncestor("Chat") then
            return true
        end
        local full = o:GetFullName()
        return type(full) == "string" and string.find(full, "Chat", 1, true) ~= nil
    end)
    return ok and res == true
end

local function trIsMine(o)
    local p = o
    for _ = 1, 14 do
        if not p then
            return false
        end
        local ok, flag = pcall(function()
            return p:GetAttribute("GM_Ui")
        end)
        if ok and flag == true then
            return true
        end
        local nm = p.Name
        if nm == SEARCH_NAME or nm == GIVER_NAME or nm == SWITCH_NAME or nm == STOMP_NAME or nm == SKIN_NAME or nm == ANTIADMIN_NAME or nm == TRANSLATE_NAME then
            return true
        end
        p = p.Parent
    end
    return false
end

local function trLang(s)
    local zh, ja, ko, en = 0, 0, 0, 0
    pcall(function()
        for _, c in utf8.codes(s) do
            if c >= 0x4E00 and c <= 0x9FFF then
                zh = zh + 1
            elseif c >= 0x3040 and c <= 0x30FF then
                ja = ja + 1
            elseif c >= 0xAC00 and c <= 0xD7AF then
                ko = ko + 1
            elseif (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
                en = en + 1
            end
        end
    end)
    if zh > 0 then
        return "zh"
    end
    if ko > 2 then
        return "ko"
    end
    if ja > 2 then
        return "ja"
    end
    if en > 0 then
        return "en"
    end
    return "auto"
end

local function trSkip(s)
    if type(s) ~= "string" then
        return true
    end
    if s == "" or s:match("^%s*$") then
        return true
    end
    if #s > TR_MAXLEN then
        return true
    end
    if s:match("^[%d%.,%s:/%%%+%-%$%(%)]+$") then
        return true
    end
    if s:match("^[^%w%s]+$") then
        return true
    end
    local lower = string.lower(s)
    for _, kw in ipairs(TR_KEYWORDS) do
        if string.find(lower, kw, 1, true) then
            return true
        end
    end
    local ok, found = pcall(function()
        return Players:FindFirstChild(s)
    end)
    if ok and found then
        return true
    end
    return false
end

local function trHttpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, false, { ["User-Agent"] = "Mozilla/5.0" })
    end)
    if ok and type(res) == "string" and res ~= "" then
        return res
    end
    return nil
end

local function trDecode(body)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

local function trUnescape(s)
    s = s:gsub("\\u(%x%x%x%x)", function(h)
        local n = tonumber(h, 16)
        if n and n > 0 and n < 0x110000 and not (n >= 0xD800 and n <= 0xDFFF) then
            return utf8.char(n)
        end
        return ""
    end)
    s = s:gsub("&#(%d+);", function(h)
        local n = tonumber(h)
        if n and n > 0 and n < 0x110000 then
            return utf8.char(n)
        end
        return ""
    end)
    s = s:gsub("&amp;", "&")
    s = s:gsub("&quot;", "\"")
    s = s:gsub("&#39;", "'")
    s = s:gsub("&apos;", "'")
    s = s:gsub("&lt;", "<")
    s = s:gsub("&gt;", ">")
    s = s:gsub("&nbsp;", " ")
    return s
end

local function trGtx(text, from, to)
    local url = string.format("https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s", from, to, HttpService:UrlEncode(text))
    local body = trHttpGet(url)
    if not body then
        return nil
    end
    local data = trDecode(body)
    if not data or type(data[1]) ~= "table" then
        return nil
    end
    local out = ""
    for _, part in ipairs(data[1]) do
        if type(part) == "table" and type(part[1]) == "string" then
            out = out .. part[1]
        end
    end
    if out == "" then
        return nil
    end
    return trUnescape(out)
end

local function trChrome(text, from, to)
    local url = string.format("https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=%s&tl=%s&q=%s", from, to, HttpService:UrlEncode(text))
    local body = trHttpGet(url)
    if not body then
        return nil
    end
    local data = trDecode(body)
    if not data then
        return nil
    end
    local parts = {}
    local function walk(t)
        if type(t) == "string" then
            if t ~= "" then
                table.insert(parts, t)
            end
        elseif type(t) == "table" then
            for _, v in ipairs(t) do
                walk(v)
            end
        end
    end
    walk(data)
    for _, v in ipairs(parts) do
        if v ~= text and not v:match("^[%a%-]+$") then
            return trUnescape(v)
        end
    end
    return nil
end

local function trMemory(text, from, to)
    local url = string.format("https://api.mymemory.translated.net/get?q=%s&langpair=%s|%s", HttpService:UrlEncode(text), from, to)
    local body = trHttpGet(url)
    if not body then
        return nil
    end
    local data = trDecode(body)
    if not data or type(data.responseData) ~= "table" then
        return nil
    end
    local t = data.responseData.translatedText
    if type(t) == "string" and t ~= "" then
        return trUnescape(t)
    end
    return nil
end

local function trLookup(text)
    local cached = Tr.Cache[text]
    if type(cached) == "string" and cached ~= "" then
        return cached
    end
    local lang = trLang(text)
    if lang == "zh" then
        return nil
    end
    local res = trGtx(text, lang, "zh-CN")
    if not res then
        res = trChrome(text, "auto", "zh-CN")
    end
    if not res then
        res = trMemory(text, lang == "auto" and "en" or lang, "zh-CN")
    end
    if not res or res == "" or res == text then
        return nil
    end
    Tr.Cache[text] = res
    return res
end

local function trEnqueue(o)
    if not o or not o.Parent then
        return
    end
    if Tr.Queued[o] or Tr.Done[o] then
        return
    end
    Tr.Queued[o] = true
    table.insert(Tr.Queue, o)
end

local trRunning = false

local function trStart()
    if trRunning then
        return
    end
    trRunning = true
    task.spawn(function()
        while Tr.Enabled do
            local o = table.remove(Tr.Queue, 1)
            if o then
                Tr.Queued[o] = nil
                if o.Parent and Tr.Enabled and not Tr.Done[o] then
                    Tr.Done[o] = true
                    local txt = nil
                    pcall(function()
                        txt = o.Text
                    end)
                    if type(txt) == "string" and txt ~= "" and not trInChat(o) and not trIsMine(o) and not trSkip(txt) then
                        local res = trLookup(txt)
                        if res then
                            pcall(function()
                                if o.Parent and Tr.Enabled and o.Text == txt then
                                    o.Text = res
                                end
                            end)
                        end
                    end
                end
                local speed = Tr.Speed
                if type(speed) ~= "number" or speed < 1 then
                    speed = 2
                end
                task.wait(1.5 / speed)
            else
                task.wait(0.2)
            end
        end
        trRunning = false
    end)
end

local function trScan(root)
    if not root then
        return
    end
    local ok, list = pcall(function()
        return root:GetDescendants()
    end)
    if not ok or type(list) ~= "table" then
        return
    end
    for _, o in ipairs(list) do
        if trIsText(o) then
            trEnqueue(o)
        end
    end
end

local function stopTranslate()
    Tr.Enabled = false
    for _, c in ipairs(Tr.Conns or {}) do
        pcall(function()
            c:Disconnect()
        end)
    end
    Tr.Conns = {}
    Tr.Queue = {}
    Tr.Queued = {}
end

local function startTranslate()
    stopTranslate()
    Tr.Enabled = true
    local function attach(root)
        if not root then
            return
        end
        pcall(function()
            table.insert(Tr.Conns, root.DescendantAdded:Connect(function(o)
                if not Tr.Enabled then
                    return
                end
                if trIsText(o) then
                    task.delay(0.1, function()
                        if o.Parent and Tr.Enabled then
                            trEnqueue(o)
                        end
                    end)
                end
            end))
        end)
    end
    attach(pg)
    if CoreGuiSvc then
        attach(CoreGuiSvc)
    end
    trScan(pg)
    if CoreGuiSvc then
        trScan(CoreGuiSvc)
    end
    trStart()
end

local function setTranslate(state)
    state = state == true
    if state then
        startTranslate()
    else
        stopTranslate()
    end
    if Relabel then
        task.defer(Relabel)
    end
    return Tr.Enabled
end

local Devv = nil
do
    local ok, mod = pcall(function() return require(RS.devv) end)
    if ok and type(mod) == "table" and type(mod.load) == "function" then
        Devv = mod
    end
end
local function load(name)
    if not Devv then return nil end
    local ok, v = pcall(function() return Devv.load(name) end)
    if ok then return v end
    return nil
end

local signal = load("Signal")
local CR = load("ClientReplicator")
local v3item = load("v3item")
local inv = (type(v3item) == "table" and v3item.inventory) or nil
local crosshairs = (type(v3item) == "table" and v3item.crosshairs) or nil

local injected = store.injected
if type(injected) ~= "table" then
    injected = {}
    store.injected = injected
end

local function randomString(length)
    length = length or 16
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = ""
    for i = 1, length do
        local r = math.random(1, #chars)
        out = out .. string.sub(chars, r, r)
    end
    return out
end

local function copyTable(t)
    local d = {}
    for k, v in pairs(t) do
        d[k] = v
    end
    return d
end

local function restoreInjected()
    if not inv then return end
    for guid, data in pairs(injected) do
        if not (inv.items and inv.items[guid]) then
            pcall(function()
                inv.add(copyTable(data), false)
            end)
        end
        local found = false
        for _, cd in ipairs(inv.currentItemsData or {}) do
            if cd.guid == guid then
                found = true
                break
            end
        end
        if not found and inv.currentItemsData then
            table.insert(inv.currentItemsData, data)
        end
    end
    if inv.rerender then
        pcall(function()
            inv:rerender()
        end)
    end
end

local function addToInventory(data)
    if not inv or type(data) ~= "table" then
        return false
    end
    if not data.guid then
        data.guid = randomString(32)
    end
    injected[data.guid] = data
    if inv.add then
        pcall(function()
            inv.add(data, false)
        end)
    end
    if inv.currentItemsData then
        table.insert(inv.currentItemsData, data)
    end
    if inv.rerender then
        pcall(function()
            inv:rerender()
        end)
    end
    return true
end

local function localRemove(guid)
    if not inv then return end
    pcall(function()
        inv.remove(guid)
    end)
    for i, d in ipairs(inv.currentItemsData or {}) do
        if d.guid == guid then
            table.remove(inv.currentItemsData, i)
            break
        end
    end
    injected[guid] = nil
    pcall(function()
        inv:rerender()
    end)
end

if inv and not store.invHooked then
    store.invHooked = true
    local origUpdate = inv.update
    inv.update = function(...)
        if origUpdate then
            origUpdate(...)
        end
        restoreInjected()
    end
    local origSwap = inv.swap
    inv.swap = function(g1, g2)
        if injected[g1] or injected[g2] then
            local a, b = nil, nil
            for i, d in ipairs(inv.currentItemsData or {}) do
                if d.guid == g1 then a = i end
                if d.guid == g2 then b = i end
            end
            if a and b then
                inv.currentItemsData[a], inv.currentItemsData[b] = inv.currentItemsData[b], inv.currentItemsData[a]
                pcall(function()
                    inv:rerender()
                end)
                return
            end
            local o = inv.ordered
            local i1, i2 = nil, nil
            for i, g in ipairs(o or {}) do
                if g == g1 then i1 = i end
                if g == g2 then i2 = i end
            end
            if i1 and i2 then
                local p1 = inv.orderedByGUID[g1]
                local p2 = inv.orderedByGUID[g2]
                o[i1], o[i2] = o[i2], o[i1]
                inv.orderedByGUID[g1] = p2
                inv.orderedByGUID[g2] = p1
                pcall(function()
                    inv:rerender()
                end)
            end
            return
        end
        if origSwap then
            return origSwap(g1, g2)
        end
    end
end

if signal and not store.signalHooked then
    store.signalHooked = true
    local origFire = signal.FireServer
    local origInvoke = signal.InvokeServer

    signal.FireServer = function(name, ...)
        local args = { ... }
        local guid = args[1]
        if type(name) == "string" and injected[guid] then
            if name == "removeItem" then
                localRemove(guid)
                return
            elseif name == "reload" then
                local item = inv and inv.items and inv.items[guid]
                if item and item.ammoManager then
                    local am = item.ammoManager
                    if am.ammo < (item.ammo or 0) then
                        task.delay(item.reloadTime or 1, function()
                            pcall(function()
                                am:setAmmo(item.ammo or 0)
                            end)
                            pcall(function()
                                am:setAmmoOut(999)
                            end)
                            pcall(function()
                                CR.Set(LocalPlayer, "reloading", false)
                            end)
                            pcall(function()
                                crosshairs.resetReload()
                            end)
                        end)
                    end
                end
                return
            end
        end
        if origFire then
            return origFire(name, ...)
        end
    end

    signal.InvokeServer = function(name, ...)
        local args = { ... }
        local guid = args[1]
        if type(name) == "string" and injected[guid] then
            if name == "attemptDrop" then
                local data = injected[guid]
                local item = inv and inv.items and inv.items[guid]
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local src = item and item.model
                if not src and item then
                    pcall(function()
                        src = item:createModel(false, LocalPlayer)
                    end)
                end
                if src and hrp then
                    local dropModel = src:Clone()
                    local look = hrp.CFrame.LookVector
                    for _, p in ipairs(dropModel:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = true
                            p.Anchored = false
                            p.CollisionGroupId = 0
                        end
                    end
                    dropModel:PivotTo(CFrame.new(hrp.Position + Vector3.new(0, 1, 0) + look * 2) * CFrame.Angles(0, math.random() * math.pi * 2, 0))
                    dropModel.Parent = workspace

                    task.spawn(function()
                        local pp = dropModel.PrimaryPart or dropModel:FindFirstChildOfClass("BasePart")
                        if not pp then return end
                        local lastY = pp.Position.Y
                        while dropModel.Parent do
                            task.wait(0.15)
                            pp = dropModel.PrimaryPart or pp
                            if not pp or not pp.Parent then
                                break
                            end
                            local dy = math.abs(pp.Position.Y - lastY)
                            lastY = pp.Position.Y
                            if dy < 0.02 then
                                break
                            end
                        end
                        if dropModel.Parent and pp and pp.Parent then
                            local ray = workspace:Raycast(pp.Position + Vector3.new(0, 8, 0), Vector3.new(0, -30, 0))
                            local gy = ray and ray.Position.Y or (pp.Position.Y - 5)
                            local cf = pp.CFrame
                            if pp.Position.Y < gy - 0.2 or pp.Position.Y > gy + 4 then
                                dropModel:PivotTo(CFrame.new(pp.Position.X, gy + 0.5, pp.Position.Z) * cf.Rotation)
                            end
                            for _, p in ipairs(dropModel:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.Anchored = true
                                end
                            end
                        end
                    end)

                    local prompt = Instance.new("ProximityPrompt")
                    prompt.ActionText = "捡起"
                    prompt.ObjectText = (item and item.name) or "武器"
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = 8
                    prompt.RequiresLineOfSight = false

                    local dropped = store.dropped
                    if type(dropped) ~= "table" then
                        dropped = {}
                        store.dropped = dropped
                    end

                    prompt.Triggered:Connect(function()
                        local d = dropped[prompt]
                        if d then
                            dropped[prompt] = nil
                            pcall(function()
                                dropModel:Destroy()
                            end)
                            addToInventory(d)
                        end
                    end)
                    dropped[prompt] = data
                    prompt.Parent = dropModel.PrimaryPart or dropModel

                    pcall(function()
                        item:SetEquipped(false)
                    end)
                    for i, d in ipairs(inv.currentItemsData or {}) do
                        if d.guid == guid then
                            table.remove(inv.currentItemsData, i)
                            break
                        end
                    end
                    injected[guid] = nil
                    pcall(function()
                        inv:rerender()
                    end)
                    return true
                end
                return false
            end
        end
        if origInvoke then
            return origInvoke(name, ...)
        end
    end
end

-- ================= 自动静默开启（商店解锁 + 购买桥接） =================
-- 常驻模块：加载即生效，不需要开关。所有局部变量统一前置声明。
local MarketplaceService = game:GetService("MarketplaceService")

-- 常量
local SHOP_GAMEPASS_ID  = 132121050
local SHOP_TP_HEIGHT    = 3
local SHOP_SYNC_WAIT    = 0.4
local SHOP_VERIFY_TIME  = 2
local SHOP_LOOP_GAP     = 0.4
local SHOP_ATTR         = "mobileDealer"
local SHOP_ATTR_FLAG    = "__mobileDealerUnlockApplied"
local SHOP_REMOTE_BUY   = "attemptPurchase"
local SHOP_REMOTE_AMMO  = "attemptPurchaseAmmo"

-- 状态变量（全部前置）
local shopSignal       = signal
local shopItems        = nil
local shopInv          = inv
local shopStateData    = nil
local shopComma        = nil
local shopBridgeBusy   = false
local shopBridgePrev   = nil
local shopBridgeOrig   = nil
local shopRunning      = false
local shopConns        = {}
local shopAppliedOnce  = false

local function shopTrack(conn)
    if conn then
        table.insert(shopConns, conn)
    end
    return conn
end

local function shopLoadModules()
    shopItems = shopItems or load("v3items")
    shopStateData = shopStateData or load("state")
    shopComma = shopComma or load("commavalue")
    if type(v3item) == "table" and type(v3item.inventory) == "table" then
        shopInv = v3item.inventory
    end
    return shopItems ~= nil
end

local function shopUserOwnsPass()
    local ok, res = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, SHOP_GAMEPASS_ID)
    end)
    if ok then
        return res == true
    end
    -- 查询失败时用属性兜底判断
    if LocalPlayer:GetAttribute(SHOP_ATTR_FLAG) == nil
        and LocalPlayer:GetAttribute(SHOP_ATTR) ~= nil then
        return true
    end
    return false
end

local function shopApplyAttribute()
    pcall(function()
        if LocalPlayer:GetAttribute(SHOP_ATTR) == nil then
            LocalPlayer:SetAttribute(SHOP_ATTR, true)
        end
        LocalPlayer:SetAttribute(SHOP_ATTR_FLAG, true)
    end)
end

local function shopIsInDealerApp(inst)
    local p = inst
    for _ = 1, 5 do
        p = p and p.Parent
        if not p then
            return false
        end
        if p.Name == "DealerApp" then
            return true
        end
    end
    return false
end

local function shopPatchGamepassLayer()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        return 0
    end
    local n = 0
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("GuiObject") and d.Visible and d.Name == "Gamepass"
            and shopIsInDealerApp(d) then
            d.Visible = false
            n = n + 1
        end
    end
    return n
end

local function shopGetMoney()
    if not shopStateData then
        return nil
    end
    local ok, v = pcall(function()
        return shopStateData.data.money
    end)
    if ok and type(v) == "number" then
        return v
    end
    return nil
end

local function shopOwnsItem(name)
    if not shopInv or type(shopInv.getFromName) ~= "function" then
        return false
    end
    local ok, v = pcall(function()
        return shopInv.getFromName(name)
    end)
    return ok and v ~= nil
end

local function shopItemData(name)
    if not shopItems or type(shopItems.getItemData) ~= "function" then
        return nil
    end
    local ok, v = pcall(function()
        return shopItems.getItemData(name)
    end)
    if ok then
        return v
    end
    return nil
end

local function shopNearestPurchasePoint(name)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end

    local from = hrp.Position
    local bestModel, bestPart, bestDist = nil, nil, nil

    -- 优先找场景里的实体售卖点
    local ios = workspace:FindFirstChild("ItemsOnSale")
    if ios then
        for _, m in ipairs(ios:GetChildren()) do
            if m.Name == name then
                local part = m:FindFirstChild("TouchDetector") or m.PrimaryPart
                if part and part:IsA("BasePart") then
                    local d = (part.Position - from).Magnitude
                    if not bestDist or d < bestDist then
                        bestModel, bestPart, bestDist = m, part, d
                    end
                end
            end
        end
    end

    -- 退回广告牌位置
    if not bestPart then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local bb = pg and pg:FindFirstChild("Billboards")
        local folder = bb and bb:FindFirstChild("itemStore")
        if folder then
            for _, b in ipairs(folder:GetChildren()) do
                local lbl = b:FindFirstChild("TopLabel")
                local ad = b.Adornee
                if lbl and lbl.Text == name and ad and ad:IsA("BasePart") then
                    local d = (ad.Position - from).Magnitude
                    if not bestDist or d < bestDist then
                        bestModel, bestPart, bestDist = ad.Parent, ad, d
                    end
                end
            end
        end
    end

    return bestPart, bestDist, bestModel
end

local function shopBeginTrip(part, model)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp or not part then
        return nil
    end

    local savedCF = char:GetPivot()
    local det = model and model:FindFirstChild("TouchDetector")
    local oldTouch = nil
    if det then
        oldTouch = det.CanTouch
        det.CanTouch = false
    end

    local targetCF = CFrame.new(part.Position + Vector3.new(0, SHOP_TP_HEIGHT, 0))

    local trip = {
        char = char,
        hrp = hrp,
        cf = savedCF,
        det = det,
        oldTouch = oldTouch,
        targetCF = targetCF,
        done = false,
    }

    function trip.snap()
        local c = trip.char
        if not (c and c.Parent) then
            return
        end
        local h = c:FindFirstChild("HumanoidRootPart")
        if h then
            h.CFrame = trip.targetCF
            h.AssemblyLinearVelocity = Vector3.zero
            h.AssemblyAngularVelocity = Vector3.zero
        end
        local hm = c:FindFirstChildOfClass("Humanoid")
        if hm then
            pcall(function()
                hm:Move(Vector3.zero, false)
            end)
        end
    end

    trip.snap()
    -- 持续钉住位置，避免被服务器的位移校验拉回去
    task.spawn(function()
        while not trip.done do
            pcall(trip.snap)
            task.wait()
        end
    end)
    return trip
end

local function shopWaitSynced(trip, secs)
    local deadline = os.clock() + (secs or SHOP_SYNC_WAIT)
    while os.clock() < deadline do
        if trip and trip.snap then
            trip.snap()
        end
        task.wait()
    end
end

local function shopEndTrip(trip)
    if not trip or trip.done then
        return
    end
    trip.done = true

    local char = trip.char
    if char and char.Parent then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = trip.cf
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        else
            pcall(function()
                char:PivotTo(trip.cf)
            end)
        end
    end

    if trip.det and trip.oldTouch ~= nil and trip.det.Parent then
        trip.det.CanTouch = trip.oldTouch
    end
end

local function shopCheckBought(name, ret, moneyBefore, wasOwned)
    if ret == true then
        return true
    end
    local deadline = os.clock() + SHOP_VERIFY_TIME
    while os.clock() < deadline do
        local m = shopGetMoney()
        if moneyBefore and m and m < moneyBefore then
            return true
        end
        if not wasOwned and shopOwnsItem(name) then
            return true
        end
        task.wait(0.1)
    end
    return false
end

local function shopBridgeItem(name, isDealer, guidArg, invoke)
    invoke = invoke or shopBridgeOrig or (shopSignal and shopSignal.InvokeServer)
    if not invoke then
        return nil
    end
    -- 已经在买了就直接转发，避免嵌套传送
    if shopBridgeBusy then
        return invoke(SHOP_REMOTE_BUY, name, isDealer, guidArg)
    end

    local part, _, model = shopNearestPurchasePoint(name)
    if not part then
        return invoke(SHOP_REMOTE_BUY, name, isDealer, guidArg)
    end

    shopBridgeBusy = true
    local trip = shopBeginTrip(part, model)
    shopWaitSynced(trip, SHOP_SYNC_WAIT)

    local wasOwned = shopOwnsItem(name)
    local moneyBefore = shopGetMoney()
    if trip and trip.snap then
        trip.snap()
    end
    local res = table.pack(invoke(SHOP_REMOTE_BUY, name, isDealer, guidArg))
    local bought = shopCheckBought(name, res[1], moneyBefore, wasOwned)

    -- 经销商渠道失败时改用普通购买再试一次
    if not bought and isDealer then
        moneyBefore = shopGetMoney()
        if trip and trip.snap then
            trip.snap()
        end
        res = table.pack(invoke(SHOP_REMOTE_BUY, name, false, guidArg))
        bought = shopCheckBought(name, res[1], moneyBefore, wasOwned)
    end

    shopEndTrip(trip)
    shopBridgeBusy = false
    return table.unpack(res, 1, res.n)
end

local function shopBridgeAmmo(name, guidArg, invoke)
    invoke = invoke or shopBridgeOrig or (shopSignal and shopSignal.InvokeServer)
    if not invoke then
        return nil
    end
    if shopBridgeBusy then
        return invoke(SHOP_REMOTE_AMMO, name, false, guidArg)
    end

    local part, _, model = shopNearestPurchasePoint(name)
    if not part then
        return invoke(SHOP_REMOTE_AMMO, name, false, guidArg)
    end

    shopBridgeBusy = true
    local trip = shopBeginTrip(part, model)
    shopWaitSynced(trip, SHOP_SYNC_WAIT)

    local moneyBefore = shopGetMoney()
    if trip and trip.snap then
        trip.snap()
    end
    local res = table.pack(invoke(SHOP_REMOTE_AMMO, name, false, guidArg))
    shopCheckBought(name, res[1], moneyBefore, true)

    shopEndTrip(trip)
    shopBridgeBusy = false
    return table.unpack(res, 1, res.n)
end

local function shopTrueCostText(name)
    local d = shopItemData(name)
    if not d or type(d.cost) ~= "number" then
        return nil
    end
    local ok, txt = pcall(function()
        return shopComma(math.round(d.cost))
    end)
    if ok and txt ~= nil then
        return "$" .. tostring(txt)
    end
    return "$" .. tostring(math.round(d.cost))
end

local function shopPatchCostLabel(lbl)
    local parent = lbl.Parent
    if not parent then
        return false
    end

    local itemName = nil
    local nameLbl = parent:FindFirstChild("NameLabel")
    local upper = parent:FindFirstChild("UpperLabel")
    if nameLbl then
        itemName = nameLbl.Text:match("^%s*(.-)%s*%(") or nameLbl.Text
    elseif upper then
        itemName = upper.Text:match("^Buy%s+(.-)%s*%?$")
    end

    if not itemName or itemName == "" then
        return false
    end
    if not shopItemData(itemName) then
        return false
    end

    local txt = shopTrueCostText(itemName)
    if txt and lbl.Text ~= txt then
        lbl.Text = txt
        return true
    end
    return false
end

local function shopPatchAllCostLabels()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        return 0
    end
    local n = 0
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "CostLabel" then
            if shopPatchCostLabel(d) then
                n = n + 1
            end
        end
    end
    return n
end

-- 安装购买拦截：链到「当前的」InvokeServer，保证 GM 原有的丢枪逻辑不被顶掉
local function shopInstallBridge()
    if not shopSignal or type(shopSignal.InvokeServer) ~= "function" then
        return false
    end

    -- 重载时先还原上一次的包装，避免层层叠加（跨注入要靠 store 记住原函数）
    if store.shopHookInstalled and type(store.shopHookPrev) == "function" then
        pcall(function()
            shopSignal.InvokeServer = store.shopHookPrev
        end)
        store.shopHookInstalled = false
    end

    shopBridgePrev = shopSignal.InvokeServer
    shopBridgeOrig = shopBridgePrev
    store.shopHookPrev = shopBridgePrev

    shopSignal.InvokeServer = function(remoteName, a, b, c, ...)
        if type(remoteName) == "string" and type(a) == "string" then
            local orig = shopBridgeOrig
            if remoteName == SHOP_REMOTE_BUY and b == true then
                local d = shopItemData(a)
                -- 已拥有且有弹药字段：走补弹
                if shopOwnsItem(a) and d and d.ammo then
                    local ok, r1, r2 = pcall(shopBridgeAmmo, a, c, orig)
                    if ok then
                        return r1, r2
                    end
                else
                    local ok, r1, r2 = pcall(shopBridgeItem, a, true, c, orig)
                    if ok then
                        return r1, r2
                    end
                end
            elseif remoteName == SHOP_REMOTE_AMMO then
                local ok, r1, r2 = pcall(shopBridgeAmmo, a, c, orig)
                if ok then
                    return r1, r2
                end
            end
        end
        if shopBridgePrev then
            return shopBridgePrev(remoteName, a, b, c, ...)
        end
    end

    store.shopHookInstalled = true
    return true
end

local function shopStartLoop()
    shopRunning = true
    task.spawn(function()
        while shopRunning do
            pcall(shopPatchGamepassLayer)
            pcall(shopPatchAllCostLabels)
            task.wait(SHOP_LOOP_GAP)
        end
    end)
end

local function shopStop()
    shopRunning = false
    for _, c in ipairs(shopConns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    shopConns = {}

    if shopSignal and shopBridgePrev and store.shopHookInstalled then
        pcall(function()
            shopSignal.InvokeServer = shopBridgePrev
        end)
        store.shopHookInstalled = false
    end

    shopBridgeBusy = false
    shopRunning = false
end

local function shopStart()
    if not shopSignal then
        return false
    end
    -- 正版拥有者不需要这套
    if shopUserOwnsPass() then
        return false
    end

    shopLoadModules()

    -- 上一次运行留下的停止接口，先收掉
    local prev = store.autoShop
    if type(prev) == "table" and type(prev.stop) == "function" then
        pcall(prev.stop)
    end

    shopAppliedOnce = false
    shopApplyAttribute()

    -- 属性被服务器清掉就补回去
    shopTrack(LocalPlayer:GetAttributeChangedSignal(SHOP_ATTR):Connect(function()
        if shopRunning and LocalPlayer:GetAttribute(SHOP_ATTR) == nil then
            shopApplyAttribute()
        end
    end))

    pcall(shopPatchGamepassLayer)
    shopInstallBridge()
    shopStartLoop()

    local api = {
        running = true,
        bridgeItem = shopBridgeItem,
        bridgeAmmo = shopBridgeAmmo,
        nearest = shopNearestPurchasePoint,
        patchCost = shopPatchAllCostLabels,
        original = shopBridgeOrig,
        beginTrip = shopBeginTrip,
        endTrip = shopEndTrip,
        reset = function()
            shopBridgeBusy = false
        end,
        stop = shopStop,
    }
    store.autoShop = api
    genv.__mobileDealerUnlock = api
    genv.__dealerBridge = api
    return true
end

shopStart()

local function getItemBin()
    local d = RS:FindFirstChild("devv")
    for _, seg in ipairs({ "shared", "Indicies", "v3items", "bin" }) do
        if not d then return nil end
        d = d:FindFirstChild(seg)
    end
    return d
end

local itemData = {}

local function scanItemNames()
    local names = {}
    local bin = getItemBin()
    if bin then
        for _, v in ipairs(bin:GetDescendants()) do
            if v:IsA("ModuleScript") then
                table.insert(names, v.Name)
            end
        end
    end
    table.sort(names)
    return names
end

local function resolveItemData(name)
    local cached = itemData[name]
    if cached then return cached end
    local bin = getItemBin()
    if not bin then return nil end
    local node = bin:FindFirstChild(name, true)
    if not node or not node:IsA("ModuleScript") then return nil end
    local ok, d = pcall(require, node)
    if not ok or type(d) ~= "table" then return nil end
    if type(d.items) == "table" and type(d.items[name]) == "table" then
        local e = d.items[name]
        if type(e.data) == "table" then
            d = e.data
        else
            d = e
        end
    elseif type(d.data) == "table" then
        d = d.data
    end
    itemData[name] = d
    return d
end

local function giveItem(name)
    if not inv or type(name) ~= "string" or name == "" then
        return false
    end
    local data = resolveItemData(name)
    if not data then return false end
    local item = copyTable(data)
    item.guid = randomString(32)
    return addToInventory(item)
end

local settingsData = nil
do
    local mod = RS:FindFirstChild("devv")
        and RS.devv:FindFirstChild("client")
        and RS.devv.client:FindFirstChild("Objects")
        and RS.devv.client.Objects:FindFirstChild("v3item")
        and RS.devv.client.Objects.v3item:FindFirstChild("bin")
        and RS.devv.client.Objects.v3item.bin:FindFirstChild("Phone")
    for _, seg in ipairs({ "modules", "controller", "modules", "phone", "screens", "SettingsApp" }) do
        mod = mod and mod:FindFirstChild(seg)
    end
    local data = mod and mod:FindFirstChild("settingsData")
    if data then
        local ok, tbl = pcall(require, data)
        if ok and type(tbl) == "table" then settingsData = tbl end
    end
end
if settingsData then
    settingsData["gm_switch"] = { displayName = SWITCH_NAME, frameType = "SettingToggle", sort = TAB_NAME, defaultValue = false, onUpdate = function() end }
    settingsData["gm_stomp"] = { displayName = STOMP_NAME, frameType = "SettingToggle", sort = TAB_NAME, defaultValue = false, onUpdate = function() end }
    settingsData["gm_skins"] = { displayName = SKIN_NAME, frameType = "SettingToggle", sort = TAB_NAME, defaultValue = false, onUpdate = function() end }
    settingsData["gm_antiadmin"] = { displayName = ANTIADMIN_NAME, frameType = "SettingToggle", sort = TAB_NAME, defaultValue = false, onUpdate = function() end }
    settingsData["gm_translate"] = { displayName = TRANSLATE_NAME, frameType = "SettingToggle", sort = TAB_NAME, defaultValue = false, onUpdate = function() end }
end

local function contentWidth(sorts, pad)
    local total, n = 0, 0
    for _, c in ipairs(sorts:GetChildren()) do
        if c:IsA("GuiObject") then
            total = total + c.Size.X.Offset
            n = n + 1
        end
    end
    return total + pad * math.max(n - 1, 0)
end

local function patchSorts(sorts)
    if not sorts then return end
    local layout = sorts:FindFirstChildOfClass("UIListLayout")
    local pad = (layout and layout.Padding and layout.Padding.Offset) or PAD_OFFSET

    if not sorts:FindFirstChild(TAB_NAME) then
        local tmpl = sorts:FindFirstChild("Game")
            or sorts:FindFirstChild("Items")
            or sorts:FindFirstChild("Sound")
        if not tmpl then return end
        local g = tmpl:Clone()
        g.Name = TAB_NAME
        g.TextLabel.Text = TAB_NAME
        g.BackgroundTransparency = 1
        g.TextLabel.TextColor3 = Color3.fromRGB(175, 175, 175)
        g.LayoutOrder = 5
        g.Parent = sorts
    end

    local target = contentWidth(sorts, pad) + EXTRA_WIDTH
    local parent = sorts.Parent
    if sorts:IsDescendantOf(Players.LocalPlayer.PlayerGui) and parent then
        local tab = sorts:FindFirstChild("Game")
        local eff = (tab and tab.AbsoluteSize.X > 0) and (tab.AbsoluteSize.X / tab.Size.X.Offset) or nil
        if eff and parent.AbsoluteSize.X > 0 then
            local parentUnscaled = parent.AbsoluteSize.X / eff
            target = math.min(target, parentUnscaled - 2)
        end
    end
    sorts.Size = UDim2.new(0, target, 0, 50)
end

local function syncCanvas(cont)
    if not cont then return end
    local h = 0
    for _, c in ipairs(cont:GetChildren()) do
        if c:IsA("GuiObject") and c.Visible then
            h = h + c.Size.Y.Offset + ROW_GAP
        end
    end
    cont.CanvasSize = UDim2.fromOffset(0, h + 80)
end

local function clearStale(cont)
    for _, n in ipairs(LEGACY_NAMES) do
        local old = cont:FindFirstChild(n)
        if old then old:Destroy() end
    end
    for _, n in ipairs({ SWITCH_NAME, STOMP_NAME, SKIN_NAME, ANTIADMIN_NAME, TRANSLATE_NAME, SEARCH_NAME, GIVER_NAME, JOIN_NAME, HEADLESS_NAME, AIM_NAME, AIM_PART_NAME, AIM_FOVUSE_NAME, AIM_FOV_NAME, AIM_SX_NAME, AIM_SY_NAME, AIM_PX_NAME, AIM_PY_NAME, AIM_RANGE_NAME }) do
        local old = cont:FindFirstChild(n)
        if old and old:GetAttribute("GM_Ver") ~= VERSION then
            old:Destroy()
        end
    end
end

-- ================= 辅助瞄准（引擎） =================
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera

-- 相机不能在加载时快照：脚本可能跑在相机创建之前，那样永远是 nil
local function currentCamera()
    local cam = Workspace.CurrentCamera
    if cam then
        CurrentCamera = cam
    end
    return CurrentCamera
end

local GunController = nil
pcall(function()
    GunController = require(RS.devv.client.Objects.v3item.bin.Gun.modules.controller)
end)

local AimAssistConfig = store.aim
if type(AimAssistConfig) ~= "table" then
    AimAssistConfig = {}
    store.aim = AimAssistConfig
end
do
    local aimDefaults = {
        Enabled = false,
        UseFov = true,
        Fov = 45,
        SpeedX = 2.7,
        SpeedY = 2.8,
        PredictionX = 2.8,
        PredictionY = 2.6,
        Range = 300,
        Part = "Body",
    }
    for k, v in pairs(aimDefaults) do
        if AimAssistConfig[k] == nil then
            AimAssistConfig[k] = v
        end
    end
end

local FOV_COLOR = Color3.fromRGB(255, 255, 255)
local FOV_THICKNESS = 1
local FOV_TRANSP = 0.5

local aimAssistHooked = false
local fovCircleGui, fovCircleFrame, fovCircleStroke
local fovCircleConnection = nil

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude
losParams.IgnoreWater = true
local losFilterCache = { nil, nil }
local losFilterReady = false

local cachedFovVisible = false
local cachedFovX, cachedFovY, cachedFovDiameter = 0, 0, 0

local BASE_FOV_TAN = math.tan(math.rad(35))
local PREDICT_BASE_TIME = 0.032
local PREDICT_DISTANCE_SCALE = 1000
local PREDICT_TIME_FACTOR = 0.36
local PREDICT_GLOBAL_MULT = 0.9

local function getCharacter(player)
    if not player then return nil end
    return player.Character
end

local function getHumanoid(player)
    local char = getCharacter(player)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function getRootPart(player)
    local char = getCharacter(player)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isPlayerValid(player)
    if not player or player == LocalPlayer then return false end
    if player:GetAttribute("isSpawned") ~= true then return false end
    local character = getCharacter(player)
    if not character or not character.Parent then return false end
    if character:FindFirstChildOfClass("ForceField") then return false end
    local humanoid = getHumanoid(player)
    if not humanoid or humanoid.Health <= 0 then return false end
    if type(CheckState) == "function" and not CheckState(player) then return false end
    return true
end

local function getScreenCenter(camera)
    if UIS.TouchEnabled then
        return camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5
    end
    local mouse = UIS:GetMouseLocation()
    return mouse.X, mouse.Y
end

local function fovToScreenPixels(camera, fovDegrees)
    local halfFov = math.clamp((fovDegrees or 0) * 0.5, 0, 89)
    local viewportHeight = camera and camera.ViewportSize.Y or 0
    if viewportHeight < 1 then return 0 end
    return viewportHeight * 0.5 * math.tan(math.rad(halfFov)) / BASE_FOV_TAN
end

local function predictPosition(position, velocity, distance, predictionX, predictionY)
    velocity = velocity or Vector3.new()
    local travelTime = PREDICT_BASE_TIME + distance / PREDICT_DISTANCE_SCALE * PREDICT_TIME_FACTOR
    local predictedOffset = Vector3.new(
        velocity.X * predictionX,
        velocity.Y * predictionY,
        velocity.Z * predictionX
    ) * travelTime * PREDICT_GLOBAL_MULT
    return position + predictedOffset
end

local function hasLineOfSight(fromPosition, toPosition, targetCharacter, localCharacter)
    if not losFilterReady or losFilterCache[1] ~= localCharacter then
        losFilterReady = true
        local gameFolder = Workspace:FindFirstChild("Game")
        losFilterCache[1] = localCharacter
        losFilterCache[2] = gameFolder and gameFolder:FindFirstChild("Local") or nil
        losParams.FilterDescendantsInstances = losFilterCache
    end

    local direction = toPosition - fromPosition
    local magnitude = direction.Magnitude
    if magnitude <= 0.25 then return true end

    local result = Workspace:Raycast(
        fromPosition,
        direction.Unit * math.min(magnitude, 1500),
        losParams
    )
    return not result or (result.Instance and result.Instance:IsDescendantOf(targetCharacter))
end

local function linearStep(progress)
    return math.clamp(progress, 0, 1)
end

local function fovHost()
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    if pg and pg.Parent then return pg end
    local lp = Players.LocalPlayer
    if lp then
        local ok, p = pcall(function() return lp:FindFirstChild("PlayerGui") end)
        if ok and p then return p end
    end
    return nil
end

local function createFovCircle()
    local host = fovHost()
    if not host then return false end

    local old = host:FindFirstChild("AimAssistFovCircle")
    if old then
        pcall(function() old:Destroy() end)
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimAssistFovCircle"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local okParent = pcall(function() screenGui.Parent = host end)
    if not okParent then
        if pg then
            pcall(function() screenGui.Parent = pg end)
        else
            pcall(function() screenGui:Destroy() end)
            return false
        end
    end

    local frame = Instance.new("Frame")
    frame.Name = "Circle"
    frame.BackgroundTransparency = 1
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = FOV_THICKNESS
    stroke.Transparency = FOV_TRANSP
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = FOV_COLOR
    stroke.Parent = frame

    fovCircleGui = screenGui
    fovCircleFrame = frame
    fovCircleStroke = stroke
    cachedFovVisible = false
    cachedFovX, cachedFovY, cachedFovDiameter = 0, 0, 0
    return true
end

local function stopFovCircleRender()
    if fovCircleConnection then
        fovCircleConnection:Disconnect()
        fovCircleConnection = nil
    end
    if fovCircleFrame then
        fovCircleFrame.Visible = false
    end
    cachedFovVisible = false
end

local function startFovCircleRender()
    stopFovCircleRender()

    local function ensure()
        if fovCircleFrame and fovCircleFrame.Parent
            and fovCircleGui and fovCircleGui.Parent then
            return true
        end
        return createFovCircle()
    end

    local function render()
        if not ensure() then return end

        local camera = currentCamera()
        local shouldShow = AimAssistConfig.Enabled
            and AimAssistConfig.UseFov
            and camera ~= nil

        if cachedFovVisible ~= shouldShow then
            cachedFovVisible = shouldShow
            fovCircleFrame.Visible = shouldShow
        end
        if not shouldShow then return end

        local mouseX, mouseY = getScreenCenter(camera)
        local diameter = math.max(2, math.floor(fovToScreenPixels(camera, AimAssistConfig.Fov) * 2 + 0.5))

        if cachedFovX ~= mouseX or cachedFovY ~= mouseY then
            cachedFovX = mouseX
            cachedFovY = mouseY
            fovCircleFrame.Position = UDim2.new(0, mouseX, 0, mouseY)
        end
        if cachedFovDiameter ~= diameter then
            cachedFovDiameter = diameter
            fovCircleFrame.Size = UDim2.new(0, diameter, 0, diameter)
        end
    end

    render()
    local okConn = pcall(function()
        fovCircleConnection = RunService.RenderStepped:Connect(render)
    end)
    if not okConn or not fovCircleConnection then
        fovCircleConnection = RunService.Heartbeat:Connect(render)
    end
end

local function aimAssistMain(first, ...)
    local dt = first
    if type(dt) ~= "number" then dt = select(1, ...) end

    if not v3item or type(v3item.GetEquipped) ~= "function" then return end
    local equippedItem = v3item.GetEquipped(LocalPlayer)
    if not equippedItem then return end
    local ammoManager = equippedItem.ammoManager
    if ammoManager and (ammoManager.ammo or 0) <= 0 then return end

    local localCharacter = getCharacter(LocalPlayer)
    local localRoot = getRootPart(LocalPlayer)
    local camera = currentCamera()
    if not localCharacter or not localRoot or not camera then return end

    local cameraCFrame = camera.CFrame
    local cameraPosition = cameraCFrame.Position
    local viewportSize = camera.ViewportSize
    local mouseX, mouseY = getScreenCenter(camera)
    local fovPixelRadius = fovToScreenPixels(camera, AimAssistConfig.Fov)
    local maxViewportRadius = math.max(1, math.min(viewportSize.X, viewportSize.Y) * 0.5)

    local bestScore = math.huge
    local bestAngleX, bestAngleY = nil, nil

    for _, player in ipairs(Players:GetPlayers()) do
        if isPlayerValid(player) then
            local character = getCharacter(player)

            local aimPart
            if AimAssistConfig.Part == "Head" then
                aimPart = character:FindFirstChild("Head")
            else
                aimPart = character:FindFirstChild("UpperTorso")
                    or character:FindFirstChild("LowerTorso")
                    or character:FindFirstChild("HumanoidRootPart")
            end

            if aimPart and aimPart.Parent then
                local targetPosition = aimPart.Position
                local distance = LocalPlayer:DistanceFromCharacter(targetPosition)

                if distance <= AimAssistConfig.Range then
                    local predicted = predictPosition(
                        targetPosition,
                        aimPart.AssemblyLinearVelocity or aimPart.Velocity or Vector3.new(),
                        distance,
                        AimAssistConfig.PredictionX,
                        AimAssistConfig.PredictionY
                    )

                    local objectSpace = cameraCFrame:PointToObjectSpace(predicted)
                    local magnitude = objectSpace.Magnitude

                    if magnitude > 0.35 then
                        local invMag = 1 / magnitude
                        local dirX = objectSpace.X * invMag
                        local dirY = objectSpace.Y * invMag
                        local dirZ = -objectSpace.Z * invMag

                        if dirZ > 0.02 then
                            local screenPos, onScreen = camera:WorldToViewportPoint(predicted)

                            if screenPos.Z > 0.05 then
                                local dx = screenPos.X - mouseX
                                local dy = screenPos.Y - mouseY
                                local screenDist = math.sqrt(dx * dx + dy * dy)

                                if not AimAssistConfig.UseFov or screenDist <= fovPixelRadius then
                                    if not onScreen then
                                        screenDist = screenDist + 400
                                    end

                                    local score = (screenDist / maxViewportRadius) ^ 2 * 1.55
                                        + (distance / math.max(1, AimAssistConfig.Range)) ^ 2 * 0.35

                                    if score < bestScore
                                        and hasLineOfSight(cameraPosition, targetPosition, character, localCharacter) then
                                        bestAngleX = math.atan2(dirX, dirZ) / (math.pi / 180)
                                        bestAngleY = math.atan2(dirY, dirZ) / (math.pi / 180)
                                        bestScore = score
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not bestAngleX then return end

    if not CR or type(CR.Get) ~= "function" or type(CR.Set) ~= "function" then return end

    local aimAssistMod = equippedItem.aimAssistMod or 1
    local speedX = linearStep(AimAssistConfig.SpeedX * aimAssistMod)
    local speedY = linearStep(AimAssistConfig.SpeedY * aimAssistMod)

    local currentX = CR.Get(LocalPlayer, "xAngle") or 0
    local currentY = CR.Get(LocalPlayer, "yAngle") or 0
    local newX = (currentX - bestAngleX * speedX) % 360
    local newY = math.clamp(currentY + bestAngleY * speedY, -80, 80)

    CR.Set(LocalPlayer, "xAngle", newX)
    CR.Set(LocalPlayer, "yAngle", newY)
end

-- 枪械控制器可能是懒加载的，晚一点才拿得到，这里按需再试
local function resolveGunController()
    if GunController and type(GunController.aimAssist) == "function" then
        return GunController
    end
    local ok, mod = pcall(function()
        return require(RS.devv.client.Objects.v3item.bin.Gun.modules.controller)
    end)
    if ok and type(mod) == "table" and type(mod.aimAssist) == "function" then
        GunController = mod
    end
    return GunController
end

local function enableAimAssist(silent)
    if aimAssistHooked then return true end
    local gc = resolveGunController()
    if not gc or type(gc.aimAssist) ~= "function" then
        return false
    end
    if type(hookfunction) ~= "function" then
        return false
    end
    local ok = pcall(function()
        hookfunction(gc.aimAssist, aimAssistMain)
    end)
    if not ok then return false end
    aimAssistHooked = true
    store.aimHookInstalled = true
    return true
end

local function disableAimAssist()
    if not aimAssistHooked then return end
    local gc = GunController
    if gc and type(restorefunction) == "function" then
        pcall(restorefunction, gc.aimAssist)
    end
    aimAssistHooked = false
    store.aimHookInstalled = false
end

-- 钩子还没装上的话，过一会儿再试几次（模块/执行器可能还没就绪）
local hookRetries = 0
local function scheduleHookRetry()
    if hookRetries >= 20 then return end
    if not AimAssistConfig.Enabled then return end
    hookRetries = hookRetries + 1
    task.delay(1, function()
        if not AimAssistConfig.Enabled then return end
        if enableAimAssist(true) then
            hookRetries = 0
        else
            scheduleHookRetry()
        end
    end)
end

-- 开关只管钩子；视野圈由 render 循环根据 Enabled+UseFov 自己显隐，
-- 所以即使钩子装不上，圈该显示还是会显示。
local function applyAimState(on)
    AimAssistConfig.Enabled = on == true
    if AimAssistConfig.Enabled then
        local ok = enableAimAssist(true)
        if not ok then
            scheduleHookRetry()
            return false
        end
        hookRetries = 0
    else
        disableAimAssist()
        hookRetries = 0
    end
    return true
end

-- 轻提示：同款圆角深色卡片，2 秒自动淡出
local function gmToast(text)
    local host = pg
    if not host then return end
    local old = host:FindFirstChild("GM_Toast")
    if old then pcall(function() old:Destroy() end) end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GM_Toast"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 20
    gui.Parent = host

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5, 1)
    box.Position = UDim2.new(0.5, 0, 0.86, 0)
    box.Size = UDim2.new(0, 260, 0, 40)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    box.BorderSizePixel = 0
    box.Parent = gui

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(235, 235, 235)
    lbl.Text = tostring(text)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = box

    task.delay(2, function()
        pcall(function() gui:Destroy() end)
    end)
end

local function NotifyAimUnavailable()
    gmToast("瞄准钩子还没就绪，正在重试（视野圈已生效）")
end

startFovCircleRender()

-- 脚本重载时先还原上一次的钩子，避免叠加
if type(restorefunction) == "function" and GunController
    and type(GunController.aimAssist) == "function" then
    if store.aimHookInstalled then
        pcall(restorefunction, GunController.aimAssist)
    end
    if store.aimPrev and type(hookfunction) == "function" then
        pcall(function()
            hookfunction(GunController.aimAssist, store.aimPrev)
        end)
        store.aimPrev = nil
    end
end
store.aimHookInstalled = false
-- 上次开着就自动恢复；钩子装不上也不关开关，避免视野圈跟着消失
if AimAssistConfig.Enabled then
    if not enableAimAssist(true) then
        scheduleHookRetry()
    end
end

-- ================= 无头断腿美化 =================
local HEADLESS_MESH = "https://assetdelivery.roblox.com/v1/asset/?id=9598310133"
local HEADLESS_TEXTURE = "https://www.roblox.com/asset/?id=902843398"
local HEADLESS_DEAD_MESH = "123"

local Beauty = store.Beauty
if type(Beauty) ~= "table" then
    Beauty = {}
    store.Beauty = Beauty
end

local BeautyConns = {}
local BeautyCharConn = nil

local function disconnectBeauty()
    for _, c in ipairs(BeautyConns) do
        pcall(function() c:Disconnect() end)
    end
    BeautyConns = {}
end

-- 隐藏头部（摘掉脸部贴图），并盯着 Head 被重新塞回来
local function hideHeadOf(char)
    if not char then return end

    local function hide(head)
        if not head then return end
        pcall(function()
            if head:GetAttribute("GM_OrigHeadTrans") == nil then
                head:SetAttribute("GM_OrigHeadTrans", head.Transparency)
            end
            head.Transparency = 1
        end)
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") then
                pcall(function() v:Destroy() end)
            end
        end
    end

    hide(char:FindFirstChild("Head"))

    local ok, conn = pcall(function()
        return char.ChildAdded:Connect(function(child)
            if child.Name == "Head" then
                task.wait(0.01)
                hide(child)
            end
        end)
    end)
    if ok and conn then
        table.insert(BeautyConns, conn)
        track(conn)
    end
end

-- 换腿上的网格（原始值记在部件属性里，脚本重载也还能还原）
local function setPartMesh(part, meshId, textureId)
    if not part then return false end
    local ok = pcall(function()
        if part:GetAttribute("GM_OrigMesh") == nil then
            part:SetAttribute("GM_OrigMesh", tostring(part.MeshId or ""))
            part:SetAttribute("GM_OrigTex", tostring(part.TextureID or ""))
        end
        part.MeshId = meshId
        if textureId then
            part.TextureID = textureId
        end
    end)
    return ok
end

local function restorePart(part)
    if not part then return end
    pcall(function()
        local m = part:GetAttribute("GM_OrigMesh")
        if m ~= nil then part.MeshId = m end
        local t = part:GetAttribute("GM_OrigTex")
        if t ~= nil then part.TextureID = t end
        part:SetAttribute("GM_OrigMesh", nil)
        part:SetAttribute("GM_OrigTex", nil)
    end)
end

local function applyLegsTo(char)
    if not char then return end
    task.spawn(function()
        if not char.Parent then return end
        local upper = char:FindFirstChild("RightUpperLeg") or char:WaitForChild("RightUpperLeg", 8)
        local lower = char:FindFirstChild("RightLowerLeg") or char:WaitForChild("RightLowerLeg", 8)
        local foot = char:FindFirstChild("RightFoot") or char:WaitForChild("RightFoot", 8)
        if not Beauty.Enabled or not char.Parent then return end
        setPartMesh(upper, HEADLESS_MESH, HEADLESS_TEXTURE)
        setPartMesh(lower, HEADLESS_DEAD_MESH)
        setPartMesh(foot, HEADLESS_DEAD_MESH)
    end)
end

local function restoreCharacter(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        pcall(function()
            local t = head:GetAttribute("GM_OrigHeadTrans")
            if t ~= nil then
                head.Transparency = t
                head:SetAttribute("GM_OrigHeadTrans", nil)
            end
        end)
    end
    restorePart(char:FindFirstChild("RightUpperLeg"))
    restorePart(char:FindFirstChild("RightLowerLeg"))
    restorePart(char:FindFirstChild("RightFoot"))
end

local function applyBeautyToCharacter(char)
    if not Beauty.Enabled or not char then return end
    hideHeadOf(char)
    applyLegsTo(char)
end

local function enableBeauty()
    Beauty.Enabled = true
    if BeautyCharConn then
        pcall(function() BeautyCharConn:Disconnect() end)
        BeautyCharConn = nil
    end
    -- 关键：一次连接，之后每次死亡重生都会重新套用
    local ok, conn = pcall(function()
        return LocalPlayer.CharacterAdded:Connect(function(char)
            applyBeautyToCharacter(char)
        end)
    end)
    if ok and conn then
        BeautyCharConn = conn
        track(conn)
    end
    local char = LocalPlayer.Character
    if char then
        applyBeautyToCharacter(char)
    else
        task.spawn(function()
            local c = LocalPlayer.CharacterAdded:Wait()
            applyBeautyToCharacter(c)
        end)
    end
    return true
end

local function disableBeauty()
    Beauty.Enabled = false
    disconnectBeauty()
    if BeautyCharConn then
        pcall(function() BeautyCharConn:Disconnect() end)
        BeautyCharConn = nil
    end
    restoreCharacter(LocalPlayer.Character)
    return true
end

local function setBeauty(state)
    if state == true then
        enableBeauty()
    else
        disableBeauty()
    end
    store.beautyOn = Beauty.Enabled
    return Beauty.Enabled
end

-- 上次开着就自动恢复（脚本重载也保持一致）
Beauty.Enabled = false
if store.beautyOn == true then
    enableBeauty()
end

local function uiTheme()
    local frames = RS:FindFirstChild("Guis") and RS.Guis:FindFirstChild("Frames")
    local tmpl = frames and frames:FindFirstChild("SettingToggle")
    local bg = Color3.fromRGB(45, 45, 52)
    local txt = Color3.fromRGB(235, 235, 235)
    local dim = Color3.fromRGB(140, 140, 140)
    local radius = 8
    if tmpl then
        if tmpl:IsA("GuiObject") then
            bg = tmpl.BackgroundColor3
        end
        local nl = tmpl:FindFirstChild("NameLabel")
        if nl and nl:IsA("TextLabel") then
            txt = nl.TextColor3
            dim = nl.TextColor3:Lerp(Color3.fromRGB(0, 0, 0), 0.45)
        end
        local c = tmpl:FindFirstChildOfClass("UICorner")
        if c then
            radius = c.CornerRadius.Offset
        end
    end
    return bg, txt, dim, radius
end

local function resolveText(t)
    if type(t) == "function" then
        local ok, v = pcall(t)
        if ok and type(v) == "string" then
            return v
        end
        return ""
    end
    return t
end

local function labelFor(en, zh)
    if Tr.Enabled then
        return zh
    end
    return en
end

local function makeToggle(cont, keyName, text, order, id, getState, setState)
    if not cont then return nil end
    local existing = cont:FindFirstChild(keyName)
    local wasVisible = existing ~= nil and existing.Visible
    if existing then existing:Destroy() end

    local frames = RS:FindFirstChild("Guis") and RS.Guis:FindFirstChild("Frames")
    local tmpl = frames and frames:FindFirstChild("SettingToggle")
    if not tmpl then return nil end

    local item = tmpl:Clone()
    item.Name = keyName
    item.LayoutOrder = order
    item.Size = UDim2.new(0.84, 0, 0, ROW_H)
    item.Position = UDim2.new(0.05, 0, 0, 0)
    item.NameLabel.Text = resolveText(text)
    item:SetAttribute("GM_Ver", VERSION)
    item:SetAttribute("GM_Ui", true)
    item:SetAttribute("Id", id)

    local onBtn = item.Buttons.On
    local offBtn = item.Buttons.Off

    local function paint()
        local v = getState() == true
        onBtn.BackgroundColor3 = v and COLOR_ON or COLOR_IDLE
        offBtn.BackgroundColor3 = (not v) and COLOR_OFF or COLOR_IDLE
    end

    paint()

    local function relabel()
        pcall(function()
            item.NameLabel.Text = resolveText(text)
        end)
    end

    track(onBtn.Activated:Connect(function()
        pcall(setState, true)
        relabel()
        paint()
    end))
    track(offBtn.Activated:Connect(function()
        pcall(setState, false)
        relabel()
        paint()
    end))

    item.Visible = wasVisible
    item.Parent = cont
    return item
end

-- 数值行：模板标题 + 圆角滑条（跟开关行同一套字体/配色/圆角）
-- opts = { name, order, text, min, max, step, get, set, fmt }
local function makeSliderRow(cont, opts)
    if not cont then return nil end
    local existing = cont:FindFirstChild(opts.name)
    local wasVisible = existing ~= nil and existing.Visible
    if existing then existing:Destroy() end

    local frames = RS:FindFirstChild("Guis") and RS.Guis:FindFirstChild("Frames")
    local tmpl = frames and frames:FindFirstChild("SettingToggle")
    if not tmpl then return nil end

    local bg, txt, dim, radius = uiTheme()
    local r = (radius and radius > 0) and radius or 8

    local item = tmpl:Clone()
    item.Name = opts.name
    item.LayoutOrder = opts.order
    item.Size = UDim2.new(0.84, 0, 0, ROW_H)
    item.Position = UDim2.new(0.05, 0, 0, 0)
    item:SetAttribute("GM_Ver", VERSION)
    item:SetAttribute("GM_Ui", true)

    local btns = item:FindFirstChild("Buttons")
    if btns then btns.Visible = false end

    item.NameLabel.Text = resolveText(opts.text)
    item.NameLabel.Size = UDim2.new(1, -70, 0, 22)
    item.NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "ValueLabel"
    valLabel.BackgroundTransparency = 1
    valLabel.AnchorPoint = Vector2.new(1, 0)
    valLabel.Position = UDim2.new(1, -4, 0, 0)
    valLabel.Size = UDim2.new(0, 66, 0, 22)
    valLabel.Font = item.NameLabel.Font
    valLabel.TextSize = item.NameLabel.TextSize
    valLabel.TextColor3 = txt
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Text = ""
    valLabel.Parent = item

    local trackBar = Instance.new("Frame")
    trackBar.Name = "Track"
    trackBar.Size = UDim2.new(1, -8, 0, 14)
    trackBar.Position = UDim2.new(0, 4, 0, 34)
    trackBar.BackgroundColor3 = bg:Lerp(txt, 0.16)
    trackBar.BackgroundTransparency = 0
    trackBar.BorderSizePixel = 0
    trackBar.Parent = item

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = trackBar

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = COLOR_ON
    fill.BorderSizePixel = 0
    fill.Parent = trackBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = txt
    knob.BorderSizePixel = 0
    knob.Parent = trackBar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local minV = opts.min or 0
    local maxV = opts.max or 1
    local span = (maxV - minV)
    if span <= 0 then span = 1 end

    local function fmt(v)
        if opts.fmt then return opts.fmt(v) end
        return tostring(v)
    end

    local function paint(v)
        local a = math.clamp((v - minV) / span, 0, 1)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valLabel.Text = fmt(v)
    end

    local function setValue(v, fire)
        v = math.clamp(v, minV, maxV)
        if opts.step and opts.step > 0 then
            v = math.floor(v / opts.step + 0.5) * opts.step
        end
        if opts.set then
            pcall(opts.set, v)
        end
        paint(v)
        if fire and opts.onChanged then
            pcall(opts.onChanged, v)
        end
    end

    local cur = 0
    if opts.get then
        local ok, v = pcall(opts.get)
        if ok and type(v) == "number" then cur = v end
    end
    paint(cur)

    local dragging = false
    local function applyX(px)
        local w = trackBar.AbsoluteSize.X
        if w <= 1 then return end
        local a = math.clamp((px - trackBar.AbsolutePosition.X) / w, 0, 1)
        setValue(minV + span * a, true)
    end

    track(trackBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            applyX(input.Position.X)
        end
    end))
    track(trackBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    track(UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then
            applyX(input.Position.X)
        end
    end))
    track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    item.Visible = wasVisible
    item.Parent = cont
    return item
end

-- 选项行：模板标题 + 一排「获取」同款按钮
-- opts = { name, order, text, options = {..}, get, set }
local function makeChoiceRow(cont, opts)
    if not cont then return nil end
    local existing = cont:FindFirstChild(opts.name)
    local wasVisible = existing ~= nil and existing.Visible
    if existing then existing:Destroy() end

    local frames = RS:FindFirstChild("Guis") and RS.Guis:FindFirstChild("Frames")
    local tmpl = frames and frames:FindFirstChild("SettingToggle")
    local buyTpl = frames and frames:FindFirstChild("DealerItem")
        and frames.DealerItem:FindFirstChild("Buy")
    if not tmpl then return nil end

    local bg, txt, dim, radius = uiTheme()

    local item = tmpl:Clone()
    item.Name = opts.name
    item.LayoutOrder = opts.order
    item.Size = UDim2.new(0.84, 0, 0, ROW_H)
    item.Position = UDim2.new(0.05, 0, 0, 0)
    item:SetAttribute("GM_Ver", VERSION)
    item:SetAttribute("GM_Ui", true)

    local btns = item:FindFirstChild("Buttons")
    if btns then btns.Visible = false end

    item.NameLabel.Text = resolveText(opts.text)
    item.NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local holder = Instance.new("Frame")
    holder.Name = "Options"
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, -8, 0, 30)
    holder.Position = UDim2.new(0, 4, 0, 34)
    holder.Parent = item

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = holder

    local buttons = {}
    local function paint()
        local cur = nil
        if opts.get then
            local ok, v = pcall(opts.get)
            if ok then cur = v end
        end
        for label, btn in pairs(buttons) do
            local active = (label == cur)
            pcall(function()
                btn.TextLabel.TextColor3 = active and COLOR_ON or dim
            end)
        end
        if opts.onPainted then pcall(opts.onPainted) end
    end

    local n = #opts.options
    local gapTotal = 8 * math.max(n - 1, 0)
    for i, label in ipairs(opts.options) do
        local btn
        if buyTpl and buyTpl:IsA("GuiObject") then
            btn = buyTpl:Clone()
        else
            btn = Instance.new("TextButton")
            btn.BackgroundColor3 = bg
            btn.BorderSizePixel = 0
        end
        btn.Name = "GM_Opt" .. tostring(i)
        btn.Size = UDim2.new(1 / n, -math.floor(gapTotal / n), 1, 0)
        btn.TextLabel.Text = label
        btn.Parent = holder
        buttons[label] = btn

        local function pick()
            if opts.set then pcall(opts.set, label) end
            paint()
        end

        local hooked = false
        local makeButton = load("makeButton")
        if makeButton then
            hooked = pcall(function()
                local b = makeButton({
                    super = "mouseOverDetect",
                    UIObject = btn,
                    baseSize = UDim2.new(1 / n, -math.floor(gapTotal / n), 1, 0),
                    scaleFactor = 0.95,
                    activatedFunc = pick,
                })
                b:Init()
            end)
        end
        if not hooked then
            local inner = btn:FindFirstChild("Button")
            if inner and inner:IsA("GuiButton") then
                track(inner.Activated:Connect(pick))
            end
            if btn:IsA("GuiButton") then
                track(btn.Activated:Connect(pick))
            end
        end
    end

    paint()

    item.Visible = wasVisible
    item.Parent = cont
    return item
end

local rowPaints = {}

-- 「加入 / 搜索」按钮上的字（不加英文括号）
local function actionLabel(zh, en)
    if Tr.Enabled then
        return zh
    end
    return en
end

-- 输入框 + 「获取」同款按钮，一行排开
-- opts = { name, order, placeholder, value, storeKey, label = function, onSubmit(text), onText(text) }
local function makeInputRow(cont, opts)
    if not cont or not opts then return nil end

    local name = opts.name
    local existing = cont:FindFirstChild(name)
    local wasVisible = existing ~= nil and existing.Visible
    if existing then existing:Destroy() end

    local frames = RS:FindFirstChild("Guis") and RS.Guis:FindFirstChild("Frames")
    local toggleTmpl = frames and frames:FindFirstChild("SettingToggle")
    local dealerTmpl = frames and frames:FindFirstChild("DealerItem")
    local buyTpl = dealerTmpl and dealerTmpl:FindFirstChild("Buy")
    local bg, txt, dim, radius = uiTheme()
    local tplLabel = toggleTmpl and toggleTmpl:FindFirstChild("NameLabel")

    -- 按钮尺寸跟「获取」保持一致，取不到模板就用默认值
    local btnW, btnH = 88, 40
    if buyTpl and buyTpl:IsA("GuiObject") then
        if buyTpl.Size.X.Scale == 0 and buyTpl.Size.X.Offset > 0 then
            btnW = buyTpl.Size.X.Offset
        end
        if buyTpl.Size.Y.Scale == 0 and buyTpl.Size.Y.Offset > 0 then
            btnH = buyTpl.Size.Y.Offset
        end
    end
    local GAP = 8
    local H = math.max(btnH, 32)
    local extra = opts.gapAfter or 0

    local row = Instance.new("Frame")
    row.Name = name
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Size = UDim2.new(0.84, 0, 0, H + extra)
    row.Position = UDim2.new(0.05, 0, 0, 0)
    row.LayoutOrder = opts.order or 1000
    row:SetAttribute("GM_Ver", VERSION)
    row:SetAttribute("GM_Ui", true)

    local box = Instance.new("TextBox")
    box.Name = "GM_InputBox"
    box.Size = UDim2.new(1, -(btnW + GAP), 0, H)
    box.Position = UDim2.new(0, 0, 0, 0)
    box.BackgroundColor3 = bg
    box.BackgroundTransparency = 0
    box.BorderSizePixel = 0
    box.Font = (tplLabel and tplLabel.Font) or Enum.Font.Gotham
    box.TextSize = (tplLabel and math.max(tplLabel.TextSize, 16)) or 16
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextColor3 = txt
    box.Text = type(opts.value) == "string" and opts.value or ""
    box.PlaceholderText = opts.placeholder or ""
    box.PlaceholderColor3 = dim
    box.ClearTextOnFocus = false
    box.ClipsDescendants = true
    box.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, (radius and radius > 0) and radius or 12)
    corner.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.Parent = box

    -- 按钮：克隆「获取」那个 Buy，保证素材/配色/圆角一模一样
    local btn = nil
    if buyTpl and buyTpl:IsA("GuiObject") then
        btn = buyTpl:Clone()
        btn.Name = "GM_ActionButton"
    else
        btn = Instance.new("TextButton")
        btn.Name = "GM_ActionButton"
        btn.BackgroundColor3 = COLOR_ON
        btn.BorderSizePixel = 0
        btn.Font = (tplLabel and tplLabel.Font) or Enum.Font.Gotham
        btn.TextSize = 16
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, (radius and radius > 0) and radius or 12)
        bc.Parent = btn
    end
    btn.AnchorPoint = Vector2.new(1, 0)
    btn.Position = UDim2.new(1, 0, 0, 0)
    btn.Size = UDim2.new(0, btnW, 0, H)
    btn.Parent = row

    local origTextSize = 16
    pcall(function() origTextSize = btn.TextLabel.TextSize end)
    local MIN_TEXT = 13

    local function measureText(text, size, font)
        local w = 0
        pcall(function()
            local ts = game:GetService("TextService")
            local sz = ts:GetTextSize(text, size, font, Vector2.new(1000, 100))
            w = sz.X
        end)
        if w <= 0 then
            pcall(function() w = btn.TextLabel.TextBounds.X end)
        end
        return w
    end

    -- 字要塞进「和获取一样大」的按钮：原字号 -> 缩字号(≥13) -> 才撑宽
    -- 必须在 makeButton 的 baseSize 定下来之前跑完，否则悬停时尺寸会弹回
    local function paintLabel()
        local text = opts.label and opts.label() or ""
        local hasLabel = false
        pcall(function() hasLabel = btn.TextLabel:IsA("TextLabel") end)
        if not hasLabel then
            if btn:IsA("TextButton") then btn.Text = text end
            return
        end
        local lbl = btn.TextLabel
        lbl.TextSize = origTextSize
        lbl.Text = text
        if btn:IsA("TextButton") then btn.Text = text end
        if lbl.TextScaled or text == "" then return end
        local avail = btnW - 14
        local need = measureText(text, origTextSize, lbl.Font)
        if need <= 0 or need <= avail then return end
        local scaled = math.floor(origTextSize * avail / need)
        if scaled >= MIN_TEXT then
            lbl.TextSize = scaled
            if measureText(text, scaled, lbl.Font) <= avail then return end
            lbl.TextSize = origTextSize
        end
        local rowW = row.AbsoluteSize.X
        if rowW <= 0 then rowW = cont.AbsoluteSize.X * 0.84 end
        local cap = (rowW > 0) and math.floor(rowW * 0.55) or 140
        local want = math.min(need + 14, cap)
        if want > btnW then
            btnW = want
            btn.Size = UDim2.new(0, btnW, 0, H)
            box.Size = UDim2.new(1, -(btnW + GAP), 0, H)
        end
    end
    paintLabel()
    rowPaints[name] = paintLabel

    local function submit()
        if opts.onSubmit then
            pcall(opts.onSubmit, tostring(box.Text or ""))
        end
    end

    -- 点击 + 悬停缩放，跟列表里的获取键用同一套
    local hooked = false
    local makeButton = load("makeButton")
    if makeButton then
        hooked = pcall(function()
            local b = makeButton({
                super = "mouseOverDetect",
                UIObject = btn,
                baseSize = UDim2.fromOffset(btnW, H),
                scaleFactor = 0.95,
                activatedFunc = submit,
            })
            b:Init()
        end)
    end
    if not hooked then
        local inner = btn:FindFirstChild("Button")
        if inner and inner:IsA("GuiButton") then
            track(inner.Activated:Connect(submit))
        end
        if btn:IsA("GuiButton") then
            track(btn.Activated:Connect(submit))
        end
    end

    track(box:GetPropertyChangedSignal("Text"):Connect(function()
        if opts.storeKey then
            store[opts.storeKey] = box.Text
        end
        if opts.onText then
            pcall(opts.onText, tostring(box.Text or ""))
        end
    end))
    track(box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submit()
        end
    end))
    local okRet, retEvent = pcall(function()
        return box.ReturnPressedFromOnScreenKeyboard
    end)
    if okRet and retEvent then
        track(retEvent:Connect(submit))
    end

    row.Visible = wasVisible
    row.Parent = cont
    return { row = row, box = box, btn = btn, paint = paintLabel, height = H }
end

-- 加入玩家：输入名/ID + 「加入」按钮
local function makeJoinRow(cont, order)
    if not cont then return nil end

    local holder = nil
    local dim = select(3, uiTheme())
    local hintId = 0
    local lastJoin = nil

    local function hint(text, color)
        if not holder then return end
        local box = holder.box
        hintId = hintId + 1
        local my = hintId
        box.PlaceholderText = text
        box.PlaceholderColor3 = color
        task.delay(2.5, function()
            if my ~= hintId or not box.Parent then return end
            box.PlaceholderText = JOIN_HINT
            box.PlaceholderColor3 = dim
        end)
    end

    local function doJoin(raw)
        if not holder then return end
        if lastJoin then
            local now = os.clock()
            if now - lastJoin < 0.6 then return end
        end
        lastJoin = os.clock()

        local target = tostring(raw or ""):match("^%s*(.-)%s*$")
        if target == "" then
            hint("请输入玩家名或ID", COLOR_OFF)
            return
        end

        local userId = tonumber(target)
        if type(userId) ~= "number" then
            local ok, res = pcall(function()
                return Players:GetUserIdFromNameAsync(target)
            end)
            if ok and tonumber(res) then
                userId = tonumber(res)
            end
        end
        if type(userId) ~= "number" then
            hint("无法解析该玩家", COLOR_OFF)
            return
        end

        local sg = signal
        if not (sg and type(sg.FireServer) == "function") then
            hint("通信未就绪", COLOR_OFF)
            return
        end

        local ok = pcall(function()
            sg.FireServer("joinServer", userId)
        end)
        if not ok then
            hint("加入失败", COLOR_OFF)
            return
        end

        store.joinTarget = ""
        holder.box.Text = ""
        hint("正在加入该玩家…", COLOR_ON)
    end

    holder = makeInputRow(cont, {
        name = JOIN_NAME,
        order = order,
        placeholder = JOIN_HINT,
        value = type(store.joinTarget) == "string" and store.joinTarget or "",
        storeKey = "joinTarget",
        gapAfter = JOIN_GAP,
        label = function() return actionLabel("加入", "Join") end,
        onSubmit = doJoin,
    })
    if not holder then return nil end
    return holder.row
end

local function buildGiver(cont)
    if not cont then return nil end

    local existing = cont:FindFirstChild(GIVER_NAME)
    local wasVisible = existing ~= nil and existing.Visible
    if existing then existing:Destroy() end

    local oldSearch = cont:FindFirstChild(SEARCH_NAME)
    if oldSearch then
        oldSearch:Destroy()
    end


    local frames = RS:FindFirstChild("Guis") and RS.Guis:FindFirstChild("Frames")
    local tmpl = frames and frames:FindFirstChild("DealerItem")
    if not tmpl then
        return nil
    end

    local wrap = Instance.new("Frame")
    wrap.Name = GIVER_NAME
    wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel = 0
    wrap.Size = UDim2.new(1, 0, 0, ROW_H)
    wrap.LayoutOrder = 1091
    wrap:SetAttribute("GM_Ver", VERSION)
    wrap:SetAttribute("GM_Ui", true)
    wrap:SetAttribute("GM_Run", runId)

    local holder = Instance.new("Frame")
    holder.Name = "GM_Rows"
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, ROW_H)
    holder.Position = UDim2.new(0, 0, 0, 0)
    holder.ClipsDescendants = false
    holder.Parent = wrap

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, ROW_GAP)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = holder

    local allNames = scanItemNames()
    local filtered = allNames
    local rows = {}
    local built = 0

    local function setHeights()
        local h = built * (ROW_H + ROW_GAP)
        if h < ROW_H then h = ROW_H end
        holder.Size = UDim2.new(1, 0, 0, h)
        wrap.Size = UDim2.new(1, 0, 0, h)
        syncCanvas(cont)
    end

    local renderRow
    local pumpVisible
    local appendBatch

    local function createRow(moduleName, index)
        local row = tmpl:Clone()
        row.Name = "GM_Row_" .. tostring(index)
        row.LayoutOrder = index
        row.Size = UDim2.new(0.84, 0, 0, ROW_H)
        row:SetAttribute("GM_Row", true)
        row:SetAttribute("GM_Ui", true)
        row:SetAttribute("GM_Module", moduleName)
        row:SetAttribute("GM_Rendered", false)
        row:SetAttribute("itemType", nil)
        if row:FindFirstChild("NameLabel") then
            row.NameLabel.Text = moduleName
        end
        if row:FindFirstChild("CostLabel") then
            row.CostLabel.Text = ""
            row.CostLabel.Visible = false
        end
        if row:FindFirstChild("OutOfStock") then
            row.OutOfStock.Visible = false
        end
        if row:FindFirstChild("Buy") then
            if row.Buy:FindFirstChild("TextLabel") then
                row.Buy.TextLabel.Text = "获取"
            end
            row.Buy:SetAttribute("itemType", nil)
        end

        local function onGive()
            giveItem(moduleName)
        end

        local hooked = false
        local makeButton = load("makeButton")
        if makeButton and row:FindFirstChild("Buy") then
            hooked = pcall(function()
                local b = makeButton({
                    super = "mouseOverDetect",
                    UIObject = row.Buy,
                    baseSize = UDim2.fromOffset(80, 40),
                    scaleFactor = 0.95,
                    activatedFunc = onGive,
                })
                b:Init()
            end)
        end
        if not hooked and row:FindFirstChild("Buy") then
            local btn = row.Buy:FindFirstChild("Button")
            if btn then track(btn.Activated:Connect(onGive)) end
        end

        row.Parent = holder
        table.insert(rows, row)
        return row
    end

    function renderRow(row)
        if not row or not row.Parent then return end
        if row:GetAttribute("GM_Rendered") == true then return end
        local moduleName = row:GetAttribute("GM_Module")
        local ok = pcall(function()
            local data = resolveItemData(moduleName)
            if not data then return end
            if type(data.name) == "string" and data.name ~= "" and row:FindFirstChild("NameLabel") then
                row.NameLabel.Text = data.name
            end
            local cl = row:FindFirstChild("CostLabel")
            if cl then
                cl.Text = ""
                cl.Visible = false
            end
            local renderItem = load("renderItem")
            if not renderItem then return end
            local vp = row:FindFirstChild("ViewportFrame")
            if not vp then return end
            local vo = data.viewportOffsets and data.viewportOffsets.hotbar
            if not vo then return end
            local cam = Instance.new("Camera")
            cam.Parent = vp
            local model = renderItem(data.name):Clone()
            model.Parent = vp
            vp.CurrentCamera = cam
            cam.CFrame = model:GetPivot() * CFrame.new(0, 0, vo.dist)
            model:PivotTo(model:GetPivot() * vo.offset * vo.rotoffset)
        end)
        if ok then
            row:SetAttribute("GM_Rendered", true)
        end
    end

    function pumpVisible()
        local top = cont.AbsolutePosition.Y
        local bottom = top + cont.AbsoluteSize.Y
        for _, row in ipairs(rows) do
            if row.Parent then
                local rt = row.AbsolutePosition.Y
                local rb = rt + row.AbsoluteSize.Y
                if rb > top - 60 and rt < bottom + 60 then
                    renderRow(row)
                end
            end
        end
    end

    function appendBatch()
        if built >= #filtered then return false end
        local last = math.min(built + BATCH, #filtered)
        for i = built + 1, last do
            createRow(filtered[i], i)
        end
        built = last
        setHeights()
        task.defer(pumpVisible)
        return true
    end

    local function clearRows()
        for _, row in ipairs(rows) do
            pcall(function()
                row:Destroy()
            end)
        end
        rows = {}
        built = 0
    end

    local searchBox = nil

    local function applyFilter()
        local q = string.lower((searchBox and searchBox.Text) or "")
        clearRows()
        if q == "" then
            filtered = allNames
        else
            local out = {}
            for _, n in ipairs(allNames) do
                if string.find(string.lower(n), q, 1, true) then
                    table.insert(out, n)
                end
            end
            filtered = out
        end
        setHeights()
        appendBatch()
        pcall(function()
            cont.CanvasPosition = Vector2.new(0, 0)
        end)
    end

    local searchHolder = makeInputRow(cont, {
        name = SEARCH_NAME,
        order = 900,
        placeholder = actionLabel("搜索物品", "Search items"),
        value = "",
        label = function() return actionLabel("搜索", "Search") end,
        onSubmit = applyFilter,
        onText = applyFilter,
    })
    if searchHolder then
        searchBox = searchHolder.box
    end

    local scrollTick = 0
    track(cont:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local now = os.clock()
        if now - scrollTick < 0.12 then
            return
        end
        scrollTick = now
        task.defer(function()
            if not wrap.Parent then return end
            pumpVisible()
            local bottom = cont.AbsolutePosition.Y + cont.AbsoluteSize.Y
            local last = rows[#rows]
            if last and last.AbsolutePosition.Y < bottom + 200 then
                appendBatch()
            end
        end)
    end))

    appendBatch()
    task.delay(0.1, pumpVisible)

    wrap.Visible = wasVisible
    wrap.Parent = cont
    return wrap, searchHolder and searchHolder.row or nil
end

local function showGMPage(sa)
    local cont = sa and sa:FindFirstChild("SettingsContainer")
    if not cont then return end
    store.lastSA = sa
    clearStale(cont)
    local giver, searchWrap = buildGiver(cont)
    local joinRow = makeJoinRow(cont, 1090)
    local translateToggle = makeToggle(cont, TRANSLATE_NAME, "一键汉化", 995, "gm_translate", function()
        return Tr.Enabled
    end, setTranslate)
    local speedToggle = makeToggle(cont, SWITCH_NAME, function()
        return labelFor("Coffee Speed", "咖啡移速")
    end, 997, "gm_switch", function()
        return SpeedBoost.Enabled
    end, setSpeedBoost)
    local stompToggle = makeToggle(cont, STOMP_NAME, function()
        return labelFor("Stomp Always-On", "踩踏常亮")
    end, 998, "gm_stomp", function()
        return Stomp.Enabled
    end, setStomp)
    local skinToggle = makeToggle(cont, SKIN_NAME, function()
        return labelFor("Unlock All Skins", "解锁全皮肤")
    end, 999, "gm_skins", function()
        return Skins.Enabled
    end, setSkins)
    local headlessToggle = makeToggle(cont, HEADLESS_NAME, function()
        return labelFor("Headless & Legs", "无头断腿美化")
    end, 1000, "gm_headless", function()
        return Beauty.Enabled
    end, setBeauty)
    local antiAdminToggle = makeToggle(cont, ANTIADMIN_NAME, function()
        return labelFor("Anti Admin", "管理员自动离开")
    end, 1001, "gm_antiadmin", function()
        return AntiAdmin.Enabled
    end, setAntiAdmin)
    -- 辅助瞄准（UI 与开关行同款）
    local aimToggle = makeToggle(cont, AIM_NAME, function()
        return actionLabel("辅助瞄准", "Aim Assist")
    end, 1002, "gm_aim", function()
        return AimAssistConfig.Enabled
    end, function(v)
        local ok = applyAimState(v)
        if not ok and v then
            NotifyAimUnavailable()
        end
    end)
    local aimPartRow = makeChoiceRow(cont, {
        name = AIM_PART_NAME,
        order = 1003,
        text = "瞄准部位",
        options = { "头部", "身体" },
        get = function()
            return AimAssistConfig.Part == "Head" and "头部" or "身体"
        end,
        set = function(label)
            AimAssistConfig.Part = (label == "头部") and "Head" or "Body"
        end,
    })
    local aimFovUseRow = makeToggle(cont, AIM_FOVUSE_NAME, function()
        return "视野限制"
    end, 1004, "gm_aim_fovuse", function()
        return AimAssistConfig.UseFov
    end, function(v)
        AimAssistConfig.UseFov = v == true
    end)
    local aimFovRow = makeSliderRow(cont, {
        name = AIM_FOV_NAME,
        order = 1005,
        text = "视野范围",
        min = 1,
        max = 300,
        get = function() return AimAssistConfig.Fov end,
        set = function(v) AimAssistConfig.Fov = v end,
        fmt = function(v) return tostring(math.floor(v + 0.5)) end,
    })
    local aimSxRow = makeSliderRow(cont, {
        name = AIM_SX_NAME,
        order = 1006,
        text = "水平速度",
        min = 0.1,
        max = 5,
        get = function() return AimAssistConfig.SpeedX end,
        set = function(v) AimAssistConfig.SpeedX = v end,
        fmt = function(v) return string.format("%.1f", v) end,
    })
    local aimSyRow = makeSliderRow(cont, {
        name = AIM_SY_NAME,
        order = 1007,
        text = "垂直速度",
        min = 0.1,
        max = 5,
        get = function() return AimAssistConfig.SpeedY end,
        set = function(v) AimAssistConfig.SpeedY = v end,
        fmt = function(v) return string.format("%.1f", v) end,
    })
    local aimPxRow = makeSliderRow(cont, {
        name = AIM_PX_NAME,
        order = 1008,
        text = "水平预判",
        min = 0,
        max = 7,
        get = function() return AimAssistConfig.PredictionX end,
        set = function(v) AimAssistConfig.PredictionX = v end,
        fmt = function(v) return string.format("%.1f", v) end,
    })
    local aimPyRow = makeSliderRow(cont, {
        name = AIM_PY_NAME,
        order = 1009,
        text = "垂直预判",
        min = 0,
        max = 7,
        get = function() return AimAssistConfig.PredictionY end,
        set = function(v) AimAssistConfig.PredictionY = v end,
        fmt = function(v) return string.format("%.1f", v) end,
    })
    local aimRangeRow = makeSliderRow(cont, {
        name = AIM_RANGE_NAME,
        order = 1010,
        text = "范围",
        min = 50,
        max = 2000,
        get = function() return AimAssistConfig.Range end,
        set = function(v) AimAssistConfig.Range = v end,
        fmt = function(v) return tostring(math.floor(v + 0.5)) end,
    })

    local keep = {}
    local function keepOn(o)
        if o then keep[o] = true end
    end
    keepOn(searchWrap)
    keepOn(joinRow)
    keepOn(speedToggle)
    keepOn(stompToggle)
    keepOn(skinToggle)
    keepOn(headlessToggle)
    keepOn(antiAdminToggle)
    keepOn(translateToggle)
    keepOn(giver)
    keepOn(aimToggle)
    keepOn(aimPartRow)
    keepOn(aimFovUseRow)
    keepOn(aimFovRow)
    keepOn(aimSxRow)
    keepOn(aimSyRow)
    keepOn(aimPxRow)
    keepOn(aimPyRow)
    keepOn(aimRangeRow)
    for _, c in ipairs(cont:GetChildren()) do
        if c:IsA("GuiObject") then
            c.Visible = keep[c] == true
        end
    end
    syncCanvas(cont)
    cont.CanvasPosition = Vector2.new(0, 0)
end

Relabel = function()
    local sa = store.lastSA
    if not sa or not sa.Parent then return end
    local cont = sa:FindFirstChild("SettingsContainer")
    if not cont then return end
    local map = {
        [SWITCH_NAME] = labelFor("Coffee Speed", "咖啡移速"),
        [STOMP_NAME] = labelFor("Stomp Always-On", "踩踏常亮"),
        [SKIN_NAME] = labelFor("Unlock All Skins", "解锁全皮肤"),
        [HEADLESS_NAME] = labelFor("Headless & Legs", "无头断腿美化"),
        [ANTIADMIN_NAME] = labelFor("Anti Admin", "管理员自动离开"),
        [TRANSLATE_NAME] = "一键汉化",
    }
    for name, text in pairs(map) do
        local item = cont:FindFirstChild(name)
        local lbl = item and item:FindFirstChild("NameLabel")
        if lbl then
            lbl.Text = text
        end
    end
    local sb = cont:FindFirstChild(SEARCH_NAME)
    local sbBox = sb and sb:FindFirstChild("GM_InputBox")
    if sbBox then
        sbBox.PlaceholderText = actionLabel("搜索物品", "Search items")
    end
    for name, paint in pairs(rowPaints) do
        if cont:FindFirstChild(name) then pcall(paint) end
    end
end

local function hideGMPage(sa)
    local cont = sa and sa:FindFirstChild("SettingsContainer")
    if not cont then return end
    for _, n in ipairs({ SEARCH_NAME, JOIN_NAME, HEADLESS_NAME, AIM_NAME, AIM_PART_NAME, AIM_FOVUSE_NAME, AIM_FOV_NAME, AIM_SX_NAME, AIM_SY_NAME, AIM_PX_NAME, AIM_PY_NAME, AIM_RANGE_NAME, SWITCH_NAME, STOMP_NAME, SKIN_NAME, ANTIADMIN_NAME, TRANSLATE_NAME, GIVER_NAME }) do
        local item = cont:FindFirstChild(n)
        if item then item.Visible = false end
    end
end

local function hookLive(sa)
    local sorts = sa and sa:FindFirstChild("Sorts")
    local gm = sorts and sorts:FindFirstChild(TAB_NAME)
    if not gm then return end

    local cont = sa.SettingsContainer
    if #cont:GetChildren() <= 1 then
        local conn
        conn = cont.ChildAdded:Connect(function()
            if #cont:GetChildren() > 1 then
                conn:Disconnect()
                hookLive(sa)
            end
        end)
        track(conn)
        return
    end
    gm:SetAttribute("GM_Hooked", true)

    track(gm.Button.Activated:Connect(function()
        task.defer(function()
            for _, t in ipairs(sorts:GetChildren()) do
                if t:IsA("GuiObject") then
                    local sel = t.Name == TAB_NAME
                    t.BackgroundTransparency = sel and 0.85 or 1
                    t.TextLabel.TextColor3 = sel and Color3.fromRGB(168, 168, 168) or Color3.fromRGB(175, 175, 175)
                end
            end
            sa.Stats.Visible = false
            sa.SettingsContainer.Visible = true
            showGMPage(sa)
        end)
    end))

    for _, t in ipairs(sorts:GetChildren()) do
        if t:IsA("GuiObject") and t.Name ~= TAB_NAME then
            local btn = t:FindFirstChild("Button")
            if btn then
                track(btn.Activated:Connect(function()
                    task.defer(function()
                        hideGMPage(sa)
                    end)
                end))
            end
        end
    end
end

local tplSettings = RS:FindFirstChild("Guis")
    and RS.Guis:FindFirstChild("ScreenGuis")
    and RS.Guis.ScreenGuis:FindFirstChild("Phone")
    and RS.Guis.ScreenGuis.Phone.Holder.ScreenContainer:FindFirstChild("SettingsApp")
patchSorts(tplSettings and tplSettings:FindFirstChild("Sorts"))

local function patchLive(sa)
    if not sa then return end
    patchSorts(sa:FindFirstChild("Sorts"))
    hookLive(sa)
end

local livePhone = pg and pg:FindFirstChild("Phone")
if livePhone then
    patchLive(livePhone.Holder.ScreenContainer:FindFirstChild("SettingsApp"))
end

if store.descConn then pcall(function() store.descConn:Disconnect() end) end
store.descConn = pg.DescendantAdded:Connect(function(d)
    if d.Name == "SettingsApp" then
        task.defer(function()
            if d.Parent then patchLive(d) end
        end)
    end
end)
track(store.descConn)

return true