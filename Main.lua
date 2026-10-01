--[[
    SPS-HUB Main Entry Point
    Universal Roblox Admin Hub - Works in any game
    Load this in Xeno to initialize the hub
]]

-- Prevent multiple loads
if _G.SPS_HUB_LOADED then
    print("⚠️ SPS-HUB is already loaded!")
    return
end

_G.SPS_HUB_LOADED = true

print("🚀 SPS-HUB Initializing...")

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local CONFIG = {
    ToggleKey = Enum.KeyCode.RightShift,
    HubVersion = "1.0.1",
}

-- Store hub settings
local HUB_SETTINGS = {
    Weapon = {
        HitboxEnabled = false,
        HitboxSize = 5,
        HitboxTransparency = 0.3,
        HitboxColor = Color3.fromRGB(218, 165, 32),
    }
}

-- Track active hitboxes
local ACTIVE_HITBOXES = {}

-- ============================================================================
-- UNIVERSAL UTILITIES
-- ============================================================================

local function getPlayerCharacter()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        return player.Character
    end
    return nil
end

local function getPlayers()
    return game.Players:GetPlayers()
end

local function findCharacterByPlayer(player)
    if player and player.Character then
        return player.Character
    end
    return nil
end

local function getHumanoid(character)
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

local function getRootPart(character)
    if character then
        return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    end
    return nil
end

-- ============================================================================
-- HITBOX SYSTEM (UNIVERSAL)
-- ============================================================================

local HitboxSystem = {}

function HitboxSystem:createHitbox(parent)
    if not parent then return nil end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "SPS_Hitbox"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Material = Enum.Material.Neon
    hitbox.CanCollide = false
    hitbox.CFrame = parent.CFrame
    hitbox.Size = Vector3.new(HUB_SETTINGS.Weapon.HitboxSize, HUB_SETTINGS.Weapon.HitboxSize, HUB_SETTINGS.Weapon.HitboxSize)
    hitbox.Color = HUB_SETTINGS.Weapon.HitboxColor
    hitbox.Transparency = HUB_SETTINGS.Weapon.HitboxTransparency
    hitbox.TopSurface = Enum.SurfaceType.Smooth
    hitbox.BottomSurface = Enum.SurfaceType.Smooth
    hitbox.Parent = parent
    
    -- Weld to parent if parent has humanoid root part
    if parent:FindFirstChild("HumanoidRootPart") then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = parent:FindFirstChild("HumanoidRootPart")
        weld.Part1 = hitbox
        weld.Parent = hitbox
    end
    
    return hitbox
end

function HitboxSystem:updateHitbox(hitbox)
    if hitbox and hitbox.Parent then
        hitbox.Size = Vector3.new(HUB_SETTINGS.Weapon.HitboxSize, HUB_SETTINGS.Weapon.HitboxSize, HUB_SETTINGS.Weapon.HitboxSize)
        hitbox.Color = HUB_SETTINGS.Weapon.HitboxColor
        hitbox.Transparency = HUB_SETTINGS.Weapon.HitboxTransparency
    end
end

function HitboxSystem:removeHitbox(hitbox)
    if hitbox and hitbox.Parent then
        hitbox:Destroy()
    end
end

function HitboxSystem:toggleAllHitboxes(enable)
    if enable then
        local players = getPlayers()
        for _, player in ipairs(players) do
            local character = findCharacterByPlayer(player)
            if character and not ACTIVE_HITBOXES[player] then
                local hitbox = self:createHitbox(character)
                if hitbox then
                    ACTIVE_HITBOXES[player] = hitbox
                end
            end
        end
    else
        for player, hitbox in pairs(ACTIVE_HITBOXES) do
            self:removeHitbox(hitbox)
        end
        ACTIVE_HITBOXES = {}
    end
end

-- Monitor new players joining
game.Players.PlayerAdded:Connect(function(player)
    if HUB_SETTINGS.Weapon.HitboxEnabled then
        player.CharacterAdded:Connect(function(character)
            wait(0.1)
            local hitbox = HitboxSystem:createHitbox(character)
            if hitbox then
                ACTIVE_HITBOXES[player] = hitbox
            end
        end)
    end
end)

