-- =========================================================================
-- 🧱 PUT & BREAK (PnB) & AUTO CLAIM SCRIPT (PRO V7.1 - CLEAN & PURE ENGINE)
-- Game: Growblox (Place ID: 112863874972771)
-- Fitur: Auto Put & Break (1-Tile & 2-Far), 100% Native Drop Collection (Zero-Teleport / Zero-Jitter),
--        Auto Drop Seed Presisi Floating Item, Auto Restock Balok & Return to Stand Pos,
--        Filter Suara Alami (Bungkam Suara Besi/Bedrock & Play Suara Put Balok), Anti-Staff Guard
-- =========================================================================

local set_id = (setthreadidentity or setidentity or function(_) end) 
local function elevate()
    pcall(set_id, 8)
end
elevate()

local genv = getgenv() 
if genv.PnB_Cleanup then
    pcall(genv.PnB_Cleanup)
elseif shared.PnB_Cleanup then
    pcall(shared.PnB_Cleanup)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local function sendKeySafe(key, isDown)
    elevate()
    pcall(function()
        VirtualInputManager:SendKeyEvent(isDown, key, false, game)
    end)
end
local lp = Players.LocalPlayer or Players:GetPlayers()[1]

local r = require 
local getconns = (getconnections or get_connections or function(...) return {} end) 

-- =========================================================================
-- 🛡️ BULLETPROOF ANTI-AFK & AUTO-RECONNECT ENGINE (100% UNBEATABLE)
-- =========================================================================
-- 1. Nonaktifkan SEMUA koneksi internal Roblox pada signal Idled (Mencegah Error 268/288 20 menit)
local function disableRobloxIdledConnections()
    pcall(function()
        local player = lp or Players.LocalPlayer or Players:GetPlayers()[1]
        if player and player.Idled then
            for _, conn in ipairs(getconns(player.Idled)) do
                if conn.Disable then
                    conn:Disable()
                elseif conn.Disconnect then
                    conn:Disconnect()
                end
            end
        end
    end)
end
disableRobloxIdledConnections()

-- Tangani jika engine Roblox mencoba menambahkan listener Idled baru
pcall(function()
    local player = lp or Players.LocalPlayer or Players:GetPlayers()[1]
    if player and player.Idled then
        player.Idled:Connect(function()
            elevate()
            disableRobloxIdledConnections()
            pcall(function()
                VirtualUser:CaptureController()
                local cam = workspace.CurrentCamera
                local cf = cam and cam.CFrame or CFrame.new()
                VirtualUser:Button2Down(Vector2.new(0, 0), cf)
                task.wait(0.04)
                VirtualUser:Button2Up(Vector2.new(0, 0), cf)
            end)
        end)
    end
end)

-- 2. Heartbeat Anti-AFK Aktif: Simulasi hardware input asli setiap 20 detik (Reset internal Roblox timer)
if not genv.PnB_AntiAFK_Active then
    genv.PnB_AntiAFK_Active = true
    task.spawn(function()
        while true do
            task.wait(20)
            elevate()
            disableRobloxIdledConnections()
            pcall(function()
                VirtualUser:CaptureController()
                local cam = workspace.CurrentCamera
                local cf = cam and cam.CFrame or CFrame.new()
                VirtualUser:Button2Down(Vector2.new(0, 0), cf)
                task.wait(0.04)
                VirtualUser:Button2Up(Vector2.new(0, 0), cf)
            end)
        end
    end)
end

-- 3. Auto-Reconnect saat Roblox Error Dialog muncul: DINONAKTIFKAN (Disabled)
local function setupAutoReconnectPrompt()
    -- Dinonaktifkan sesuai permintaan user agar tidak mengganggu reconnect manual
end
pcall(setupAutoReconnectPrompt)

-- 4. Micro-Movement Server Keep-Alive (Mencegah kick inactivity dari server world Growblox)
if not genv.PnB_WorldKeepAlive then
    genv.PnB_WorldKeepAlive = true
    task.spawn(function()
        while true do
            task.wait(35)
            elevate()
            -- Lakukan micro-twitch saat bot idle di world (tidak sedang autoPnB, tidak sedang relokasi drop seed atau rejoining)
            local curState = genv.PnB_State
            if curState and not curState.autoPnB and not curState.isRelocating and not curState.isRejoining then
                pcall(function()
                    sendKeySafe(Enum.KeyCode.D, true)
                    task.wait(0.02)
                    sendKeySafe(Enum.KeyCode.D, false)
                    task.wait(0.01)
                    sendKeySafe(Enum.KeyCode.A, true)
                    task.wait(0.02)
                    sendKeySafe(Enum.KeyCode.A, false)
                end)
            end
        end
    end)
end

local WorldRemotes = ReplicatedStorage:FindFirstChild("WorldRemotes") 

local function findWorldFromAnySource()
    if getgc then
        local ok, gcList = pcall(getgc, true)
        if ok and type(gcList) == "table" then
            for _, v in ipairs(gcList) do
                if type(v) == "table" and rawget(v, "fg") and rawget(v, "bg") and rawget(v, "goTo") and rawget(v, "touchBlocks") then
                    return v
                end
            end
        end
    end
    if getconnections and RunService then
        local ok, rConns = pcall(getconnections, RunService.RenderStepped)
        if ok and rConns then
            for _, c in ipairs(rConns) do
                local fn = c.Function
                if fn and typeof(fn) == "function" then
                    for i = 1, debug.getinfo(fn).nups do
                        local up = debug.getupvalue(fn, i)
                        if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") and rawget(up, "goTo") then
                            return up
                        elseif typeof(up) == "function" then
                            for j = 1, debug.getinfo(up).nups do
                                local inUp = debug.getupvalue(up, j)
                                if type(inUp) == "table" and rawget(inUp, "fg") and rawget(inUp, "bg") and rawget(inUp, "goTo") then
                                    return inUp
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if WorldRemotes and getconnections then
        for _, child in ipairs(WorldRemotes:GetChildren()) do
            if child:IsA("RemoteEvent") then
                local ok, conns = pcall(getconnections, child.OnClientEvent)
                if ok and conns and #conns > 0 then
                    for _, c in ipairs(conns) do
                        local fn = c.Function
                        if fn then
                            for i = 1, debug.getinfo(fn).nups do
                                local up = debug.getupvalue(fn, i)
                                if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") and rawget(up, "goTo") then
                                    return up
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local World = findWorldFromAnySource()
if not World then
    print("[PnB] Menunggu pemain masuk ke World...")
end

-- 🛡️ Bypass 0.30s Placement Debounce:
-- Cegah setTile / tileChanged dari mengunci pukulan balok yang baru ditaruh
if World then
    local dummyFg = setmetatable({}, {__index = function() return 0 end, __newindex = function() end})
    local dummyBg = setmetatable({}, {__index = function() return 0 end, __newindex = function() end})
    World.placedAt = {fg = dummyFg, bg = dummyBg}
end

local invUI = nil
local okInv, invModule = pcall(function()
    local pg = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
    local gg = pg and (pg:FindFirstChild("GameGui") or pg:WaitForChild("GameGui", 5))
    return gg and (gg:FindFirstChild("InventoryUI") or gg:WaitForChild("InventoryUI", 5))
end)
if okInv and invModule then
    pcall(function() invUI = r(invModule) end)
end

local backpack = nil
local function refreshBackpackReference()
    elevate()
    -- Source 1: plantSeed in getgc(false) (Direct live backpack in GrowBlox v1210)
    if getgc then
        local okF, fns = pcall(getgc, false)
        if okF and type(fns) == "table" then
            for _, fn in ipairs(fns) do
                if type(fn) == "function" and debug.getinfo(fn).name == "plantSeed" then
                    for i = 1, debug.getinfo(fn).nups do
                        local u = debug.getupvalue(fn, i)
                        if type(u) == "table" and type(rawget(u, "slots")) == "table" and type(rawget(u, "capacity")) == "number" then
                            backpack = u
                            return backpack
                        end
                    end
                end
            end
        end
    end

    -- Source 2: hitFn upvalues (live game engine memory)
    if hitFn then
        for _, up in pairs(debug.getupvalues(hitFn)) do
            if type(up) == "table" and type(rawget(up, "slots")) == "table" and type(rawget(up, "capacity")) == "number" then
                backpack = up
                return backpack
            end
        end
    end

    -- Source 3: Deteksi akurat via getgc(true) (field: slots, capacity, selected)
    if getgc then
        local ok, list = pcall(getgc, true)
        if ok and type(list) == "table" then
            for _, v in ipairs(list) do
                if type(v) == "table" and type(rawget(v, "slots")) == "table" and type(rawget(v, "capacity")) == "number" and (rawget(v, "selected") ~= nil or v.select ~= nil) then
                    backpack = v
                    return backpack
                end
            end
        end
    end

    -- Source 4: Cached backpack
    if backpack and type(backpack.slots) == "table" then
        return backpack
    end

    return backpack
end
refreshBackpackReference()

-- 🛡️ UNIVERSAL MODULE RESOLVER (100% Kebal Obfuscasi & Unparenting Shared)
local ItemDB = nil
local ItemIcon = nil
local Sfx = nil
local Roles = nil
local AreaLock = nil
local Net = nil

local function ensureItemDB()
    if ItemDB and rawget(ItemDB, 2) then return ItemDB end

    -- Source 1: getgc(false) closure search (turning, set, pop - ultra fast < 3ms)
    if getgc then
        local okF, fns = pcall(getgc, false)
        if okF and type(fns) == "table" then
            for _, fn in ipairs(fns) do
                if typeof(fn) == "function" and (islclosure == nil or islclosure(fn)) then
                    local n = debug.getinfo(fn).name
                    if n == "turning" or n == "set" or n == "pop" then
                        for i = 1, debug.getinfo(fn).nups do
                            local u = debug.getupvalue(fn, i)
                            if type(u) == "table" and rawget(u, 2) and type(rawget(u, 2)) == "table" and rawget(rawget(u, 2), "name") == "Dirt" then
                                ItemDB = u
                                return ItemDB
                            end
                        end
                    end
                end
            end
            for _, fn in ipairs(fns) do
                if typeof(fn) == "function" and (islclosure == nil or islclosure(fn)) then
                    for i = 1, debug.getinfo(fn).nups do
                        local u = debug.getupvalue(fn, i)
                        if type(u) == "table" and rawget(u, 2) and type(rawget(u, 2)) == "table" and rawget(rawget(u, 2), "name") == "Dirt" then
                            ItemDB = u
                            return ItemDB
                        end
                    end
                end
            end
        end
    end

    -- Source 2: SharedFolder
    local SharedFolder = ReplicatedStorage:FindFirstChild("Shared")
    if SharedFolder and SharedFolder:FindFirstChild("ItemDB") then
        pcall(function() ItemDB = r(SharedFolder.ItemDB) end)
        if ItemDB and rawget(ItemDB, 2) then return ItemDB end
    end
    -- Source 2: InventoryUI.mount upvalue 15
    if not invUI then
        local pg = lp:FindFirstChild("PlayerGui")
        local gg = pg and pg:FindFirstChild("GameGui")
        local im = gg and gg:FindFirstChild("InventoryUI")
        if im then pcall(function() invUI = r(im) end) end
    end
    if invUI and invUI.mount then
        pcall(function()
            local u15 = debug.getupvalue(invUI.mount, 15)
            if type(u15) == "table" and rawget(u15, 2) and rawget(rawget(u15, 2), "name") == "Dirt" then
                ItemDB = u15
            end
        end)
        if ItemDB and rawget(ItemDB, 2) then return ItemDB end
    end
    -- Source 3: hitFn upvalues (live game engine)
    if hitFn then
        for _, up in ipairs(debug.getupvalues(hitFn)) do
            if type(up) == "table" and rawget(up, 2) and type(rawget(up, 2)) == "table" and rawget(rawget(up, 2), "name") == "Dirt" then
                ItemDB = up
                return ItemDB
            end
        end
    end
    -- Source 4: shared[Qz]
    local qz = ReplicatedStorage:GetAttribute("Qz")
    if qz and shared[qz] then
        local sTable = shared[qz]
        pcall(function()
            local mod = sTable.ItemDB or (sTable.FindFirstChild and sTable:FindFirstChild("ItemDB")) or sTable.RnyflzPbj74 or sTable.wqntdn4Z81w
            if mod then ItemDB = r(mod) end
        end)
        if ItemDB and rawget(ItemDB, 2) then return ItemDB end
    end
    -- Source 5: getgc(true) dengan rawget (100% Kebal Metamethod / Signal Error)
    if getgc then
        local ok, gcList = pcall(getgc, true)
        if ok and type(gcList) == "table" then
            for _, v in ipairs(gcList) do
                if type(v) == "table" then
                    local d = rawget(v, 2)
                    if type(d) == "table" and rawget(d, "name") == "Dirt" then
                        local l = rawget(v, 4)
                        if type(l) == "table" and rawget(l, "name") == "Lava" then
                            ItemDB = v
                            return ItemDB
                        end
                    end
                end
            end
        end
    end
    return ItemDB
end

local function ensureItemIcon()
    if ItemIcon and type(ItemIcon.new) == "function" then return ItemIcon end

    -- Source 1: plantSeed in getgc(false) (Direct & Instant in GrowBlox v1210)
    if getgc then
        local okF, fns = pcall(getgc, false)
        if okF and type(fns) == "table" then
            for _, fn in ipairs(fns) do
                if type(fn) == "function" and debug.getinfo(fn).name == "plantSeed" then
                    for i = 1, debug.getinfo(fn).nups do
                        local u = debug.getupvalue(fn, i)
                        if type(u) == "table" and type(rawget(u, "new")) == "function" and type(rawget(u, "set")) == "function" then
                            ItemIcon = u
                            return ItemIcon
                        end
                    end
                end
            end
            -- Fallback across all functions in getgc(false)
            for _, fn in ipairs(fns) do
                if type(fn) == "function" then
                    local nups = debug.getinfo(fn).nups or 0
                    if nups >= 3 then
                        for i = 1, nups do
                            local u = debug.getupvalue(fn, i)
                            if type(u) == "table" and type(rawget(u, "new")) == "function" and type(rawget(u, "set")) == "function" and (rawget(u, "mascot") ~= nil or rawget(u, "setImage") ~= nil) then
                                ItemIcon = u
                                return ItemIcon
                            end
                        end
                    end
                end
            end
        end
    end

    -- Source 2: SharedFolder
    local SharedFolder = ReplicatedStorage:FindFirstChild("Shared") or ReplicatedStorage:WaitForChild("Shared", 2)
    if SharedFolder and SharedFolder:FindFirstChild("ItemIcon") then
        pcall(function() ItemIcon = r(SharedFolder.ItemIcon) end)
        if ItemIcon and type(ItemIcon.new) == "function" then return ItemIcon end
    end
    -- Source 3: InventoryUI.mount upvalue 17
    if not invUI then
        local pg = lp:FindFirstChild("PlayerGui")
        local gg = pg and pg:FindFirstChild("GameGui")
        local im = gg and gg:FindFirstChild("InventoryUI")
        if im then pcall(function() invUI = r(im) end) end
    end
    if invUI and invUI.mount then
        pcall(function()
            local u17 = debug.getupvalue(invUI.mount, 17)
            if type(u17) == "table" and type(rawget(u17, "new")) == "function" and type(rawget(u17, "set")) == "function" then
                ItemIcon = u17
            end
        end)
        if ItemIcon and type(ItemIcon.new) == "function" then return ItemIcon end
    end
    -- Source 4: shared[Qz]
    local qz = ReplicatedStorage:GetAttribute("Qz")
    if qz and shared[qz] then
        local sTable = shared[qz]
        pcall(function()
            local mod = sTable.ItemIcon or (sTable.FindFirstChild and sTable:FindFirstChild("ItemIcon")) or sTable.XvvW1zTmyjk
            if mod then ItemIcon = r(mod) end
        end)
        if ItemIcon and type(ItemIcon.new) == "function" then return ItemIcon end
    end
    -- Source 5: getgc(true)
    if not ItemIcon and getgc then
        local ok, gcList = pcall(getgc, true)
        if ok and type(gcList) == "table" then
            for _, v in ipairs(gcList) do
                if type(v) == "table" and type(rawget(v, "new")) == "function" and type(rawget(v, "set")) == "function" then
                    ItemIcon = v
                    break
                end
            end
        end
    end
    return ItemIcon
end

local function ensureNet()
    if Net and rawget(Net, "drop") then return Net end
    if getgc then
        local ok, gcList = pcall(getgc, true)
        if ok and type(gcList) == "table" then
            for _, v in ipairs(gcList) do
                if type(v) == "table" and rawget(v, "treeChanged") and rawget(v, "tileChanged") and rawget(v, "drop") then
                    Net = v
                    return Net
                end
            end
        end
    end
    local SharedFolder = ReplicatedStorage:FindFirstChild("Shared")
    if SharedFolder and SharedFolder:FindFirstChild("Net") then
        pcall(function() Net = r(SharedFolder.Net) end)
        if Net then return Net end
    end
    return Net
end

-- Inisialisasi awal
ensureItemDB()
ensureItemIcon()
ensureNet()

-- Resolusi Sfx, Net, Roles, AreaLock via plantSeed (Direct & Instant)
if getgc then
    local okF, fns = pcall(getgc, false)
    if okF and type(fns) == "table" then
        for _, fn in ipairs(fns) do
            if type(fn) == "function" and debug.getinfo(fn).name == "plantSeed" then
                for i = 1, debug.getinfo(fn).nups do
                    local u = debug.getupvalue(fn, i)
                    if type(u) == "table" then
                        if not Sfx and (rawget(u, "playAt") or rawget(u, "play")) and (rawget(u, "IDS") or rawget(u, "ITEM")) then
                            Sfx = u
                        end
                    end
                end
                break
            end
        end
    end
end

if getgc then
    local ok, gcList = pcall(getgc, true)
    if ok and type(gcList) == "table" then
        for _, v in ipairs(gcList) do
            if type(v) == "table" then
                if not Net and rawget(v, "treeChanged") and rawget(v, "tileChanged") and rawget(v, "tile") then
                    Net = v
                end
                if not Roles and rawget(v, "isModerator") and rawget(v, "isDeveloper") and rawget(v, "isStaff") then
                    Roles = v
                end
                if not AreaLock and rawget(v, "hasAccess") and rawget(v, "canBreak") then
                    AreaLock = v
                end
                if not Sfx and rawget(v, "play") and rawget(v, "playAt") then
                    Sfx = v
                end
            end
        end
    end
end

local qz = ReplicatedStorage:GetAttribute("Qz")
if qz and shared[qz] then
    local sTable = shared[qz]
    if not Net then
        pcall(function()
            local mod = sTable.Net or sTable.j1PKXTgzz or sTable.FdScbWqyz
            if mod then Net = r(mod) end
        end)
    end
    if not Roles then
        pcall(function()
            local mod = sTable.Roles or sTable.rbmTYTEGG
            if mod then Roles = r(mod) end
        end)
    end
    if not AreaLock then
        pcall(function()
            local mod = sTable.AreaLock
            if mod then AreaLock = r(mod) end
        end)
    end
    if not Sfx then
        pcall(function()
            local mod = sTable.Sfx
            if mod then Sfx = r(mod) end
        end)
    end
end

local SharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if SharedFolder then
    if not Sfx and SharedFolder:FindFirstChild("Sfx") then pcall(function() Sfx = r(SharedFolder.Sfx) end) end
    if not Roles and SharedFolder:FindFirstChild("Roles") then pcall(function() Roles = r(SharedFolder.Roles) end) end
    if not AreaLock and SharedFolder:FindFirstChild("AreaLock") then pcall(function() AreaLock = r(SharedFolder.AreaLock) end) end
    if not Net and SharedFolder:FindFirstChild("Net") then pcall(function() Net = r(SharedFolder.Net) end) end
end

-- 🔇 Filter Suara Mengganggu (Bungkam suara pukulan besi / bedrock: cant_place_tile, punch_locked, weird_hit, metal_hit, metal_destroy)
local SoundService = game:GetService("SoundService")
local origSfxPlay = Sfx and Sfx.play
local origSfxPlayAt = Sfx and Sfx.playAt

local mutedSfx = {
    cant_place_tile = true,
    punch_locked = true,
    weird_hit = true,
    metal_hit = true,
    metal_destroy = true,
}

if Sfx and Sfx.play then
    Sfx.play = function(id, ...)
        if mutedSfx[id] then
            return -- Bungkam suara pukulan besi/bedrock yang annoying
        end
        return origSfxPlay(id, ...)
    end
end
if Sfx and Sfx.playAt then
    Sfx.playAt = function(x, y, id, ...)
        if mutedSfx[id] then
            return
        end
        return origSfxPlayAt(x, y, id, ...)
    end
