--[[
    SPS-HUB Hitbox Manager
    Lightweight hitbox controller for any Roblox game
]]

if _G.SPS_HUB_HITBOX_LOADED then
    print("⚠️ Hitbox Manager already loaded!")
    return
end

_G.SPS_HUB_HITBOX_LOADED = true

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local SETTINGS = {
    HitboxEnabled = false,
    HitboxSize = 5,
    HitboxTransparency = 0.3,
    HitboxColor = Color3.fromRGB(218, 165, 32),
    ToggleKey = Enum.KeyCode.RightShift,
}

local ACTIVE_HITBOXES = {}

-- ============================================================================
-- HITBOX SYSTEM
-- ============================================================================

local HitboxSystem = {}

function HitboxSystem:createHitbox(character)
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not rootPart then return nil end
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "SPS_Hitbox"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Material = Enum.Material.Neon
    hitbox.CanCollide = false
    hitbox.CFrame = rootPart.CFrame
    hitbox.Size = Vector3.new(SETTINGS.HitboxSize, SETTINGS.HitboxSize, SETTINGS.HitboxSize)
    hitbox.Color = SETTINGS.HitboxColor
    hitbox.Transparency = SETTINGS.HitboxTransparency
    hitbox.TopSurface = Enum.SurfaceType.Smooth
    hitbox.BottomSurface = Enum.SurfaceType.Smooth
    hitbox.Parent = rootPart
    
    -- Weld to root part
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = hitbox
    weld.Parent = hitbox
    
    return hitbox
end

function HitboxSystem:updateHitbox(hitbox)
    if hitbox and hitbox.Parent then
        hitbox.Size = Vector3.new(SETTINGS.HitboxSize, SETTINGS.HitboxSize, SETTINGS.HitboxSize)
        hitbox.Color = SETTINGS.HitboxColor
        hitbox.Transparency = SETTINGS.HitboxTransparency
    end
end

function HitboxSystem:removeHitbox(hitbox)
    if hitbox and hitbox.Parent then
        hitbox:Destroy()
    end
end

function HitboxSystem:toggleAll(enable)
    if enable then
        local players = game.Players:GetPlayers()
        for _, player in ipairs(players) do
            if player.Character and not ACTIVE_HITBOXES[player] then
                local hitbox = self:createHitbox(player.Character)
                if hitbox then
                    ACTIVE_HITBOXES[player] = hitbox
                end
            end
        end
        print("✓ Hitboxes enabled")
    else
        for player, hitbox in pairs(ACTIVE_HITBOXES) do
            self:removeHitbox(hitbox)
        end
        ACTIVE_HITBOXES = {}
        print("✕ Hitboxes disabled")
    end
end

-- Monitor new players
game.Players.PlayerAdded:Connect(function(player)
    if SETTINGS.HitboxEnabled then
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
-- GUI
-- ============================================================================

local DESIGN = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        SecondaryBG = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(218, 165, 32),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(100, 85, 50),
        ButtonHover = Color3.fromRGB(50, 50, 65),
    },
}

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
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or DESIGN.Colors.Border
    stroke.Thickness = thickness or 2
    stroke.Parent = parent
end

local function tweenProperty(object, property, endValue, duration)
    duration = duration or 0.3
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(object, tweenInfo, {[property] = endValue})
    tween:Play()
end

-- ============================================================================
-- MAIN UI
-- ============================================================================

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxManager"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Window
local MainWindow = createFrame(ScreenGui, {
    Name = "MainWindow",
    BackgroundColor3 = DESIGN.Colors.Background,
    Size = UDim2.new(0, 350, 0, 300),
    Position = UDim2.new(0.5, -175, 0.5, -150),
})

createCorner(MainWindow)
createStroke(MainWindow, DESIGN.Colors.Border, 2)

-- Title Bar
local TitleBar = createFrame(MainWindow, {
    Name = "TitleBar",
    BackgroundColor3 = DESIGN.Colors.SecondaryBG,
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
})

createCorner(TitleBar)

local TitleText = createTextLabel(TitleBar, {
    Name = "Title",
    Text = "Hitbox Manager",
    TextColor3 = DESIGN.Colors.Accent,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
})

-- Close Button
local CloseButton = createFrame(TitleBar, {
    Name = "CloseButton",
    BackgroundColor3 = DESIGN.Colors.ButtonHover,
    Size = UDim2.new(0, 35, 0, 35),
    Position = UDim2.new(1, -40, 0.5, -17.5),
})

createCorner(CloseButton, 6)