-- Remove hitbox when player leaves
game.Players.PlayerRemoving:Connect(function(player)
    if ACTIVE_HITBOXES[player] then
        HitboxSystem:removeHitbox(ACTIVE_HITBOXES[player])
        ACTIVE_HITBOXES[player] = nil
    end
end)

-- ============================================================================
-- GUI LOADER
-- ============================================================================

local GUI = {}
GUI.Version = "1.0.1"

-- Colors
local DESIGN = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        SecondaryBG = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(218, 165, 32),
        AccentLight = Color3.fromRGB(255, 200, 50),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(100, 85, 50),
        ButtonHover = Color3.fromRGB(50, 50, 65),
        ButtonActive = Color3.fromRGB(218, 165, 32),
    },
    Dimensions = {
        MainWindowWidth = 450,
        MainWindowHeight = 600,
        TabButtonHeight = 40,
        PanelPadding = 15,
        CornerRadius = 8,
        BorderThickness = 2,
    },
    Animation = {
        TweenDuration = 0.3,
        TweenStyle = Enum.EasingStyle.Quad,
        TweenDirection = Enum.EasingDirection.Out,
    },
}

-- Utility Functions
local function createFrame(parent, props)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BorderSizePixel = 0
    for key, value in pairs(props or {}) do
        frame[key] = value
    end
    return frame
end

local function createTextLabel(parent, props)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    for key, value in pairs(props or {}) do
        label[key] = value
    end
    return label
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or DESIGN.Dimensions.CornerRadius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or DESIGN.Colors.Border
    stroke.Thickness = thickness or DESIGN.Dimensions.BorderThickness
    stroke.Parent = parent
    return stroke
end

local function tweenProperty(object, property, endValue, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or DESIGN.Animation.TweenDuration,
        style or DESIGN.Animation.TweenStyle,
        direction or DESIGN.Animation.TweenDirection
    )
    local tween = game:GetService("TweenService"):Create(object, tweenInfo, {[property] = endValue})
    tween:Play()
    return tween
end

-- ============================================================================
-- GUI CLASS
-- ============================================================================

function GUI.new()
    local self = setmetatable({}, {__index = GUI})
    
    local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SPS-HUB-GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = PlayerGui
    
    self.IsDragging = false
    self.DragOffset = Vector2.new(0, 0)
    self.CurrentTab = 1
    self.Tabs = {}
    
    self:createMainWindow()
    
    return self
end

function GUI:createMainWindow()
    self.MainWindow = createFrame(self.ScreenGui, {
        Name = "MainWindow",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(0, DESIGN.Dimensions.MainWindowWidth, 0, DESIGN.Dimensions.MainWindowHeight),
        Position = UDim2.new(0.5, -DESIGN.Dimensions.MainWindowWidth / 2, 0.5, -DESIGN.Dimensions.MainWindowHeight / 2),
    })
    
    createCorner(self.MainWindow, DESIGN.Dimensions.CornerRadius)
    createStroke(self.MainWindow, DESIGN.Colors.Border, 2)
    self:addShadow(self.MainWindow)
    self:createTitleBar()
    self:createTabBar()
    self:createContentArea()
end

function GUI:addShadow(target)
    local shadow = createFrame(target.Parent, {
        Name = "Shadow",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = target.Size,
        Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset + 5, target.Position.Y.Scale, target.Position.Y.Offset + 5),
        ZIndex = target.ZIndex - 1,
    })
    createCorner(shadow, DESIGN.Dimensions.CornerRadius)
    
    local connection
    connection = target.Changed:Connect(function(prop)
        if prop == "Position" or prop == "Size" then
            shadow.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset + 5, target.Position.Y.Scale, target.Position.Y.Offset + 5)
            shadow.Size = target.Size
        end
    end)
end

