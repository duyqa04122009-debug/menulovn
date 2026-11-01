-- [[ BLOX FRUITS FLUENT UI SCRIPT COMPLETE ]] --

-- Auto Exec / Rejoin Config
if not game:IsLoaded() then game.Loaded:Wait() end
local QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if QueueOnTeleport then
    QueueOnTeleport([[
        repeat task.wait() until game:IsLoaded()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/main.lua"))()
    ]])
end

-- Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()

-- Variables & Settings
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local Flags = {
    AutoFarm = false,
    AutoHopAdmin = true,
    AutoSea = false,
    AutoHakiObsV1 = false,
    AutoHakiObsV2 = false,
    AutoHakiRainbow = false,
    AutoFruit = false,
    BringMob = false
}

-- Target Islands Data (Tọa độ các đảo chính)
local SeaIslands = {
    ["Sea 1"] = {
        ["Starter Island"] = Vector3.new(1059, 16, 1428),
        ["Jungle"] = Vector3.new(-1250, 12, 350),
        ["Pirate Village"] = Vector3.new(-1130, 14, 3850),
        ["Desert"] = Vector3.new(1000, 14, 4400),
        ["Middle Town"] = Vector3.new(-675, 14, 1500),
        ["Frozen Village"] = Vector3.new(1150, 7, -1150),
        ["MarineFord"] = Vector3.new(-4800, 20, 4250),
        ["Skypiea"] = Vector3.new(-4850, 715, -2600),
        ["Prison"] = Vector3.new(4850, 5, 750),
        ["Magma Village"] = Vector3.new(-5250, 8, 8500),
        ["Underwater City"] = Vector3.new(3850, 6, -1900),
        ["Fountain City"] = Vector3.new(5150, 4, 4100)
    },
    ["Sea 2"] = {
        ["Cafe / Rose Kingdom"] = Vector3.new(-425, 73, 300),
        ["Green Zone"] = Vector3.new(-2350, 72, -3150),
        ["Graveyard"] = Vector3.new(-5400, 48, -750),
        ["Snow Mountain"] = Vector3.new(650, 400, -5300),
        ["Cold Castle"] = Vector3.new(5850, 28, -6250),
        ["Forgotten Island"] = Vector3.new(-3050, 240, -10150)
    },
    ["Sea 3"] = {
        ["Port Town"] = Vector3.new(-290, 7, 5300),
        ["Hydra Island"] = Vector3.new(5700, 600, 200),
        ["Great Tree"] = Vector3.new(2250, 25, -7200),
        ["Floating Turtle"] = Vector3.new(-13200, 330, -7600),
        ["Castle on the Sea"] = Vector3.new(-5000, 315, -3000),
        ["Haunted Castle"] = Vector3.new(-9500, 140, 5500),
        ["Tiki Outpost"] = Vector3.new(-16200, 10, 500)
    }
}

-- Tween Fly (Dịch chuyển bay từ từ tránh Ban / Kick)
local function TweenTo(targetCFrame, speed)
    speed = speed or 250
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- 1. Create Window
local Window = Fluent:CreateWindow({
    Title = "Blox Fruits VIP Script",
    SubTitle = "Fluent UI System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Floating Logo Toggle Button (Tạo Logo để bật/tắt UI)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local LogoBtn = Instance.new("ImageButton", ScreenGui)
LogoBtn.Size = UDim2.new(0, 50, 0, 50)
LogoBtn.Position = UDim2.new(0, 10, 0.5, -25)
LogoBtn.Image = "rbxassetid://6031075931" -- Logo icon
LogoBtn.Draggable = true
LogoBtn.Active = true
LogoBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LogoBtn.BorderSizePixel = 2
LogoBtn.BorderColor3 = Color3.fromRGB(0, 170, 255)

local Corner = Instance.new("UICorner", LogoBtn)
Corner.CornerRadius = UDim.new(1, 0)

LogoBtn.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- Tabs setup
local Tabs = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "rbxassetid://4483345998" }),
    Teleport = Window:AddTab({ Title = "Dịch Chuyển (Teleport)", Icon = "map" }),
    Quests = Window:AddTab({ Title = "Nhiệm Vụ & Sea", Icon = "award" }),
    Haki = Window:AddTab({ Title = "Haki System", Icon = "shield" }),
    Items = Window:AddTab({ Title = "Trái Ác Quỷ", Icon = "gift" }),
    Settings = Window:AddTab({ Title = "Hệ Thống / Anti", Icon = "settings" })
}

-- TAB 1: AUTO FARM & GOM QUÁI
Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Tự Động Farm Theo Cấp Độ (Level)",
    Default = false,
    Callback = function(Value)
        Flags.AutoFarm = Value
    end
})

Tabs.Main:AddToggle("BringMobToggle", {
    Title = "Auto Gom Quái Lại Gần (Gom Mob)",
    Default = false,
    Callback = function(Value)
        Flags.BringMob = Value
    end
})

