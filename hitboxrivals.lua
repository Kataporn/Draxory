local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Chiffon Hub" .. " | ".."Hitbox : Rival".." | ".."[Version 1]",
    Icon = "",
    Author = "",
    Folder = "Chiffon",
    Size = UDim2.fromOffset(579, 513),
    Transparent = true,
    Theme = "Dark", -- Set theme to DefaultTheme
    SideBarWidth = 200,
    --Background = "rbxassetid://105273285764750",
    HasOutline = false,
    ToggleKey = Enum.KeyCode.Insert
})


    Window:EditOpenButton({
        Title = "Open Example UI",
        Icon = "monitor",
        CornerRadius = UDim.new(0,10),
        StrokeThickness = 2,
        Color = ColorSequence.new( -- gradient
            Color3.fromHex("FF0F7B"), 
            Color3.fromHex("F89B29")
        ),
        --Enabled = false,
        Draggable = true,
    })


    local Tabs = {
        AutoFarm = Window:Tab({ Title = "AutoFarm [Beta Testing]", Icon = "mouse-pointer-2", Desc = "Automated farming and grinding features." }),
        General = Window:Tab({ Title = "General", Icon = "mouse-pointer-2", Desc = "General settings and basic functions for the application." }),
        Modifications = Window:Tab({ Title = "Modifications", Icon = "settings-2", Desc = "Modify player movement and physics settings." }),
        Risk = Window:Tab({ Title = "Risk", Icon = "alert-triangle", Desc = "Features that may be detected by anti-cheat systems." }),
        Style = Window:Tab({ Title = "Style", Icon = "brush", Desc = "Customize the visual appearance and style settings." }),
        b = Window:Divider(),
        Configuration = Window:Tab({ Title = "Configuration", Icon = "settings", Desc = "Manage window settings and file configurations." }),
    }

    Window:SelectTab(1)

    Tabs.General:Section({ Title = "Spam" })

Tabs.General:Section({ Title = "Auto Steal" })

local autoStealEnabled = false
local stealConnection = nil
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

-- Function to find ball hitbox with error handling
local function findBall()
    local success, ball = pcall(function()
        return workspace.Football:FindFirstChild("FootBallHitbox")
    end)
    return success and ball or nil
end

-- Enhanced auto steal function with optimizations
local function autoSteal()
    local ball = findBall()
    local player = Players.LocalPlayer
    local character = player.Character
    
    if not ball or not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Optimize movement calculations
    local ballPos = ball.Position + Vector3.new(0, 3, 0) -- Offset above the ball to prevent falling
    local characterPos = humanoidRootPart.Position
    local distance = (characterPos - ballPos).Magnitude
    
    -- Faster speed adjustment for quicker response
    local speed = math.min(distance/120, 0.1)
    
    -- Enhanced tween with smoother movement
    local tweenInfo = TweenInfo.new(
        speed,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    -- Create and play optimized tween with offset position
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(ballPos)}
    )
    
    -- Add error handling for tween
    local success = pcall(function()
        tween:Play()
        tween.Completed:Wait()
        
        -- Quick key press simulation
        VirtualInputManager:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, "E", false, game)
    end)
    
    if not success then
        tween:Cancel()
    end
end

-- Create toggle for auto steal
local autoStealToggle = Tabs.General:Toggle({
    Title = "Auto Steal Ball",
    Default = false,
    Callback = function(state)
        autoStealEnabled = state
        
        if state then
            stealConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if autoStealEnabled then
                    autoSteal()
                end
            end)
        else
            if stealConnection then
                stealConnection:Disconnect()
                stealConnection = nil
            end
        end
    end
})

-- Add keybind for auto steal
Tabs.General:Keybind({
    Title = "Auto Steal Keybind",
    Description = "Press to toggle Auto Steal",
    Value = "",
    CanChange = true,
    Callback = function()
        autoStealEnabled = not autoStealEnabled
        autoStealToggle:SetValue(autoStealEnabled)
    end
})


local spamConnection = nil
local SpamDribbleEnabled = false

-- Create toggle instance first so we can reference it in keybind
spamToggle = Tabs.General:Toggle({
    Title = "Spam Drible",
    Default = false,
    Callback = function(state)
        SpamDribbleEnabled = state
        if state then
            -- Set dribble cooldown to 0
            workspace.dr4xory.Settings.DribbleCooldown.Value = 0
            
            -- Start spamming Q key
            spamConnection = game:GetService("RunService").Heartbeat:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "Q", false, game)
                task.wait()
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "Q", false, game)
            end)
        else
            -- Reset dribble cooldown to 3
            workspace.dr4xory.Settings.DribbleCooldown.Value = 3
            
            -- Stop spamming Q key
            if spamConnection then
                spamConnection:Disconnect()
                spamConnection = nil
            end
        end
    end
})