end

for sName in pairs(mutedSfx) do
    local snd = SoundService:FindFirstChild(sName)
    if snd and snd:IsA("Sound") then
        snd.Volume = 0
    end
end

pcall(function()
    SoundService.DescendantAdded:Connect(function(child)
        if child:IsA("Sound") and mutedSfx[child.Name] then
            child.Volume = 0
        end
    end)
end)

-- 🛡️ Zero Packet Teleport / Pure Stealth: sendServerPos dinonaktifkan total agar posisi karakter 100% natural
local function sendServerPos(nx, ny)
    -- Disabled demi keamanan (Anti-Teleport / Anti-Flicker)
end

-- 🛡️ Permission, Lock, & Staff Boundary Helpers (Anti-Kick & Anti-Grief)
-- Mendukung World Owner, Public World, serta Admin / Member dengan akses lock
local function canBuildAt(tx, ty)
    if not World then return false end
    if tx < 0 or tx >= (World.w or 100) or ty < 0 or ty >= (World.h or 60) then
        return false
    end

    -- 1. Game engine punchLocked check per-tile (mendeteksi small lock / area lock pada koordinat spesifik)
    if World.punchLocked then
        local ok, isLocked = pcall(World.punchLocked, tx, ty)
        if ok and isLocked then
            return false
        end
    end

    -- 2. AreaLock / World Lock permission check
    if World.lock then
        -- Cek via module resmi AreaLock (otomatis menangani owner, public, dan admin access list)
        if AreaLock and AreaLock.hasAccess then
            local ok, hasAcc = pcall(AreaLock.hasAccess, World.lock, lp.UserId)
            if ok and hasAcc ~= nil then
                if not hasAcc and not World.lock.open then
                    return false
                end
                return true
            end
        end

        -- Fallback pemeriksaan manual: menangani format array tuple {{userId, name}} maupun integer {userId}
        if World.lock.owner and World.lock.owner ~= lp.UserId then
            local hasAccess = false
            if World.lock.access and type(World.lock.access) == "table" then
                for _, entry in ipairs(World.lock.access) do
                    if type(entry) == "table" and entry[1] == lp.UserId then
                        hasAccess = true
                        break
                    elseif entry == lp.UserId then
                        hasAccess = true
                        break
                    end
                end
            end
            if not hasAccess and not World.lock.open then
                return false
            end
        end
    end

    return true
end

local function canPunchAt(tx, ty)
    return canBuildAt(tx, ty)
end

local function isStaffMember(p)
    if not p then return false end
    local uid = p.UserId
    if not uid then return false end

    -- 1. Deteksi Group Rank resmi Growblox Developer Group (ID 5796263, rank >= 200)
    local okRank, rankVal = pcall(function() return p:GetRankInGroup(5796263) end)
    if okRank and rankVal and rankVal >= 200 then return true end

    -- 2. Deteksi lewat Attribute langsung pada instance Player (Tag, Rank, StillTag, IsMod)
    local tag = p:GetAttribute("Tag")
    if tag ~= nil and tostring(tag) ~= "" then return true end
    local rank = p:GetAttribute("Rank")
    if rank ~= nil and tostring(rank) ~= "" then return true end
    if p:GetAttribute("StillTag") == true or p:GetAttribute("IsMod") == true then return true end

    -- 3. Deteksi Nama Akun (Pola Moderator / Admin / Staff)
    local pName = string.lower(p.Name or "")
    if string.find(pName, "mod_") or string.find(pName, "admin_") or string.find(pName, "growblox_") or string.find(pName, "staff_") then
        return true
    end

    -- 4. Deteksi lewat modul Roles resmi menggunakan UserId
    if Roles then
        local ok1, isStaff = pcall(Roles.isStaff, uid)
        if ok1 and isStaff then return true end
        local ok2, isMod = pcall(Roles.isModerator, uid)
        if ok2 and isMod then return true end
        local ok3, isDev = pcall(Roles.isDeveloper, uid)
        if ok3 and isDev then return true end
        if Roles.showsStaff then
            local ok4, sStaff = pcall(Roles.showsStaff, uid)
            if ok4 and sStaff then return true end
        end
    end
    return false
end

local function checkAnyStaffPresent()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isStaffMember(p) then
            return true, p.Name
        end
    end
    return false, nil
end

-- ⚡ Ekstraksi fungsi engine langsung secara dinamis (Anti-Shift / Self-Healing)
local hitFn 
local setTileFn 
local updateDropsFn 
local dropsTable 
local TileSize = 64
local Frame 
local gemAnims 
local flyToBackpack 
local gm 
local setDropCount 

-- 💎 Ekstraksi dropsTable resmi langsung dari World.dropList (100% akurat & anti-shift)
if World and World.dropList then
    pcall(function()
        dropsTable = debug.getupvalue(World.dropList, 1)
    end)
end

-- Method A: getgc(false) direct search for hit / setTile
if getgc then
    local ok, funcs = pcall(getgc, false)
    if ok and type(funcs) == "table" then
        for _, fn in ipairs(funcs) do
            if typeof(fn) == "function" then
                local fnName = debug.getinfo(fn).name
                if fnName == "hit" and not hitFn then
                    for _, up in ipairs(debug.getupvalues(fn)) do
                        if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") then
                            hitFn = fn
                            if not World then World = up end
                            break
                        end
                    end
                elseif fnName == "setTile" and not setTileFn then
                    for _, up in ipairs(debug.getupvalues(fn)) do
                        if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") then
                            setTileFn = fn
                            break
                        end
                    end
                end
            end
        end
    end
end

-- Method B: Scan RenderStepped connections (100% kebal nama modul)
local renderConns = {}
if getconns then
    local ok, res = pcall(getconns, RunService.RenderStepped)
    if ok and type(res) == "table" then
        renderConns = res
    end
end
local gameStepFn 
for _, c in ipairs(renderConns) do
    local f = c.Function
    if f and typeof(f) == "function" then
        local nups = debug.getinfo(f).nups
        local isMain = false
        for i = 1, nups do
            local up = debug.getupvalue(f, i)
            if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") then
                isMain = true
                if not World then World = up end
                break
            end
        end
        if isMain then
            gameStepFn = f
            break
        end
    end
end

if gameStepFn then
    local nups = debug.getinfo(gameStepFn).nups
    for i = 1, nups do
        local up = debug.getupvalue(gameStepFn, i)
        local t = typeof(up)
        if t == "function" then
            local uinfo = debug.getinfo(up)
            -- Deteksi updateDropsFn (fungsi internal pengelola render drop yang memegang dropsTable sebagai upvalue 1)
            if dropsTable and uinfo.nups >= 10 then
                pcall(function()
                    if debug.getupvalue(up, 1) == dropsTable then
                        updateDropsFn = up
                    end
                end)
            end
            for j = 1, uinfo.nups do
                local inUp = debug.getupvalue(up, j)
                local inT = typeof(inUp)
                if inT == "function" then
                    local name = debug.getinfo(inUp).name
                    if name == "hit" and not hitFn then hitFn = inUp
                    elseif name == "setTile" and not setTileFn then setTileFn = inUp
                    elseif name == "flyToBackpack" and not flyToBackpack then flyToBackpack = inUp
                    elseif name == "setDropCount" and not setDropCount then setDropCount = inUp end
                elseif inT == "table" then
                    if inUp.bubble or inUp.console then
                        gm = inUp
                    end
                end
            end
        elseif t == "table" and (up.bubble or up.console) then
            gm = up
        elseif t == "number" and (up == 64 or up == 32) then
            TileSize = up
        elseif t == "Instance" and (up.Name == "Camera" or up.Name == "World") then
            Frame = up
        end
    end
end

-- Ekstraksi referensi visual dari updateDropsFn jika ditemukan
if updateDropsFn then
    pcall(function()
        if not flyToBackpack then flyToBackpack = debug.getupvalue(updateDropsFn, 14) end
        if not setDropCount then setDropCount = debug.getupvalue(updateDropsFn, 16) end
        if not Frame then Frame = debug.getupvalue(updateDropsFn, 12) or debug.getupvalue(updateDropsFn, 18) end
        if not gemAnims then gemAnims = debug.getupvalue(updateDropsFn, 13) end
    end)
end

-- Fallback jika dropsTable belum didapatkan
if not dropsTable and World and World.drops then
    dropsTable = World.drops
end

-- Menunggu world & engine siap (dukungan mobile executor Delta / loading map)
if not hitFn or not setTileFn then
    local waitAttempts = 0
    while waitAttempts < 12 and (not hitFn or not setTileFn) do
        task.wait(0.5)
        waitAttempts = waitAttempts + 1
        if not World then World = findWorldFromAnySource() end
        if getgc then
            local ok, funcs = pcall(getgc, false)
            if ok and type(funcs) == "table" then
                for _, fn in ipairs(funcs) do
                    if typeof(fn) == "function" then
                        local fnName = debug.getinfo(fn).name
                        if fnName == "hit" and not hitFn then
                            for _, up in ipairs(debug.getupvalues(fn)) do
                                if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") then
                                    hitFn = fn
                                    if not World then World = up end
                                    break
                                end
                            end
                        elseif fnName == "setTile" and not setTileFn then
                            for _, up in ipairs(debug.getupvalues(fn)) do
                                if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") then
                                    setTileFn = fn
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

if not hitFn then
    warn("[PnB] Fungsi hit internal belum terdeteksi. Pastikan Anda sudah spawn di dalam World!")
end
if not setTileFn then
    warn("[PnB] Fungsi setTile internal belum terdeteksi. Pastikan Anda sudah spawn di dalam World!")
end

local state = {
    selectedBlockId = nil ,
    selectedBlockName = nil ,
    autoPnB = false,
    autoClaim = false,
    direction = "Kanan",
    mode = "Custom (1-Blok)",
    customTiles = {
        ["1,0"] = true,
        ["1,-1"] = true
    } ,
    offsetY = 0,
    placeDelay = 0.16,
    punchDelay = 0.14, -- Kecepatan pukul default: responsif & aman (140ms)
    maxCollectRange = 2.85, -- Radius Luas & Presisi (Menjangkau seluruh gems di kiri, kanan, & atas)
    seedDropPos = nil ,
    targetSeedId = nil ,
    seedDropThreshold = 195,
    nextDropAttempt = 0,
    standPos = nil ,
    stockPos = nil ,
    isRelocating = false,
    isRejoining = false,
    pnbThread = nil ,
    claimThread = nil ,
    rejoinThread = nil ,
    savedWorldName = nil ,
    autoRejoinWorld = true ,
    wasRunningBeforeDisconnect = false ,
    resumePnBOnRejoin = true ,
    walkTo = nil ,
    startWorker = nil ,
    connections = {} 
}

-- Integrasi kompatibilitas global dengan setup script teman (AutoBreakCustom)
genv.AutoBreakCustom = genv.AutoBreakCustom or {}
if genv.AutoBreakCustom.SeedDropPos then state.seedDropPos = genv.AutoBreakCustom.SeedDropPos end
if genv.AutoBreakCustom.TargetSeedID then state.targetSeedId = tonumber(genv.AutoBreakCustom.TargetSeedID) end
if genv.AutoBreakCustom.StandPos then state.standPos = genv.AutoBreakCustom.StandPos end
if genv.AutoBreakCustom.StockPos then state.stockPos = genv.AutoBreakCustom.StockPos end
if genv.AutoBreakCustom.AutoRejoinWorld ~= nil then state.autoRejoinWorld = genv.AutoBreakCustom.AutoRejoinWorld end
if genv.AutoBreakCustom.SavedWorld then state.savedWorldName = genv.AutoBreakCustom.SavedWorld end

-- 🌍 Resolusi Fungsi Navigasi World (enterWorld, currentWorld, warp)
local currentWorldFn = nil
local enterWorldFn = nil
local warpFn = nil

local enterFn = nil

local function resolveWorldNavFunctions()
    if currentWorldFn and (enterWorldFn or warpFn or enterFn) then return end
    if getgc then
        local ok, fns = pcall(getgc, false)
        if ok and type(fns) == "table" then
            for _, fn in ipairs(fns) do
                if type(fn) == "function" then
                    local name = debug.getinfo(fn).name
                    if name == "currentWorld" and not currentWorldFn then
                        currentWorldFn = fn
                    elseif name == "enterWorld" and not enterWorldFn then
                        enterWorldFn = fn
                    elseif name == "warp" and not warpFn then
                        warpFn = fn
                    elseif name == "enter" and not enterFn then
                        enterFn = fn
                    end
                end
            end
        end
    end
end
resolveWorldNavFunctions()

