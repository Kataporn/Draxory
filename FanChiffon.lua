repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
getgenv().Settings = {
    -- Player ESP Settings
    ESP = {
        Enabled = false,
        ShowBox = false,
        ShowHealth = false,
        ShowName = false,
        ShowDistance = false,
        ShowTeam = false,
        ShowTracer = false,
        MaxDistance = 1000,
        RefreshRate = 1/60
    },
    
    -- Movement Settings
    Movement = {
        WalkSpeed = 50,
        FlySpeed = 50,
        TpWalkEnabled = false,
        NoclipEnabled = false,
        FlyEnabled = false
    },
    
    -- UI Settings
    UI = {
        Theme = "Dark",
        Transparent = false
    }
}

setfpscap(360)
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()


-- Define default theme colors
local defaultTheme = {
    background = "#FFF0F5", -- Lavender blush background
    accent = "#FFB6C1", -- Light pink accent
    text = "#fc83ed", -- Pale violet red text
    placeholder = "#C71585" -- Medium violet red placeholder
}

-- Add default theme to WindUI
WindUI:AddTheme({
    Name = "Chiffon",
    Accent = defaultTheme.accent,
    Outline = defaultTheme.background,
    Text = defaultTheme.text,
    PlaceholderText = defaultTheme.placeholder
})

local Window = WindUI:CreateWindow({
    Title = "Chiffon",
    Icon = "",
    Author = "💕",
    Folder = "Chiffon",
    Size = UDim2.fromOffset(579, 513),
    Transparent = false,
    Theme = "Light", -- Set theme to DefaultTheme
    SideBarWidth = 200,
    Background = "rbxassetid://105273285764750",
    HasOutline = false,
    ToggleKey = Enum.KeyCode.Insert
})

-- Create a consistent gradient for UI elements
local function createGradient(color1, color2)
    return ColorSequence.new(
        Color3.fromHex(color1),
        Color3.fromHex(color2)
    )
end

Window:EditOpenButton({
    Title = "Open Example UI",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 2,
    Color = createGradient(defaultTheme.background, defaultTheme.accent), -- Using default theme colors
    Draggable = true,
})

-- Rest of the code remains the same, but using the default theme colors
local Tabs = {
    General = Window:Tab({ 
        Title = "General", 
        Icon = "house-wifi",
        Description = "General features and settings"
    }),
    PlayerVisual = Window:Tab({ 
        Title = "Player ESP", 
        Icon = "user",
        Description = "Visual player enhancements and ESP features"
    }),
    Modifications = Window:Tab({ 
        Title = "Modifications", 
        Icon = "blend",
        Description = "Game modifications and player abilities"
    }),

    b = Window:Divider(),
    Settings = Window:Tab({ 
        Title = "Configuration",
        Icon = "settings",
        Description = "UI customization and configuration"
    })
}

Window:SelectTab(1)

------------------------------------------------------------------  Genneral  ---------------------------------------------------------------------

Tabs.General:Section({ Title = " General " })

------------------------------------------------------------------  Player Esp --------------------------------------------------------------------

Tabs.PlayerVisual:Section({ Title = " Player ESP " })

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Enhanced ESP Configuration
local ESPConfig = {
    Enabled = false,
    ShowBox = false,
    ShowHealth = false,
    ShowName = false,
    ShowDistance = false,
    ShowTeam = false,
    ShowTracer = false,
    Colors = {
        Box = Color3.fromRGB(255, 255, 255),
        Health = Color3.fromRGB(0, 255, 0),
        Name = Color3.fromRGB(255, 255, 255),
        Distance = Color3.fromRGB(255, 255, 255),
        Tracer = Color3.fromRGB(255, 0, 0),
        Friend = Color3.fromRGB(0, 255, 0),
        Enemy = Color3.fromRGB(255, 0, 0)
    },
    Transparency = {
        Box = 1,
        Health = 1,
        Name = 1,
        Distance = 1,
        Tracer = 0.5
    },
    MaxDistance = 1000,
    RefreshRate = 1/60,
    BoxStyle = "3D" -- "2D" or "3D"
}