function GUI:createTitleBar()
    local titleBar = createFrame(self.MainWindow, {
        Name = "TitleBar",
        BackgroundColor3 = DESIGN.Colors.SecondaryBG,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    createCorner(titleBar, DESIGN.Dimensions.CornerRadius)
    
    local titleText = createTextLabel(titleBar, {
        Name = "Title",
        Text = "SPS-HUB v" .. CONFIG.HubVersion,
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, DESIGN.Dimensions.PanelPadding, 0, 0),
    })
    
    local closeButton = createFrame(titleBar, {
        Name = "CloseButton",
        BackgroundColor3 = DESIGN.Colors.ButtonHover,
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -45, 0.5, -17.5),
    })
    
    createCorner(closeButton, 6)
    
    local closeText = createTextLabel(closeButton, {
        Name = "CloseText",
        Text = "✕",
        TextColor3 = DESIGN.Colors.Text,
        TextSize = 18,
    })
    closeText.Size = UDim2.new(1, 0, 1, 0)
    
    closeButton.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tweenProperty(self.MainWindow, "BackgroundTransparency", 1, 0.3)
            wait(0.3)
            self.ScreenGui:Destroy()
            _G.SPS_HUB_GUI = nil
        end
    end)
    
    closeButton.MouseEnter:Connect(function()
        tweenProperty(closeButton, "BackgroundColor3", DESIGN.Colors.Accent, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        tweenProperty(closeButton, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.2)
    end)
    
    self:makeDraggable(titleBar)
end

function GUI:makeDraggable(dragHandle)
    dragHandle.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            local mouse = game.Players.LocalPlayer:GetMouse()
            self.DragOffset = Vector2.new(
                self.MainWindow.AbsolutePosition.X - mouse.X,
                self.MainWindow.AbsolutePosition.Y - mouse.Y
            )
        end
    end)
    
    dragHandle.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = game.Players.LocalPlayer:GetMouse()
            self.MainWindow.Position = UDim2.new(
                0,
                mouse.X + self.DragOffset.X,
                0,
                mouse.Y + self.DragOffset.Y
            )
        end
    end)
end

function GUI:createTabBar()
    local tabBar = createFrame(self.MainWindow, {
        Name = "TabBar",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(1, 0, 0, DESIGN.Dimensions.TabButtonHeight),
        Position = UDim2.new(0, 0, 0, 50),
    })
    
    local separator = createFrame(tabBar, {
        Name = "Separator",
        BackgroundColor3 = DESIGN.Colors.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
    })
    
    self.TabBar = tabBar
    self.TabButtonContainer = createFrame(tabBar, {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    })
    
    local tabNames = {"Player", "Movement", "Targeting", "Weapon", "Vehicle", "Utility"}
    
    for i, tabName in ipairs(tabNames) do
        self:createTabButton(tabName, i)
    end
end

function GUI:createTabButton(tabName, tabIndex)
    local buttonSize = DESIGN.Dimensions.MainWindowWidth / 6
    
    local tabButton = createFrame(self.TabButtonContainer, {
        Name = tabName .. "Tab",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(0, buttonSize - 2, 1, 0),
        Position = UDim2.new(0, (tabIndex - 1) * buttonSize, 0, 0),
    })
    
    local tabText = createTextLabel(tabButton, {
        Name = "Text",
        Text = tabName,
        TextColor3 = DESIGN.Colors.TextMuted,
        TextSize = 12,
    })
    tabText.Size = UDim2.new(1, 0, 1, 0)
    
    local highlight = createFrame(tabButton, {
        Name = "Highlight",
        BackgroundColor3 = DESIGN.Colors.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Visible = (tabIndex == self.CurrentTab),
    })
    
    tabButton.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:switchTab(tabIndex)
        end
    end)
    
    tabButton.MouseEnter:Connect(function()
        if tabIndex ~= self.CurrentTab then
            tweenProperty(tabText, "TextColor3", DESIGN.Colors.Text, 0.15)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if tabIndex ~= self.CurrentTab then
            tweenProperty(tabText, "TextColor3", DESIGN.Colors.TextMuted, 0.15)
        end
    end)
    
    table.insert(self.Tabs, {
        Button = tabButton,
        Text = tabText,
        Highlight = highlight,
        Index = tabIndex,
        Name = tabName,
    })
end