local function isPlayerInWorld()
    local pGui = lp:FindFirstChild("PlayerGui")
    if pGui then
        local mGui = pGui:FindFirstChild("MenuGui")
        local mFrame = mGui and mGui:FindFirstChild("Menu")
        if mFrame and mFrame.Visible == true then
            return false
        end
        local gGui = pGui:FindFirstChild("GameGui")
        local wFrame = gGui and gGui:FindFirstChild("World")
        if wFrame and wFrame.Visible == true then
            return true
        end
    end
    local w = World or findWorldFromAnySource()
    return (w and type(w.name) == "string" and #w.name > 0) or false
end

local function getCurrentWorldName()
    if not isPlayerInWorld() then return nil end
    local w = World or findWorldFromAnySource()
    if w and type(w.name) == "string" and #w.name > 0 then return w.name end
    resolveWorldNavFunctions()
    if currentWorldFn then
        local ok, wName = pcall(currentWorldFn)
        if ok and type(wName) == "string" and #wName > 0 then return wName end
    end
    return nil
end

local function isPlayerCurrentlyInTargetWorld(targetWorld)
    if not targetWorld or #targetWorld == 0 then return false end
    if not isPlayerInWorld() then return false end
    local cur = getCurrentWorldName()
    if not cur or #cur == 0 then return false end
    return string.upper(cur) == string.upper(targetWorld)
end

local function attemptWarpWorld(targetWorld)
    if not targetWorld or #targetWorld == 0 then return end
    elevate()
    resolveWorldNavFunctions()

    -- Layer 1: Panggilan fungsi engine resmi (World.enter, World.warp, enterWorld, warp, enter)
    local w = World or findWorldFromAnySource()
    if w and w.enter then pcall(w.enter, targetWorld) end
    if w and w.warp then pcall(w.warp, targetWorld) end
    if enterWorldFn then pcall(enterWorldFn, targetWorld) end
    if warpFn then pcall(warpFn, targetWorld) end
    if enterFn then pcall(enterFn, targetWorld) end

    -- Layer 2: Chat warp command (/warp <world>)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        if tcs and tcs.TextChannels and tcs.TextChannels:FindFirstChild("RBXGeneral") then
            tcs.TextChannels.RBXGeneral:SendAsync("/warp " .. targetWorld)
        end
    end)
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local say = rep:FindFirstChild("DefaultChatSystemChatEvents") and rep.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if say then
            say:FireServer("/warp " .. targetWorld, "All")
        end
    end)

    -- Layer 3: CoreGui Auto-Reconnect (Mencegah Roblox Error 277 / 268)
    pcall(function()
        local promptGui = game:GetService("CoreGui")("RobloxPromptGui")
        if promptGui then
            local promptOverlay = promptGui:FindFirstChild("promptOverlay")
            local errPrompt = promptOverlay and promptOverlay:FindFirstChild("ErrorPrompt")
            if errPrompt then
                local btn = errPrompt:FindFirstChild("ButtonPrimary") or errPrompt:FindFirstChild("ReconnectButton", true)
                if btn and btn:IsA("GuiButton") then
                    local pos = btn.AbsolutePosition
                    VirtualInputManager:SendMouseButtonEvent(pos.X + 20, pos.Y + 15, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X + 20, pos.Y + 15, 0, false, game, 1)
                end
            end
        end
    end)

    -- Layer 4: Input box di MenuGui jika pemain berada di tampilan menu
    pcall(function()
        local pGui = lp:FindFirstChild("PlayerGui")
        local mGui = pGui and pGui:FindFirstChild("MenuGui")
        if mGui then
            local box = mGui:FindFirstChild("WorldName", true) or mGui:FindFirstChild("SearchBox", true) or mGui:FindFirstChild("TextBox", true)
            if box and box:IsA("TextBox") then
                box.Text = targetWorld
                local joinBtn = mGui:FindFirstChild("Join", true) or mGui:FindFirstChild("Warp", true) or mGui:FindFirstChild("Play", true)
                if joinBtn and (joinBtn:IsA("TextButton") or joinBtn:IsA("ImageButton")) then
                    pcall(function()
                        if type(firesignal) == "function" then
                            pcall(firesignal, joinBtn.MouseButton1Click)
                            pcall(firesignal, joinBtn.Activated)
                        end
                        VirtualInputManager:SendMouseButtonEvent(joinBtn.AbsolutePosition.X + 10, joinBtn.AbsolutePosition.Y + 10, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(joinBtn.AbsolutePosition.X + 10, joinBtn.AbsolutePosition.Y + 10, 0, false, game, 1)
                    end)
                end
            end
        end
    end)
end

local function rehookWorldPointers()
    World = findWorldFromAnySource()
    if World and World.dropList then
        pcall(function()
            dropsTable = debug.getupvalue(World.dropList, 1)
        end)
    end
    -- Self-healing hitFn & setTileFn jika terjadi pergantian instansi engine world
    if not hitFn or (World and debug.getupvalue(hitFn, 1) ~= World) then
        if getgc then
            local ok, fns = pcall(getgc, false)
            if ok and type(fns) == "table" then
                for _, fn in ipairs(fns) do
                    if typeof(fn) == "function" and debug.getinfo(fn).name == "hit" then
                        for _, up in ipairs(debug.getupvalues(fn)) do
                            if type(up) == "table" and rawget(up, "fg") and rawget(up, "bg") then
                                hitFn = fn
                                break
                            end
                        end
                    end
                    if hitFn and (not World or debug.getupvalue(hitFn, 1) == World) then break end
                end
            end
        end
    end
    refreshBackpackReference()
    ensureItemDB()
    ensureItemIcon()
    if World then
        local dummyFg = setmetatable({}, {__index = function() return 0 end, __newindex = function() end})
        local dummyBg = setmetatable({}, {__index = function() return 0 end, __newindex = function() end})
        World.placedAt = {fg = dummyFg, bg = dummyBg}
    end
end

-- 🌍 Simpan dan lacak nama world
local curW = getCurrentWorldName()
if curW and #curW > 0 then
    state.savedWorldName = curW
    genv.PnB_SavedWorld = curW
elseif genv.PnB_SavedWorld then
    state.savedWorldName = genv.PnB_SavedWorld
end

-- Forward declaration fungsi watchdog rejoin
local startRejoinWatchdog = nil

-- Expose global state for diagnostics and control
genv.PnB_State = state
shared.PnB_State = state
_G.PnB_State = state

local function findMatchingSeedId(blockId)
    if not ItemDB or not ItemDB[blockId] then return nil end
    local rawName = ItemDB[blockId].name or ""
    local cleanName = string.lower((string.gsub(rawName, "`(%S)", "")))
    for id, item in pairs(ItemDB) do
        if type(item) == "table" and item.name then
            local iname = string.lower((string.gsub(item.name, "`(%S)", "")))
            if iname == cleanName .. " seed" or iname == cleanName .. " seeds" then
                return id
            end
        end
    end
    if ItemDB[blockId + 1] and string.find(string.lower(ItemDB[blockId + 1].name or ""), "seed") then
        return blockId + 1
    end
    return nil
end

local function walkToTile(targetX, targetY, timeoutSec)
    local maxTime = os.clock() + (timeoutSec or 8.0)
    local targetSafeX = targetX + 0.50
    elevate()
    local w = World or findWorldFromAnySource()
    local lastX = (w and w.goTo and debug.getupvalue(w.goTo, 1)) or targetSafeX
    local stuckCount = 0

    while os.clock() < maxTime and (state.autoPnB or state.isRelocating or state.isRejoining) do
        w = World or findWorldFromAnySource()
        local curX = (w and w.goTo and debug.getupvalue(w.goTo, 1)) or targetSafeX
        local curY = (w and w.goTo and debug.getupvalue(w.goTo, 2)) or ((targetY or 0) + 0.999)
        local diffX = targetSafeX - curX
        local curTileY = math.floor(curY)
        local diffY = targetY and (targetY - curTileY) or 0

        -- Jika target berada di platform atas (diffY < 0), tekan tombol lompat (W / Space)
        if diffY < 0 then
            sendKeySafe(Enum.KeyCode.W, true)
            task.wait(0.12)
            sendKeySafe(Enum.KeyCode.W, false)
        end



        local isArrivedY = true
        if targetY then
            isArrivedY = (math.abs(curTileY - targetY) <= 1)
        end

        if math.abs(diffX) <= 0.10 and isArrivedY then
            sendKeySafe(Enum.KeyCode.A, false)
            sendKeySafe(Enum.KeyCode.D, false)
            pcall(function()
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                end
            end)
            return true
        end

        -- Anti-stuck detection pada tanjakan/gundukan kecil
        if math.abs(curX - lastX) < 0.03 then
            stuckCount = stuckCount + 1
            if stuckCount >= 8 then
                sendKeySafe(Enum.KeyCode.Space, true)
                task.wait(0.10)
                sendKeySafe(Enum.KeyCode.Space, false)
                stuckCount = 0
            end
        else
            stuckCount = 0
        end
        lastX = curX

        local moveKey = (diffX > 0) and Enum.KeyCode.D or Enum.KeyCode.A
        local stopKey = (diffX > 0) and Enum.KeyCode.A or Enum.KeyCode.D
        sendKeySafe(stopKey, false)
        sendKeySafe(moveKey, true)

        task.wait(0.02)
    end
    sendKeySafe(Enum.KeyCode.A, false)
    sendKeySafe(Enum.KeyCode.D, false)
    pcall(function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end)
    w = World or findWorldFromAnySource()
    local finalX = (w and w.goTo and debug.getupvalue(w.goTo, 1)) or targetSafeX
    return math.abs(targetSafeX - finalX) <= 0.45
end

local function getItemLayer(id)
    ensureItemDB()
    local item = ItemDB and ItemDB[id]
    if item and item.background then
        return "bg"
    end
    return "fg"
end

local function isPlaceableFarmableItem(itemId)
    if not itemId or itemId == 18 or itemId == 32 then return false end
    ensureItemDB()
    if not ItemDB then return false end
    local item = ItemDB[itemId]
    if not item or type(item) ~= "table" then return false end
    -- Kecualikan tool (Fist, Wrench), cloth, seed, potion habis pakai, dll.
    if item.tool or item.cloth or item.seed or item.consumable or item.wrench then
        return false
    end
    if item.kind == "tool" or item.kind == "cloth" or item.kind == "seed" then
        return false
    end
    -- Terima semua item placeable yang bisa dipukul / dipasang di tile world:
    -- Termasuk: Block, Lava, Door, Sign, World Lock, Torch, Background, Farmable, dll.
    if type(item.hits) == "number" and item.hits > 0 then
        return true
    end
    if item.solid == true or item.background == true or item.farmable == true or item.kind == "block" or item.actionType == "door" or item.actionType == "sign" or item.actionType == "lock" then
        return true
    end
    return false
end

local function removeColorAndSymbols(str)
    if not str then return "" end
    local s = string.gsub(str, "`(%S)", "")
    s = string.gsub(s, "Dr%.%s*", "")
    s = string.gsub(s, "%s*%[BOOST%]", "")
    s = string.gsub(s, "%(%d+%)", "")
    s = string.gsub(s, "`{2}|(~{2})", "")
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    return s
end

local function sendChat(text)
    elevate()
    local tcs = TextChatService 
    local channel = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
    if channel then
        pcall(function() channel:SendAsync(text) end)
    end
end

local pickerModal = nil
local searchBox = nil
local populateBlockPicker = nil
local updatePickButton = nil
local updateStatusLabel = nil
local updatePnBButton = nil
local updateClaimButton = nil
local seedIdInput = nil
local seedXInput = nil
local seedYInput = nil
local standXInput = nil
local standYInput = nil
local stockXInput = nil
local stockYInput = nil
local updateSeedUI = nil
local updatePosUI = nil

-- =========================================================================
-- ⚡ ULTRA CLEAN DROP COLLECTION (100% Native - ZERO Teleport & ZERO Glitch)
-- =========================================================================
local function collectDropSync(u13)
    if not u13 or type(u13.uid) ~= "number" or u13.n <= 0 then return false end
    if u13.taking and (type(u13.taking) ~= "number" or (os.clock() - u13.taking) < 1.0) then return false end
    if u13.failedUntil and os.clock() < u13.failedUntil then return false end
    elevate()

    u13.pending = nil
    u13.armed = true

    local bp = refreshBackpackReference()
    local n = u13.n
    if u13.id ~= 112 and bp then
        local room = bp.room and bp:room(u13.id) or (200 - bp:count(u13.id))
        n = math.min(u13.n, room)
    end

    if n <= 0 then
        u13.failedUntil = os.clock() + 1.0
        if gm and gm.bubble then
            pcall(gm.bubble, "(backpack full)")
        end
        return false
    end

    u13.taking = os.clock()

    -- 💎 Panggil fungsi resmi World.takeDrop milik game client (ByteNet Net.call)
    local success, err = pcall(World.takeDrop, u13.uid, n)
    u13.taking = nil

    if success and type(err) == "number" and err > 0 then
        -- 🌟 Item berhasil di-claim: Animasi terbang & sfx resmi game
        pcall(function()
            local camX = updateDropsFn and debug.getupvalue(updateDropsFn, 10) or 0
            local camY = updateDropsFn and debug.getupvalue(updateDropsFn, 11) or 0
            local screenPos = Vector2.new((u13.x - camX) * TileSize, (u13.y - camY) * TileSize)

            if u13.id == 112 then
                if not u13.flown then
                    u13.flown = true
                    if Sfx and Sfx.play then Sfx.play("gem_pickup", "object_collect") end
                    local Gem = u13.frame and u13.frame:FindFirstChild("Gem")
                    if Gem and Frame then
                        local clone = Gem:Clone()
                        clone.AnchorPoint = Vector2.new(0.5, 0.5)
                        clone.Size = UDim2.fromOffset(0.6 * TileSize, 0.6 * TileSize)
                        clone.ZIndex = 1017
                        clone.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
                        clone.Parent = Frame
                        if gemAnims then
                            table.insert(gemAnims, {t = 0, gem = clone, from = Vector2.new(u13.x, u13.y)})
                        end
                    end
                    if u13.frame then u13.frame.Visible = false end
                end
            else
                if not u13.flown then
                    u13.flown = true
                    if Sfx and Sfx.play then Sfx.play("object_collect") end
                    if flyToBackpack then
                        flyToBackpack(u13.id, screenPos)
                    end
                    if u13.frame then u13.frame.Visible = false end
                end
            end
        end)

        pcall(function()
            if u13.id ~= 112 then
                if bp and bp.add then
                    bp:add(u13.id, err)
                end
                local v1 = ItemDB and ItemDB[u13.id]
                if v1 and gm and gm.console then
                    gm.console(string.format("`5[``Collect`5]`` You collected `w%d %s``!", err, v1.name))
                end
            else
                if gm and gm.addGems then
                    gm.addGems(err)
                end
            end

            if setDropCount then
                setDropCount(u13, u13.n - err)
                if u13.n > 0 then
                    u13.flown = nil
                    if u13.frame then u13.frame.Visible = not u13.culled end
                end
            elseif u13.frame then
                u13.frame:Destroy()
            end
        end)

        return true
    else
        -- Jika belum diambil atau di luar radius: biarkan frame tetap terlihat di tanah!
        u13.flown = nil
        if u13.frame then
            u13.frame.Visible = not u13.culled
        end
        u13.failedUntil = os.clock() + 0.20
        u13.taking = nil
        return false
    end
end

local isScanningDrops = false
local lastScanTime = 0
local lastDropUiUpdate = 0
local function vacuumNearbyDrops()
    if not state.autoClaim then return end
    local now = os.clock()
    -- Perlindungan terhadap thread cancel agar tidak deadlock: jika tersangkut > 0.3s, otomatis reset
    if isScanningDrops and (now - lastScanTime) < 0.30 then return end
    isScanningDrops = true
    lastScanTime = now
    elevate()

    pcall(function()
        local curX = (debug.getupvalue(World.goTo, 1)) or 0
        local curY = (debug.getupvalue(World.goTo, 2)) or 0
        if curX == 0 and state.standPos then
            curX = state.standPos.x + 0.50
            curY = state.standPos.y + 0.50
        end

        local list = nil
        if World and type(World.dropList) == "function" then
            local ok, res = pcall(World.dropList)
            if ok and type(res) == "table" then list = res end
            if not list then
                local okUp, up1 = pcall(debug.getupvalue, World.dropList, 1)
                if okUp and type(up1) == "table" then list = up1 end
            end
        end
        if not list then list = dropsTable or {} end
        local totalDrops = #list
        if totalDrops == 0 then
            return
        end

        local maxRange = state.maxCollectRange or 2.85
        local maxRangeSq = maxRange * maxRange
        local sPos = state.seedDropPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.SeedDropPos)

        local targets = {}
        for i = 1, totalDrops do
            local d = list[i]
            if d and type(d.uid) == "number" and d.n > 0 then
                local isTaking = d.taking and (type(d.taking) ~= "number" or (os.clock() - d.taking) < 1.0)
                local isFailed = d.failedUntil and os.clock() < d.failedUntil
                if not isTaking and not isFailed then
                    -- ⚡ ULTRA-FAST AABB PRE-FILTER (0 math.sqrt untuk 99.9% drop di world!)
                    local dx = d.x - curX
                    if dx <= 3.2 and dx >= -3.2 then
                        local dy = d.y - curY
                        if dy <= 3.2 and dy >= -3.5 then
                            -- 🛡️ EXCLUDE SEED DROP PILE:
                            -- Jika drop berada di dalam radius 2.0 tile dari pos drop seed (sPos), JANGAN PERNAH di-vacuum!
                            local isSeedDropPile = false
                            if sPos then
                                local sx = d.x - (sPos.x + 0.50)
                                local sy = d.y - (sPos.y + 0.50)
                                if (sx * sx + sy * sy) <= 4.0 then -- radius 2.0^2
                                    isSeedDropPile = true
                                end
                            end

                            if not isSeedDropPile then
                                local clampedY = math.clamp(d.y, curY - 2.0, curY)
                                local cdy = d.y - clampedY
                                local distSq = dx * dx + cdy * cdy
                                if distSq <= maxRangeSq then
                                    table.insert(targets, {drop = d, distSq = distSq})
                                    if #targets >= 10 then break end -- Batch limit per cycle
                                end
                            end
                        end
                    end
                end
            end
        end

        if #targets > 0 then
            if #targets > 1 then
                table.sort(targets, function(a, b) return a.distSq < b.distSq end)
            end

            local collectedAny = false
            for _, entry in ipairs(targets) do
                if not state.autoClaim then break end
                if collectDropSync(entry.drop) then
                    collectedAny = true
                end
            end

            -- ⚡ THROTTLED UI UPDATE: Refresh UI maksimal 1x per 0.5s setelah batch selesai, bebas lag!
            if collectedAny and (os.clock() - lastDropUiUpdate >= 0.5) then
                lastDropUiUpdate = os.clock()
                task.defer(function()
                    if updatePickButton then updatePickButton() end
                    if pickerModal and pickerModal.Visible and populateBlockPicker then
                        populateBlockPicker(searchBox and searchBox.Text or "")
                    end
                end)
            end
        end
    end)

    isScanningDrops = false
end

local function startClaimWorker()
    isScanningDrops = false
    if state.claimThread then
        task.cancel(state.claimThread)
        state.claimThread = nil
    end

    state.claimThread = task.spawn(function()
        elevate()
        print("[PnB AutoClaim] Background Claim Worker berjalan (Optimized 0.18s).")
        while state.autoClaim do
            vacuumNearbyDrops()
            task.wait(0.18) -- 0.18s (~5.5 Hz) = Sangat responsif & 0 FPS drop!
        end
        print("[PnB AutoClaim] Background Claim Worker berhenti.")
    end)
end

local function checkCaptchaClaim(rawText)
    if not state.autoClaim or not rawText or type(rawText) ~= "string" then return end
    local match = string.match(rawText, "/claim%s+([%w%d%p]+)") or string.match(rawText, "claim%s+([%w%d%p]+)")
    if match then
        local code = removeColorAndSymbols(match)
        if code and #code > 0 then
            print("[PnB AutoClaim] Captcha /claim terdeteksi. Kode:", code)
            task.delay(0.35, function()
                sendChat("/claim " .. code)
            end)
        end
    end
end

if WorldRemotes and WorldRemotes:FindFirstChild("WorldNotice") then
    local noticeConn = WorldRemotes.WorldNotice.OnClientEvent:Connect(function(msg)
        elevate()
        if type(msg) == "string" then
            checkCaptchaClaim(msg)
        end
    end)
    table.insert(state.connections, noticeConn)
end

if (TextChatService )("MessageReceived") then
    local chatConn = (TextChatService ).MessageReceived:Connect(function(textChatMessage)
        elevate()
        if textChatMessage and textChatMessage.Text then
            checkCaptchaClaim(textChatMessage.Text)
        end
    end)
    table.insert(state.connections, chatConn)
end

if WorldRemotes and WorldRemotes:FindFirstChild("DropAdded") then
    local dropConn = WorldRemotes.DropAdded.OnClientEvent:Connect(function(...)
        elevate()
        if state.autoClaim and not state.autoPnB then
            task.spawn(vacuumNearbyDrops)
        end
    end)
    table.insert(state.connections, dropConn)
end

local function handleInventoryUpdate()
    refreshBackpackReference()
    task.defer(function()
        if updatePickButton then updatePickButton() end
        if pickerModal and pickerModal.Visible and populateBlockPicker then
            populateBlockPicker(searchBox and searchBox.Text or "")
        end
    end)
end

if WorldRemotes and WorldRemotes:FindFirstChild("InventorySync") then
    local invConn = WorldRemotes.InventorySync.OnClientEvent:Connect(function(...)
        elevate()
        handleInventoryUpdate()
    end)
    table.insert(state.connections, invConn)
end

if WorldRemotes and WorldRemotes:FindFirstChild("ItemsGiven") then
    local itemsGivenConn = WorldRemotes.ItemsGiven.OnClientEvent:Connect(function(...)
        elevate()
        handleInventoryUpdate()
    end)
    table.insert(state.connections, itemsGivenConn)
end

-- 🛡️ Staff Join Listener (Otomatis matikan bot jika ada staff/moderator masuk world)
local playerAddedConn = Players.PlayerAdded:Connect(function(player)
    elevate()
    task.wait(0.5)
    if isStaffMember(player) then
        if state.autoPnB then
            state.autoPnB = false
            if updatePnBButton then updatePnBButton() end
            if updateStatusLabel then updateStatusLabel("🚨 STAFF MASUK: " .. player.Name .. "! PnB STOP!") end
            print("[PnB Shield] Staff terdeteksi masuk (" .. player.Name .. ")! Auto PnB dinonaktifkan.")
        end
    end
end)
table.insert(state.connections, playerAddedConn)

-- 🛡️ ModNotice Listener (Otomatis matikan bot jika ada peringatan moderator)
if WorldRemotes and WorldRemotes:FindFirstChild("ModNotice") then
    local modNoticeConn = WorldRemotes.ModNotice.OnClientEvent:Connect(function(noticeText)
        elevate()
        if state.autoPnB then
            state.autoPnB = false
            if updatePnBButton then updatePnBButton() end
            if updateStatusLabel then updateStatusLabel("🚨 MOD NOTICE DITERIMA! PnB STOP!") end
            print("[PnB Shield] ModNotice diterima! Auto PnB dihentikan.")
        end
    end)
    table.insert(state.connections, modNoticeConn)
end

-- 🛡️ World Closed & Leave World Listeners
if WorldRemotes and WorldRemotes:FindFirstChild("WorldClosed") then
    local wcConn = WorldRemotes.WorldClosed.OnClientEvent:Connect(function()
        elevate()
        print("[PnB Shield] WorldClosed event.")
    end)
    table.insert(state.connections, wcConn)
end

if WorldRemotes and WorldRemotes:FindFirstChild("LeaveWorld") then
    local lwConn = WorldRemotes.LeaveWorld.OnClientEvent:Connect(function()
        elevate()
        print("[PnB Shield] LeaveWorld event.")
    end)
    table.insert(state.connections, lwConn)
end

local function placeTile(tx, ty, blockId)
    if not state.autoPnB or not blockId then return false end
    local bp = refreshBackpackReference()
    if not bp or bp:count(blockId) <= 0 then return false end
    elevate()

    -- 🛡️ Cek batas dan izin build sebelum menaruh
    if not canBuildAt(tx, ty) then
        return false
    end

    local layer = getItemLayer(blockId)
    local targetWorld = (layer == "bg") and World.bg or World.fg
    -- Jangan taruh jika tile sudah terisi pada layer ini
    if targetWorld and targetWorld[ty] and targetWorld[ty][tx] and targetWorld[ty][tx] ~= 0 then
        return false
    end

    bp:select(blockId)
    setTileFn(layer, tx, ty, blockId, false, false)
    bp:remove(blockId, 1)

    -- 🔊 Suara menaruh (put) balok normal pada umumnya
    if Sfx and origSfxPlay then
        origSfxPlay("tile_created")
    end

    -- 🛡️ Humanized Place Delay (+ variasi acak natural 12-35ms)
    task.wait(state.placeDelay + (math.random(12, 35) / 1000))

    local placedTile = targetWorld and targetWorld[ty] and targetWorld[ty][tx] or 0
    return placedTile == blockId
end

local function placeTileFast(tx, ty, blockId)
    if not state.autoPnB or not blockId then return false end
    local bp = refreshBackpackReference()
    if not bp or bp:count(blockId) <= 0 then return false end
    elevate()

    -- 🛡️ Cek batas dan izin build sebelum menaruh
    if not canBuildAt(tx, ty) then
        return false
    end

    local layer = getItemLayer(blockId)
    local targetWorld = (layer == "bg") and World.bg or World.fg
    if targetWorld and targetWorld[ty] and targetWorld[ty][tx] and targetWorld[ty][tx] ~= 0 then
        return false
    end

    bp:select(blockId)
    setTileFn(layer, tx, ty, blockId, false, false)
    bp:remove(blockId, 1)

    -- 🔊 Suara menaruh (put) balok normal pada umumnya
    if Sfx and origSfxPlay then
        origSfxPlay("tile_created")
    end
    return true
end

local function breakTile(tx, ty, blockId)
    if not state.autoPnB then return end
    elevate()

    if not canPunchAt(tx, ty) then
        return
    end

    local bp = refreshBackpackReference()
    if bp then
        bp:select(18) -- Fist
    end

    local layer = blockId and getItemLayer(blockId) or "fg"
    local maxAttempts = 35
    local attempts = 0
    while attempts < maxAttempts and state.autoPnB do
        local targetWorld = (layer == "bg") and World.bg or World.fg
        local currentBlock = targetWorld and targetWorld[ty] and targetWorld[ty][tx] or 0
        if currentBlock == 0 then break end

        hitFn(tx, ty, true)
        attempts = attempts + 1
        
        -- ⚡ Instant vacuum jika ada gem / drop keluar saat memukul
        if state.autoClaim then
            vacuumNearbyDrops()
        end
        
        -- ⚡ Break Delay Snappy & Aman
        task.wait(math.max(0.06, state.punchDelay))
    end

    -- ⚡ Instant vacuum seketika balok pecah (mencegah penumpukan)
    if state.autoClaim then
        vacuumNearbyDrops()
    end

    task.wait(0.02)
end

local function getNativePutDown()
    if getgc then
        local okF, fns = pcall(getgc, false)
        if okF and type(fns) == "table" then
            for _, fn in ipairs(fns) do
                if typeof(fn) == "function" and (islclosure == nil or islclosure(fn)) and debug.getinfo(fn).name == "putDown" then
                    return fn
                end
            end
        end
    end
    return nil
end

