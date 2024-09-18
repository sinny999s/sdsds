local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Sinny Tool", HidePremium = false})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- FPS and Ping UI Variables
local showFPS = false
local fpsLabel = Instance.new("TextLabel")
local pingLabel = Instance.new("TextLabel")
local screenGui = Instance.new("ScreenGui")

-- Properties for FPS and Ping UI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

fpsLabel.Name = "Fps"
fpsLabel.Parent = screenGui
fpsLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.BackgroundTransparency = 1.000
fpsLabel.Position = UDim2.new(0.786, 0, 0, 0)
fpsLabel.Size = UDim2.new(0, 125, 0, 25)
fpsLabel.Font = Enum.Font.SourceSans
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextScaled = true
fpsLabel.TextWrapped = true
fpsLabel.Visible = false

pingLabel.Name = "Ping"
pingLabel.Parent = screenGui
pingLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pingLabel.BackgroundTransparency = 1.000
pingLabel.Position = UDim2.new(0.700, 0, 0, 0)
pingLabel.Size = UDim2.new(0, 125, 0, 25)
pingLabel.Font = Enum.Font.SourceSans
pingLabel.TextColor3 = Color3.fromRGB(253, 253, 253)
pingLabel.TextScaled = true
pingLabel.TextWrapped = true
pingLabel.Visible = false

-- Function to update FPS and Ping
RunService.RenderStepped:Connect(function()
    local frameTime = RunService.RenderStepped:Wait()
    fpsLabel.Text = "FPS: " .. math.round(1 / frameTime)
    
    local pingValue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    pingLabel.Text = "Ping: " .. pingValue
end)

-- Aim/Visual Tab
local AimTab = Window:MakeTab({
    Name = "Aim/Visual",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Gun Mods Tab
local GunTab = Window:MakeTab({
    Name = "Gun Mods",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Misc Tab
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Toggle FPS Counter
MiscTab:AddToggle({
    Name = "Show FPS & Ping",
    Default = false,
    Callback = function(state)
        showFPS = state
        fpsLabel.Visible = showFPS
        pingLabel.Visible = showFPS
    end    
})

-- ESP Functions
local function createESP(player)
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.new(1, 0, 0) -- Red color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
    end
end

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("Highlight") then
        player.Character.Highlight:Destroy()
    end
end

-- ESP Toggle
AimTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(state)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if state then
                    createESP(player)
                else
                    removeESP(player)
                end
            end
        end

        if state then
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    createESP(player)
                end)
            end)
            Players.PlayerRemoving:Connect(function(player)
                removeESP(player)
            end)
        end
    end    
})

-- Aimbot Variables
local aimbotEnabled = false
local smoothing = 0.1
local lockPart = "Head"
local aiming = false

local function getNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(lockPart) then
            if player.Team ~= LocalPlayer.Team then -- Team check added here
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local distance = (LocalPlayer.Character.PrimaryPart.Position - player.Character[lockPart].Position).magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestEnemy = player
                    end
                end
            end
        end
    end
    return nearestEnemy
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and aiming then
        local target = getNearestEnemy()
        if target and target.Character and target.Character:FindFirstChild(lockPart) then
            local targetPosition = target.Character[lockPart].Position
            local camera = workspace.CurrentCamera
            local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothing)
        end
    end
end)

-- Aimbot Toggle
AimTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
        print(aimbotEnabled and "Aimbot enabled!" or "Aimbot disabled!")
    end    
})

-- Mouse Input for enabling/disabling Aimbot with RMB
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right Mouse Button
        aiming = true
        print("Lock-On Aimbot activated!")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right Mouse Button
        aiming = false
        print("Lock-On Aimbot deactivated!")
    end
end)

-- Gun Mods Section
local originalValues = {
    FireRate = {},
    ReloadTime = {},
    EReloadTime = {},
    Auto = {},
    Spread = {},
    Recoil = {}
}

-- Infinite Ammo Toggle
GunTab:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(state)
        game:GetService("RunService").Stepped:Connect(function()
            if state then
                local playerGui = LocalPlayer.PlayerGui
                if playerGui and playerGui:FindFirstChild("GUI") and playerGui.GUI:FindFirstChild("Client") then
                    local variables = playerGui.GUI.Client.Variables
                    if variables and variables:FindFirstChild("ammocount") and variables:FindFirstChild("ammocount2") then
                        variables.ammocount.Value = 99
                        variables.ammocount2.Value = 99
                    end
                end
            end
        end)
    end
})

-- Fast Reload Toggle
GunTab:AddToggle({
    Name = "Fast Reload",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
            if v:FindFirstChild("ReloadTime") then
                if state then
                    if not originalValues.ReloadTime[v] then
                        originalValues.ReloadTime[v] = v.ReloadTime.Value
                    end
                    v.ReloadTime.Value = 0.01
                else
                    if originalValues.ReloadTime[v] then
                        v.ReloadTime.Value = originalValues.ReloadTime[v]
                    else
                        v.ReloadTime.Value = 0.8 
                    end
                end
            end
            if v:FindFirstChild("EReloadTime") then
                if state then
                    if not originalValues.EReloadTime[v] then
                        originalValues.EReloadTime[v] = v.EReloadTime.Value
                    end
                    v.EReloadTime.Value = 0.01
                else
                    if originalValues.EReloadTime[v] then
                        v.EReloadTime.Value = originalValues.EReloadTime[v]
                    else
                        v.EReloadTime.Value = 0.8 
                    end
                end
            end
        end
    end
})

-- Fast Fire Rate Toggle
GunTab:AddToggle({
    Name = "Fast Fire Rate",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "FireRate" or v.Name == "BFireRate" then
                if state then
                    if not originalValues.FireRate[v] then
                        originalValues.FireRate[v] = v.Value
                    end
                    v.Value = 0.02
                else
                    if originalValues.FireRate[v] then
                        v.Value = originalValues.FireRate[v]
                    else
                        v.Value = 0.8 
                    end
                end
            end
        end
    end
})

-- Always Auto Toggle
GunTab:AddToggle({
    Name = "Always Auto",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "Auto" or v.Name == "AutoFire" or v.Name == "Automatic" or v.Name == "AutoShoot" or v.Name == "AutoGun" then
                if state then
                    if not originalValues.Auto[v] then
                        originalValues.Auto[v] = v.Value
                    end
                    v.Value = true
                else
                    if originalValues.Auto[v] then
                        v.Value = originalValues.Auto[v]
                    else
                        v.Value = false 
                    end
                end
            end
        end
    end
})

-- No Spread Toggle
GunTab:AddToggle({
    Name = "No Spread",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
            if v.Name == "MaxSpread" or v.Name == "Spread" or v.Name == "SpreadControl" then
                if state then
                    if not originalValues.Spread[v] then
                        originalValues.Spread[v] = v.Value
                    end
                    v.Value = 0
                else
                    if originalValues.Spread[v] then
                        v.Value = originalValues.Spread[v]
                    else
                        v.Value = 1 
                    end
                end
            end
        end
    end
})

-- No Recoil Toggle
GunTab:AddToggle({
    Name = "No Recoil",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
            if v.Name == "RecoilControl" or v.Name == "Recoil" then
                if state then
                    if not originalValues.Recoil[v] then
                        originalValues.Recoil[v] = v.Value
                    end
                    v.Value = 0
                else
                    if originalValues.Recoil[v] then
                        originalValues.Recoil[v] = originalValues.Recoil[v]
                    else
                        v.Value = 1 
                    end
                end
            end
        end
    end
})

-- Initialize Orion
OrionLib:Init()