local CloseText = createTextLabel(CloseButton, {
    Name = "CloseText",
    Text = "✕",
    TextColor3 = DESIGN.Colors.Text,
    TextSize = 16,
})
CloseText.Size = UDim2.new(1, 0, 1, 0)

local IsDragging = false
local DragOffset = Vector2.new(0, 0)

TitleBar.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsDragging = true
        local mouse = game.Players.LocalPlayer:GetMouse()
        DragOffset = Vector2.new(
            MainWindow.AbsolutePosition.X - mouse.X,
            MainWindow.AbsolutePosition.Y - mouse.Y
        )
    end
end)

TitleBar.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsDragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = game.Players.LocalPlayer:GetMouse()
        MainWindow.Position = UDim2.new(0, mouse.X + DragOffset.X, 0, mouse.Y + DragOffset.Y)
    end
end)

CloseButton.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        tweenProperty(MainWindow, "BackgroundTransparency", 1, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end
end)

CloseButton.MouseEnter:Connect(function()
    tweenProperty(CloseButton, "BackgroundColor3", DESIGN.Colors.Accent, 0.2)
end)

CloseButton.MouseLeave:Connect(function()
    tweenProperty(CloseButton, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.2)
end)

-- Content Area
local ContentArea = createFrame(MainWindow, {
    Name = "ContentArea",
    BackgroundColor3 = DESIGN.Colors.Background,
    Size = UDim2.new(1, 0, 1, -45),
    Position = UDim2.new(0, 0, 0, 45),
})

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 12)
Padding.PaddingBottom = UDim.new(0, 12)
Padding.PaddingLeft = UDim.new(0, 12)
Padding.PaddingRight = UDim.new(0, 12)
Padding.Parent = ContentArea

-- Toggle Button
local ToggleContainer = createFrame(ContentArea, {
    Name = "ToggleContainer",
    BackgroundColor3 = DESIGN.Colors.SecondaryBG,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 0),
})

createCorner(ToggleContainer, 6)
createStroke(ToggleContainer, DESIGN.Colors.Border, 1)

local ToggleLabel = createTextLabel(ToggleContainer, {
    Name = "Label",
    Text = "Enable Hitboxes",
    TextColor3 = DESIGN.Colors.Text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
})

local ToggleSwitch = createFrame(ToggleContainer, {
    Name = "Toggle",
    BackgroundColor3 = DESIGN.Colors.TextMuted,
    Size = UDim2.new(0, 30, 0, 18),
    Position = UDim2.new(1, -40, 0.5, -9),
})

createCorner(ToggleSwitch, 9)

local ToggleCircle = createFrame(ToggleSwitch, {
    Name = "Circle",
    BackgroundColor3 = DESIGN.Colors.Text,
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(0, 1, 0.5, -8),
})

createCorner(ToggleCircle, 8)

local IsToggled = false

ToggleContainer.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsToggled = not IsToggled
        
        if IsToggled then
            tweenProperty(ToggleSwitch, "BackgroundColor3", DESIGN.Colors.Accent, 0.2)
            tweenProperty(ToggleCircle, "Position", UDim2.new(0, 13, 0.5, -8), 0.2)
        else
            tweenProperty(ToggleSwitch, "BackgroundColor3", DESIGN.Colors.TextMuted, 0.2)
            tweenProperty(ToggleCircle, "Position", UDim2.new(0, 1, 0.5, -8), 0.2)
        end
        
        SETTINGS.HitboxEnabled = IsToggled
        HitboxSystem:toggleAll(IsToggled)
    end
end)

ToggleContainer.MouseEnter:Connect(function()
    tweenProperty(ToggleContainer, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.15)
end)

ToggleContainer.MouseLeave:Connect(function()
    tweenProperty(ToggleContainer, "BackgroundColor3", DESIGN.Colors.SecondaryBG, 0.15)
end)

-- Size Slider
local SizeContainer = createFrame(ContentArea, {
    Name = "SizeControl",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 50),
})

local SizeLabel = createTextLabel(SizeContainer, {
    Name = "Label",
    Text = "Hitbox Size",
    TextColor3 = DESIGN.Colors.Text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0.7, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 0),
})

local SizeValue = createTextLabel(SizeContainer, {
    Name = "Value",
    Text = SETTINGS.HitboxSize,
    TextColor3 = DESIGN.Colors.Accent,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    Size = UDim2.new(0.3, 0, 0, 20),
    Position = UDim2.new(0.7, 0, 0, 0),
})