local function performDrop(id, count, targetX, targetY)
    local dropAmount = math.min(count, 200)
    if dropAmount <= 0 then return false end

    elevate()
    local tileX = math.floor(targetX)
    local tileY = math.floor(targetY)
    local dropX = tileX + 0.50
    local dropY = tileY + 0.50
    local netObj = ensureNet()
    local bp = refreshBackpackReference()
    local startCount = bp and bp:count(id) or 0

    -- 1. Cek apakah target tile adalah Display Box
    local isDisplay = false
    if World then
        if World.displays and type(World.displays.get) == "function" then
            local ok, disp = pcall(World.displays.get, tileX, tileY)
            if ok and disp ~= nil then
                isDisplay = true
            end
        end
        if not isDisplay and World.fg and World.fg[tileY] then
            local fgId = World.fg[tileY][tileX]
            if fgId and fgId > 0 then
                local item = ItemDB and ItemDB[fgId]
                if item and item.display then
                    isDisplay = true
                end
            end
        end
    end

    if isDisplay then
        -- 🌟 Eksekusi resmi game engine: World.displayPut(tileX, tileY, itemId, count, dropX)
        -- Sesuai dekompilasi baris 7371 / 18694:
        -- a1 = tileX, a2 = tileY, a3 = id, a4 = count, a5 = dropX
        if World and type(World.displayPut) == "function" then
            pcall(World.displayPut, tileX, tileY, id, dropAmount, dropX)
            task.wait(0.25)
            local curBp = refreshBackpackReference()
            local curCount = curBp and curBp:count(id) or 0
            if curCount < startCount then
                print(string.format("[PnB Drop] Sukses deposit %d item (%d) ke Display Box (%d,%d). Sisa di tas: %d", dropAmount, id, tileX, tileY, curCount))
                return true
            end
        end
    end

    -- 2. Fallback: Native putDown game client (Drop Player Asli ke lantai)
    -- Sesuai baris 1071 / 2085: putDown(id, count, x, y)
    local putDown = getNativePutDown()
    if putDown then
        local ok = pcall(putDown, id, dropAmount, dropX, dropY)
        if ok then
            local curBp = refreshBackpackReference()
            if curBp and curBp.remove then
                curBp:remove(id, dropAmount)
            end
            print(string.format("[PnB Drop] Sukses putDown %d seed (ID %d) di (%.1f, %.1f).", dropAmount, id, dropX, dropY))
            return true
        end
    end

    -- 3. Fallback langsung via Net.drop.send
    if netObj and netObj.drop and netObj.drop.send then
        netObj.drop.send({
            id = id,
            n = dropAmount,
            x = dropX,
            y = dropY,
        })
        task.wait(0.15)
        local curBp = refreshBackpackReference()
        if curBp and curBp.remove then
            curBp:remove(id, dropAmount)
        end
        print(string.format("[PnB Drop] Sukses Net.drop.send %d item (%d) ke lantai (%d,%d).", dropAmount, id, tileX, tileY))
        return true
    end

    return false
end

local function startPnBWorker()
    if state.pnbThread then
        task.cancel(state.pnbThread)
        state.pnbThread = nil
    end

    state.pnbThread = task.spawn(function()
        elevate()
        print("[PnB] Auto PnB dimulai...")

        -- 🛡️ 1. Staff Check on Start:
        local hasStaff, staffName = checkAnyStaffPresent()
        if hasStaff then
            state.autoPnB = false
            if updatePnBButton then updatePnBButton() end
            if updateStatusLabel then updateStatusLabel("🚨 STAFF TERDETEKSI: " .. (staffName or "Staff") .. "!") end
            print("[PnB Shield] Ada staff di world saat start (" .. tostring(staffName) .. ")! Membatalkan.")
            return
        end

        local startAnchorX = debug.getupvalue(World.goTo, 1) or 0
        local startAnchorY = debug.getupvalue(World.goTo, 2) or 0
        local anchorTileX = math.floor(startAnchorX)
        local anchorTileY = math.floor(startAnchorY)
        local dir = (state.direction == "Kiri") and -1 or 1

        -- Inisialisasi StandPos jika belum diatur
        if not state.standPos and genv.AutoBreakCustom and genv.AutoBreakCustom.StandPos then
            state.standPos = genv.AutoBreakCustom.StandPos
        end
        if not state.standPos then
            state.standPos = {x = anchorTileX, y = anchorTileY}
            if genv.AutoBreakCustom then genv.AutoBreakCustom.StandPos = state.standPos end
        else
            anchorTileX = state.standPos.x
            anchorTileY = state.standPos.y
        end

        -- Pastikan karakter berada di Pos Berdiri yang ditentukan
        local curTileX = math.floor(startAnchorX)
        local curTileY = math.floor(startAnchorY)
        local distFromCenter = math.abs(startAnchorX - (anchorTileX + 0.50))

        if curTileX ~= anchorTileX or curTileY ~= anchorTileY or distFromCenter > 0.35 then
            if updateStatusLabel then updateStatusLabel(string.format("📍 Menuju Pos Berdiri (%d,%d)...", anchorTileX, anchorTileY)) end
            walkToTile(anchorTileX, anchorTileY, 5.0)
        end
        sendKeySafe(Enum.KeyCode.A, false)
        sendKeySafe(Enum.KeyCode.D, false)
        pcall(function()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)

        -- 🛡️ Kalibrasi posisi berdiri tepat di tengah tile (anchorTileX + 0.50)
        local safeAnchorX = anchorTileX + 0.50
        local liveStartX = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
        if math.abs(liveStartX - safeAnchorX) > 0.10 then
            local alignKey = (liveStartX < safeAnchorX) and Enum.KeyCode.D or Enum.KeyCode.A
            local alignTimeout = os.clock() + 0.20
            sendKeySafe(alignKey, true)
            while os.clock() < alignTimeout do
                local cur = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                if (alignKey == Enum.KeyCode.D and cur >= safeAnchorX) or (alignKey == Enum.KeyCode.A and cur <= safeAnchorX) then
                    break
                end
                task.wait(0.01)
            end
            sendKeySafe(alignKey, false)
            pcall(function()
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
            end)
            task.wait(0.02)
        end
        safeAnchorX = (debug.getupvalue(World.goTo, 1)) or (anchorTileX + 0.50)

        local consecutiveFails = 0
        local lastWorldKeepAlive = os.clock()

        while state.autoPnB do
            elevate()

            -- 🛡️ Jika pemain sedang di luar world (lobby/menu) atau sedang proses rejoining:
            if not isPlayerInWorld() or state.isRejoining then
                task.wait(0.5)
            else

            -- 🛡️ Keep-Alive Watchdog (Pukulan aktif mereset inactivity engine tanpa perlu gerak fisik)
            if os.clock() - lastWorldKeepAlive >= 150 then
                lastWorldKeepAlive = os.clock()
            end

            -- 🛡️ Real-Time Staff Guard (Pemeriksaan berkala setiap putaran PnB) hasStaffNow, staffNameNow = checkAnyStaffPresent()
            if hasStaffNow then
                state.autoPnB = false
                sendKeySafe(Enum.KeyCode.A, false)
                sendKeySafe(Enum.KeyCode.D, false)
                if updatePnBButton then updatePnBButton() end
                if updateStatusLabel then updateStatusLabel("🚨 STAF TERDETEKSI: " .. (staffNameNow or "Staff") .. "! (Safe Stop)") end
                print("[PnB Shield] Staf terdeteksi di world (" .. tostring(staffNameNow) .. ")! Menghentikan PnB seketika demi keamanan.")
                break
            end

            -- 🛡️ Safety Boundary & Auto-Walk to StandPos (aktif baik saat pergeseran maupun baru masuk world manual) not state.isRelocating then
                local w = World or findWorldFromAnySource()
                local liveX = (w and w.goTo and debug.getupvalue(w.goTo, 1)) or anchorTileX
                local liveY = (w and w.goTo and debug.getupvalue(w.goTo, 2)) or anchorTileY
                local targetX = state.standPos and state.standPos.x or anchorTileX
                local targetY = state.standPos and state.standPos.y or anchorTileY
                if math.abs(liveX - (targetX + 0.50)) > 1.8 or math.abs(math.floor(liveY) - targetY) > 1.5 then
                    if updateStatusLabel then updateStatusLabel(string.format("🚶 Menuju Pos Berdiri (%d,%d)...", targetX, targetY)) end
                    state.isRelocating = true
                    walkToTile(targetX, targetY, 12.0)
                    state.isRelocating = false
                    anchorTileX = targetX
                    anchorTileY = targetY
                    safeAnchorX = targetX + 0.50
                    local liveAfter = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                    if math.abs(liveAfter - safeAnchorX) > 0.10 then
                        local alignKey = (liveAfter < safeAnchorX) and Enum.KeyCode.D or Enum.KeyCode.A
                        local alignTimeout = os.clock() + 0.20
                        sendKeySafe(alignKey, true)
                        while os.clock() < alignTimeout do
                            local cur = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                            if (alignKey == Enum.KeyCode.D and cur >= safeAnchorX) or (alignKey == Enum.KeyCode.A and cur <= safeAnchorX) then
                                break
                            end
                            task.wait(0.01)
                        end
                        sendKeySafe(alignKey, false)
                        pcall(function()
                            local char = lp.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
                        end)
                        task.wait(0.02)
                    end
                    safeAnchorX = (debug.getupvalue(World.goTo, 1)) or (targetX + 0.50)
                    task.wait(0.05)
                end
            end

            if not state.selectedBlockId or not state.selectedBlockName then
                if updateStatusLabel then updateStatusLabel("Pilih item block terlebih dahulu!") end
                state.autoPnB = false
                if updatePnBButton then updatePnBButton() end
                break
            end

            local bp = refreshBackpackReference()

            -- 🌱 FITUR AUTO DROP SEED (Drop saat seed mencapai 200 / ambang batas di koordinat tujuan)
            local sId = state.targetSeedId 
                or (genv.AutoBreakCustom and tonumber(genv.AutoBreakCustom.TargetSeedID))
                or findMatchingSeedId(state.selectedBlockId)

            -- Auto scan jika sId masih belum terdeteksi: cari seed apa saja yang >= threshold (default 195/200)
            if not sId and bp and bp.slots then
                for _, slot in ipairs(bp.slots) do
                    local slotId = slot.id or slot[1]
                    local slotCount = slot.n or slot.count or slot[2] or 0
                    if slotId and slotId > 0 and slotCount >= (state.seedDropThreshold or 195) then
                        local item = ItemDB and ItemDB[slotId]
                        if item and (item.kind == "seed" or string.find(item.name:lower(), "seed")) then
                            sId = slotId
                            break
                        end
                    end
                end
            end

            local sPos = state.seedDropPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.SeedDropPos)
            local stPos = state.standPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.StandPos) or {x = anchorTileX, y = anchorTileY}

            if sId and sPos and bp then
                local sCount = bp:count(sId)
                if sCount >= (state.seedDropThreshold or 195) and (not state.nextDropAttempt or os.clock() >= state.nextDropAttempt) then
                    if updateStatusLabel then updateStatusLabel(string.format("🌱 Menuju Pos Drop Seed (%d pcs)...", sCount)) end
                    state.isRelocating = true

                    -- 🛑 Matikan Auto Claim sementara agar seed yang di-drop tidak langsung terhisap kembali
                    local prevAutoClaim = state.autoClaim
                    state.autoClaim = false
                    if updateClaimButton then updateClaimButton() end
                    if state.claimThread then
                        task.cancel(state.claimThread)
                        state.claimThread = nil
                    end

                    -- 1. Karakter berjalan tepat ke tile sPos
                    walkToTile(sPos.x, sPos.y, 6.0)
                    task.wait(0.15)

                    -- 2. Drop semua stack seed yang >= threshold selagi berada di sPos
                    local dropAttempts = 0
                    while dropAttempts < 5 do
                        local curBp = refreshBackpackReference()
                        local curSeeds = curBp and curBp:count(sId) or 0
                        if curSeeds < (state.seedDropThreshold or 195) then break end

                        local dropAmount = math.min(curSeeds, 200)
                        if updateStatusLabel then updateStatusLabel(string.format("🌱 Drop Seed (%d pcs) di (%d,%d)...", dropAmount, sPos.x, sPos.y)) end
                        local dropOk = performDrop(sId, dropAmount, sPos.x, sPos.y)
                        task.wait(0.35)
                        dropAttempts = dropAttempts + 1

                        local postBp = refreshBackpackReference()
                        local remaining = postBp and postBp:count(sId) or 0
                        if remaining >= curSeeds then
                            -- Jumlah seed tidak berkurang (Display Box penuh atau gagal drop)
                            print(string.format("[PnB Drop] Seed tidak berkurang setelah drop (Display Box penuh?). Menghentikan drop."))
                            break
                        end
                    end

                    -- 3. Karakter berjalan KEMBALI ke Pos Berdiri
                    if updateStatusLabel then updateStatusLabel(string.format("📍 Balik ke Pos Berdiri (%d,%d)...", stPos.x, stPos.y)) end
                    walkToTile(stPos.x, stPos.y, 6.0)
                    safeAnchorX = stPos.x + 0.50
                    anchorTileX = stPos.x
                    anchorTileY = stPos.y
                    local liveAfterReturn = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                    if math.abs(liveAfterReturn - safeAnchorX) > 0.10 then
                        local alignKey = (liveAfterReturn < safeAnchorX) and Enum.KeyCode.D or Enum.KeyCode.A
                        local alignTimeout = os.clock() + 0.20
                        sendKeySafe(alignKey, true)
                        while os.clock() < alignTimeout do
                            local cur = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                            if (alignKey == Enum.KeyCode.D and cur >= safeAnchorX) or (alignKey == Enum.KeyCode.A and cur <= safeAnchorX) then
                                break
                            end
                            task.wait(0.01)
                        end
                        sendKeySafe(alignKey, false)
                        pcall(function()
                            local char = lp.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
                        end)
                        task.wait(0.02)
                    end
                    safeAnchorX = (debug.getupvalue(World.goTo, 1)) or (stPos.x + 0.50)
                    state.isRelocating = false
                    isScanningDrops = false

                    -- Refresh backpack dan cek sisa seed
                    local postBp = refreshBackpackReference()
                    local remainingSeeds = postBp and postBp:count(sId) or 0
                    if remainingSeeds >= (state.seedDropThreshold or 195) then
                        state.nextDropAttempt = os.clock() + 5.0
                        print(string.format("[PnB Drop] Perhatian: Seed masih tersisa %d (Display Box penuh atau Drop gagal). Cooldown 5s.", remainingSeeds))
                    else
                        state.nextDropAttempt = 0
                    end

                    -- Bersihkan flag taking yang mungkin tersangkut agar Auto Claim tidak macet di loop berikutnya
                    pcall(function()
                        local dList = (World and World.dropList and (World.dropList() or debug.getupvalue(World.dropList, 1))) or dropsTable
                        if dList then
                            for _, d in ipairs(dList) do
                                if d and d.taking then d.taking = nil end
                            end
                        end
                    end)

                    -- ✨ Aktifkan kembali Auto Claim setelah karakter kembali ke posisi berdiri
                    if prevAutoClaim then
                        state.autoClaim = true
                        if updateClaimButton then updateClaimButton() end
                        startClaimWorker()
                    end
                    task.wait(0.10)
                end
            end

            -- 📦 FITUR AUTO RESTOCK POS (Jalan ke Pos Stok & ambil stok balok saat stok backpack menipis)
            local skPos = state.stockPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.StockPos)
            local stock = bp and bp:count(state.selectedBlockId) or 0
            if stock <= 2 and skPos then
                if updateStatusLabel then updateStatusLabel(string.format("📦 Jalan ke Pos Stok (%d,%d)...", skPos.x, skPos.y)) end
                state.isRelocating = true
                walkToTile(skPos.x, skPos.y, 6.0)
                task.wait(0.15)

                if updateStatusLabel then updateStatusLabel("📦 Mengambil stok di Pos Stok...") end
                local restockTimeout = os.clock() + 3.0
                while os.clock() < restockTimeout and state.autoPnB do
                    local curLiveX = debug.getupvalue(World.goTo, 1) or (skPos.x + 0.5)
                    local curLiveY = debug.getupvalue(World.goTo, 2) or (skPos.y + 0.5)
                    local list = (World and World.dropList and debug.getupvalue(World.dropList, 1)) or dropsTable or {}
                    
                    -- Reset failedUntil agar drop di area stok langsung diambil tanpa terblokir cooldown
                    for _, d in ipairs(list) do
                        d.failedUntil = nil
                    end

                    for _, d in ipairs(list) do
                        if type(d.uid) == "number" and d.n > 0 and d.id == state.selectedBlockId then
                            local dDistSk = math.sqrt((d.x - (skPos.x + 0.5))^2 + (d.y - (skPos.y + 0.5))^2)
                            local dDistPlayer = math.sqrt((d.x - curLiveX)^2 + (d.y - curLiveY)^2)
                            if dDistSk <= 2.5 or dDistPlayer <= 2.5 then
                                collectDropSync(d)
                            end
                        end
                    end
                    vacuumNearbyDrops()
                    local curStock = bp and bp:count(state.selectedBlockId) or 0
                    if curStock >= 190 then break end
                    task.wait(0.08)
                end

                if updateStatusLabel then updateStatusLabel(string.format("📍 Balik ke Pos Berdiri (%d,%d)...", stPos.x, stPos.y)) end
                walkToTile(stPos.x, stPos.y, 6.0)
                safeAnchorX = stPos.x + 0.50
                anchorTileX = stPos.x
                anchorTileY = stPos.y
                local liveAfterStock = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                if math.abs(liveAfterStock - safeAnchorX) > 0.10 then
                    local alignKey = (liveAfterStock < safeAnchorX) and Enum.KeyCode.D or Enum.KeyCode.A
                    local alignTimeout = os.clock() + 0.20
                    sendKeySafe(alignKey, true)
                    while os.clock() < alignTimeout do
                        local cur = (debug.getupvalue(World.goTo, 1)) or safeAnchorX
                        if (alignKey == Enum.KeyCode.D and cur >= safeAnchorX) or (alignKey == Enum.KeyCode.A and cur <= safeAnchorX) then
                            break
                        end
                        task.wait(0.01)
                    end
                    sendKeySafe(alignKey, false)
                    pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
                    end)
                    task.wait(0.02)
                end
                safeAnchorX = (debug.getupvalue(World.goTo, 1)) or (stPos.x + 0.50)
                state.isRelocating = false
                task.wait(0.05)

                stock = bp and bp:count(state.selectedBlockId) or 0
                if stock <= 0 then
                    state.autoPnB = false
                    if updatePnBButton then updatePnBButton() end
                    if updateStatusLabel then updateStatusLabel("📦 Stok di Pos Stok habis!") end
                    print("[PnB] Stok di Pos Stok kosong. Put and Break dihentikan.")
                    break
                end
            end

            if stock <= 0 then
                if updateStatusLabel then updateStatusLabel("Block habis di backpack!") end
                print("[PnB] Block habis di backpack!")
                state.autoPnB = false
                if updatePnBButton then updatePnBButton() end
                break
            end

            if updatePickButton then updatePickButton() end

            local px = anchorTileX
            local py = anchorTileY
            local layer = getItemLayer(state.selectedBlockId)
            local targetWorld = (layer == "bg") and World.bg or World.fg

            if state.mode == "1-Tile" then
                local tx = px + dir
                local ty = py + state.offsetY

                -- 🛡️ 4. Build Permission & Lock Check:
                if not canBuildAt(tx, ty) then
                    state.autoPnB = false
                    if updatePnBButton then updatePnBButton() end
                    if updateStatusLabel then updateStatusLabel("⛔ World/Area Terkunci (Tak Ada Akses)!") end
                    print("[PnB Shield] Area tile (" .. tx .. "," .. ty .. ") terkunci! Stop.")
                    break
                end

                local currentB = targetWorld and targetWorld[ty] and targetWorld[ty][tx] or 0
                if currentB == 0 then
                    if updateStatusLabel then updateStatusLabel("Menaruh: " .. state.selectedBlockName .. " (" .. stock .. ")") end
                    local placed = placeTile(tx, ty, state.selectedBlockId)
                    if not placed then
                        consecutiveFails = consecutiveFails + 1
                    else
                        consecutiveFails = 0
                    end
                else
                    consecutiveFails = 0
                end

                if consecutiveFails >= 3 then
                    state.autoPnB = false
                    if updatePnBButton then updatePnBButton() end
                    if updateStatusLabel then updateStatusLabel("⛔ Gagal Menaruh Balok (Area Terkunci)!") end
                    print("[PnB Shield] 3x gagal menaruh balok di (" .. tx .. "," .. ty .. "). Stop.")
                    break
                end

                if updateStatusLabel then updateStatusLabel("Memukul balok di (" .. tx .. "," .. ty .. ")...") end
                breakTile(tx, ty, state.selectedBlockId)

                -- 3. Klaim drop secara native (100% diam, zero jitter/teleport)
                if state.autoClaim then
                    task.wait(0.04)
                    vacuumNearbyDrops()
                end
            elseif state.mode == "2-Far" then
                local far1X = px + (dir * 1)
                local far2X = px + (dir * 2)
                local targetY = py + state.offsetY

                -- 🛡️ 4. Build Permission & Lock Check for 2 tiles:
                if not canBuildAt(far1X, targetY) or not canBuildAt(far2X, targetY) then
                    state.autoPnB = false
                    if updatePnBButton then updatePnBButton() end
                    if updateStatusLabel then updateStatusLabel("⛔ Area Terkunci (Tak Ada Akses)!") end
                    print("[PnB Shield] Area 2-Far terkunci! Stop.")
                    break
                end

                -- 🛡️ Karakter tetap tepat di tengah safeAnchorX (koreksi halus jika bergeser > 0.14)
                local curLiveX = debug.getupvalue(World.goTo, 1) or safeAnchorX
                local diffCenter = curLiveX - safeAnchorX
                if math.abs(diffCenter) > 0.14 and not state.isRelocating then
                    local backKey = (diffCenter > 0) and Enum.KeyCode.A or Enum.KeyCode.D
                    local retTimeout = os.clock() + 0.15
                    sendKeySafe(backKey, true)
                    while os.clock() < retTimeout do
                        local live = debug.getupvalue(World.goTo, 1) or safeAnchorX
                        if math.abs(live - safeAnchorX) <= 0.05 then
                            break
                        end
                        task.wait(0.01)
                    end
                    sendKeySafe(backKey, false)
                    pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                        end
                    end)
                    task.wait(0.02)
                end

                -- 1. Taruh balok 1 & balok 2 (hanya jika kosong pada layernya)
                local b1 = targetWorld and targetWorld[targetY] and targetWorld[targetY][far1X] or 0
                if b1 == 0 and bp:count(state.selectedBlockId) > 0 then
                    if updateStatusLabel then updateStatusLabel("Menaruh: " .. state.selectedBlockName .. " (" .. stock .. ")") end
                    local p1 = placeTile(far1X, targetY, state.selectedBlockId)
                    if not p1 then consecutiveFails = consecutiveFails + 1 else consecutiveFails = 0 end
                end

                local b2 = targetWorld and targetWorld[targetY] and targetWorld[targetY][far2X] or 0
                if b2 == 0 and bp:count(state.selectedBlockId) > 0 then
                    local p2 = placeTile(far2X, targetY, state.selectedBlockId)
                    if not p2 then consecutiveFails = consecutiveFails + 1 else consecutiveFails = 0 end
                end

                if consecutiveFails >= 4 then
                    state.autoPnB = false
                    if updatePnBButton then updatePnBButton() end
                    if updateStatusLabel then updateStatusLabel("⛔ Gagal Menaruh Balok (Area Terkunci)!") end
                    print("[PnB Shield] 4x gagal menaruh balok. Stop.")
                    break
                end

                -- 2. Pukul balok 1 & balok 2 secara paralel (Simultan)
                if updateStatusLabel then updateStatusLabel("Memukul 2 balok di depan...") end
                local bpFist = refreshBackpackReference()
                if bpFist then bpFist:select(18) end

                local farTargets = {{x = far1X, y = targetY}, {x = far2X, y = targetY}}
                local farCycles = 0
                while farCycles < 40 and state.autoPnB do
                    local remainingFar = 0
                    for _, ft in ipairs(farTargets) do
                        if not state.autoPnB then break end
                        local curB = targetWorld and targetWorld[ft.y] and targetWorld[ft.y][ft.x] or 0
                        if curB ~= 0 then
                            remainingFar = remainingFar + 1
                            if World then
                                World.actAt = 0
                                World.punchReady = 0
                            end
                            hitFn(ft.x, ft.y, true)
                            if state.autoClaim then vacuumNearbyDrops() end
                            task.wait(math.max(0.06, state.punchDelay))
                        end
                    end
                    if remainingFar == 0 then break end
                    farCycles = farCycles + 1
                end

                -- 3. Klaim seluruh drop secara instan di posisi berdiri (100% diam, zero walk)
                if state.autoClaim then
                    task.wait(0.04)
                    local dList = (World and World.dropList and debug.getupvalue(World.dropList, 1)) or dropsTable
                    if dList then
                        for _, d in ipairs(dList) do
                            d.failedUntil = nil
                        end
                    end
                    vacuumNearbyDrops()
                    task.wait(0.04)
                    vacuumNearbyDrops()
                end
            else
                -- 🔲 Custom Mode (5x5 Tile Matrix Selector)
                local activeTiles = {}
                for key, active in pairs(state.customTiles) do
                    if active then
                        local sx, sy = string.match(key, "^([%-%d]+),([%-%d]+)$")
                        if sx and sy then
                            local dx = tonumber(sx)
                            local dy = tonumber(sy)
                            if dx and dy then
                                table.insert(activeTiles, {dx = dx, dy = dy, dist = math.sqrt(dx*dx + dy*dy)})
                            end
                        end
                    end
                end

                if #activeTiles == 0 then
                    if updateStatusLabel then updateStatusLabel("Pilih minimal 1 tile pada 5x5 Matrix!") end
                    task.wait(0.35)
                else
                    table.sort(activeTiles, function(a, b)
                        if a.dy ~= b.dy then return a.dy > b.dy end
                        return math.abs(a.dx) < math.abs(b.dx)
                    end)

                    local allAllowed = true
                    for _, t in ipairs(activeTiles) do
                        local tx = px + t.dx
                        local ty = py + t.dy
                        if not canBuildAt(tx, ty) or not canPunchAt(tx, ty) then
                            allAllowed = false
                            break
                        end
                    end

                    if not allAllowed then
                        state.autoPnB = false
                        if updatePnBButton then updatePnBButton() end
                        if updateStatusLabel then updateStatusLabel("⛔ Area Terkunci (Tak Ada Akses)!") end
                        break
                    end

                    local hasRight = false
                    local hasLeft = false
                    local needsSweep = false
                    local sweepDir = (state.direction == "Kiri") and -1 or 1

                    for _, t in ipairs(activeTiles) do
                        if t.dx > 0 and (t.dy == 0 or t.dy == -1) then hasRight = true end
                        if t.dx < 0 and (t.dy == 0 or t.dy == -1) then hasLeft = true end
                        if math.abs(t.dx) >= 2 then
                            needsSweep = true
                            sweepDir = (t.dx > 0) and 1 or -1
                        end
                    end

                    -- 🛡️ Jaga karakter selalu tepat di tengah tile (koreksi halus jika bergeser > 0.14)
                    local curLiveX = debug.getupvalue(World.goTo, 1) or (anchorTileX + 0.50)
                    local diffCenter = curLiveX - (anchorTileX + 0.50)
                    if math.abs(diffCenter) > 0.14 and not state.isRelocating then
                        local backKey = (diffCenter > 0) and Enum.KeyCode.A or Enum.KeyCode.D
                        local retTimeout = os.clock() + 0.15
                        sendKeySafe(backKey, true)
                        while os.clock() < retTimeout do
                            local live = debug.getupvalue(World.goTo, 1) or (anchorTileX + 0.50)
                            if math.abs(live - (anchorTileX + 0.50)) <= 0.05 then
                                break
                            end
                            task.wait(0.01)
                        end
                        sendKeySafe(backKey, false)
                        pcall(function()
                            local char = lp.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                            end
                        end)
                        task.wait(0.02)
                    end

                    -- ⚡ 1. TARUH BALOK TARGET SATU PER SATU
                    for _, t in ipairs(activeTiles) do
                        if not state.autoPnB then break end
                        local tx = px + t.dx
                        local ty = py + t.dy
                        local curB = targetWorld and targetWorld[ty] and targetWorld[ty][tx] or 0
                        if curB == 0 and bp:count(state.selectedBlockId) > 0 then
                            if updateStatusLabel then updateStatusLabel("Menaruh: " .. state.selectedBlockName .. " (" .. stock .. ")") end
                            placeTile(tx, ty, state.selectedBlockId)
                        end
                    end

                    -- ⚡ 2. SETELAH SEMUA DITARUH, PUKUL SEMUA BALOK TARGET SECARA PARALEL (SIMULTAN)
                    local bpFist = refreshBackpackReference()
                    if bpFist then
                        bpFist:select(18) -- Fist
                    end

                    -- 🛡️ Pastikan debounce placedAt tetap 0 agar tidak ada penolakan pukulan dari engine
                    if World and World.placedAt then
                        if not getmetatable(World.placedAt.fg) then
                            World.placedAt.fg = setmetatable({}, {__index = function() return 0 end, __newindex = function() end})
                        end
                        if not getmetatable(World.placedAt.bg) then
                            World.placedAt.bg = setmetatable({}, {__index = function() return 0 end, __newindex = function() end})
                        end
                    end

                    local maxPunchCycles = 40
                    local punchCycles = 0
                    while punchCycles < maxPunchCycles and state.autoPnB do
                        local remainingBlocks = 0
                        for _, t in ipairs(activeTiles) do
                            if not state.autoPnB then break end
                            local tx = px + t.dx
                            local ty = py + t.dy
                            local curB = targetWorld and targetWorld[ty] and targetWorld[ty][tx] or 0
                            if curB ~= 0 then
                                remainingBlocks = remainingBlocks + 1
                                if World then
                                    World.actAt = 0
                                    World.punchReady = 0
                                end
                                hitFn(tx, ty, true)

                                if state.autoClaim then
                                    vacuumNearbyDrops()
                                end

                                -- ⚡ Break Delay Snappy
                                task.wait(math.max(0.06, state.punchDelay))
                            end
                        end

                        if remainingBlocks == 0 then
                            break
                        end

                        punchCycles = punchCycles + 1
                    end

                    -- ⚡ 3. Final vacuum memastikan seluruh drop di sekitar terambil
                    if state.autoClaim then
                        vacuumNearbyDrops()
                    end
                end
            end

            task.wait(0.04 + (math.random(10, 25) / 1000))
        end

        sendKeySafe(Enum.KeyCode.A, false)
        sendKeySafe(Enum.KeyCode.D, false)
        state.autoPnB = false
        if updatePnBButton then updatePnBButton() end
        if updateStatusLabel then updateStatusLabel("Status: Berhenti (Idle)") end
        print("[PnB] Auto PnB dihentikan.")
    end)
