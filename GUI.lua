--[[
    SPS-HUB GUI System
    A premium, draggable dashboard-style interface for Roblox admin hub
    Dark theme with metallic gold accents and smooth animations
]]

local GUI = {}
GUI.Version = "1.0.0"

-- ============================================================================
-- CONFIGURATION & CONSTANTS
-- ============================================================================

local DESIGN = {
    -- Colors
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),           -- near-black/dark charcoal
        SecondaryBG = Color3.fromRGB(35, 35, 45),          -- slightly lighter charcoal
        Accent = Color3.fromRGB(218, 165, 32),             -- metallic gold/yellow
        AccentLight = Color3.fromRGB(255, 200, 50),        -- lighter gold for hover
        Text = Color3.fromRGB(255, 255, 255),              -- primary white text
        TextMuted = Color3.fromRGB(150, 150, 160),         -- muted gray
        Border = Color3.fromRGB(100, 85, 50),              -- subtle gold
        ButtonHover = Color3.fromRGB(50, 50, 65),          -- hover state
        ButtonActive = Color3.fromRGB(218, 165, 32),       -- active accent
    },
    
    -- Dimensions
    Dimensions = {
        MainWindowWidth = 450,
        MainWindowHeight = 600,
        TabButtonHeight = 40,
        PanelPadding = 15,
        CornerRadius = 8,
        BorderThickness = 2,
    },
    
    -- Animation
    Animation = {
        TweenDuration = 0.3,
        TweenStyle = Enum.EasingStyle.Quad,
        TweenDirection = Enum.EasingDirection.Out,
    },
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function createImageLabel(parent, props)
    local label = Instance.new("ImageLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    
    for key, value in pairs(props or {}) do
        label[key] = value
    end
    
    return label
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

local function createFrame(parent, props)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BorderSizePixel = 0
    
    for key, value in pairs(props or {}) do
        frame[key] = value
    end
    
    return frame
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
-- MAIN GUI INITIALIZATION
-- ============================================================================

function GUI.new()
    local self = setmetatable({}, {__index = GUI})
    
    -- Get screen GUI service
    local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SPS-HUB-GUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = PlayerGui
    
    -- Initialize drag state
    self.IsDragging = false
    self.DragOffset = Vector2.new(0, 0)
    
    -- Initialize tab system
    self.CurrentTab = 1
    self.Tabs = {}
    
    -- Create main window
    self:createMainWindow()
    
    return self
end

function GUI:createMainWindow()
    -- Main Window Frame
    self.MainWindow = createFrame(self.ScreenGui, {
        Name = "MainWindow",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(0, DESIGN.Dimensions.MainWindowWidth, 0, DESIGN.Dimensions.MainWindowHeight),
        Position = UDim2.new(0.5, -DESIGN.Dimensions.MainWindowWidth / 2, 0.5, -DESIGN.Dimensions.MainWindowHeight / 2),
    })
    
    -- Add corner radius
    createCorner(self.MainWindow, DESIGN.Dimensions.CornerRadius)
    
    -- Add border/stroke
    createStroke(self.MainWindow, DESIGN.Colors.Border, 2)
    
    -- Add shadow effect
    self:addShadow(self.MainWindow)
    
    -- Create title bar
    self:createTitleBar()
    
    -- Create tab buttons container
    self:createTabBar()
    
    -- Create content area
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
    
    -- Make shadow follow main window
    local connection
    connection = target.Changed:Connect(function(prop)
        if prop == "Position" or prop == "Size" then
            shadow.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset + 5, target.Position.Y.Scale, target.Position.Y.Offset + 5)
            shadow.Size = target.Size
        end
    end)
end

function GUI:createTitleBar()
    -- Title Bar Background
    local titleBar = createFrame(self.MainWindow, {
        Name = "TitleBar",
        BackgroundColor3 = DESIGN.Colors.SecondaryBG,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    createCorner(titleBar, DESIGN.Dimensions.CornerRadius)
    
    -- Title Text
    local titleText = createTextLabel(titleBar, {
        Name = "Title",
        Text = "SPS-HUB",
        TextColor3 = DESIGN.Colors.Accent,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, DESIGN.Dimensions.PanelPadding, 0, 0),
    })
    
    -- Close Button
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
    
    -- Close button interaction
    local closeUIS = game:GetService("UserInputService")
    closeButton.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tweenProperty(self.MainWindow, "BackgroundTransparency", 1, 0.3)
            self.ScreenGui:Destroy()
        end
    end)
    
    -- Hover effect for close button
    closeButton.MouseEnter:Connect(function()
        tweenProperty(closeButton, "BackgroundColor3", DESIGN.Colors.Accent, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        tweenProperty(closeButton, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.2)
    end)
    
    -- Make title bar draggable
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
    -- Tab Bar Background
    local tabBar = createFrame(self.MainWindow, {
        Name = "TabBar",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(1, 0, 0, DESIGN.Dimensions.TabButtonHeight),
        Position = UDim2.new(0, 0, 0, 50),
    })
    
    -- Add separator line
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
    
    -- Create tab buttons
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
    
    -- Highlight bar (bottom border for active tab)
    local highlight = createFrame(tabButton, {
        Name = "Highlight",
        BackgroundColor3 = DESIGN.Colors.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Visible = (tabIndex == self.CurrentTab),
    })
    
    -- Tab interaction
    tabButton.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:switchTab(tabIndex)
        end
    end)
    
    -- Hover effect
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
    -- Content Background
    self.ContentArea = createFrame(self.MainWindow, {
        Name = "ContentArea",
        BackgroundColor3 = DESIGN.Colors.Background,
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 90),
    })
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.PaddingBottom = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.PaddingLeft = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.PaddingRight = UDim.new(0, DESIGN.Dimensions.PanelPadding)
    padding.Parent = self.ContentArea
    
    -- Create content pages for each tab
    for i, tab in ipairs(self.Tabs) do
        local contentPage = createFrame(self.ContentArea, {
            Name = tab.Name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = (i == self.CurrentTab),
        })
        
        -- Store reference
        tab.ContentPage = contentPage
        
        -- Add sample content
        self:populateTabContent(contentPage, tab.Name)
    end
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
        Text = "Configure " .. tabName .. " settings here",
        TextColor3 = DESIGN.Colors.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 35),
    })
    
    -- Create sample toggle buttons
    for i = 1, 2 do
        self:createToggleButton(contentPage, tabName .. " Option " .. i, i * 60 + 70)
    end
end

function GUI:createToggleButton(parent, buttonText, yPosition)
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
    
    -- Toggle switch
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
    
    -- Toggle interaction
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
        end
    end)
    
    -- Hover effect
    buttonContainer.MouseEnter:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.ButtonHover, 0.15)
    end)
    
    buttonContainer.MouseLeave:Connect(function()
        tweenProperty(buttonContainer, "BackgroundColor3", DESIGN.Colors.SecondaryBG, 0.15)
    end)
end

function GUI:switchTab(tabIndex)
    self.CurrentTab = tabIndex
    
    -- Update all tab buttons
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
-- MODULE EXPORT
-- ============================================================================

return GUI
