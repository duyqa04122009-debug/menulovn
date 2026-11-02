--[[ Blox Fruits Auto Farm Hub - Venice | 1 file | Rayfield UI ]]
if getgenv().VeniceHubLoaded then
    pcall(function() Rayfield:Destroy() end)
end
getgenv().VeniceHubLoaded = true

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
local Remotes = RS:FindFirstChild("Remotes")
local CommF_ = Remotes and Remotes:FindFirstChild("CommF_")

local State = {
    weapon = "", bringMobs = true, safeTPMode = true,
    autoFarmLevel = false, autoChest = false, killAura = false, autoDungeon = false,
    chipName = "Flame", autoChip = false, autoStartRaid = false,
    autoFruit = false, fruitTracker = false,
    stats = { Melee = false, Defense = false, Sword = false, Gun = false, Fruit = false },
    thread = {},
}

local function invoke(...)
    if not CommF_ then return false end
    local args = { ... }
    return pcall(function() CommF_:InvokeServer(table.unpack(args)) end)
end

local function getChar()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r or h.Health <= 0 then return nil end
    return c, h, r
end

local function getLevel()
    local d = LP:FindFirstChild("Data")
    local l = d and d:FindFirstChild("Level")
    return l and l.Value or 1
end

local function safeTP(cf, dist)
    local _, _, hrp = getChar()
    if not hrp then return end
    hrp.Anchored = true
    if State.safeTPMode and dist and dist < 300 then
        local tw = TweenService:Create(hrp, TweenInfo.new(math.clamp(dist / 250, 0.2, 1.4), Enum.EasingStyle.Linear), { CFrame = cf })
        tw:Play()
        tw.Completed:Wait()
    else
        hrp.CFrame = cf
        task.wait(0.1)
    end
    task.wait(0.05)
    hrp.Anchored = false
end

local function touch(part)
    local _, _, hrp = getChar()
    if not hrp or not part then return end
    if firetouchinterest then
        pcall(firetouchinterest, hrp, part, 0)
        task.wait()
        pcall(firetouchinterest, hrp, part, 1)
    else
        hrp.CFrame = part.CFrame
    end
end

local function fireInteract(obj)
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") and fireproximityprompt then
            pcall(fireproximityprompt, d); return true
        elseif d:IsA("ClickDetector") and fireclickdetector then
            pcall(fireclickdetector, d); return true
        end
    end
    return false
end

local function getEnemies()
    local list = {}
    local f = workspace:FindFirstChild("Enemies")
    if not f then return list end
    for _, v in ipairs(f:GetChildren()) do
        local h = v:FindFirstChildOfClass("Humanoid")
        local r = v:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health > 0 then
            table.insert(list, { model = v, hum = h, hrp = r })
        end
    end
    return list
end

local function bringMob(e, hrp)
    if not e.hrp or e.hum.Health <= 0 then return end
    e.hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-5, 5), 0, math.random(-9, -5))
end

local function equipWeapon(name)
    local char, hum = getChar()
    if not char or name == "" then return false end
    if char:FindFirstChild(name) then return true end
    local tool = LP.Backpack:FindFirstChild(name)
    if tool then
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.1)
        return true
    end
    return false
end

local function getQuestInfo()
    local pg = LP:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local q = main and main:FindFirstChild("Quest")
    if not (q and q.Visible) then return nil end
    for _, d in ipairs(q:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text ~= "" then
            local lv = d.Text:match("Lv%.?%s*(%d+)")
            if lv then
                local n = d.Text:match("%]%s*([%a%s]+)") or d.Text:match("Defeat%s+%d+%s+([%a%s]+)")
                if n then return (n:gsub("^%s+", ""):gsub("%s+$", "")), tonumber(lv) end
            end
        end
    end
    return nil
end

local function readGiver(model)
    local mob, lvl
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("TextLabel") then
            local lv = d.Text:match("Lv%.?%s*(%d+)")
            local nm = d.Text:match("%]%s*([%a%s]+)")
            if lv and nm then
                mob = nm:gsub("^%s+", ""):gsub("%s+$", "")
                lvl = tonumber(lv)
                break
            end
        end
    end
    return mob, lvl
end

local function findQuestGiver()
    local myLv = getLevel()
    local best, bestLv
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and v.Name:find("Quest Giver") then
            local mob, lvl = readGiver(v)
            if mob and lvl and lvl <= myLv then
                if not bestLv or lvl > bestLv then
                    best = { model = v, mob = mob, level = lvl }
                    bestLv = lvl
                end
            end
        end
    end
    if not best then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Model") and v.Name:find("Quest Giver") then
                local mob, lvl = readGiver(v)
                if mob then return { model = v, mob = mob, level = lvl } end
            end
        end
    end
    return best
end

local function acceptQuest()
    local g = findQuestGiver()
    if not g then return false end
    if invoke("StartQuest", g.mob, g.level or 1) then
        task.wait(0.6)
        if getQuestInfo() then return true end
    end
    local root = g.model:FindFirstChild("HumanoidRootPart") or g.model:FindFirstChild("Head")
    if root then
        safeTP(root.CFrame * CFrame.new(0, 0, 6))
        task.wait(0.2)
        fireInteract(g.model)
        task.wait(0.8)
    end
    return getQuestInfo() ~= nil
end

local function startAttackLoop()
    if State.thread.attack then return end
    State.thread.attack = task.spawn(function()
        local CF
        pcall(function() CF = require(LP.PlayerScripts.CombatFramework) end)
        while State.autoFarmLevel or State.killAura or State.autoDungeon do
            local char, _, hrp = getChar()
            if hrp then
                if State.weapon ~= "" then equipWeapon(State.weapon) end
                local ac = CF and CF.activeController
                if ac then
                    pcall(function() ac.hitboxMagn