end

startRejoinWatchdog = function()
    if state.rejoinThread then
        task.cancel(state.rejoinThread)
        state.rejoinThread = nil
    end

    if not state.autoRejoinWorld then return end

    state.rejoinThread = task.spawn(function()
        elevate()
        print("[PnB AutoRejoin] Watchdog Auto Rejoin & Resume aktif.")
        local outsideWorldSeconds = 0

        while state.autoRejoinWorld do
            task.wait(1.0)
            if not state.autoRejoinWorld then break end

            local currentW = getCurrentWorldName()
            if currentW and #currentW > 0 then
                state.savedWorldName = currentW
                genv.PnB_SavedWorld = currentW
            end

            local targetWorld = state.savedWorldName or genv.PnB_SavedWorld

            if targetWorld and #targetWorld > 0 and not state.isRejoining then
                local inTargetWorld = isPlayerCurrentlyInTargetWorld(targetWorld)

                if inTargetWorld then
                    outsideWorldSeconds = 0
                else
                    outsideWorldSeconds = outsideWorldSeconds + 1
                end

                -- Jika terdeteksi di luar target world selama >= 2 detik berturut-turut:
                if outsideWorldSeconds >= 2 and not inTargetWorld then
                    state.isRejoining = true
                    print(string.format("[PnB AutoRejoin] Terdeteksi keluar dari world! Target: %s. Melakukan warp masuk kembali...", targetWorld))

                    if updateStatusLabel then
                        updateStatusLabel(string.format("🔄 Rejoining world %s...", targetWorld))
                    end

                    task.wait(1.5)

                    -- 1. Upaya warp/masuk kembali
                    attemptWarpWorld(targetWorld)

                    -- 2. Tunggu proses loading world selesai (maksimal 20 detik)
                    local timeout = os.clock() + 20
                    while os.clock() < timeout and state.autoRejoinWorld do
                        task.wait(1.0)
                        rehookWorldPointers()
                        if isPlayerCurrentlyInTargetWorld(targetWorld) then
                            break
                        end
                        if math.floor(os.clock()) % 4 == 0 then
                            attemptWarpWorld(targetWorld)
                        end
                    end

                    -- 3. Tunggu 2 detik agar map & karakter ter-render sempurna
                    task.wait(2.0)
                    rehookWorldPointers()

                    -- 4. Jalan dari Spawn menuju Posisi Berdiri (StandPos)
                    local stPos = state.standPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.StandPos)
                    if stPos then
                        print(string.format("[PnB AutoRejoin] Berjalan dari Spawn ke StandPos: (%d, %d)...", stPos.x, stPos.y))
                        if updateStatusLabel then
                            updateStatusLabel(string.format("🚶 Menuju Pos Berdiri (%d, %d)...", stPos.x, stPos.y))
                        end
                        walkToTile(stPos.x, stPos.y, 15.0)
                        task.wait(0.3)
                    end

                    outsideWorldSeconds = 0
                    state.isRejoining = false
                end
            end
        end
        print("[PnB AutoRejoin] Watchdog Rejoin dihentikan.")
    end)
end

state.walkTo = walkToTile
state.startWorker = startPnBWorker
state.rejoinWatchdog = startRejoinWatchdog

-- =========================================================================
-- ⚡ ROBLOX DISCONNECT & SERVER AUTO-RECONNECT
-- =========================================================================
local function setupRobloxAutoReconnect()
    local ts = game:GetService("TeleportService")
    local guiService = game:GetService("GuiService")
    local coreGui = game:GetService("CoreGui")
    local isReconnecting = false

    local function handleDisconnect(reason)
        if isReconnecting then return end
        isReconnecting = true
        print(string.format("[PnB AutoRejoin] Roblox Disconnect Terdeteksi (%s)! Menyiapkan Reconnect ke Server...", reason))

        -- 1. Queue script via queue_on_teleport agar jalan otomatis setelah server baru dimuat
        pcall(function()
            local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
            if qot then
                qot('loadstring(game:HttpGet("https://raw.githubusercontent.com/s160424169/pnb/main/pnb.lua"))()')
            end
        end)

        -- 2. Tunggu 3.5 detik lalu teleport kembali ke PlaceId
        task.wait(3.5)
        pcall(function()
            ts:Teleport(game.PlaceId, lp)
        end)
    end

    -- Listener 1: GuiService ErrorMessageChanged
    pcall(function()
        guiService.ErrorMessageChanged:Connect(function()
            local msg = guiService:GetErrorMessage()
            if msg and #msg > 0 then
                handleDisconnect("GuiService: " .. tostring(msg))
            end
        end)
    end)

    -- Listener 2: CoreGui.RobloxPromptGui ErrorPrompt
    pcall(function()
        local promptGui = coreGui:WaitForChild("RobloxPromptGui", 5)
        if promptGui then
            local overlay = promptGui:WaitForChild("promptOverlay", 5)
            if overlay then
                overlay.ChildAdded:Connect(function(child)
                    if child.Name == "ErrorPrompt" then
                        handleDisconnect("RobloxPromptGui ErrorPrompt")
                    end
                end)
            end
        end
    end)

    -- Listener 3: TeleportService failure
    pcall(function()
        ts.TeleportInitFailed:Connect(function(player, result, errorMessage)
            if player == lp then
                task.wait(4.0)
                pcall(function() ts:Teleport(game.PlaceId, lp) end)
            end
        end)
    end)
end

task.spawn(setupRobloxAutoReconnect)

-- =========================================================================
-- 🖥️ USER INTERFACE (GUI)
-- =========================================================================

local dirBtn = nil
local modeBtn = nil
local pickerModal = nil
local populateBlockPicker = nil

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(55, 60, 72)
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local uiParent = lp:WaitForChild("PlayerGui")
local old = uiParent:FindFirstChild("PlantAndBreakGUI")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "PlantAndBreakGUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = uiParent

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(284, 520)
mainFrame.Position = UDim2.new(0, 70, 0.16, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 60, 72)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

do
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.Text = "🧱 Put & Break (PnB)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

-- 📱 FLOATING PILL (MINIMIZED WIDGET)
local pillWidget = Instance.new("Frame")
pillWidget.Name = "PnBPill"
pillWidget.Size = UDim2.new(0, 180, 0, 32)
pillWidget.Position = UDim2.new(0, 25, 0.40, 0)
pillWidget.BackgroundColor3 = Color3.fromRGB(20, 24, 33)
pillWidget.BorderSizePixel = 0
pillWidget.Active = true
pillWidget.Draggable = true
pillWidget.Visible = false
pillWidget.Parent = sg

Instance.new("UICorner", pillWidget).CornerRadius = UDim.new(0, 16)
local pillStroke = Instance.new("UIStroke", pillWidget)
pillStroke.Color = Color3.fromRGB(168, 85, 247)
pillStroke.Thickness = 1.2

local pillBtn = Instance.new("TextButton", pillWidget)
pillBtn.Size = UDim2.new(1, 0, 1, 0)
pillBtn.BackgroundTransparency = 1
pillBtn.Font = Enum.Font.GothamBold
pillBtn.Text = "🔨 Put & Break [IDLE] ↗"
pillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pillBtn.TextSize = 11

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(24, 24)
minBtn.Position = UDim2.new(1, -58, 0, 5)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 15
minBtn.BackgroundTransparency = 1
minBtn.Parent = header

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    pillWidget.Visible = true
end)

pillBtn.MouseButton1Click:Connect(function()
    pillWidget.Visible = false
    mainFrame.Visible = true
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function()
    elevate()
    sg:Destroy()
    if genv.PnB_Cleanup then
        genv.PnB_Cleanup()
    end
end)
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 18)
statusLabel.Position = UDim2.fromOffset(12, 34)
statusLabel.Text = "Status: Idle (Siap)"
statusLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = mainFrame

updateStatusLabel = function(text)
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = text
    end
end
genv.PnB_UpdateStatusFn = updateStatusLabel

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollContainer"
scrollFrame.Size = UDim2.new(1, 0, 1, -54)
scrollFrame.Position = UDim2.fromOffset(0, 54)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 75, 90)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.CanvasSize = UDim2.new()
scrollFrame.Parent = mainFrame

local pickBtn = Instance.new("TextButton")
pickBtn.Name = "PickItemButton"
pickBtn.Size = UDim2.new(1, -24, 0, 40)
pickBtn.Position = UDim2.fromOffset(12, 4)
pickBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
pickBtn.BorderSizePixel = 0
pickBtn.AutoButtonColor = true
pickBtn.Text = ""
pickBtn.Parent = scrollFrame

local pickCorner = Instance.new("UICorner")
pickCorner.CornerRadius = UDim.new(0, 8)
pickCorner.Parent = pickBtn

local pickStroke = Instance.new("UIStroke")
pickStroke.Color = Color3.fromRGB(60, 65, 80)
pickStroke.Thickness = 1
pickStroke.Parent = pickBtn

local iconContainer = Instance.new("Frame")
iconContainer.Name = "IconSlot"
iconContainer.Size = UDim2.fromOffset(30, 30)
iconContainer.Position = UDim2.fromOffset(8, 6)
iconContainer.BackgroundTransparency = 1
iconContainer.ZIndex = 3
iconContainer.Parent = pickBtn

local pickLabel = Instance.new("TextLabel")
pickLabel.Name = "PickLabel"
pickLabel.Size = UDim2.new(1, -48, 1, 0)
pickLabel.Position = UDim2.fromOffset(44, 0)
pickLabel.Text = "📦 Pilih Item (Block)"
pickLabel.TextColor3 = Color3.fromRGB(229, 231, 235)
pickLabel.Font = Enum.Font.GothamBold
pickLabel.TextSize = 12
pickLabel.TextXAlignment = Enum.TextXAlignment.Left
pickLabel.BackgroundTransparency = 1
pickLabel.Parent = pickBtn

updatePickButton = function()
    elevate()
    ensureItemIcon()
    local bp = refreshBackpackReference()
    if state.selectedBlockId and state.selectedBlockName and bp then
        local stock = 0
        if type(bp.count) == "function" then
            local ok, cnt = pcall(function() return bp:count(state.selectedBlockId) end)
            if ok and type(cnt) == "number" then stock = cnt end
        elseif bp.slots then
            for _, s in ipairs(bp.slots) do
                local sId = s and (s.id or s[1])
                local sN = s and (s.n or s.count or s[2]) or 0
                if sId == state.selectedBlockId then stock = stock + sN end
            end
        end
        pickLabel.Text = string.format("%s (x%d)", state.selectedBlockName, stock)
        pickStroke.Color = Color3.fromRGB(59, 130, 246)

        local currentIconId = iconContainer:GetAttribute("RenderedId")
        if currentIconId ~= state.selectedBlockId or #iconContainer:GetChildren() == 0 then
            iconContainer:ClearAllChildren()
            iconContainer:SetAttribute("RenderedId", state.selectedBlockId)
            pcall(function()
                if ItemIcon and type(ItemIcon.new) == "function" then
                    local ic = ItemIcon.new(iconContainer, UDim2.fromOffset(28, 28), 4)
                    ItemIcon.set(ic, state.selectedBlockId)
                    if ic then
                        local fr = (type(ic) == "table" and ic.frame) or (typeof(ic) == "Instance" and ic)
                        if fr then
                            fr.AnchorPoint = Vector2.new(0.5, 0.5)
                            fr.Position = UDim2.fromScale(0.5, 0.5)
                            fr.Visible = true
                        end
                        if type(ic) == "table" and ic.base then ic.base.Visible = true end
                    end
                end
            end)
        end
    else
        pickLabel.Text = "📦 Pilih Item (Block)"
        pickStroke.Color = Color3.fromRGB(60, 65, 80)
        iconContainer:ClearAllChildren()
        iconContainer:SetAttribute("RenderedId", nil)
    end
