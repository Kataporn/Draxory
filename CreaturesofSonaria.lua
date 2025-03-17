repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- Initialize DarkPurple theme
local darkPurpleTheme = {
    Name = "DarkPurple",
    Accent = "#04021f",
    Outline = "#8A2BE2",
    Text = "#ffffff",
    PlaceholderText = "#ffffff"
}

-- Add DarkPurple theme to WindUI
WindUI:AddTheme(darkPurpleTheme)

local Window = WindUI:CreateWindow({
    Title = "Grimvale",
    Icon = "rbxassetid://139028703331590",
    Author = "Example UI",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "DarkPurple", -- Set default theme to DarkPurple
    SideBarWidth = 200,
    --Background = "rbxassetid://13511292247", -- rbxassetid only
    HasOutline = false,
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
    main = Window:Tab({ Title = "Main", Icon = "mouse-pointer-2", Desc = "" }),
    b = Window:Divider(),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings", Desc = "" }),
}

Window:SelectTab(1)

-- Variables to store connections
local teleportLoop = nil
local autoEConnection = nil

-- Combined Features Section
Tabs.main:Section({ Title = "Features" })

-- Create a toggle for both teleport and auto press
Tabs.main:Toggle({
    Title = "Auto Farm Water 💧",
    Default = false,
    Callback = function(state)
        if state then
            -- Start teleport loop
            teleportLoop = game:GetService("RunService").Heartbeat:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.CFrame = CFrame.new(-971.976501, 287.972504, -511.114258, -0.572483838, 0.160252288, -0.804102898, -0.248510242, 0.900668621, 0.356424868, 0.781348228, 0.403875291, -0.475793779)
                end
            end)
            
            -- Start auto pressing E
            autoEConnection = game:GetService("RunService").Heartbeat:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                wait(10) -- Small delay to prevent excessive key presses
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
            end)
        else
            -- Stop both loops
            if teleportLoop then
                teleportLoop:Disconnect()
                teleportLoop = nil
            end
            if autoEConnection then
                autoEConnection:Disconnect()
                autoEConnection = nil
            end
        end
    end
})

---------------------------------------     Configuration    -----------------------------------------------------------------

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

-- Window Settings Section
Tabs.Settings:Section({ Title = "Window Settings" })

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown = Tabs.Settings:Dropdown({
    Title = "Select Theme",
    Multi = false,
    AllowNone = false,
    Value = "DarkPurple", -- Set default value to DarkPurple
    Values = themeValues,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
themeDropdown:Select("DarkPurple") -- Select DarkPurple by default

local ToggleTransparency = Tabs.Settings:Toggle({
    Title = "Window Transparency",
    Callback = function(e)
        Window:ToggleTransparency(e)
    end,
    Value = WindUI:GetTransparency()
})

-- Theme Creator Section
Tabs.Settings:Section({ Title = "Theme Creator" })

local currentThemeName = "DarkPurple"
local themes = {
    DarkPurple = {
        Accent = "#04021f",
        Outline = "#8A2BE2", 
        Text = "#ffffff",
        PlaceholderText = "#ffffff"
    }
}

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].PlaceholderText

-- Auto-update theme function
local function updateTheme()
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
        updateTheme()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Background Color",
    Default = Color3.fromHex(ThemeAccent),
    Callback = function(color)
        ThemeAccent = color:ToHex()
        updateTheme()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Outline Color",
    Default = Color3.fromHex(ThemeOutline),
    Callback = function(color)
        ThemeOutline = color:ToHex()
        updateTheme()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Text Color",
    Default = Color3.fromHex(ThemeText),
    Callback = function(color)
        ThemeText = color:ToHex()
        updateTheme()
    end
})

Tabs.Settings:Colorpicker({
    Title = "Placeholder Text Color",
    Default = Color3.fromHex(ThemePlaceholderText),
    Callback = function(color)
        ThemePlaceholderText = color:ToHex()
        updateTheme()
    end
})

-- Configuration Management Section
Tabs.Settings:Section({ Title = "Configuration Management" })

local fileNameInput = ""
Tabs.Settings:Input({
    Title = "Configuration Name",
    PlaceholderText = "Enter configuration name",
    Callback = function(text)
        fileNameInput = text
    end
})

local filesDropdown
local files = ListFiles()

filesDropdown = Tabs.Settings:Dropdown({
    Title = "Saved Configurations",
    Multi = false,
    AllowNone = true,
    Values = files,
    Callback = function(selectedFile)
        fileNameInput = selectedFile
    end
})

Tabs.Settings:Button({
    Title = "Save Configuration",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.Settings:Button({
    Title = "Load Configuration",
    Callback = function()
        if fileNameInput ~= "" then
            local data = LoadFile(fileNameInput)
            if data then
                WindUI:Notify({
                    Title = "Configuration Loaded",
                    Content = "Loaded settings: " .. HttpService:JSONEncode(data),
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
    Title = "Refresh Configurations",
    Callback = function()
        filesDropdown:Refresh(ListFiles())
    end
})