local ESPCache = {}

-- Enhanced Drawing Function
local function NewDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

-- Enhanced ESP Setup
local function SetupESP(player)
    if ESPCache[player] then return end
    
    ESPCache[player] = {
        Box = NewDrawing("Square", {
            Thickness = 1.5,
            Filled = false,
            Transparency = ESPConfig.Transparency.Box,
            Color = ESPConfig.Colors.Box,
            Visible = false
        }),
        BoxOutline = NewDrawing("Square", {
            Thickness = 3,
            Filled = false,
            Transparency = 0.5,
            Color = Color3.new(0, 0, 0),
            Visible = false
        }),
        Health = NewDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Transparency = ESPConfig.Transparency.Health,
            Color = ESPConfig.Colors.Health,
            Visible = false
        }),
        HealthBackground = NewDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Transparency = 0.5,
            Color = Color3.new(0, 0, 0),
            Visible = false
        }),
        Name = NewDrawing("Text", {
            Text = player.Name,
            Size = 14,
            Center = true,
            Outline = true,
            Font = Drawing.Fonts.UI,
            Color = ESPConfig.Colors.Name,
            Visible = false
        }),
        Distance = NewDrawing("Text", {
            Size = 13,
            Center = true,
            Outline = true,
            Font = Drawing.Fonts.UI,
            Color = ESPConfig.Colors.Distance,
            Visible = false
        }),
        Tracer = NewDrawing("Line", {
            Thickness = 1,
            Transparency = ESPConfig.Transparency.Tracer,
            Color = ESPConfig.Colors.Tracer,
            Visible = false
        })
    }
end

-- Enhanced Cleanup
local function CleanupESP(player)
    local esp = ESPCache[player]
    if esp then
        for _, drawing in pairs(esp) do
            pcall(function() drawing:Remove() end)
        end
        ESPCache[player] = nil
    end
end

-- Enhanced ESP Update Function
local function UpdateESP()
    local camera = workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer
    
    for player, esp in pairs(ESPCache) do
        -- Reset visibility
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
        
        if not ESPConfig.Enabled then continue end
        if not player.Character or not player.Character:FindFirstChild("Humanoid") then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not (humanoid and root) then continue end
        
        local pos, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        local dist = (camera.CFrame.Position - root.Position).Magnitude
        if dist > ESPConfig.MaxDistance then continue end
        
        -- Calculate box dimensions with smooth scaling
        local scale = math.clamp(1 - (dist / ESPConfig.MaxDistance), 0.3, 1)
        local size = (camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y - 
                     camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0)).Y) / 2
        local box = Vector2.new(size * 1.5 * scale, size * 3 * scale)
        local boxPos = Vector2.new(pos.X - size * 1.5 / 2, pos.Y - size * 1.5)

        -- Update ESP elements with enhanced visuals
        if ESPConfig.ShowBox then
            esp.BoxOutline.Size = box
            esp.BoxOutline.Position = boxPos
            esp.BoxOutline.Visible = true
            
            esp.Box.Size = box
            esp.Box.Position = boxPos
            esp.Box.Visible = true
        end
        
        if ESPConfig.ShowHealth then
            local health = humanoid.Health / humanoid.MaxHealth
            local healthBarWidth = 4 * scale
            local healthBarHeight = box.Y
            
            esp.HealthBackground.Size = Vector2.new(healthBarWidth, healthBarHeight)
            esp.HealthBackground.Position = Vector2.new(boxPos.X - healthBarWidth * 2, boxPos.Y)
            esp.HealthBackground.Visible = true
            
            esp.Health.Size = Vector2.new(healthBarWidth, healthBarHeight * health)
            esp.Health.Position = Vector2.new(boxPos.X - healthBarWidth * 2, boxPos.Y + (healthBarHeight * (1 - health)))
            esp.Health.Color = Color3.fromHSV(health * 0.3, 1, 1)
            esp.Health.Visible = true
        end
        
        if ESPConfig.ShowName then
            esp.Name.Position = Vector2.new(pos.X, boxPos.Y - 16 * scale)
            esp.Name.Size = 14 * scale
            esp.Name.Visible = true
        end
        
        if ESPConfig.ShowDistance then
            esp.Distance.Text = string.format("%.0f studs", dist)
            esp.Distance.Position = Vector2.new(pos.X, boxPos.Y + box.Y + 2)
            esp.Distance.Size = 13 * scale
            esp.Distance.Visible = true
        end
        
        if ESPConfig.ShowTracer then
            esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(pos.X, pos.Y)
            esp.Tracer.Visible = true
        end
    end