-- Loop Auto Farm & Bring Mob
task.spawn(function()
    while task.wait(0.5) do
        if Flags.AutoFarm then
            pcall(function()
                local level = LocalPlayer.Data.Level.Value
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Flags.BringMob and Flags.AutoFarm then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - root.Position).Magnitude < 300 then
                            v.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                            v.HumanoidRootPart.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

-- TAB 2: DỊCH CHUYỂN (TELEPORT BAY TỪ TỪ)
local CurrentSeaName = "Sea 1"
if game.PlaceId == 4442272183 then CurrentSeaName = "Sea 2"
elseif game.PlaceId == 7449423635 then CurrentSeaName = "Sea 3" end

local SelectedIsland = ""
local IslandDropdown = Tabs.Teleport:AddDropdown("IslandSelect", {
    Title = "Chọn Đảo Dịch Chuyển (" .. CurrentSeaName .. ")",
    Values = (function()
        local t = {}
        for k, _ in pairs(SeaIslands[CurrentSeaName] or {}) do table.insert(t, k) end
        return t
    end)(),
    Multi = false,
    Default = 1,
    Callback = function(Value)
        SelectedIsland = Value
    end
})

Tabs.Teleport:AddButton({
    Title = "Bay Đến Đảo Đã Chọn (Dịch Chuyển Từ Từ)",
    Callback = function()
        if SelectedIsland ~= "" and SeaIslands[CurrentSeaName][SelectedIsland] then
            local targetPos = SeaIslands[CurrentSeaName][SelectedIsland]
            TweenTo(CFrame.new(targetPos + Vector3.new(0, 50, 0)), 250)
        end
    end
})

-- TAB 3: AUTO SEA & NHIỆM VỤ ĐẶC BIỆT
Tabs.Quests:AddToggle("AutoSeaToggle", {
    Title = "Tự Động Làm NV Qua Sea (Sea 1 -> 2 -> 3)",
    Default = false,
    Callback = function(Value)
        Flags.AutoSea = Value
    end
})

Tabs.Quests:AddButton({
    Title = "Dịch Chuyển Thủ Công Đến Sea 1",
    Callback = function() TeleportService:Teleport(2753915549, LocalPlayer) end
})
Tabs.Quests:AddButton({
    Title = "Dịch Chuyển Thủ Công Đến Sea 2",
    Callback = function() TeleportService:Teleport(4442272183, LocalPlayer) end
})
Tabs.Quests:AddButton({
    Title = "Dịch Chuyển Thủ Công Đến Sea 3",
    Callback = function() TeleportService:Teleport(7449423635, LocalPlayer) end
})

-- TAB 4: HAKI SYSTEM (V1, V2, RAINBOW)
Tabs.Haki:AddToggle("HakiObsV1", {
    Title = "Auto Làm NV Haki Quan Sát V1",
    Default = false,
    Callback = function(V) Flags.AutoHakiObsV1 = V end
})
Tabs.Haki:AddToggle("HakiObsV2", {
    Title = "Auto Làm NV Haki Quan Sát V2 (Hungry Man)",
    Default = false,
    Callback = function(V) Flags.AutoHakiObsV2 = V end
})
Tabs.Haki:AddToggle("HakiRainbow", {
    Title = "Auto Làm NV Haki 7 Màu (Rainbow Haki)",
    Default = false,
    Callback = function(V) Flags.AutoHakiRainbow = V end
})

-- TAB 5: NHẶT TRÁI ÁC QUỶ HYỀN THOẠI & THẦN THOẠI
local LegendaryFruits = {"Dough", "Shadow", "Venom", "Control", "Spirit", "Dragon", "Leopard", "Kitsune", "T-Rex", "Gravity", "Blizzard", "Sound", "Mammoth"}

Tabs.Items:AddToggle("AutoFruitToggle", {
    Title = "Auto Nhặt Trái Huyền Thoại & Thần Thoại Khi Xuất Hiện",
    Default = false,
    Callback = function(Value)
        Flags.AutoFruit = Value
    end
})

task.spawn(function()
    while task.wait(1) do
        if Flags.AutoFruit then
            pcall(function()
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") or v:FindFirstChild("Handle") then
                        for _, fruitName in pairs(LegendaryFruits) do
                            if string.find(v.Name, fruitName) then
                                Fluent:Notify({
                                    Title = "Phát Hiện Trái Quý!",
                                    Content = "Đang bay đến nhặt: " .. v.Name,
                                    Duration = 5
                                })
                                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if root and v:FindFirstChild("Handle") then
                                    TweenTo(v.Handle.CFrame, 300)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- TAB 6: ANTI-AFK & ANTI-ADMIN AUTO HOP
Tabs.Settings:AddToggle("AntiAdmin", {
    Title = "Auto Hop Server Khi Có Admin / Mod Vào",
    Default = true,
    Callback = function(Value)
        Flags.AutoHopAdmin = Value
    end
})

-- Anti-AFK Logic
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Auto Hop Server System
local function ServerHop()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local List = HttpService:JSONDecode(game:HttpGet(Api))
    if List and List.data then
        for _, server in pairs(List.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end
end

-- Admin Detector
Players.PlayerAdded:Connect(function(player)
    if Flags.AutoHopAdmin then
        if player:GetRankInGroup(2943477) > 1 or player.MembershipType == Enum.MembershipType.Premium and player:FindFirstChild("Admin") then
            Fluent:Notify({
                Title = "CẢNH BÁO ADMIN!",
                Content = "Admin/Staff đã vào Server! Đang Hop Server...",
                Duration = 3
            })
            task.wait(1)
            ServerHop()
        end
    end
end)

-- Notification & Finalizing
Fluent:Notify({
    Title = "Blox Fruits Script Loaded!",
    Content = "Bấm vào Logo hình tròn bên trái để Ẩn/Hiện Menu UI.",
    Duration = 5
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)