function GUI:createContentArea()
    self.ContentArea = createFrame(self.MainWindow, {
        Name = "ContentArea",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 90),
    })
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.PaddingBottom = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.PaddingLeft = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.PaddingRight = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.Parent = self.ContentArea
    
    for i, tab in ipairs(self.Tabs) do
        local contentPage = createFrame(self.ContentArea, {
            Name = tab.Name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = (i == self.CurrentTab),
        })
        
        tab.ContentPage = contentPage
        
        if tab.Name == "Weapon" then
            self:populateWeaponTab(contentPage)
        elseif tab.Name == "Player" then
            self:populatePlayerTab(contentPage)
        else
            self:populateTabContent(contentPage, tab.Name)
        end
    end
end

function GUI:populateWeaponTab(contentPage)
    local title = createTextLabel(contentPage, {
        Name = "Title",
        Text = "Weapon Settings",
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    local description = createTextLabel(contentPage, {
        Name = "Description",
        Text = "Configure hitbox and weapon properties",
        TextColor3 = DESIGN.Colors.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 32),
    })
    
    -- Enable Hitbox Toggle
    self:createToggleButton(contentPage, "Enable Hitboxes", 70, function(state)
        HUB_SETTINGS.Weapon.HitboxEnabled = state
        HitboxSystem:toggleAllHitboxes(state)
        print("🎯 Hitboxes " .. (state and "enabled" or "disabled"))
    end)
    
    -- Hitbox Size Slider
    self:createSliderControl(contentPage, "Hitbox Size", 110, 1, 20, HUB_SETTINGS.Weapon.HitboxSize, function(value)
        HUB_SETTINGS.Weapon.HitboxSize = value
        for _, hitbox in pairs(ACTIVE_HITBOXES) do
            HitboxSystem:updateHitbox(hitbox)
        end
        print("📏 Hitbox size: " .. value)
    end)
    
    -- Hitbox Transparency Slider
    self:createSliderControl(contentPage, "Transparency", 160, 0, 1, HUB_SETTINGS.Weapon.HitboxTransparency, function(value)
        HUB_SETTINGS.Weapon.HitboxTransparency = value
        for _, hitbox in pairs(ACTIVE_HITBOXES) do
            HitboxSystem:updateHitbox(hitbox)
        end
        print("👁 Transparency: " .. math.floor(value * 100) .. "%")
    end, 0.01)
    
    -- Hitbox Color Picker
    self:createColorPickerButton(contentPage, "Hitbox Color", 210, function(color)
        HUB_SETTINGS.Weapon.HitboxColor = color
        for _, hitbox in pairs(ACTIVE_HITBOXES) do
            HitboxSystem:updateHitbox(hitbox)
        end
        print("🎨 Color changed")
    end)
    
    -- Reset Button
    self:createActionButton(contentPage, "Reset to Default", 270, function()
        HUB_SETTINGS.Weapon.HitboxSize = 5
        HUB_SETTINGS.Weapon.HitboxTransparency = 0.3
        HUB_SETTINGS.Weapon.HitboxColor = Color3.fromRGB(218, 165, 32)
        for _, hitbox in pairs(ACTIVE_HITBOXES) do
            HitboxSystem:updateHitbox(hitbox)
        end
        print("↻ Settings reset to default")
    end, Color3.fromRGB(180, 50, 50))
end

function GUI:populatePlayerTab(contentPage)
    local title = createTextLabel(contentPage, {
        Name = "Title",
        Text = "Player Info",
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    local player = game.Players.LocalPlayer
    local playerName = player.Name
    local userId = tostring(player.UserId)
    
    local infoText = createTextLabel(contentPage, {
        Name = "PlayerInfo",
        Text = "Player: " .. playerName .. "\nUserID: " .. userId .. "\nGame: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        TextColor3 = DESIGN.Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 35),
    })
    
    -- Display online players
    local onlineTitle = createTextLabel(contentPage, {
        Name = "OnlineTitle",
        Text = "Online Players: " .. #getPlayers(),
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 120),
    })
end

function GUI:populateTabContent(contentPage, tabName)
    local title = createTextLabel(contentPage, {
        Name = "Title",
        Text = tabName .. " Features",
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    local description = createTextLabel(contentPage, {
        Name = "Description",
        Text = "Coming soon: " .. tabName .. " features",
        TextColor3 = DESIGN.Colors.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 35),
    })
    
    for i = 1, 2 do
        self:createToggleButton(contentPage, tabName .. " Option " .. i, i * 60 + 70)
    end
end

function GUI:createToggleButton(parent, buttonText, yPosition, callback)
    local buttonContainer = createFrame(parent, {
        Name = "ToggleButton",
        BackgroundColor3 = DESIGN.Colors.SecondaryBG,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, yPosition),
    })
    
    createCorner(buttonContainer, 6)
    createStroke(buttonContainer, DESIGN.Colors.Border, 1)
    
    local buttonLabel = createTextLabel(buttonContainer, {
        Name = "Label",
        Text = buttonText,
        TextColor3 = DESIGN.Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
    })
    
    local toggleSwitch = createFrame(buttonContainer, {
        Name = "Toggle",
        BackgroundColor3 = DESIGN.Colors.TextMuted,
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -40, 0.5, -9),
    })
    
    createCorner(toggleSwitch, 9)
    
    local toggleCircle = createFrame(toggleSwitch, {
        Name = "Circle",
        BackgroundColor3 = DESIGN.Colors.Text,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 1, 0.5, -8),
    })
    
    createCorner(toggleCircle, 8)
    
    local isToggled = false
    
    buttonContainer.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isToggled = not isToggled
            
            if isToggled then
                tweenProperty(toggleSwitch, "BackgroundColor3", DESIGN.Colors.Accent, 0.2)
                tweenProperty(toggleCircle, "Position", UDim2.new(0, 13, 0.5, -8), 0.2)
            else
                tweenProperty(toggleSwitch, "BackgroundColor3", DESIGN.Colors.TextMuted, 0.2)
                tweenProperty(toggleCircle, "Position", UDim2.new(0, 1, 0.5, -8), 0.2)
            end
            
            if callback then
                callback(isToggled)
            end
        end
    end)
    
    buttonContainer.MouseEnter:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.15)
    end)
    
    buttonContainer.MouseLeave:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.SecondaryBG, 0.15)
    end)
