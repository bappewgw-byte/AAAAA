-- ========================================================
-- REPTILLIAN UI LIBRARY (HOSTED VERSION)
-- ========================================================
local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Helper Tween
local function Tween(instance, properties, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Helper Draggable System
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

-- INITIALIZATION
function Library.new(titleText)
    local self = setmetatable({}, Library)

    local parentTarget
    if gethui then
        parentTarget = gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        parentTarget = CoreGui
    else
        parentTarget = CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Prevent duplicates
    if parentTarget:FindFirstChild("ReptillianUI") then
        parentTarget.ReptillianUI:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ReptillianUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentTarget

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Header / Title Bar
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    MakeDraggable(MainFrame, Header)

    local Title = Instance.new("TextLabel")
    Title.Text = titleText or "UI Library"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Header

    -- Navigation Container (Tabs)
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -220, 1, 0)
    TabBar.Position = UDim2.new(0, 200, 0, 0)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Header

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0, 8)
    TabList.Parent = TabBar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingRight = UDim.new(0, 15)
    TabPadding.Parent = TabBar

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -30, 1, -60)
    ContentContainer.Position = UDim2.new(0, 15, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- Notification Container
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotifHolder"
    NotifHolder.Size = UDim2.new(0, 250, 1, -20)
    NotifHolder.Position = UDim2.new(1, -260, 0, 10)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.Parent = NotifHolder

    self.Gui = ScreenGui
    self.MainFrame = MainFrame
    self.TabBar = TabBar
    self.ContentContainer = ContentContainer
    self.NotifHolder = NotifHolder
    self.Tabs = {}

    return self
end

-- NOTIFICATION
function Library:Notify(title, text, duration)
    duration = duration or 3

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 60)
    Notif.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Notif.BackgroundTransparency = 1
    Notif.BorderSizePixel = 0
    Notif.Parent = self.NotifHolder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Notif

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = title or "Notification"
    TitleLbl.Size = UDim2.new(1, -20, 0, 20)
    TitleLbl.Position = UDim2.new(0, 10, 0, 8)
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Parent = Notif

    local TextLbl = Instance.new("TextLabel")
    TextLbl.Text = text or ""
    TextLbl.Size = UDim2.new(1, -20, 0, 25)
    TextLbl.Position = UDim2.new(0, 10, 0, 28)
    TextLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    TextLbl.Font = Enum.Font.Gotham
    TextLbl.TextSize = 12
    TextLbl.TextXAlignment = Enum.TextXAlignment.Left
    TextLbl.TextWrapped = true
    TextLbl.BackgroundTransparency = 1
    TextLbl.Parent = Notif

    Tween(Notif, {BackgroundTransparency = 0})

    task.delay(duration, function()
        local tw = Tween(Notif, {BackgroundTransparency = 1})
        Tween(TitleLbl, {TextTransparency = 1})
        Tween(TextLbl, {TextTransparency = 1})
        tw.Completed:Connect(function()
            Notif:Destroy()
        end)
    end)
end