Tabs.General:Keybind({
    Title = "Dribble Keybind", 
    Description = "Change the Keybind to enable AutoDribble",
    Value = "",
    CanChange = true,
    Callback = function()
        -- Toggle the state and update the UI
        SpamDribbleEnabled = not SpamDribbleEnabled
        spamToggle:SetValue(SpamDribbleEnabled)
    end
})
    
    Tabs.General:Section({ Title = "Hitbox [Risk]" })

-- Configuration for hitbox modification
_G.HitboxSize = 50
_G.HitboxEnabled = true
_G.ShowVisual = true

-- Create a visual indicator for the hitbox
local function createVisualHitbox()
    local visual = Instance.new("Part")
    visual.Name = "HitboxVisual"
    visual.Anchored = true
    visual.CanCollide = false
    visual.Transparency = 0.5
    visual.Material = Enum.Material.ForceField
    visual.Color = Color3.fromRGB(255, 0, 0)
    visual.Shape = Enum.PartType.Ball
    return visual
end

local visualHitbox = createVisualHitbox()
local connection = nil

local function startHitboxUpdate()
    if connection then return end
    
    connection = game:GetService('RunService').RenderStepped:Connect(function()
        local Ball = workspace.Football:FindFirstChild("FootBallHitbox")
        
        if _G.HitboxEnabled and Ball then
            pcall(function()
                Ball.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                visualHitbox.Size = Ball.Size
                visualHitbox.CFrame = Ball.CFrame
                visualHitbox.Parent = _G.ShowVisual and workspace or nil
            end)
        else
            visualHitbox.Parent = nil
        end
    end)
end

local function stopHitboxUpdate()
    if connection then
        connection:Disconnect()
        connection = nil
        
        -- Reset ball size if it exists
        local Ball = workspace.Football:FindFirstChild("FootBallHitbox")
        if Ball then
            Ball.Size = Vector3.new(1, 1, 1) -- Reset to default size
        end
        
        -- Remove visual
        visualHitbox.Parent = nil
    end
end

-- Store references to the toggles
local hitboxToggle
local visualToggle

hitboxToggle = Tabs.General:Toggle({
    Title = "Enable Hitbox Extender",
    Default = true,
    Callback = function(state)
        _G.HitboxEnabled = state
        if state then
            startHitboxUpdate()
        else
            stopHitboxUpdate()
        end
        print("Hitbox extender: " .. (state and "Enabled" or "Disabled"))
    end
})

visualToggle = Tabs.General:Toggle({
    Title = "Show Hitbox Visual",
    Default = true,
    Callback = function(state)
        _G.ShowVisual = state
        visualHitbox.Transparency = state and 0.5 or 1
        print("Hitbox visual: " .. (state and "Visible" or "Hidden"))
    end
})

-- Add keybind for hitbox toggle
Tabs.General:Keybind({
    Title = "Hitbox Toggle Keybind",
    Description = "Press to toggle hitbox extender",
    Value = "",
    CanChange = true,
    Callback = function()
        _G.HitboxEnabled = not _G.HitboxEnabled
        hitboxToggle:SetValue(_G.HitboxEnabled)
    end
})

Tabs.General:Slider({
    Title = "Hitbox Size",
    Value = {
        Min = 1,
        Max = 1000,
        Default = _G.HitboxSize,
    },
    Callback = function(value)
        _G.HitboxSize = value
        print("Hitbox size updated to: " .. value)
    end
})

-- Start the hitbox update initially
startHitboxUpdate()
    
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



    Tabs.Risk:Section({ Title = "Stats" })

-- Get player stats references
local player = game:GetService("Players").LocalPlayer
local stats = player.Stats

-- Create labels to display current values
local statsLabels = {}
local inputValues = {} -- Store input values for each stat
local originalValues = {} -- Store original values before looping
    
-- Create a function to update all stat displays
local function updateStatsDisplay()
    for stat, label in pairs(statsLabels) do
        if stats:FindFirstChild(stat) then
            label:SetCode(stat .. ": " .. tostring(stats[stat].Value))
        end
    end