end

-- Auto-select item farmable stok terbanyak jika belum ada yang dipilih
task.defer(function()
    local bp = refreshBackpackReference()
    if bp and not state.selectedBlockId then
        local bestSlot = nil
        for _, slot in ipairs(bp.slots) do
            if isPlaceableFarmableItem(slot.id) and slot.n > 0 then
                if not bestSlot or slot.n > bestSlot.n then
                    bestSlot = slot
                end
            end
        end
        if bestSlot then
            local meta = ItemDB[bestSlot.id]
            state.selectedBlockId = bestSlot.id
            state.selectedBlockName = meta and meta.name or ("Item " .. bestSlot.id)
            if updatePickButton then updatePickButton() end
        end
    end
end)

pickerModal = Instance.new("Frame")
pickerModal.Name = "ItemPickerModal"
pickerModal.Size = UDim2.fromOffset(280, 310)
pickerModal.Position = UDim2.new(0, 300, 0.35, 0)
pickerModal.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
pickerModal.BorderSizePixel = 0
pickerModal.Visible = false
pickerModal.Active = true
pickerModal.Draggable = true
pickerModal.Parent = sg

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 8)
pCorner.Parent = pickerModal

local pStroke = Instance.new("UIStroke")
pStroke.Color = Color3.fromRGB(55, 60, 72)
pStroke.Thickness = 1.5
pStroke.Parent = pickerModal

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundTransparency = 1
topBar.Parent = pickerModal

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -64, 1, 0)
modalTitle.Position = UDim2.fromOffset(10, 0)
modalTitle.Text = "📦 Pilih Block / Farmable"
modalTitle.TextColor3 = Color3.fromRGB(220, 225, 235)
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 12
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.BackgroundTransparency = 1
modalTitle.Parent = topBar

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.fromOffset(24, 22)
refreshBtn.Position = UDim2.new(1, -54, 0, 4)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 11
refreshBtn.Parent = topBar
local refCorner = Instance.new("UICorner")
refCorner.CornerRadius = UDim.new(0, 4)
refCorner.Parent = refreshBtn

local modalCloseBtn = Instance.new("TextButton")
modalCloseBtn.Size = UDim2.fromOffset(24, 22)
modalCloseBtn.Position = UDim2.new(1, -28, 0, 4)
modalCloseBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
modalCloseBtn.BorderSizePixel = 0
modalCloseBtn.Text = "✕"
modalCloseBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
modalCloseBtn.Font = Enum.Font.GothamBold
modalCloseBtn.TextSize = 11
modalCloseBtn.Parent = topBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = modalCloseBtn
modalCloseBtn.MouseButton1Click:Connect(function()
    pickerModal.Visible = false
end)

searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -16, 0, 26)
searchBox.Position = UDim2.fromOffset(8, 32)
searchBox.BackgroundColor3 = Color3.fromRGB(28, 31, 40)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "🔍 Cari nama block / farmable..."
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(240, 242, 245)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 11
searchBox.ClearTextOnFocus = false
searchBox.Parent = pickerModal

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 6)
sCorner.Parent = searchBox

local sStroke = Instance.new("UIStroke")
sStroke.Color = Color3.fromRGB(50, 55, 68)
sStroke.Thickness = 1
sStroke.Parent = searchBox

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -66)
scroll.Position = UDim2.fromOffset(8, 62)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 75, 90)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = pickerModal

local grid = Instance.new("UIListLayout")
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Padding = UDim.new(0, 4)
grid.Parent = scroll

populateBlockPicker = function(query)
    elevate()
    ensureItemDB()
    ensureItemIcon()

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end

    local q = query or (searchBox and searchBox.Text) or ""
    local cleanQuery = string.lower(q)("%s+", "")

    local bp = refreshBackpackReference()
    local bagStock = {}
    local bagSlots = {}
    local seenIds = {}

    if bp and bp.slots then
        for _, slot in ipairs(bp.slots) do
            local id = slot and (slot.id or slot[1])
            local cnt = slot and (slot.n or slot.count or slot[2]) or 0
            if id and type(id) == "number" and id > 0 and cnt > 0 then
                bagStock[id] = (bagStock[id] or 0) + cnt
                if not seenIds[id] and isPlaceableFarmableItem(id) then
                    seenIds[id] = true
                    table.insert(bagSlots, id)
                end
            end
        end
    end

    local candidateList = {}
    local addedIds = {}

    local function addCandidate(id, inBagCount, fromDB)
        if not id or addedIds[id] then return end
        if not isPlaceableFarmableItem(id) then return end
        local it = ItemDB and ItemDB[id]
        local rawName = (it and it.name) or ("Item " .. id)
        local cleanName = removeColorAndSymbols(rawName)()("%s+", "")
        local rawLower = string.lower(rawName)("%s+", "")

        -- Filter jika ada pencarian query
        if cleanQuery ~= "" then
            if not string.find(rawLower, cleanQuery, 1, true) and not string.find(cleanName, cleanQuery, 1, true) then
                return
            end
        end

        addedIds[id] = true
        table.insert(candidateList, {
            id = id,
            item = it,
            name = rawName,
            count = inBagCount,
            isBg = it and it.background == true,
            fromDB = fromDB == true
        })
    end

    -- 1. Prioritaskan item yang sedang aktif dipilih pemain di paling atas
    if state.selectedBlockId then
        local curCount = bagStock[state.selectedBlockId] or 0
        addCandidate(state.selectedBlockId, curCount, false)
    end

    -- 2. Masukkan semua item farmable placeable dari tas pemain
    for _, id in ipairs(bagSlots) do
        addCandidate(id, bagStock[id] or 0, false)
    end

    -- 3. Urutkan item dari tas:
    --    - Item aktif terpilih nomor 1
    --    - Item tas dengan stok terbanyak di atas (a.count > b.count)
    table.sort(candidateList, function(a, b)
        if a.id == state.selectedBlockId then return true end
        if b.id == state.selectedBlockId then return false end
        return a.count > b.count
    end)

    -- 4. JIKA pemain mengetik di searchBox dan ingin mencari block lain dari database ItemDB:
    if cleanQuery ~= "" and ItemDB then
        local dbMatches = {}
        for id, it in pairs(ItemDB) do
            if type(id) == "number" and type(it) == "table" and it.name and not addedIds[id] then
                if isPlaceableFarmableItem(id) then
                    local rawName = it.name
                    local cleanName = removeColorAndSymbols(rawName)()("%s+", "")
                    local rawLower = string.lower(rawName)("%s+", "")
                    if string.find(rawLower, cleanQuery, 1, true) or string.find(cleanName, cleanQuery, 1, true) then
                        table.insert(dbMatches, id)
                        if #dbMatches >= 30 then break end
                    end
                end
            end
        end
        table.sort(dbMatches)
        for _, id in ipairs(dbMatches) do
            addCandidate(id, bagStock[id] or 0, true)
        end
    end

    local foundCount = #candidateList
    if foundCount == 0 then
        local emptyL = Instance.new("TextLabel")
        emptyL.Size = UDim2.new(1, -16, 0, 48)
        emptyL.Position = UDim2.fromOffset(8, 8)
        emptyL.BackgroundTransparency = 1
        emptyL.Text = (cleanQuery == "") and "🎒 Tas kosong / tidak ada block farmable!" or ("🔍 Tidak ada block cocok dengan '" .. q .. "'")
        emptyL.TextColor3 = Color3.fromRGB(156, 163, 175)
        emptyL.Font = Enum.Font.Gotham
        emptyL.TextSize = 11
        emptyL.TextWrapped = true
        emptyL.Parent = scroll
        scroll.CanvasSize = UDim2.new(0, 0, 0, 60)
        return
    end

    for _, c in ipairs(candidateList) do
        local id = c.id
        local itemName = c.name
        local isBg = c.isBg
        local count = c.count
        local fromDB = c.fromDB

        local itemBtn = Instance.new("TextButton")
        itemBtn.Name = "Item_" .. id
        itemBtn.Size = UDim2.new(1, 0, 0, 36)
        itemBtn.BackgroundColor3 = (id == state.selectedBlockId) and Color3.fromRGB(38, 52, 75) or Color3.fromRGB(28, 31, 40)
        itemBtn.BorderSizePixel = 0
        itemBtn.AutoButtonColor = true
        itemBtn.Text = ""
        itemBtn.Parent = scroll

        local iCorner = Instance.new("UICorner")
        iCorner.CornerRadius = UDim.new(0, 6)
        iCorner.Parent = itemBtn

        if id == state.selectedBlockId then
            local selStroke = Instance.new("UIStroke")
            selStroke.Color = Color3.fromRGB(59, 130, 246)
            selStroke.Thickness = 1.2
            selStroke.Parent = itemBtn
        end

        local iconF = Instance.new("Frame")
        iconF.Size = UDim2.fromOffset(26, 26)
        iconF.Position = UDim2.fromOffset(5, 5)
        iconF.BackgroundTransparency = 1
        iconF.ZIndex = 3
        iconF.Parent = itemBtn

        pcall(function()
            if ItemIcon and type(ItemIcon.new) == "function" then
                local ic = ItemIcon.new(iconF, UDim2.fromOffset(24, 24), 4)
                ItemIcon.set(ic, id)
                if ic then
                    local fr = (type(ic) == "table" and ic.frame) or (typeof(ic) == "Instance" and ic)
                    if fr then
                        fr.AnchorPoint = Vector2.new(0.5, 0.5)
                        fr.Position = UDim2.fromScale(0.5, 0.5)
                        fr.Visible = true
                    end
                    if type(ic) == "table" and ic.base then ic.base.Visible = true end
                end
            end
        end)

        local nameL = Instance.new("TextLabel")
        nameL.Name = "ItemNameLabel"
        nameL.Size = UDim2.new(1, -125, 1, 0)
        nameL.Position = UDim2.fromOffset(36, 0)
        nameL.Text = itemName
        nameL.TextColor3 = count > 0 and Color3.fromRGB(243, 244, 246) or Color3.fromRGB(160, 165, 175)
        nameL.Font = Enum.Font.GothamMedium
        nameL.TextSize = 11
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.BackgroundTransparency = 1
        nameL.Parent = itemBtn

        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.fromOffset(28, 16)
        badge.Position = UDim2.new(1, -78, 0.5, -8)
        badge.Text = isBg and "BG" or "BLK"
        badge.TextColor3 = isBg and Color3.fromRGB(192, 132, 252) or Color3.fromRGB(56, 189, 248)
        badge.BackgroundColor3 = isBg and Color3.fromRGB(48, 28, 64) or Color3.fromRGB(24, 44, 64)
        badge.Font = Enum.Font.GothamBold
        badge.TextSize = 8
        badge.Parent = itemBtn
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = badge

        local countL = Instance.new("TextLabel")
        countL.Name = "ItemCountLabel"
        countL.Size = UDim2.fromOffset(42, 36)
        countL.Position = UDim2.new(1, -46, 0, 0)
        countL.Text = fromDB and "DB" or ("x" .. count)
        countL.TextColor3 = fromDB and Color3.fromRGB(120, 125, 140) or (count > 0 and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(239, 68, 68))
        countL.Font = Enum.Font.GothamBold
        countL.TextSize = 11
        countL.TextXAlignment = Enum.TextXAlignment.Right
        countL.BackgroundTransparency = 1
        countL.Parent = itemBtn

        itemBtn.MouseButton1Click:Connect(function()
            elevate()
            state.selectedBlockId = id
            state.selectedBlockName = itemName
            local matchSeed = findMatchingSeedId(id)
            state.targetSeedId = matchSeed
            if genv.AutoBreakCustom then
                genv.AutoBreakCustom.TargetSeedID = matchSeed and tostring(matchSeed) or nil
            end
            if seedIdInput then
                seedIdInput.Text = matchSeed and tostring(matchSeed) or ""
            end
            if updateSeedUI then updateSeedUI() end
            if updatePickButton then updatePickButton() end
            pickerModal.Visible = false
        end)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, foundCount * 40 + 10)
end

searchBox:GetPropertyChangedSignal("Text")(function()
    populateBlockPicker(searchBox.Text)
end)

refreshBtn.MouseButton1Click:Connect(function()
    elevate()
    refreshBackpackReference()
    populateBlockPicker(searchBox.Text)
end)

-- Auto sync update jika modal picker sedang terbuka
task.spawn(function()
    while sg and sg.Parent do
        if pickerModal and pickerModal.Visible and populateBlockPicker then
            refreshBackpackReference()
            populateBlockPicker(searchBox and searchBox.Text or "")
        end
        if updatePickButton then
            updatePickButton()
        end
        task.wait(1.5)
    end
end)

pickBtn.MouseButton1Click:Connect(function()
    elevate()
    pickerModal.Visible = not pickerModal.Visible
    if pickerModal.Visible then
        pickerModal.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 290, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
        refreshBackpackReference()
        populateBlockPicker(searchBox and searchBox.Text or "")
    end
end)

do
local pnbBtn = Instance.new("TextButton")
pnbBtn.Name = "AutoPnBButton"
pnbBtn.Size = UDim2.new(1, -24, 0, 36)
pnbBtn.Position = UDim2.fromOffset(12, 48)
pnbBtn.BackgroundColor3 = Color3.fromRGB(39, 42, 54)
pnbBtn.BorderSizePixel = 0
pnbBtn.AutoButtonColor = true
pnbBtn.Text = "▶ START Auto PnB"
pnbBtn.TextColor3 = Color3.fromRGB(243, 244, 246)
pnbBtn.Font = Enum.Font.GothamBold
pnbBtn.TextSize = 13
pnbBtn.Parent = scrollFrame

local pnbCorner = Instance.new("UICorner")
pnbCorner.CornerRadius = UDim.new(0, 8)
pnbCorner.Parent = pnbBtn

updatePnBButton = function()
    if state.autoPnB then
        pnbBtn.Text = "⏹ STOP Put & Break"
        pnbBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        pnbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        pnbBtn.Text = "▶ START Put & Break"
        pnbBtn.BackgroundColor3 = Color3.fromRGB(39, 42, 54)
        pnbBtn.TextColor3 = Color3.fromRGB(243, 244, 246)
    end
end

pnbBtn.MouseButton1Click:Connect(function()
    elevate()
    if not state.selectedBlockId then
        updateStatusLabel("Pilih item block terlebih dahulu!")
        pickerModal.Visible = true
        refreshBackpackReference()
        populateBlockPicker()
        return
    end

    state.autoPnB = not state.autoPnB
    updatePnBButton()

    if state.autoPnB then
        local curW = getCurrentWorldName()
        if curW and #curW > 0 then
            state.savedWorldName = curW
            genv.PnB_SavedWorld = curW
            if genv.AutoBreakCustom then genv.AutoBreakCustom.SavedWorld = curW end
        end
        state.resumePnBOnRejoin = true
        if state.autoRejoinWorld and not state.rejoinThread and startRejoinWatchdog then
            startRejoinWatchdog()
        end
        startPnBWorker()
    else
        state.resumePnBOnRejoin = false
        if state.pnbThread then
            task.cancel(state.pnbThread)
            state.pnbThread = nil
        end
        sendKeySafe(Enum.KeyCode.A, false)
        sendKeySafe(Enum.KeyCode.D, false)
        updateStatusLabel("Status: Berhenti (Idle)")
    end
end)

local claimBtn = Instance.new("TextButton")
claimBtn.Name = "AutoClaimButton"
claimBtn.Size = UDim2.new(1, -24, 0, 36)
claimBtn.Position = UDim2.fromOffset(12, 88)
claimBtn.BackgroundColor3 = Color3.fromRGB(39, 42, 54)
claimBtn.BorderSizePixel = 0
claimBtn.AutoButtonColor = true
claimBtn.Text = "💎 Auto Claim: OFF"
claimBtn.TextColor3 = Color3.fromRGB(209, 213, 219)
claimBtn.Font = Enum.Font.GothamBold
claimBtn.TextSize = 13
claimBtn.Parent = scrollFrame

local claimCorner = Instance.new("UICorner")
claimCorner.CornerRadius = UDim.new(0, 8)
claimCorner.Parent = claimBtn

local function updateClaimButton()
    if state.autoClaim then
        claimBtn.Text = "✨ Auto Claim: ON"
        claimBtn.BackgroundColor3 = Color3.fromRGB(14, 165, 233)
        claimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        claimBtn.Text = "💎 Auto Claim: OFF"
        claimBtn.BackgroundColor3 = Color3.fromRGB(39, 42, 54)
        claimBtn.TextColor3 = Color3.fromRGB(209, 213, 219)
    end
end

claimBtn.MouseButton1Click:Connect(function()
    elevate()
    state.autoClaim = not state.autoClaim
    updateClaimButton()

    if state.autoClaim then
        print("[PnB] Auto Claim Aktif.")
        startClaimWorker()
        task.spawn(vacuumNearbyDrops)
    else
        if state.claimThread then
            task.cancel(state.claimThread)
            state.claimThread = nil
        end
        print("[PnB] Auto Claim Dimatikan.")
    end
end)
end

do
local optFrame = Instance.new("Frame")
optFrame.Size = UDim2.new(1, -24, 0, 30)
optFrame.Position = UDim2.fromOffset(12, 128)
optFrame.BackgroundTransparency = 1
optFrame.Parent = scrollFrame

local dirBtn = Instance.new("TextButton")
dirBtn.Size = UDim2.new(0.5, -4, 1, 0)
dirBtn.Position = UDim2.fromOffset(0, 0)
dirBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
dirBtn.BorderSizePixel = 0
dirBtn.Text = "Arah: Kanan ▶"
dirBtn.TextColor3 = Color3.fromRGB(209, 213, 219)
dirBtn.Font = Enum.Font.GothamMedium
dirBtn.TextSize = 11
dirBtn.Parent = optFrame
local dirCorner = Instance.new("UICorner")
dirCorner.CornerRadius = UDim.new(0, 6)
dirCorner.Parent = dirBtn

local refreshMatrixUI = nil

local PNB_MODES = {
    "1-Tile",
    "2-Far",
    "3-Block",
    "6-Block",
    "Custom"
}

local function applyModePreset()
    local dirNum = (state.direction == "Kiri") and -1 or 1
    if state.mode == "3-Block" then
        state.customTiles = {
            [dirNum .. ",0"] = true,
            [dirNum .. ",-1"] = true,
            [dirNum .. ",-2"] = true
        }
    elseif state.mode == "6-Block" then
        state.customTiles = {
            [dirNum .. ",0"] = true,
            [dirNum .. ",-1"] = true,
            [dirNum .. ",-2"] = true,
            [(dirNum * 2) .. ",0"] = true,
            [(dirNum * 2) .. ",-1"] = true,
            [(dirNum * 2) .. ",-2"] = true
        }
    end
end

dirBtn.MouseButton1Click:Connect(function()
    elevate()
    if state.direction == "Kanan" then
        state.direction = "Kiri"
        dirBtn.Text = "Arah: ◀ Kiri"
    else
        state.direction = "Kanan"
        dirBtn.Text = "Arah: Kanan ▶"
    end
    applyModePreset()
    refreshMatrixUI()
end)

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.5, -4, 1, 0)
modeBtn.Position = UDim2.new(0.5, 4, 0, 0)
modeBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
modeBtn.BorderSizePixel = 0
modeBtn.Text = "Mode: " .. state.mode
modeBtn.TextColor3 = Color3.fromRGB(209, 213, 219)
modeBtn.Font = Enum.Font.GothamMedium
modeBtn.TextSize = 11
modeBtn.Parent = optFrame
local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 6)
modeCorner.Parent = modeBtn