-- TAB CREATION
function Library:CreateTab(tabName)
    local Tab = {}

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 80, 0, 28)
    TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.Parent = self.TabBar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.Visible = false
    Page.Parent = self.ContentContainer

    local PageGrid = Instance.new("UIGridLayout")
    PageGrid.CellSize = UDim2.new(0.49, -5, 1, 0)
    PageGrid.CellPadding = UDim2.new(0.02, 0, 0, 0)
    PageGrid.Parent = Page

    Tab.Page = Page
    Tab.Button = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            Tween(t.Button, {BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(150, 150, 160)})
        end
        Page.Visible = true
        Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(120, 80, 220), TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)

    if #self.Tabs == 0 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    table.insert(self.Tabs, Tab)

    -- SECTION CREATION
    function Tab:CreateSection(sectionTitle)
        local Section = {}

        local SecFrame = Instance.new("Frame")
        SecFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        SecFrame.Parent = Page

        local SecCorner = Instance.new("UICorner")
        SecCorner.CornerRadius = UDim.new(0, 8)
        SecCorner.Parent = SecFrame

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Text = sectionTitle or "Section"
        TitleLbl.Size = UDim2.new(1, -20, 0, 25)
        TitleLbl.Position = UDim2.new(0, 10, 0, 5)
        TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextSize = 13
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Parent = SecFrame

        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -20, 1, -35)
        Container.Position = UDim2.new(0, 10, 0, 30)
        Container.BackgroundTransparency = 1
        Container.Parent = SecFrame

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = Container

        -- TOGGLE
        function Section:AddToggle(text, default, callback)
            callback = callback or function() end
            local state = default or false

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 30)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Container

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, -40, 1, 0)
            Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Parent = Frame

            local Box = Instance.new("TextButton")
            Box.Size = UDim2.new(0, 18, 0, 18)
            Box.Position = UDim2.new(1, -18, 0.5, -9)
            Box.BackgroundColor3 = state and Color3.fromRGB(120, 80, 220) or Color3.fromRGB(38, 38, 45)
            Box.Text = ""
            Box.Parent = Frame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = Box

            Box.MouseButton1Click:Connect(function()
                state = not state
                Tween(Box, {BackgroundColor3 = state and Color3.fromRGB(120, 80, 220) or Color3.fromRGB(38, 38, 45)})
                callback(state)
            end)
        end

        -- SLIDER
        function Section:AddSlider(text, min, max, default, callback)
            callback = callback or function() end
            local value = default or min

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 42)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Container

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(0.7, 0, 0, 18)
            Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Parent = Frame

            local ValLbl = Instance.new("TextLabel")
            ValLbl.Text = tostring(value)
            ValLbl.Size = UDim2.new(0.3, 0, 0, 18)
            ValLbl.Position = UDim2.new(0.7, 0, 0, 0)
            ValLbl.TextColor3 = Color3.fromRGB(140, 140, 150)
            ValLbl.Font = Enum.Font.Gotham
            ValLbl.TextSize = 12
            ValLbl.TextXAlignment = Enum.TextXAlignment.Right
            ValLbl.BackgroundTransparency = 1
            ValLbl.Parent = Frame

            local Track = Instance.new("TextButton")
            Track.Size = UDim2.new(1, 0, 0, 6)
            Track.Position = UDim2.new(0, 0, 0, 26)
            Track.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
            Track.Text = ""
            Track.Parent = Frame

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
            Fill.BorderSizePixel = 0
            Fill.Parent = Track

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            local dragging = false
            local function Update(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                ValLbl.Text = tostring(value)
                Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                callback(value)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)
        end

        -- DROPDOWN
        function Section:AddDropdown(text, list, callback)
            callback = callback or function() end
            local open = false

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 48)
            Frame.BackgroundTransparency = 1
            Frame.ClipsDescendants = true
            Frame.Parent = Container

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, 0, 0, 18)
            Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Parent = Frame

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 24)
            DropBtn.Position = UDim2.new(0, 0, 0, 20)
            DropBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
            DropBtn.Text = "  Select..."
            DropBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.TextSize = 11
            DropBtn.TextXAlignment = Enum.TextXAlignment.Left
            DropBtn.Parent = Frame

            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropBtn

            local OptionHolder = Instance.new("Frame")
            OptionHolder.Size = UDim2.new(1, 0, 0, #list * 22)
            OptionHolder.Position = UDim2.new(0, 0, 0, 48)
            OptionHolder.BackgroundTransparency = 1
            OptionHolder.Parent = Frame

            local OptLayout = Instance.new("UIListLayout")
            OptLayout.Padding = UDim.new(0, 2)
            OptLayout.Parent = OptionHolder

            for _, opt in ipairs(list) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 20)
                OptBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                OptBtn.Text = "  " .. opt
                OptBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Parent = OptionHolder

                OptBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = "  " .. opt
                    open = false
                    Tween(Frame, {Size = UDim2.new(1, 0, 0, 48)})
                    callback(opt)
                end)
            end

            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                local targetHeight = open and (48 + #list * 22) or 48
                Tween(Frame, {Size = UDim2.new(1, 0, 0, targetHeight)})
            end)
        end

        -- TEXTBOX
        function Section:AddTextbox(text, placeholder, callback)
            callback = callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 48)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Container

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, 0, 0, 18)
            Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Parent = Frame

            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, 0, 0, 24)
            Input.Position = UDim2.new(0, 0, 0, 20)
            Input.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
            Input.PlaceholderText = placeholder or "Type here..."
            Input.Text = ""
            Input.TextColor3 = Color3.fromRGB(220, 220, 230)
            Input.Font = Enum.Font.Gotham
            Input.TextSize = 11
            Input.Parent = Frame

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = Input

            Input.FocusLost:Connect(function(enterPressed)
                callback(Input.Text, enterPressed)
            end)
        end

        return Section
    end

    return Tab
end

-- Return Library agar bisa dipanggil lewat loadstring()
return Library