end

-- Create sections for each stat with input modification
local statsList = {
    "Ankles", "Assists", "Cash", "Goals", "Level",
    "LuckyFlowSpins", "LuckySpins", "Matches", "NormalFlowSpins",
    "NormalSpins", "Steals"
}

for _, statName in ipairs(statsList) do
    if stats:FindFirstChild(statName) then
        -- Create code display for current value
        statsLabels[statName] = Tabs.Risk:Code({
            Title = statName,
            Code = statName .. ": " .. tostring(stats[statName].Value)
        })
        
        -- Initialize input value storage
        inputValues[statName] = tostring(stats[statName].Value)
        
        -- Create input field for modification
        Tabs.Risk:Input({
            Title = "Set " .. statName,
            Default = tostring(stats[statName].Value),
            Placeholder = "Enter new " .. statName .. " value",
            NumbersOnly = true,
            Callback = function(input)
                inputValues[statName] = input
            end
        })

        -- Add toggle for looping value updates
        Tabs.Risk:Toggle({
            Title = "Loop " .. statName .. " Value", 
            Default = false,
            Callback = function(state)
                if state then
                    -- Store original value
                    originalValues[statName] = stats[statName].Value
                    
                    -- Set new value immediately when toggle is turned on
                    local newValue = tonumber(inputValues[statName])
                    if newValue then
                        local success, err = pcall(function()
                            local statObj = stats[statName]
                            local newStat = Instance.new("NumberValue")
                            newStat.Value = newValue
                            newStat.Name = statName
                            statObj:Destroy()
                            newStat.Parent = stats
                        end)
                        
                        if not success then
                            warn("Failed to set " .. statName .. ": " .. tostring(err))
                        end
                    end
                else
                    -- Restore original value when toggle is turned off
                    if originalValues[statName] then
                        local success, err = pcall(function()
                            local statObj = stats[statName]
                            local newStat = Instance.new("NumberValue")
                            newStat.Value = originalValues[statName]
                            newStat.Name = statName
                            statObj:Destroy()
                            newStat.Parent = stats
                        end)
                        
                        if not success then
                            warn("Failed to restore " .. statName .. ": " .. tostring(err))
                        end
                        originalValues[statName] = nil
                    end
                end
            end
        })
    end
end

-- Create connection for stats display update and cash monitoring
local updateConnection
updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
    if not player or not player.Parent then
        updateConnection:Disconnect()
        return
    end
    updateStatsDisplay()
    checkCashChange()
end)

-- Variables for style selection and auto spin
local selectedStyle = "None"
local autoSpinEnabled = false
local spinConnection = nil
local autoSpinToggle = nil -- Store toggle reference

-- Create dropdown for style selection
Tabs.Style:Dropdown({
    Title = "Select Style to Get",
    Values = { "Isagi", "Chigiri", "King","Nagi", "Rin", "Sae", "Shidou" },
    Value = "None",
    Callback = function(option) 
        selectedStyle = option
        print("Target Style: " .. option)
    end
})

-- Create toggle for auto spin
autoSpinToggle = Tabs.Style:Toggle({
    Title = "Auto Spin Normal Until Get Selected Style",
    Default = false,
    Callback = function(state)
        autoSpinEnabled = state
        
        if state then
            -- Set GUI selection to spin button
            game.GuiService.SelectedObject = game:GetService("Players").LocalPlayer.PlayerGui.MainSpinGui.SpinGui.NormalSpin
            
            spinConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoSpinEnabled then
                    -- Get current style and check if matches selected style
                    local currentStyle = game:GetService("Players").LocalPlayer.Stats.Style.Value
                    
                    -- If current style matches selected style, stop spinning
                    if currentStyle == selectedStyle then
                        autoSpinEnabled = false
                        autoSpinToggle:SetValue(false) -- Turn off the toggle
                        if spinConnection then
                            spinConnection:Disconnect()
                            spinConnection = nil
                        end
                        return
                    end
                    
                    -- Continue spinning if styles don't match
                    local spinButton = game:GetService("Players").LocalPlayer.PlayerGui.MainSpinGui.SpinGui.NormalSpin
                    if spinButton then
                        -- Press Enter key to activate spin button
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        
                        -- Click the spin button
                        local args = {
                            [1] = "Enter"
                        }
                        spinButton.MouseButton1Click:Fire(unpack(args))
                        
                        task.wait(5) -- Wait for spin animation
                    end
                    task.wait(1) -- Wait between spins
                end
            end)
        else
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
        end
    end
})