end

function GUI:createSliderControl(parent, label, yPosition, minVal, maxVal, currentVal, callback, step)
    step = step or 1
    
    local container = createFrame(parent, {
        Name = "SliderControl",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, yPosition),
    })
    
    local labelText = createTextLabel(container, {
        Name = "Label",
        Text = label,
        TextColor3 = DESIGN.Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.7, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    local valueText = createTextLabel(container, {
        Name = "Value",
        Text = math.floor(currentVal * 100) / 100,
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0.3, 0, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 0),
    })
    
    local sliderBG = createFrame(container, {
        Name = "SliderBG",
        BackgroundColor3 = DESIGN.Colors.SecondaryBG,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 25),
    })
    
    createCorner(sliderBG, 3)
    createStroke(sliderBG, DESIGN.Colors.Border, 1)
    
    local sliderFill = createFrame(sliderBG, {
        Name = "Fill",
        BackgroundColor3 = DESIGN.Colors.Accent,
        Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    createCorner(sliderFill, 3)
    
    local sliderButton = createFrame(container, {
        Name = "Button",
        BackgroundColor3 = DESIGN.Colors.Accent,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((currentVal - minVal) / (maxVal - minVal), -7, 0, 21),
    })
    
    createCorner(sliderButton, 7)
    
    local isDragging = false
    
    sliderButton.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    sliderBG.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    sliderBG.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local sliderAbsPos = sliderBG.AbsolutePosition.X
            local sliderSize = sliderBG.AbsoluteSize.X
            
            local percentage = math.clamp((mouse.X - sliderAbsPos) / sliderSize, 0, 1)
            local newValue = minVal + (percentage * (maxVal - minVal))
            
            newValue = math.floor(newValue / step) * step
            
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderButton.Position = UDim2.new(percentage, -7, 0, 21)
            valueText.Text = math.floor(newValue * 100) / 100
            
            if callback then
                callback(newValue)
            end
        end
    end)
end

function GUI:createColorPickerButton(parent, label, yPosition, callback)
    local buttonContainer = createFrame(parent, {
        Name = "ColorPickerButton",
        BackgroundColor3 = DESIGN.Colors.SecondaryBG,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, yPosition),
    })
    
    createCorner(buttonContainer, 6)
    createStroke(buttonContainer, DESIGN.Colors.Border, 1)
    
    local labelText = createTextLabel(buttonContainer, {
        Name = "Label",
        Text = label,
        TextColor3 = DESIGN.Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
    })
    
    local colorPreview = createFrame(buttonContainer, {
        Name = "ColorPreview",
        BackgroundColor3 = HUB_SETTINGS.Weapon.HitboxColor,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
    })
    
    createCorner(colorPreview, 5)
    createStroke(colorPreview, DESIGN.Colors.Border, 1)
    
    buttonContainer.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local colors = {
                Color3.fromRGB(218, 165, 32),
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(255, 165, 0),
            }
            
            local randomColor = colors[math.random(1, #colors)]
            colorPreview.BackgroundColor3 = randomColor
            
            if callback then
                callback(randomColor)
            end
        end
    end)
    
    buttonContainer.MouseEnter:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.15)
    end)
    
    buttonContainer.MouseLeave:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.SecondaryBG, 0.15)
    end)