end

-- Enhanced UI Controls
local function CreateToggle(title, setting, description)
    Tabs.PlayerVisual:Toggle({
        Title = title,
        Description = description or "",
        Default = false,
        Callback = function(state)
            ESPConfig[setting] = state
        end
    })
end

-- Setup Connections
Players.PlayerAdded:Connect(SetupESP)
Players.PlayerRemoving:Connect(CleanupESP)

for _, player in ipairs(Players:GetPlayers()) do
    SetupESP(player)
end

-- Create Enhanced UI Elements
CreateToggle("Enable ESP", "Enabled", "Toggle all ESP features")
CreateToggle("Show Box", "ShowBox", "Display bounding box around players")
CreateToggle("Show Health Bar", "ShowHealth", "Display dynamic health indicator")
CreateToggle("Show Name", "ShowName", "Display player names")
CreateToggle("Show Distance", "ShowDistance", "Show distance to players")
CreateToggle("Show Tracers", "ShowTracer", "Display lines pointing to players")

-- Enhanced Color Controls
local function CreateColorPicker(title, colorType, description)
    Tabs.PlayerVisual:Colorpicker({
        Title = title,
        Description = description or "",
        Default = ESPConfig.Colors[colorType],
        Callback = function(color)
            ESPConfig.Colors[colorType] = color
            for _, esp in pairs(ESPCache) do
                if esp[colorType] then
                    esp[colorType].Color = color
                end
            end
        end
    })
end

CreateColorPicker("Box Color", "Box", "Customize box outline color")
CreateColorPicker("Health Bar Color", "Health", "Customize health bar color")
CreateColorPicker("Name Color", "Name", "Customize name text color")
CreateColorPicker("Distance Color", "Distance", "Customize distance text color")
CreateColorPicker("Tracer Color", "Tracer", "Customize tracer line color")

-- Optimized Update Loop
local lastUpdate = 0
local updateInterval = ESPConfig.RefreshRate

local espConnection = RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastUpdate >= updateInterval then
        pcall(UpdateESP)
        lastUpdate = now
    end
end)

-- Enhanced Cleanup
Players.LocalPlayer.Destroying:Connect(function()
    if espConnection then espConnection:Disconnect() end
    for player in pairs(ESPCache) do CleanupESP(player) end
end)
------------------------------------------------------------------ Modifications ------------------------------------------------------------------
-- Main tab elements with consistent styling
local TpWalkEnabled = false
local WalkSpeed = 50

-- Create a section for movement controls
Tabs.Modifications:Section({ Title = " Player Manager " })

-- Add slider with improved value range and smoother increments
Tabs.Modifications:Slider({
    Title = "WalkSpeed",
    Description = "Change the Keybind to enable walkspeed",
    Value = {
        Min = 1,
        Max = 200,
        Default = 50,
        Precise = 1 -- Allow decimal points for finer control
    },
    Callback = function(value)
        WalkSpeed = value
    end
})