-- Create toggle for auto lucky spin
autoSpinToggle = Tabs.Style:Toggle({
    Title = "Auto Lucky Spin Until Get Selected Style",
    Default = false,
    Callback = function(state)
        autoSpinEnabled = state
        
        if state then
            -- Set GUI selection to lucky spin button
            game.GuiService.SelectedObject = game:GetService("Players").LocalPlayer.PlayerGui.MainSpinGui.SpinGui.LuckySpin
            
            spinConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoSpinEnabled then
                    -- Get current style and check if matches selected style
                    local currentStyle = game:GetService("Players").LocalPlayer.Stats.Style.Value
                    
                    -- If current style matches selected style, stop spinning
                    if currentStyle == selectedStyle then
                        autoSpinEnabled = false
                        autoSpinToggle:SetValue(false) -- Turn off the toggle
                        if spinConnection then
                            spinConnection:Disconnect()
                            spinConnection = nil
                        end
                        return
                    end
                    
                    -- Continue spinning if styles don't match
                    local spinButton = game:GetService("Players").LocalPlayer.PlayerGui.MainSpinGui.SpinGui.LuckySpin
                    if spinButton then
                        -- Press Enter key to activate spin button
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        
                        -- Click the lucky spin button
                        local args = {
                            [1] = "Enter"
                        }
                        spinButton.MouseButton1Click:Fire(unpack(args))
                        
                        task.wait(5) -- Wait for spin animation
                    end
                    task.wait(1) -- Wait between spins
                end
            end)
        else
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
        end
    end
})

Tabs.AutoFarm:Code({
    Title = "Money",
    Code = tostring(game:GetService("Players").LocalPlayer.Stats.Cash.Value)
})

local autoFarmEnabled = false
local farmConnection = nil
local lastClickTime = 0
local clickCooldown = 2 -- Cooldown in seconds between actions

Tabs.AutoFarm:Toggle({
    Title = "Auto Farm [Teleport] Home", 
    Default = false,
    Callback = function(state)
        autoFarmEnabled = state
        
        if state then
            -- Teleport to lobby popup GUI first
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = workspace.Lobby.PopUpGui.CFrame
                
                -- Wait 5 seconds before proceeding
                task.wait(5)
                
                -- Set selected objects for positions and continuously send Enter key
                local positions = {
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Home.CenterForward,
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Home.CenterMid,
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Home.LeftWinger,
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Home.RightWinger,
                }
                
                -- Continuously send Enter key while cycling through positions
                local positionIndex = 1
                while positionIndex <= #positions and autoFarmEnabled do
                    game.GuiService.SelectedObject = positions[positionIndex]
                    
                    -- Send Enter key continuously for this position
                    for i = 1, 10 do -- Send Enter 10 times per position
                        if not autoFarmEnabled then break end
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                    end
                    
                    positionIndex = positionIndex + 1
                end
            end

            farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoFarmEnabled then
                    -- Get required references
                    local character = game.Players.LocalPlayer.Character
                    if not character then return end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then return end
                    
                    local ball = workspace.Football:FindFirstChild("FootBallHitbox")
                    local goal = workspace.Map.HomeGoal:FindFirstChild("GoalHitbox")
                    if not ball or not goal then return end
                    
                    -- Check cooldown before performing actions
                    local currentTime = tick()
                    if currentTime - lastClickTime >= clickCooldown then
                        -- First teleport to ball
                        humanoidRootPart.CFrame = CFrame.new(ball.Position)
                        task.wait(0.1) -- Small delay
                        
                        -- Then teleport to goal
                        humanoidRootPart.CFrame = CFrame.new(goal.Position)
                        
                        -- Click to shoot
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        
                        lastClickTime = currentTime
                    end
                end
            end)
        else
            if farmConnection then
                farmConnection:Disconnect()
                farmConnection = nil
            end
        end
    end
})