end

function GUI:createActionButton(parent, label, yPosition, callback, accentColor)
    accentColor = accentColor or DESIGN.Colors.Accent
    
    local buttonContainer = createFrame(parent, {
        Name = "ActionButton",
        BackgroundColor3 = DESIGN.Colors.SecondaryBG,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, yPosition),
    })
    
    createCorner(buttonContainer, 6)
    createStroke(buttonContainer, accentColor, 1)
    
    local labelText = createTextLabel(buttonContainer, {
        Name = "Label",
        Text = label,
        TextColor3 = accentColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(1, 0, 1, 0),
    })
    
    buttonContainer.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tweenProperty(buttonContainer, "BackgroundColor3", accentColor, 0.1)
            wait(0.1)
            tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.SecondaryBG, 0.1)
            
            if callback then
                callback()
            end
        end
    end)
    
    buttonContainer.MouseEnter:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.15)
    end)
    
    buttonContainer.MouseLeave:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.SecondaryBG, 0.15)
    end)
end

function GUI:switchTab(tabIndex)
    self.CurrentTab = tabIndex
    
    for i, tab in ipairs(self.Tabs) do
        if i == tabIndex then
            tab.Highlight.Visible = true
            tweenProperty(tab.Text, "TextColor3", DESIGN.Colors.Accent, 0.15)
            tab.ContentPage.Visible = true
        else
            tab.Highlight.Visible = false
            tweenProperty(tab.Text, "TextColor3", DESIGN.Colors.TextMuted, 0.15)
            tab.ContentPage.Visible = false
        end
    end
end

-- ============================================================================
-- HUB MANAGER
-- ============================================================================

local HubManager = {}
HubManager.IsVisible = false
HubManager.GUI = nil

function HubManager:toggleHub()
    if self.GUI and self.GUI.ScreenGui and self.GUI.ScreenGui.Parent then
        self.IsVisible = false
        tweenProperty(self.GUI.MainWindow, "BackgroundTransparency", 1, 0.3)
        wait(0.3)
        self.GUI.ScreenGui:Destroy()
        self.GUI = nil
        print("✕ SPS-HUB Hidden")
    else
        self.IsVisible = true
        self.GUI = GUI.new()
        print("✓ SPS-HUB Loaded")
    end
end

-- ============================================================================
-- KEYBIND SETUP
-- ============================================================================

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.ToggleKey then
        HubManager:toggleHub()
    end
end)

print("✓ SPS-HUB Ready! Press RightShift to toggle")
print("═══════════════════════════════════════")
print("📍 Version: " .. CONFIG.HubVersion)
print("📍 Status: Loaded in Xeno")
print("📍 Toggle Key: RightShift")
print("═══════════════════════════════════════")
print("✓ Universal mode: Works in ANY Roblox game")