modeBtn.MouseButton1Click:Connect(function()
    elevate()
    local curIdx = 1
    for idx, m in ipairs(PNB_MODES) do
        if state.mode == m then curIdx = idx; break end
    end
    local nextIdx = (curIdx % #PNB_MODES) + 1
    state.mode = PNB_MODES[nextIdx]
    modeBtn.Text = "Mode: " .. state.mode
    applyModePreset()
    refreshMatrixUI()
end)

-- 🔲 VISUAL TILE SELECTOR (Khusus Radius 1-Blok & 100% Diam / Zero Macro)
local matrixLabel = Instance.new("TextLabel")
matrixLabel.Size = UDim2.new(1, -24, 0, 18)
matrixLabel.Position = UDim2.fromOffset(12, 164)
matrixLabel.Text = "Pilih Tile PnB (Radius Maks 1 Blok):"
matrixLabel.TextColor3 = Color3.fromRGB(240, 242, 248)
matrixLabel.Font = Enum.Font.GothamMedium
matrixLabel.TextSize = 11
matrixLabel.TextXAlignment = Enum.TextXAlignment.Left
matrixLabel.BackgroundTransparency = 1
matrixLabel.Parent = scrollFrame

local matrixContainer = Instance.new("Frame")
matrixContainer.Name = "MatrixContainer"
matrixContainer.Size = UDim2.new(1, -24, 0, 162)
matrixContainer.Position = UDim2.fromOffset(12, 184)
matrixContainer.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
matrixContainer.BorderSizePixel = 0
matrixContainer.Parent = scrollFrame

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 8)
mCorner.Parent = matrixContainer

local mStroke = Instance.new("UIStroke")
mStroke.Color = Color3.fromRGB(52, 56, 70)
mStroke.Thickness = 1.2
mStroke.Parent = matrixContainer

local cellButtons = {}
local cellDefaultLabels = {
    ["-1,-2"] = "Kiri\nAtas",
    ["0,-2"]  = "Tengah\nAtas",
    ["1,-2"]  = "Kanan\nAtas",
    ["-1,-1"] = "Kiri\nTengah",
    ["0,-1"]  = "👤 Badan\n(Non-Solid)",
    ["1,-1"]  = "Kanan\nTengah",
    ["-1,0"]  = "Kiri\nBawah",
    ["0,0"]   = "👤 Kaki\n(Non-Solid)",
    ["1,0"]   = "Kanan\nBawah"
}

refreshMatrixUI = function()
    for key, btn in pairs(cellButtons) do
        if state.customTiles[key] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 230, 130)
            btn.Text = "✓"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 20
        else
            if key == "0,-1" or key == "0,0" then
                btn.BackgroundColor3 = Color3.fromRGB(34, 42, 56)
                btn.Text = cellDefaultLabels[key] or ""
                btn.TextColor3 = Color3.fromRGB(130, 175, 220)
                btn.TextSize = 9
            else
                btn.BackgroundColor3 = Color3.fromRGB(44, 48, 62)
                btn.Text = cellDefaultLabels[key] or ""
                btn.TextColor3 = Color3.fromRGB(150, 155, 170)
                btn.TextSize = 10
            end
        end
    end
end

local function createTileButton(key, pos, size)
    local btn = Instance.new("TextButton")
    btn.Name = "Tile_" .. key
    btn.Position = pos
    btn.Size = size
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.GothamBold

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = btn

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(60, 65, 82)
    cStroke.Thickness = 1
    cStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        elevate()
        state.customTiles[key] = not state.customTiles[key]
        if not state.customTiles[key] then
            state.customTiles[key] = nil
        end
        state.mode = "Custom (1-Blok)"
        if modeBtn then modeBtn.Text = "Mode: Custom (1-Blok)" end
        refreshMatrixUI()
    end)

    btn.Parent = matrixContainer
    cellButtons[key] = btn
    return btn
end

-- 🔲 3x3 TILE MATRIX SELECTOR (9 Tile Bebas Dipilih: 3 Atas Sejajar, Samping, & Tengah Non-Solid)
-- Baris 1: 3 Di Atas Kepala Sejajar (dy = -2)
createTileButton("-1,-2", UDim2.fromOffset(8, 8), UDim2.fromOffset(76, 44))
createTileButton("0,-2",  UDim2.fromOffset(92, 8), UDim2.fromOffset(76, 44))
createTileButton("1,-2",  UDim2.fromOffset(176, 8), UDim2.fromOffset(76, 44))

-- Baris 2: Ketinggian Kepala / Tengah (dy = -1) - Termasuk Tengah [0,-1] untuk Sugarcane/FishTank/Chandelier
createTileButton("-1,-1", UDim2.fromOffset(8, 58), UDim2.fromOffset(76, 44))
createTileButton("0,-1",  UDim2.fromOffset(92, 58), UDim2.fromOffset(76, 44))
createTileButton("1,-1",  UDim2.fromOffset(176, 58), UDim2.fromOffset(76, 44))

-- Baris 3: Ketinggian Kaki / Bawah (dy = 0) - Termasuk Tengah [0,0] untuk Non-Solid Items
createTileButton("-1,0",  UDim2.fromOffset(8, 108), UDim2.fromOffset(76, 44))
createTileButton("0,0",   UDim2.fromOffset(92, 108), UDim2.fromOffset(76, 44))
createTileButton("1,0",   UDim2.fromOffset(176, 108), UDim2.fromOffset(76, 44))

refreshMatrixUI()

-- 🎛️ PRESET BUTTONS (Kanan, Kiri, Atas (3), 6-Tile, Reset)
local presetFrame = Instance.new("Frame")
presetFrame.Name = "PresetFrame"
presetFrame.Size = UDim2.new(1, -24, 0, 28)
presetFrame.Position = UDim2.fromOffset(12, 354)
presetFrame.BackgroundTransparency = 1
presetFrame.Parent = scrollFrame

local function createPresetButton(name, xOffset, width, onClick)
    local pBtn = Instance.new("TextButton")
    pBtn.Name = "Preset_" .. name
    pBtn.Size = UDim2.fromOffset(width, 28)
    pBtn.Position = UDim2.fromOffset(xOffset, 0)
    pBtn.BackgroundColor3 = Color3.fromRGB(48, 52, 66)
    pBtn.BorderSizePixel = 0
    pBtn.Text = name
    pBtn.TextColor3 = Color3.fromRGB(240, 242, 248)
    pBtn.Font = Enum.Font.GothamBold
    pBtn.TextSize = 10
    pBtn.Parent = presetFrame

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 6)
    pCorner.Parent = pBtn

    pBtn.MouseButton1Click:Connect(function()
        elevate()
        onClick()
    end)
    return pBtn
end

createPresetButton("Kanan (2)", 0, 48, function()
    table.clear(state.customTiles)
    state.customTiles["1,0"] = true
    state.customTiles["1,-1"] = true
    state.direction = "Kanan"
    state.mode = "Custom (1-Blok)"
    if dirBtn then dirBtn.Text = "Arah: Kanan ▶" end
    if modeBtn then modeBtn.Text = "Mode: Custom (1-Blok)" end
    refreshMatrixUI()
end)

createPresetButton("Kiri (2)", 52, 48, function()
    table.clear(state.customTiles)
    state.customTiles["-1,0"] = true
    state.customTiles["-1,-1"] = true
    state.direction = "Kiri"
    state.mode = "Custom (1-Blok)"
    if dirBtn then dirBtn.Text = "Arah: ◀ Kiri" end
    if modeBtn then modeBtn.Text = "Mode: Custom (1-Blok)" end
    refreshMatrixUI()
end)

createPresetButton("Atas (3)", 104, 48, function()
    table.clear(state.customTiles)
    state.customTiles["-1,-2"] = true
    state.customTiles["0,-2"] = true
    state.customTiles["1,-2"] = true
    state.mode = "Custom (1-Blok)"
    if modeBtn then modeBtn.Text = "Mode: Custom (1-Blok)" end
    refreshMatrixUI()
end)

createPresetButton("6-Tile", 156, 48, function()
    table.clear(state.customTiles)
    state.customTiles["-1,-2"] = true
    state.customTiles["0,-2"] = true
    state.customTiles["1,-2"] = true
    state.customTiles["1,-1"] = true
    state.customTiles["1,0"] = true
    state.customTiles["-1,-1"] = true
    state.mode = "Custom (1-Blok)"
    if modeBtn then modeBtn.Text = "Mode: Custom (1-Blok)" end
    refreshMatrixUI()
end)

createPresetButton("Reset", 208, 48, function()
    table.clear(state.customTiles)
    refreshMatrixUI()
end)

-- ⚡ PENGATURAN KECEPATAN PUKUL (BREAK SPEED OPTIONS)
local speedFrame = Instance.new("Frame")
speedFrame.Name = "SpeedFrame"
speedFrame.Size = UDim2.new(1, -24, 0, 68)
speedFrame.Position = UDim2.fromOffset(12, 388)
speedFrame.BackgroundColor3 = Color3.fromRGB(30, 33, 44)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = scrollFrame
local spCorner = Instance.new("UICorner", speedFrame)
spCorner.CornerRadius = UDim.new(0, 6)
local spStroke = Instance.new("UIStroke", speedFrame)
spStroke.Color = Color3.fromRGB(56, 189, 248)
spStroke.Thickness = 1.0

local spTitle = Instance.new("TextLabel", speedFrame)
spTitle.Size = UDim2.new(1, -12, 0, 16)
spTitle.Position = UDim2.fromOffset(6, 4)
spTitle.Text = "⚡ Pilihan Kecepatan Break (Punch Delay):"
spTitle.TextColor3 = Color3.fromRGB(240, 242, 248)
spTitle.Font = Enum.Font.GothamBold
spTitle.TextSize = 10
spTitle.TextXAlignment = Enum.TextXAlignment.Left
spTitle.BackgroundTransparency = 1

local spRow1 = Instance.new("Frame", speedFrame)
spRow1.Size = UDim2.new(1, -12, 0, 20)
spRow1.Position = UDim2.fromOffset(6, 20)
spRow1.BackgroundTransparency = 1

local updateSpeedLabel = nil

local function createSpeedPreset(txt, val, xPos, width)
    local btn = Instance.new("TextButton", spRow1)
    btn.Size = UDim2.fromOffset(width, 20)
    btn.Position = UDim2.fromOffset(xPos, 0)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(44, 49, 64)
    btn.TextColor3 = Color3.fromRGB(220, 230, 245)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        elevate()
        state.punchDelay = val
        if updateSpeedLabel then updateSpeedLabel() end
    end)
    return btn
end

createSpeedPreset("⚡ 0.10s", 0.10, 0, 56)
createSpeedPreset("🚀 0.14s", 0.14, 60, 56)
createSpeedPreset("🎯 0.18s", 0.18, 120, 56)
createSpeedPreset("🛡️ 0.24s", 0.24, 180, 56)

local spRow2 = Instance.new("Frame", speedFrame)
spRow2.Size = UDim2.new(1, -12, 0, 22)
spRow2.Position = UDim2.fromOffset(6, 42)
spRow2.BackgroundTransparency = 1

local spMinus = Instance.new("TextButton", spRow2)
spMinus.Size = UDim2.fromOffset(24, 20)
spMinus.Position = UDim2.fromOffset(0, 1)
spMinus.Text = "−"
spMinus.BackgroundColor3 = Color3.fromRGB(45, 52, 68)
spMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
spMinus.Font = Enum.Font.GothamBold
spMinus.TextSize = 13
Instance.new("UICorner", spMinus).CornerRadius = UDim.new(0, 4)

local speedValLabel = Instance.new("TextLabel", spRow2)
speedValLabel.Size = UDim2.new(1, -56, 1, 0)
speedValLabel.Position = UDim2.fromOffset(28, 0)
speedValLabel.Text = string.format("Break Delay: %.2fs (Cepat)", state.punchDelay)
speedValLabel.TextColor3 = Color3.fromRGB(56, 189, 248)
speedValLabel.Font = Enum.Font.GothamBold
speedValLabel.TextSize = 10
speedValLabel.BackgroundTransparency = 1

local spPlus = Instance.new("TextButton", spRow2)
spPlus.Size = UDim2.fromOffset(24, 20)
spPlus.Position = UDim2.new(1, -24, 0, 1)
spPlus.Text = "+"
spPlus.BackgroundColor3 = Color3.fromRGB(45, 52, 68)
spPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
spPlus.Font = Enum.Font.GothamBold
spPlus.TextSize = 13
Instance.new("UICorner", spPlus).CornerRadius = UDim.new(0, 4)

updateSpeedLabel = function()
    local note
    if state.punchDelay <= 0.10 then
        note = "Super Cepat"
    elseif state.punchDelay <= 0.14 then
        note = "Cepat"
    elseif state.punchDelay <= 0.18 then
        note = "Normal"
    else
        note = "Aman"
    end
    speedValLabel.Text = string.format("Break Delay: %.2fs (%s)", state.punchDelay, note)
end

spMinus.MouseButton1Click:Connect(function()
    elevate()
    state.punchDelay = math.max(0.06, state.punchDelay - 0.02)
    if updateSpeedLabel then updateSpeedLabel() end
end)

spPlus.MouseButton1Click:Connect(function()
    elevate()
    state.punchDelay = math.min(0.40, state.punchDelay + 0.02)
    if updateSpeedLabel then updateSpeedLabel() end
end)
end

-- =========================================================================
-- 📍 FUNGSI PENGAMBIL POSISI TILE AKURAT (Shared across all UI sections)
-- =========================================================================
local function getAccurateTilePos()
    elevate()
    local w = World or findWorldFromAnySource()
    if w and w.goTo then
        local ok1, curX = pcall(debug.getupvalue, w.goTo, 1)
        local ok2, curY = pcall(debug.getupvalue, w.goTo, 2)
        if ok1 and ok2 and typeof(curX) == "number" and typeof(curY) == "number" then
            return math.floor(curX), math.floor(curY)
        end
    end
    if hitFn then
        for _, up in ipairs(debug.getupvalues(hitFn)) do
            if type(up) == "table" and rawget(up, "goTo") then
                local ok1, curX = pcall(debug.getupvalue, up.goTo, 1)
                local ok2, curY = pcall(debug.getupvalue, up.goTo, 2)
                if ok1 and ok2 and typeof(curX) == "number" and typeof(curY) == "number" then
                    return math.floor(curX), math.floor(curY)
                end
            end
        end
    end
    local char = lp.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if hrp then
        local ts = TileSize or 64
        return math.floor(hrp.Position.X / ts), math.floor(-hrp.Position.Y / ts)
    end
    return 0, 0
end

-- ================== FITUR AUTO DROP SEED ==================
do
local seedDropFrame = Instance.new("Frame")
seedDropFrame.Name = "SeedDropFrame"
seedDropFrame.Size = UDim2.new(1, -24, 0, 48)
seedDropFrame.Position = UDim2.fromOffset(12, 444)
seedDropFrame.BackgroundTransparency = 1
seedDropFrame.Parent = scrollFrame

local seedDropBtn = Instance.new("TextButton")
seedDropBtn.Size = UDim2.new(0.38, -4, 0, 22)
seedDropBtn.Position = UDim2.new(0, 0, 0, 0)
seedDropBtn.Text = "🌱 Set Pos Drop"
seedDropBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
seedDropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
seedDropBtn.Font = Enum.Font.GothamBold
seedDropBtn.TextSize = 10
seedDropBtn.Parent = seedDropFrame
local sCorner1 = Instance.new("UICorner")
sCorner1.CornerRadius = UDim.new(0, 4)
sCorner1.Parent = seedDropBtn

seedXInput = Instance.new("TextBox")
seedXInput.Size = UDim2.new(0.18, -3, 0, 22)
seedXInput.Position = UDim2.new(0.38, 0, 0, 0)
seedXInput.PlaceholderText = "X"
seedXInput.Text = state.seedDropPos and tostring(state.seedDropPos.x) or ""
seedXInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
seedXInput.TextColor3 = Color3.fromRGB(255, 255, 255)
seedXInput.Font = Enum.Font.GothamMedium
seedXInput.TextSize = 10
seedXInput.Parent = seedDropFrame
local sCornerX = Instance.new("UICorner")
sCornerX.CornerRadius = UDim.new(0, 4)
sCornerX.Parent = seedXInput

seedYInput = Instance.new("TextBox")
seedYInput.Size = UDim2.new(0.18, -3, 0, 22)
seedYInput.Position = UDim2.new(0.56, 0, 0, 0)
seedYInput.PlaceholderText = "Y"
seedYInput.Text = state.seedDropPos and tostring(state.seedDropPos.y) or ""
seedYInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
seedYInput.TextColor3 = Color3.fromRGB(255, 255, 255)
seedYInput.Font = Enum.Font.GothamMedium
seedYInput.TextSize = 10
seedYInput.Parent = seedDropFrame
local sCornerY = Instance.new("UICorner")
sCornerY.CornerRadius = UDim.new(0, 4)
sCornerY.Parent = seedYInput

seedIdInput = Instance.new("TextBox")
seedIdInput.Size = UDim2.new(0.26, -2, 0, 22)
seedIdInput.Position = UDim2.new(0.74, 2, 0, 0)
seedIdInput.PlaceholderText = "Seed ID"
seedIdInput.Text = tostring(state.targetSeedId or (genv.AutoBreakCustom and genv.AutoBreakCustom.TargetSeedID) or "")
seedIdInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
seedIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
seedIdInput.Font = Enum.Font.GothamMedium
seedIdInput.TextSize = 10
seedIdInput.Parent = seedDropFrame
local sCorner2 = Instance.new("UICorner")
sCorner2.CornerRadius = UDim.new(0, 4)
sCorner2.Parent = seedIdInput

local seedPosLabel = Instance.new("TextLabel")
seedPosLabel.Size = UDim2.new(1, 0, 0, 18)
seedPosLabel.Position = UDim2.fromOffset(0, 26)
seedPosLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
seedPosLabel.TextSize = 9
seedPosLabel.Font = Enum.Font.GothamMedium
seedPosLabel.BackgroundTransparency = 1
seedPosLabel.TextXAlignment = Enum.TextXAlignment.Left
seedPosLabel.Parent = seedDropFrame

updateSeedUI = function()
    local sp = state.seedDropPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.SeedDropPos)
    local sId = state.targetSeedId or (genv.AutoBreakCustom and genv.AutoBreakCustom.TargetSeedID)
    local seedName = (sId and ItemDB and ItemDB[tonumber(sId)]) and (" (" .. removeColorAndSymbols(ItemDB[tonumber(sId)].name) .. ")") or ""
    if sp then
        seedPosLabel.Text = string.format("Drop Seed: (%d,%d)%s | Auto-drop tas >= %d", sp.x, sp.y, seedName, state.seedDropThreshold or 195)
        if seedXInput and not seedXInput:IsFocused() then seedXInput.Text = tostring(sp.x) end
        if seedYInput and not seedYInput:IsFocused() then seedYInput.Text = tostring(sp.y) end
    else
        seedPosLabel.Text = string.format("Drop Seed: Belum Diatur%s (Ketik X,Y / Klik Set)", seedName)
    end
    if seedIdInput and not seedIdInput:IsFocused() then
        seedIdInput.Text = sId and tostring(sId) or ""
    end
end
updateSeedUI()

seedDropBtn.MouseButton1Click:Connect(function()
    elevate()
    local tx, ty = getAccurateTilePos()
    state.seedDropPos = {x = tx, y = ty}
    if genv.AutoBreakCustom then
        genv.AutoBreakCustom.SeedDropPos = state.seedDropPos
    end
    updateSeedUI()
    if updateStatusLabel then updateStatusLabel(string.format("🌱 Pos Drop Seed diset: (%d, %d)", tx, ty)) end
    print(string.format("[PnB UI] 🌱 Pos Drop Seed diatur ke: (%d, %d)", tx, ty))
end)

seedIdInput.FocusLost:Connect(function()
    elevate()
    local val = seedIdInput.Text
    local num = tonumber(val)
    state.targetSeedId = num
    if genv.AutoBreakCustom then
        genv.AutoBreakCustom.TargetSeedID = val
    end
    updateSeedUI()
end)

local function applyManualSeed()
    elevate()
    local nx = tonumber(seedXInput.Text)
    local ny = tonumber(seedYInput.Text)
    if nx and ny then
        state.seedDropPos = {x = math.floor(nx), y = math.floor(ny)}
        if genv.AutoBreakCustom then genv.AutoBreakCustom.SeedDropPos = state.seedDropPos end
        updateSeedUI()
    end
end
seedXInput.FocusLost:Connect(applyManualSeed)
seedYInput.FocusLost:Connect(applyManualSeed)
end

-- ================== FITUR AUTO RESTOCK & DOOR POS ==================
do
local restockFrame = Instance.new("Frame")
restockFrame.Name = "RestockFrame"
restockFrame.Size = UDim2.new(1, -24, 0, 78)
restockFrame.Position = UDim2.fromOffset(12, 500)
restockFrame.BackgroundTransparency = 1
restockFrame.Parent = scrollFrame