Tabs.AutoFarm:Toggle({
    Title = "Auto Farm [Teleport] Away", 
    Default = false,
    Callback = function(state)
        autoFarmEnabled = state
        
        if state then
            -- Teleport to lobby popup GUI first
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = workspace.Lobby.PopUpGui.CFrame
                
                -- Wait 5 seconds before proceeding
                task.wait(5)
                
                -- Set selected objects for positions and continuously send Enter key
                local positions = {
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Away.CenterForward,
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Away.CenterMid,
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Away.LeftWinger,
                    game:GetService("Players").LocalPlayer.PlayerGui.Main.GoalPositions.Away.RightWinger,
                }
                
                -- Continuously send Enter key while cycling through positions
                local positionIndex = 1
                while positionIndex <= #positions and autoFarmEnabled do
                    game.GuiService.SelectedObject = positions[positionIndex]
                    
                    -- Send Enter key continuously for this position
                    for i = 1, 10 do -- Send Enter 10 times per position
                        if not autoFarmEnabled then break end
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                    end
                    
                    positionIndex = positionIndex + 1
                end
            end

            farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if autoFarmEnabled then
                    -- Get required references
                    local character = game.Players.LocalPlayer.Character
                    if not character then return end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then return end
                    
                    local ball = workspace.Football:FindFirstChild("FootBallHitbox")
                    local goal = workspace.Map.AwayGoal:FindFirstChild("GoalHitbox")
                    if not ball or not goal then return end
                    
                    -- Check cooldown before performing actions
                    local currentTime = tick()
                    if currentTime - lastClickTime >= clickCooldown then
                        -- First teleport to ball
                        humanoidRootPart.CFrame = CFrame.new(ball.Position)
                        task.wait(0.1) -- Small delay
                        
                        -- Then teleport to goal
                        humanoidRootPart.CFrame = CFrame.new(goal.Position)
                        
                        -- Click to shoot
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        
                        lastClickTime = currentTime
                    end
                end
            end)
        else
            if farmConnection then
                farmConnection:Disconnect()
                farmConnection = nil
            end
        end
    end
})


    -- Configuration


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

    Tabs.Configuration:Section({ Title = "Window" })

    local themeValues = {}
    for name, _ in pairs(WindUI:GetThemes()) do
        table.insert(themeValues, name)
    end

    local themeDropdown = Tabs.Configuration:Dropdown({
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

    local ToggleTransparency = Tabs.Configuration:Toggle({
        Title = "Toggle Window Transparency",
        Callback = function(e)
            Window:ToggleTransparency(e)
        end,
        Value = WindUI:GetTransparency()
    })

    Tabs.Configuration:Section({ Title = "Save" })

    local fileNameInput = ""
    Tabs.Configuration:Input({
        Title = "Write File Name",
        PlaceholderText = "Enter file name",
        Callback = function(text)
            fileNameInput = text
        end
    })

    Tabs.Configuration:Button({
        Title = "Save File",
        Callback = function()
            if fileNameInput ~= "" then
                SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
            end
        end
    })

    Tabs.Configuration:Section({ Title = "Load" })

    local filesDropdown
    local files = ListFiles()

    filesDropdown = Tabs.Configuration:Dropdown({
        Title = "Select File",
        Multi = false,
        AllowNone = true,
        Values = files,
        Callback = function(selectedFile)
            fileNameInput = selectedFile
        end
    })

    Tabs.Configuration:Button({
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

    Tabs.Configuration:Button({
        Title = "Overwrite File",
        Callback = function()
            if fileNameInput ~= "" then
                SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
            end
        end
    })

    Tabs.Configuration:Button({
        Title = "Refresh List",
        Callback = function()
            filesDropdown:Refresh(ListFiles())
        end
    })

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

    local CreateInput = Tabs.Configuration:Input({
        Title = "Theme Name",
        Value = currentThemeName,
        Callback = function(name)
            currentThemeName = name
        end
    })

    Tabs.Configuration:Colorpicker({
        Title = "Background Color",
        Default = Color3.fromHex(ThemeAccent),
        Callback = function(color)
            ThemeAccent = color:ToHex()
        end
    })

    Tabs.Configuration:Colorpicker({
        Title = "Outline Color",
        Default = Color3.fromHex(ThemeOutline),
        Callback = function(color)
            ThemeOutline = color:ToHex()
        end
    })

    Tabs.Configuration:Colorpicker({
        Title = "Text Color",
        Default = Color3.fromHex(ThemeText),
        Callback = function(color)
            ThemeText = color:ToHex()
        end
    })

    Tabs.Configuration:Colorpicker({
        Title = "Placeholder Text Color",
        Default = Color3.fromHex(ThemePlaceholderText),
        Callback = function(color)
            ThemePlaceholderText = color:ToHex()
        end
    })

    Tabs.Configuration:Button({
        Title = "Update Theme",
        Callback = function()
            updateTheme()
        end
    })