-- Create a connection variable to store the TpWalk connection
local tpWalkConnection = nil

-- Function to handle TpWalk logic
local function TpWalk()
    local player = game.Players.LocalPlayer
    local character = player.Character

    if not character or not TpWalkEnabled then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoidRootPart and humanoid then
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            -- Smoother movement calculation
            local delta = game:GetService("RunService").Heartbeat:Wait()
            local movement = moveDirection * (WalkSpeed * delta)
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + movement
        end
    end
end

-- Create a toggle instance variable to reference later
local tpWalkToggle = Tabs.Modifications:Toggle({
    Title = "Enable WalkSpeed",
    Description = "",
    Default = false,
    Callback = function(state)
        TpWalkEnabled = state

        -- Clean up existing connection
        if tpWalkConnection then
            tpWalkConnection:Disconnect()
            tpWalkConnection = nil
        end

        if state then
            -- Use RenderStepped for smoother animation
            tpWalkConnection = game:GetService("RunService").RenderStepped:Connect(TpWalk)
        end
    end
})

-- Create a keybind that controls the toggle state
Tabs.Modifications:Keybind({
    Title = "WalkSpeed Keybind",
    Description = "Change the Keybind to enable WalkSpeed",
    Value = "",
    CanChange = true,
    Callback = function()
        -- Toggle the state and update the UI
        TpWalkEnabled = not TpWalkEnabled
        tpWalkToggle:SetValue(TpWalkEnabled)
    end
})

-- Initialize variables for Noclip
local NoclipEnabled = false
local noclipConnection = nil
local noclipRenderConnection = nil

-- Create a section for Noclip controls
Tabs.Modifications:Section({ Title = " Noclip " })

-- Create toggle for Noclip
local noclipToggle = Tabs.Modifications:Toggle({
    Title = "Noclip",
    Description = "Phase through objects",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
        
        -- Clean up existing connections
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if noclipRenderConnection then
            noclipRenderConnection:Disconnect()
            noclipRenderConnection = nil
        end
        
        if state then
            -- Setup Noclip with both Stepped and RenderStepped for better reliability
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                local player = game.Players.LocalPlayer
                if not player then return end
                
                local character = player.Character
                if not character then return end
                
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
            
            -- Add a second connection to RenderStepped for smoother performance
            noclipRenderConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if not player then return end
                
                local character = player.Character
                if not character then return end
                
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            -- Reset collision when disabled
            local player = game.Players.LocalPlayer
            if not player then return end
            
            local character = player.Character
            if not character then return end
            
            -- Use pcall to prevent errors when setting CanCollide
            pcall(function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end)
        end
    end
})

-- Add keybind for Noclip
Tabs.Modifications:Keybind({
    Title = "Toggle Noclip Keybind",
    Description = "Change the Keybind to enable Noclip",
    Value = "",
    CanChange = true,
    Callback = function()
        -- Toggle the state and update the UI
        NoclipEnabled = not NoclipEnabled
        noclipToggle:SetValue(NoclipEnabled)
    end
})

-- Add character added event to maintain noclip when character respawns
Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if NoclipEnabled then
        -- Short delay to ensure character is fully loaded
        task.wait(0.5)
        
        -- Re-enable noclip if it was enabled
        noclipToggle:SetValue(false)
        task.wait(0.1)
        noclipToggle:SetValue(true)
    end
end)

-- Cleanup on character removal
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if noclipRenderConnection then
        noclipRenderConnection:Disconnect()
        noclipRenderConnection = nil
    end
end)

-- Initialize variables for Flying
local FlyEnabled = false
local flyConnection = nil
local flySpeed = 50
local currentBodyVelocity = nil

-- Create a section for Flying controls
Tabs.Modifications:Section({ Title = " Fly " })