-- Row 1: Posisi Berdiri
local standBtn = Instance.new("TextButton")
standBtn.Size = UDim2.new(0.48, -4, 0, 22)
standBtn.Position = UDim2.new(0, 0, 0, 0)
standBtn.Text = "📍 Set Pos Berdiri"
standBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
standBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
standBtn.Font = Enum.Font.GothamBold
standBtn.TextSize = 10
standBtn.Parent = restockFrame
local rCorner1 = Instance.new("UICorner")
rCorner1.CornerRadius = UDim.new(0, 4)
rCorner1.Parent = standBtn

standXInput = Instance.new("TextBox")
standXInput.Size = UDim2.new(0.26, -3, 0, 22)
standXInput.Position = UDim2.new(0.48, 0, 0, 0)
standXInput.PlaceholderText = "X"
standXInput.Text = state.standPos and tostring(state.standPos.x) or ""
standXInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
standXInput.TextColor3 = Color3.fromRGB(255, 255, 255)
standXInput.Font = Enum.Font.GothamMedium
standXInput.TextSize = 10
standXInput.Parent = restockFrame
local stCornerX = Instance.new("UICorner")
stCornerX.CornerRadius = UDim.new(0, 4)
stCornerX.Parent = standXInput

standYInput = Instance.new("TextBox")
standYInput.Size = UDim2.new(0.26, -3, 0, 22)
standYInput.Position = UDim2.new(0.74, 0, 0, 0)
standYInput.PlaceholderText = "Y"
standYInput.Text = state.standPos and tostring(state.standPos.y) or ""
standYInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
standYInput.TextColor3 = Color3.fromRGB(255, 255, 255)
standYInput.Font = Enum.Font.GothamMedium
standYInput.TextSize = 10
standYInput.Parent = restockFrame
local stCornerY = Instance.new("UICorner")
stCornerY.CornerRadius = UDim.new(0, 4)
stCornerY.Parent = standYInput

-- Row 2: Posisi Stok
local stockBtn = Instance.new("TextButton")
stockBtn.Size = UDim2.new(0.48, -4, 0, 22)
stockBtn.Position = UDim2.new(0, 0, 0, 26)
stockBtn.Text = "📦 Set Pos Stok"
stockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
stockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stockBtn.Font = Enum.Font.GothamBold
stockBtn.TextSize = 10
stockBtn.Parent = restockFrame
local rCorner2 = Instance.new("UICorner")
rCorner2.CornerRadius = UDim.new(0, 4)
rCorner2.Parent = stockBtn

stockXInput = Instance.new("TextBox")
stockXInput.Size = UDim2.new(0.26, -3, 0, 22)
stockXInput.Position = UDim2.new(0.48, 0, 0, 26)
stockXInput.PlaceholderText = "X"
stockXInput.Text = state.stockPos and tostring(state.stockPos.x) or ""
stockXInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
stockXInput.TextColor3 = Color3.fromRGB(255, 255, 255)
stockXInput.Font = Enum.Font.GothamMedium
stockXInput.TextSize = 10
stockXInput.Parent = restockFrame
local skCornerX = Instance.new("UICorner")
skCornerX.CornerRadius = UDim.new(0, 4)
skCornerX.Parent = stockXInput

stockYInput = Instance.new("TextBox")
stockYInput.Size = UDim2.new(0.26, -3, 0, 22)
stockYInput.Position = UDim2.new(0.74, 0, 0, 26)
stockYInput.PlaceholderText = "Y"
stockYInput.Text = state.stockPos and tostring(state.stockPos.y) or ""
stockYInput.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
stockYInput.TextColor3 = Color3.fromRGB(255, 255, 255)
stockYInput.Font = Enum.Font.GothamMedium
stockYInput.TextSize = 10
stockYInput.Parent = restockFrame
local skCornerY = Instance.new("UICorner")
skCornerY.CornerRadius = UDim.new(0, 4)
skCornerY.Parent = stockYInput

-- Row 3: Label Status Posisi
local posStatusLabel = Instance.new("TextLabel")
posStatusLabel.Size = UDim2.new(1, 0, 0, 18)
posStatusLabel.Position = UDim2.fromOffset(0, 52)
posStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
posStatusLabel.TextSize = 9
posStatusLabel.Font = Enum.Font.GothamMedium
posStatusLabel.BackgroundTransparency = 1
posStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
posStatusLabel.Parent = restockFrame

updatePosUI = function()
    local sp = state.standPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.StandPos)
    local st = state.stockPos or (genv.AutoBreakCustom and genv.AutoBreakCustom.StockPos)
    posStatusLabel.Text = string.format("Berdiri:%s | Stok:%s", sp and string.format("(%d,%d)", sp.x, sp.y) or "---", st and string.format("(%d,%d)", st.x, st.y) or "---")
    if sp and standXInput and standYInput then
        if not standXInput:IsFocused() then standXInput.Text = tostring(sp.x) end
        if not standYInput:IsFocused() then standYInput.Text = tostring(sp.y) end
    end
    if st and stockXInput and stockYInput then
        if not stockXInput:IsFocused() then stockXInput.Text = tostring(st.x) end
        if not stockYInput:IsFocused() then stockYInput.Text = tostring(st.y) end
    end
end
updatePosUI()

standBtn.MouseButton1Click:Connect(function()
    elevate()
    local tx, ty = getAccurateTilePos()
    state.standPos = {x = tx, y = ty}
    if genv.AutoBreakCustom then genv.AutoBreakCustom.StandPos = state.standPos end
    updatePosUI()
    if updateStatusLabel then updateStatusLabel(string.format("📍 Pos Berdiri diset: (%d, %d)", tx, ty)) end
    print(string.format("[PnB UI] 📍 Pos Berdiri diatur ke: (%d, %d)", tx, ty))
end)

stockBtn.MouseButton1Click:Connect(function()
    elevate()
    local tx, ty = getAccurateTilePos()
    state.stockPos = {x = tx, y = ty}
    if genv.AutoBreakCustom then genv.AutoBreakCustom.StockPos = state.stockPos end
    updatePosUI()
    if updateStatusLabel then updateStatusLabel(string.format("📦 Pos Stok diset: (%d, %d)", tx, ty)) end
    print(string.format("[PnB UI] 📦 Pos Stok diatur ke: (%d, %d)", tx, ty))
end)

local function applyManualStand()
    elevate()
    local nx = tonumber(standXInput.Text)
    local ny = tonumber(standYInput.Text)
    if nx and ny then
        state.standPos = {x = math.floor(nx), y = math.floor(ny)}
        if genv.AutoBreakCustom then genv.AutoBreakCustom.StandPos = state.standPos end
        updatePosUI()
    end
end
standXInput.FocusLost:Connect(applyManualStand)
standYInput.FocusLost:Connect(applyManualStand)

local function applyManualStock()
    elevate()
    local nx = tonumber(stockXInput.Text)
    local ny = tonumber(stockYInput.Text)
    if nx and ny then
        state.stockPos = {x = math.floor(nx), y = math.floor(ny)}
        if genv.AutoBreakCustom then genv.AutoBreakCustom.StockPos = state.stockPos end
        updatePosUI()
    end
end
stockXInput.FocusLost:Connect(applyManualStock)
stockYInput.FocusLost:Connect(applyManualStock)
end

-- ================== FITUR AUTO REJOIN & RESUME WORLD ==================
do
local rejoinFrame = Instance.new("Frame")
rejoinFrame.Name = "RejoinFrame"
rejoinFrame.Size = UDim2.new(1, -24, 0, 72)
rejoinFrame.Position = UDim2.fromOffset(12, 582)
rejoinFrame.BackgroundTransparency = 1
rejoinFrame.Parent = scrollFrame

local rejoinToggleBtn = Instance.new("TextButton")
rejoinToggleBtn.Size = UDim2.new(1, 0, 0, 24)
rejoinToggleBtn.Position = UDim2.new(0, 0, 0, 0)
rejoinToggleBtn.Text = state.autoRejoinWorld and "🔄 Auto Rejoin & Resume World: ON" or "🔄 Auto Rejoin & Resume World: OFF"
rejoinToggleBtn.BackgroundColor3 = state.autoRejoinWorld and Color3.fromRGB(38, 166, 91) or Color3.fromRGB(45, 50, 65)
rejoinToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinToggleBtn.Font = Enum.Font.GothamBold
rejoinToggleBtn.TextSize = 10
rejoinToggleBtn.Parent = rejoinFrame
local rjCorner = Instance.new("UICorner")
rjCorner.CornerRadius = UDim.new(0, 4)
rjCorner.Parent = rejoinToggleBtn

local worldRow = Instance.new("Frame")
worldRow.Size = UDim2.new(1, 0, 0, 22)
worldRow.Position = UDim2.fromOffset(0, 27)
worldRow.BackgroundTransparency = 1
worldRow.Parent = rejoinFrame

local worldLbl = Instance.new("TextLabel")
worldLbl.Size = UDim2.fromOffset(48, 22)
worldLbl.Position = UDim2.new(0, 0, 0, 0)
worldLbl.Text = "Target:"
worldLbl.TextColor3 = Color3.fromRGB(200, 205, 220)
worldLbl.Font = Enum.Font.GothamBold
worldLbl.TextSize = 10
worldLbl.TextXAlignment = Enum.TextXAlignment.Left
worldLbl.BackgroundTransparency = 1
worldLbl.Parent = worldRow

local worldInput = Instance.new("TextBox")
worldInput.Size = UDim2.new(1, -52, 1, 0)
worldInput.Position = UDim2.fromOffset(52, 0)
worldInput.BackgroundColor3 = Color3.fromRGB(32, 35, 45)
worldInput.TextColor3 = Color3.fromRGB(52, 211, 153)
worldInput.Font = Enum.Font.GothamBold
worldInput.TextSize = 10
worldInput.ClearTextOnFocus = false
worldInput.Text = state.savedWorldName or ""
worldInput.PlaceholderText = "Nama World Target..."
worldInput.Parent = worldRow
addCorner(worldInput, 4)
addStroke(worldInput, Color3.fromRGB(55, 60, 75), 1)

local rejoinStatusLabel = Instance.new("TextLabel")
rejoinStatusLabel.Size = UDim2.new(1, 0, 0, 16)
rejoinStatusLabel.Position = UDim2.fromOffset(0, 52)
rejoinStatusLabel.TextColor3 = Color3.fromRGB(160, 175, 205)
rejoinStatusLabel.TextSize = 9
rejoinStatusLabel.Font = Enum.Font.GothamMedium
rejoinStatusLabel.BackgroundTransparency = 1
rejoinStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
rejoinStatusLabel.Text = string.format("World: %s | Auto-Warp -> Jalan ke StandPos", state.savedWorldName or "---")
rejoinStatusLabel.Parent = rejoinFrame

worldInput.FocusLost:Connect(function()
    if #worldInput.Text > 0 then
        local wUp = string.upper(worldInput.Text)
        state.savedWorldName = wUp
        genv.PnB_SavedWorld = wUp
        if genv.AutoBreakCustom then genv.AutoBreakCustom.SavedWorld = wUp end
        worldInput.Text = wUp
        rejoinStatusLabel.Text = string.format("World: %s | Auto-Warp -> Jalan ke StandPos", wUp)
    end
end)

rejoinToggleBtn.MouseButton1Click:Connect(function()
    elevate()
    state.autoRejoinWorld = not state.autoRejoinWorld
    rejoinToggleBtn.Text = state.autoRejoinWorld and "🔄 Auto Rejoin & Resume World: ON" or "🔄 Auto Rejoin & Resume World: OFF"
    rejoinToggleBtn.BackgroundColor3 = state.autoRejoinWorld and Color3.fromRGB(38, 166, 91) or Color3.fromRGB(45, 50, 65)
    
    local wName = getCurrentWorldName()
    if wName and #wName > 0 then
        state.savedWorldName = wName
        worldInput.Text = wName
    end
    rejoinStatusLabel.Text = string.format("World: %s | Auto-Warp -> Jalan ke StandPos", state.savedWorldName or "---")

    if state.autoRejoinWorld then
        if startRejoinWatchdog then startRejoinWatchdog() end
    elseif state.rejoinThread then
        task.cancel(state.rejoinThread)
        state.rejoinThread = nil
    end
end)

local shieldLabel = Instance.new("TextLabel")
shieldLabel.Size = UDim2.new(1, -24, 0, 16)
shieldLabel.Position = UDim2.fromOffset(12, 662)
shieldLabel.Text = "🛡️ Shield: Anti-AFK (20m) + Anti-Staff"
shieldLabel.TextColor3 = Color3.fromRGB(52, 211, 153)
shieldLabel.Font = Enum.Font.GothamMedium
shieldLabel.TextSize = 9
shieldLabel.TextXAlignment = Enum.TextXAlignment.Center
shieldLabel.BackgroundTransparency = 1
shieldLabel.Parent = scrollFrame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 16)
footer.Position = UDim2.fromOffset(12, 682)
footer.Text = "Auto Claim: 100% Instan Tanpa Gerak (Per-Balok)"
footer.TextColor3 = Color3.fromRGB(120, 125, 140)
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.BackgroundTransparency = 1
footer.Parent = scrollFrame

local bottomSpacer = Instance.new("Frame")
bottomSpacer.Size = UDim2.new(1, -24, 0, 20)
bottomSpacer.Position = UDim2.fromOffset(12, 704)
bottomSpacer.BackgroundTransparency = 1
bottomSpacer.Parent = scrollFrame
end

-- Action helpers untuk testing dan integrasi programmatic
genv.PnB_Actions = {
    selectBlock = function(id)
        local meta = ItemDB[id]
        if meta then
            state.selectedBlockId = id
            state.selectedBlockName = meta.name
            local matchSeed = findMatchingSeedId(id)
            state.targetSeedId = matchSeed
            if genv.AutoBreakCustom then
                genv.AutoBreakCustom.TargetSeedID = matchSeed and tostring(matchSeed) or nil
            end
            if seedIdInput then
                seedIdInput.Text = matchSeed and tostring(matchSeed) or ""
            end
            if updateSeedUI then updateSeedUI() end
            if updatePickButton then updatePickButton() end
            return true
        end
        return false
    end,
    setMode = function(m)
        if m == "1-Tile" or m == "2-Far" or m == "3-Block" or m == "6-Block" or m == "Custom" or m == "Custom (1-Blok)" then
            state.mode = m
            if applyModePreset then applyModePreset() end
            if refreshMatrixUI then refreshMatrixUI() end
            if modeBtn then modeBtn.Text = "Mode: " .. m end
            return true
        end
        return false
    end,
    setDirection = function(d)
        if d == "Kanan" or d == "Kiri" then
            state.direction = d
            if dirBtn then dirBtn.Text = (d == "Kanan") and "Arah: Kanan ▶" or "Arah: ◀ Kiri" end
            return true
        end
        return false
    end,
    setCustomTile = function(dx, dy, enabled)
        local key = dx .. "," .. dy
        if enabled then
            state.customTiles[key] = true
        else
            state.customTiles[key] = nil
        end
        refreshMatrixUI()
        return true
    end,
    applyPreset = function(name)
        if name == "Kanan" then
            table.clear(state.customTiles)
            state.customTiles["1,0"] = true
            state.customTiles["1,-1"] = true
            state.direction = "Kanan"
        elseif name == "Kiri" then
            table.clear(state.customTiles)
            state.customTiles["-1,0"] = true
            state.customTiles["-1,-1"] = true
            state.direction = "Kiri"
        elseif name == "Atas" or name == "Atas (3)" then
            table.clear(state.customTiles)
            state.customTiles["-1,-2"] = true
            state.customTiles["0,-2"] = true
            state.customTiles["1,-2"] = true
        elseif name == "6-Tile" or name == "6-Blok" then
            table.clear(state.customTiles)
            state.customTiles["-1,-2"] = true
            state.customTiles["0,-2"] = true
            state.customTiles["1,-2"] = true
            state.customTiles["1,-1"] = true
            state.customTiles["1,0"] = true
            state.customTiles["-1,-1"] = true
        elseif name == "Non-Solid" or name == "Sugarcane" or name == "FishTank" then
            table.clear(state.customTiles)
            state.customTiles["0,-1"] = true
            state.customTiles["0,0"] = true
            state.customTiles["1,-1"] = true
            state.customTiles["1,0"] = true
            state.customTiles["0,-2"] = true
        elseif name == "Full" or name == "Full (9)" then
            table.clear(state.customTiles)
            state.customTiles["-1,-2"] = true
            state.customTiles["0,-2"] = true
            state.customTiles["1,-2"] = true
            state.customTiles["-1,-1"] = true
            state.customTiles["0,-1"] = true
            state.customTiles["1,-1"] = true
            state.customTiles["-1,0"] = true
            state.customTiles["0,0"] = true
            state.customTiles["1,0"] = true
        elseif name == "Reset" then
            table.clear(state.customTiles)
        end
        state.mode = "Custom (1-Blok)"
        if modeBtn then modeBtn.Text = "Mode: Custom (1-Blok)" end
        if dirBtn then dirBtn.Text = (state.direction == "Kanan") and "Arah: Kanan ▶" or "Arah: ◀ Kiri" end
        refreshMatrixUI()
        return true
    end,
    getCustomTiles = function()
        return state.customTiles
    end,
    refreshMatrix = refreshMatrixUI,
    toggleClaim = function(on)
        if on == nil then
            state.autoClaim = not state.autoClaim
        else
            state.autoClaim = on
        end
        updateClaimButton()
        if state.autoClaim then
            startClaimWorker()
            task.spawn(vacuumNearbyDrops)
        elseif state.claimThread then
            task.cancel(state.claimThread)
            state.claimThread = nil
        end
        return state.autoClaim
    end,
    togglePnB = function(on)
        if on == nil then
            state.autoPnB = not state.autoPnB
        else
            state.autoPnB = on
        end
        updatePnBButton()
        if state.autoPnB then
            startPnBWorker()
        elseif state.pnbThread then
            sendKeySafe(Enum.KeyCode.A, false)
            sendKeySafe(Enum.KeyCode.D, false)
            task.cancel(state.pnbThread)
            state.pnbThread = nil
            if updateStatusLabel then updateStatusLabel("Status: Berhenti (Idle)") end
        end
        return state.autoPnB
    end,
    setSeedDropPos = function(x, y)
        state.seedDropPos = {x = x, y = y}
        if genv.AutoBreakCustom then genv.AutoBreakCustom.SeedDropPos = state.seedDropPos end
        if updateSeedUI then updateSeedUI() end
        return true
    end,
    setTargetSeed = function(id)
        state.targetSeedId = id
        if genv.AutoBreakCustom then genv.AutoBreakCustom.TargetSeedID = tostring(id) end
        if seedIdInput then seedIdInput.Text = tostring(id) end
        if updateSeedUI then updateSeedUI() end
        return true
    end,
    setStandPos = function(x, y)
        state.standPos = {x = x, y = y}
        if genv.AutoBreakCustom then genv.AutoBreakCustom.StandPos = state.standPos end
        if updatePosUI then updatePosUI() end
        return true
    end,
    setStockPos = function(x, y)
        state.stockPos = {x = x, y = y}
        if genv.AutoBreakCustom then genv.AutoBreakCustom.StockPos = state.stockPos end
        if updatePosUI then updatePosUI() end
        return true
    end,
    save = function()
        return true
    end
}
shared.PnB_Actions = genv.PnB_Actions

genv.PnB_Cleanup = function()
    state.autoPnB = false
    state.autoClaim = false
    sendKeySafe(Enum.KeyCode.A, false)
    sendKeySafe(Enum.KeyCode.D, false)
    if state.pnbThread then
        task.cancel(state.pnbThread)
        state.pnbThread = nil
    end
    if state.claimThread then
        task.cancel(state.claimThread)
        state.claimThread = nil
    end
    for _, c in ipairs(state.connections) do
        pcall(function() c:Disconnect() end)
    end
    state.connections = {}
    if sg and sg.Parent then
        sg:Destroy()
    end
    if pickerModal and pickerModal.Parent then
        pickerModal:Destroy()
    end
    if Sfx and origSfxPlay then
        Sfx.play = origSfxPlay
    end
    if Sfx and origSfxPlayAt then
        Sfx.playAt = origSfxPlayAt
    end
    genv.PnB_State = nil
    genv.PnB_Actions = nil
    shared.PnB_State = nil
    shared.PnB_Actions = nil
    print("[PnB] Selesai di-cleanup.")
end
shared.PnB_Cleanup = genv.PnB_Cleanup

-- Inisialisasi otomatis Rejoin Watchdog jika autoRejoinWorld aktif
if state.autoRejoinWorld and startRejoinWatchdog then
    task.spawn(function()
        task.wait(1.0)
        startRejoinWatchdog()
    end)
end

print("[PnB] Put and Break & Auto Claim (Pro V7.1 - Clean & Pure Engine) siap digunakan!")