local SizeBG = createFrame(SizeContainer, {
    Name = "SliderBG",
    BackgroundColor3 = DESIGN.Colors.SecondaryBG,
    Size = UDim2.new(1, 0, 0, 6),
    Position = UDim2.new(0, 0, 0, 25),
})

createCorner(SizeBG, 3)
createStroke(SizeBG, DESIGN.Colors.Border, 1)

local SizeFill = createFrame(SizeBG, {
    Name = "Fill",
    BackgroundColor3 = DESIGN.Colors.Accent,
    Size = UDim2.new((SETTINGS.HitboxSize - 1) / 19, 0, 1, 0),
})

createCorner(SizeFill, 3)

local SizeButton = createFrame(SizeContainer, {
    Name = "Button",
    BackgroundColor3 = DESIGN.Colors.Accent,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new((SETTINGS.HitboxSize - 1) / 19, -7, 0, 21),
})

createCorner(SizeButton, 7)

local SizeIsDragging = false

SizeButton.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SizeIsDragging = true
    end
end)

SizeButton.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SizeIsDragging = false
    end
end)

SizeBG.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SizeIsDragging = true
    end
end)

SizeBG.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SizeIsDragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if SizeIsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = game.Players.LocalPlayer:GetMouse()
        local sliderAbsPos = SizeBG.AbsolutePosition.X
        local sliderSize = SizeBG.AbsoluteSize.X
        
        local percentage = math.clamp((mouse.X - sliderAbsPos) / sliderSize, 0, 1)
        local newValue = math.floor(1 + (percentage * 19))
        
        SETTINGS.HitboxSize = newValue
        SizeFill.Size = UDim2.new(percentage, 0, 1, 0)
        SizeButton.Position = UDim2.new(percentage, -7, 0, 21)
        SizeValue.Text = newValue
        
        for _, hitbox in pairs(ACTIVE_HITBOXES) do
            HitboxSystem:updateHitbox(hitbox)
        end
    end
end)

-- Transparency Slider
local TransContainer = createFrame(ContentArea, {
    Name = "TransControl",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 105),
})

local TransLabel = createTextLabel(TransContainer, {
    Name = "Label",
    Text = "Transparency",
    TextColor3 = DESIGN.Colors.Text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0.7, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 0),
})

local TransValue = createTextLabel(TransContainer, {
    Name = "Value",
    Text = math.floor(SETTINGS.HitboxTransparency * 100) .. "%",
    TextColor3 = DESIGN.Colors.Accent,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    Size = UDim2.new(0.3, 0, 0, 20),
    Position = UDim2.new(0.7, 0, 0, 0),
})

local TransBG = createFrame(TransContainer, {
    Name = "SliderBG",
    BackgroundColor3 = DESIGN.Colors.SecondaryBG,
    Size = UDim2.new(1, 0, 0, 6),
    Position = UDim2.new(0, 0, 0, 25),
})

createCorner(TransBG, 3)
createStroke(TransBG, DESIGN.Colors.Border, 1)

local TransFill = createFrame(TransBG, {
    Name = "Fill",
    BackgroundColor3 = DESIGN.Colors.Accent,
    Size = UDim2.new(SETTINGS.HitboxTransparency, 0, 1, 0),
})

createCorner(TransFill, 3)

local TransButton = createFrame(TransContainer, {
    Name = "Button",
    BackgroundColor3 = DESIGN.Colors.Accent,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(SETTINGS.HitboxTransparency, -7, 0, 21),
})

createCorner(TransButton, 7)

local TransIsDragging = false

TransButton.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TransIsDragging = true
    end
end)

TransButton.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TransIsDragging = false
    end
end)

TransBG.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TransIsDragging = true
    end
end)

TransBG.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TransIsDragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if TransIsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = game.Players.LocalPlayer:GetMouse()
        local sliderAbsPos = TransBG.AbsolutePosition.X
        local sliderSize = TransBG.AbsoluteSize.X
        
        local percentage = math.clamp((mouse.X - sliderAbsPos) / sliderSize, 0, 1)
        SETTINGS.HitboxTransparency = percentage
        
        TransFill.Size = UDim2.new(percentage, 0, 1, 0)
        TransButton.Position = UDim2.new(percentage, -7, 0, 21)
        TransValue.Text = math.floor(percentage * 100) .. "%"
        
        for _, hitbox in pairs(ACTIVE_HITBOXES) do
            HitboxSystem:updateHitbox(hitbox)
        end
    end
end)

-- ============================================================================
-- KEYBIND
-- ============================================================================

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == SETTINGS.ToggleKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("✓ Hitbox Manager Ready")
print("Press RightShift to toggle panel")