-- Add slider for fly speed
Tabs.Modifications:Slider({
    Title = "Fly Speed",
    Description = "Adjust flying speed",
    Value = {
        Min = 1,
        Max = 200,
        Default = 50,
        Precise = 1
    },
    Callback = function(value)
        flySpeed = value
    end
})

-- Create toggle for Flying
local flyToggle = Tabs.Modifications:Toggle({
    Title = "Enable Flying",
    Description = "Toggle player flying ability",
    Default = false,
    Callback = function(state)
        -- Prevent toggle from auto-enabling
        if state ~= FlyEnabled then
            FlyEnabled = state
            
            -- Cleanup existing connections and physics
            local function cleanupFlyComponents()
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                
                if currentBodyVelocity then
                    currentBodyVelocity:Destroy()
                    currentBodyVelocity = nil
                end
            end

            cleanupFlyComponents()
            
            if state then
                -- Initialize flying components
                local player = game.Players.LocalPlayer
                if not player then return end
                
                local character = player.Character
                if not character then return end
                
                local UserInputService = game:GetService("UserInputService")
                
                local humanoid = character:FindFirstChild("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if not (humanoid and humanoidRootPart) then return end
                
                -- Setup anti-gravity physics
                currentBodyVelocity = Instance.new("BodyVelocity")
                currentBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                currentBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                currentBodyVelocity.Parent = humanoidRootPart
                
                -- Movement key mapping
                local MOVEMENT_KEYS = {
                    [Enum.KeyCode.W] = function(camera) return camera.CFrame.LookVector end,
                    [Enum.KeyCode.S] = function(camera) return -camera.CFrame.LookVector end,
                    [Enum.KeyCode.A] = function(camera) return -camera.CFrame.RightVector end,
                    [Enum.KeyCode.D] = function(camera) return camera.CFrame.RightVector end,
                    [Enum.KeyCode.Space] = function() return Vector3.new(0, 1, 0) end,
                    [Enum.KeyCode.LeftControl] = function() return Vector3.new(0, -1, 0) end
                }
                
                -- Handle flying movement with improved performance
                flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    if not camera then return end
                    
                    local moveDirection = Vector3.new(0, 0, 0)
                    
                    -- Calculate movement direction
                    for key, getVector in pairs(MOVEMENT_KEYS) do
                        if UserInputService:IsKeyDown(key) then
                            local vectorValue = getVector(camera)
                            if vectorValue then
                                moveDirection = moveDirection + vectorValue
                            end
                        end
                    end
                    
                    -- Apply smooth movement with direction normalization
                    if currentBodyVelocity and currentBodyVelocity.Parent then
                        currentBodyVelocity.Velocity = moveDirection.Magnitude > 0 
                            and moveDirection.Unit * flySpeed 
                            or Vector3.new(0, 0, 0)
                    else
                        -- If BodyVelocity was removed, recreate it
                        if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
                            currentBodyVelocity = Instance.new("BodyVelocity")
                            currentBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                            currentBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            currentBodyVelocity.Parent = humanoidRootPart
                        end
                    end
                end)
            else
                -- Reset character state
                local player = game.Players.LocalPlayer
                if not player then return end
                
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoidRootPart then
                    humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end
    end
})

-- Add keybind for Flying
Tabs.Modifications:Keybind({
    Title = "Fly Keybind",
    Description = "Change the Keybind to enable Flying",
    Value = "",
    CanChange = true,
    Callback = function()
        -- Toggle the state and update the UI
        FlyEnabled = not FlyEnabled
        flyToggle:SetValue(FlyEnabled)
    end
})

-- Cleanup on character removal
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if currentBodyVelocity then
        currentBodyVelocity:Destroy()
        currentBodyVelocity = nil
    end
    FlyEnabled = false
    flyToggle:SetValue(false)
end)
------------------------------------------------------------------ Configuration ------------------------------------------------------------------
local HttpService = game:GetService("HttpService")

local folderPath = "WindUI"
makefolder(folderPath)

