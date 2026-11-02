local url = "https://raw.githubusercontent.com/duyqa04122009-debug/20-10-vui-ve/refs/heads/main/file-ea6.lua.txt"

local function show(msg)
    warn(msg)
    local gui = Instance.new("ScreenGui")
    gui.Name = "DebugUI"
    gui.ResetOnSpawn = false
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 160)
    frame.Position = UDim2.new(0.5, -210, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, -16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 90, 90)
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Text = msg
    label.Parent = frame

    task.delay(20, function() gui:Destroy() end)
end

-- Bước 1: tải nội dung
local okFetch, content = pcall(function()
    return game:HttpGet(url, true)
end)

if not okFetch then
    show("HTTP FAIL\n" .. tostring(content))
    return
end

if type(content) ~= "string" or content:find("404: Not Found", 1, true) then
    show("404 - FILE KHONG TON TAI\nSua ten file tren GitHub thanh .lua hoac dung link .lua.txt")
    return
end

-- Bước 2: compile
local fn, err = loadstring(content)
if not fn then
    show("COMPILE ERROR\n" .. tostring(err))
    return
end

-- Bước 3: chạy
local okRun, runErr = pcall(fn)
if not okRun then
    show("RUNTIME ERROR\n" .. tostring(runErr))
end