local function SaveFile(fileName, data)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    local jsonData = HttpService:JSONEncode(data)
    writefile(filePath, jsonData)
end

local function LoadFile(fileName)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    if isfile(filePath) then
        local jsonData = readfile(filePath)
        return HttpService:JSONDecode(jsonData)
    end
end

local function ListFiles()
    local files = {}
    for _, file in ipairs(listfiles(folderPath)) do
        local fileName = file:match("([^/]+)%.json$")
        if fileName then
            table.insert(files, fileName)
        end
    end
    return files
end

Tabs.Settings:Section({ Title = "Window" })

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown = Tabs.Settings:Dropdown({
    Title = "Select Theme",
    Multi = false,
    AllowNone = false,
    Value = nil,
    Values = themeValues,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
themeDropdown:Select(WindUI:GetCurrentTheme())

local ToggleTransparency = Tabs.Settings:Toggle({
    Title = "Toggle Window Transparency",
    Callback = function(e)
        Window:ToggleTransparency(e)
    end,
    Value = WindUI:GetTransparency()
})

Tabs.Settings:Section({ Title = "Save" })

local fileNameInput = ""
Tabs.Settings:Input({
    Title = "Write File Name",
    PlaceholderText = "Enter file name",
    Callback = function(text)
        fileNameInput = text
    end
})

Tabs.Settings:Button({
    Title = "Save File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.Settings:Section({ Title = "Load" })

local filesDropdown
local files = ListFiles()

filesDropdown = Tabs.Settings:Dropdown({
    Title = "Select File",
    Multi = false,
    AllowNone = true,
    Values = files,
    Callback = function(selectedFile)
        fileNameInput = selectedFile
    end
})

Tabs.Settings:Button({
    Title = "Load File",
    Callback = function()
        if fileNameInput ~= "" then
            local data = LoadFile(fileNameInput)
            if data then
                WindUI:Notify({
                    Title = "File Loaded",
                    Content = "Loaded data: " .. HttpService:JSONEncode(data),
                    Duration = 5,
                })
                if data.Transparent then 
                    Window:ToggleTransparency(data.Transparent)
                    ToggleTransparency:SetValue(data.Transparent)
                end
                if data.Theme then WindUI:SetTheme(data.Theme) end
            end
        end
    end
})

Tabs.Settings:Button({
    Title = "Overwrite File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.Settings:Button({
    Title = "Refresh List",
    Callback = function()
        filesDropdown:Refresh(ListFiles())
    end
})

Tabs.Settings:Section({ Title = "Create Theme" })

local currentThemeName = WindUI:GetCurrentTheme()
local themes = WindUI:GetThemes()

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].PlaceholderText

function updateTheme()
    WindUI:AddTheme({
        Name = currentThemeName,
        Accent = ThemeAccent,
        Outline = ThemeOutline,
        Text = ThemeText,
        PlaceholderText = ThemePlaceholderText
    })
    WindUI:SetTheme(currentThemeName)
end

local CreateInput = Tabs.Settings:Input({
    Title = "Theme Name",
    Value = currentThemeName,
    Callback = function(name)
        currentThemeName = name
    end
})

Tabs.Settings:Colorpicker({
    Title = "Background Color",
    Default = Color3.fromHex(ThemeAccent),
    Callback = function(color)
        ThemeAccent = color:ToHex()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Outline Color",
    Default = Color3.fromHex(ThemeOutline),
    Callback = function(color)
        ThemeOutline = color:ToHex()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Text Color",
    Default = Color3.fromHex(ThemeText),
    Callback = function(color)
        ThemeText = color:ToHex()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Placeholder Text Color",
    Default = Color3.fromHex(ThemePlaceholderText),
    Callback = function(color)
        ThemePlaceholderText = color:ToHex()
    end
})

Tabs.Settings:Button({
    Title = "Update Theme",
    Callback = function()
        updateTheme()
    end
})
