-- ========================================================
-- GENEROUS UI LIBRARY
-- ========================================================
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function Tween(instance, properties, duration)
    duration = duration or 0.2
    local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

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

function Library.new(hubName, gameSubTitle)
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

    if parentTarget:FindFirstChild("GenerousUI") then
        parentTarget.GenerousUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GenerousUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentTarget

    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 620, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -220)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- SIDEBAR (LEFT)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, -20)
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame

    -- Header Card
    local HeaderCard = Instance.new("Frame")
    HeaderCard.Size = UDim2.new(1, 0, 0, 65)
    HeaderCard.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    HeaderCard.BorderSizePixel = 0
    HeaderCard.Parent = Sidebar

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = HeaderCard

    MakeDraggable(MainFrame, HeaderCard)

    local LogoBox = Instance.new("Frame")
    LogoBox.Size = UDim2.new(0, 42, 0, 42)
    LogoBox.Position = UDim2.new(0, 12, 0.5, -21)
    LogoBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    LogoBox.Parent = HeaderCard

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent = LogoBox

    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "Z"
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.TextColor3 = Color3.fromRGB(220, 220, 220)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 16
    LogoText.BackgroundTransparency = 1
    LogoText.Parent = LogoBox

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = hubName or "Balright"
    TitleLbl.Size = UDim2.new(1, -65, 0, 20)
    TitleLbl.Position = UDim2.new(0, 62, 0, 14)
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Parent = HeaderCard

    local SubLbl = Instance.new("TextLabel")
    SubLbl.Text = gameSubTitle or "for Game"
    SubLbl.Size = UDim2.new(1, -65, 0, 18)
    SubLbl.Position = UDim2.new(0, 62, 0, 32)
    SubLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
    SubLbl.Font = Enum.Font.Gotham
    SubLbl.TextSize = 11
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubLbl.BackgroundTransparency = 1
    SubLbl.Parent = HeaderCard

    -- Nav Scroll Container
    local NavContainer = Instance.new("ScrollingFrame")
    NavContainer.Size = UDim2.new(1, 0, 1, -150)
    NavContainer.Position = UDim2.new(0, 0, 0, 75)
    NavContainer.BackgroundTransparency = 1
    NavContainer.BorderSizePixel = 0
    NavContainer.ScrollBarThickness = 0
    NavContainer.Parent = Sidebar

    local NavList = Instance.new("UIListLayout")
    NavList.Padding = UDim.new(0, 4)
    NavList.SortOrder = Enum.SortOrder.LayoutOrder
    NavList.Parent = NavContainer

    -- Footer Card
    local FooterCard = Instance.new("Frame")
    FooterCard.Size = UDim2.new(1, 0, 0, 60)
    FooterCard.Position = UDim2.new(0, 0, 1, -60)
    FooterCard.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    FooterCard.BorderSizePixel = 0
    FooterCard.Parent = Sidebar

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 8)
    FooterCorner.Parent = FooterCard

    local SubExpiryLbl = Instance.new("TextLabel")
    SubExpiryLbl.Text = "Sub expires in 23d"
    SubExpiryLbl.Size = UDim2.new(1, -20, 0, 20)
    SubExpiryLbl.Position = UDim2.new(0, 12, 0, 10)
    SubExpiryLbl.TextColor3 = Color3.fromRGB(130, 130, 140)
    SubExpiryLbl.Font = Enum.Font.Gotham
    SubExpiryLbl.TextSize = 11
    SubExpiryLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubExpiryLbl.BackgroundTransparency = 1
    SubExpiryLbl.Parent = FooterCard

    local SessionLbl = Instance.new("TextLabel")
    SessionLbl.Text = "Session duration: 00:00"
    SessionLbl.Size = UDim2.new(1, -20, 0, 20)
    SessionLbl.Position = UDim2.new(0, 12, 0, 28)
    SessionLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    SessionLbl.Font = Enum.Font.GothamBold
    SessionLbl.TextSize = 12
    SessionLbl.TextXAlignment = Enum.TextXAlignment.Left
    SessionLbl.BackgroundTransparency = 1
    SessionLbl.Parent = FooterCard

    -- Session Timer
    local startTime = os.time()
    task.spawn(function()
        while task.wait(1) do
            local elapsed = os.time() - startTime
            local m = math.floor(elapsed / 60)
            local s = elapsed % 60
            SessionLbl.Text = string.format("Session duration: %d:%02d", m, s)
        end
    end)

    -- MAIN CONTENT (RIGHT)
    local MainContent = Instance.new("Frame")
    MainContent.Size = UDim2.new(1, -230, 1, -20)
    MainContent.Position = UDim2.new(0, 220, 0, 10)
    MainContent.BackgroundTransparency = 1
    MainContent.Parent = MainFrame

    local PageTitle = Instance.new("TextLabel")
    PageTitle.Text = "Page Title"
    PageTitle.Size = UDim2.new(1, 0, 0, 30)
    PageTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextSize = 18
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.BackgroundTransparency = 1
    PageTitle.Parent = MainContent

    self.Gui = ScreenGui
    self.MainFrame = MainFrame
    self.NavContainer = NavContainer
    self.MainContent = MainContent
    self.PageTitle = PageTitle
    self.Pages = {}

    return self
end

-- ADD CATEGORY LABEL TO SIDEBAR
function Library:AddCategory(categoryName)
    local Label = Instance.new("TextLabel")
    Label.Text = categoryName
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.TextColor3 = Color3.fromRGB(100, 100, 110)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = self.NavContainer
end

-- CREATE PAGE
function Library:CreatePage(pageName, icon)
    local Page = {}
    icon = icon or "🔥"

    local PageBtn = Instance.new("TextButton")
    PageBtn.Size = UDim2.new(1, 0, 0, 36)
    PageBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    PageBtn.BackgroundTransparency = 1
    PageBtn.Text = "  " .. icon .. "   " .. pageName
    PageBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
    PageBtn.Font = Enum.Font.GothamMedium
    PageBtn.TextSize = 13
    PageBtn.TextXAlignment = Enum.TextXAlignment.Left
    PageBtn.Parent = self.NavContainer

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = PageBtn

    -- Page Container Frame
    local PageFrame = Instance.new("Frame")
    PageFrame.Size = UDim2.new(1, 0, 1, -35)
    PageFrame.Position = UDim2.new(0, 0, 0, 35)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.Parent = self.MainContent

    -- Sub-Tabs Bar (Pills)
    local SubTabBar = Instance.new("Frame")
    SubTabBar.Size = UDim2.new(1, 0, 0, 32)
    SubTabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    SubTabBar.Parent = PageFrame

    local SubCorner = Instance.new("UICorner")
    SubCorner.CornerRadius = UDim.new(0, 8)
    SubCorner.Parent = SubTabBar

    local SubList = Instance.new("UIListLayout")
    SubList.FillDirection = Enum.FillDirection.Horizontal
    SubList.Padding = UDim.new(0, 4)
    SubList.Parent = SubTabBar

    local SubPad = Instance.new("UIPadding")
    SubPad.PaddingLeft = UDim.new(0, 4)
    SubPad.PaddingTop = UDim.new(0, 4)
    SubPad.Parent = SubTabBar

    local SubContentHolder = Instance.new("Frame")
    SubContentHolder.Size = UDim2.new(1, 0, 1, -42)
    SubContentHolder.Position = UDim2.new(0, 0, 0, 42)
    SubContentHolder.BackgroundTransparency = 1
    SubContentHolder.Parent = PageFrame

    Page.Frame = PageFrame
    Page.SubTabBar = SubTabBar
    Page.SubContentHolder = SubContentHolder
    Page.SubTabs = {}

    PageBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do
            p.Frame.Visible = false
            Tween(p.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(120, 120, 130)})
        end
        PageFrame.Visible = true
        self.PageTitle.Text = pageName
        Tween(PageBtn, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(240, 240, 240)})
    end)

    if #self.Pages == 0 then
        PageFrame.Visible = true
        self.PageTitle.Text = pageName
        PageBtn.BackgroundTransparency = 0
        PageBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end

    Page.Button = PageBtn
    table.insert(self.Pages, Page)

    -- CREATE SUB TAB
    function Page:CreateSubTab(subName)
        local SubTab = {}

        local SubBtn = Instance.new("TextButton")
        SubBtn.Size = UDim2.new(0, 70, 0, 24)
        SubBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        SubBtn.BackgroundTransparency = 1
        SubBtn.Text = subName
        SubBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
        SubBtn.Font = Enum.Font.GothamMedium
        SubBtn.TextSize = 11
        SubBtn.Parent = Page.SubTabBar

        local SubBtnCorner = Instance.new("UICorner")
        SubBtnCorner.CornerRadius = UDim.new(0, 6)
        SubBtnCorner.Parent = SubBtn

        local ContentScroll = Instance.new("ScrollingFrame")
        ContentScroll.Size = UDim2.new(1, 0, 1, 0)
        ContentScroll.BackgroundTransparency = 1
        ContentScroll.BorderSizePixel = 0
        ContentScroll.ScrollBarThickness = 2
        ContentScroll.Visible = false
        ContentScroll.Parent = Page.SubContentHolder

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = ContentScroll

        SubBtn.MouseButton1Click:Connect(function()
            for _, st in pairs(Page.SubTabs) do
                st.Content.Visible = false
                Tween(st.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(120, 120, 130)})
            end
            ContentScroll.Visible = true
            Tween(SubBtn, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(240, 240, 240)})
        end)

        if #Page.SubTabs == 0 then
            ContentScroll.Visible = true
            SubBtn.BackgroundTransparency = 0
            SubBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end

        SubTab.Button = SubBtn
        SubTab.Content = ContentScroll
        table.insert(Page.SubTabs, SubTab)

        -- CREATE CARD / SECTION
        function SubTab:CreateCard(cardTitle, cardIcon)
            cardIcon = cardIcon or "🔥"
            local Card = {}

            local CardFrame = Instance.new("Frame")
            CardFrame.Size = UDim2.new(1, -5, 0, 280)
            CardFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
            CardFrame.Parent = ContentScroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            local CardHeader = Instance.new("TextLabel")
            CardHeader.Text = cardIcon .. "  " .. cardTitle
            CardHeader.Size = UDim2.new(1, -20, 0, 30)
            CardHeader.Position = UDim2.new(0, 12, 0, 5)
            CardHeader.TextColor3 = Color3.fromRGB(160, 160, 170)
            CardHeader.Font = Enum.Font.GothamBold
            CardHeader.TextSize = 13
            CardHeader.TextXAlignment = Enum.TextXAlignment.Left
            CardHeader.BackgroundTransparency = 1
            CardHeader.Parent = CardFrame

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -24, 1, -40)
            Container.Position = UDim2.new(0, 12, 0, 35)
            Container.BackgroundTransparency = 1
            Container.Parent = CardFrame

            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 8)
            List.Parent = Container

            -- TOGGLE
            function Card:AddToggle(text, default, callback)
                callback = callback or function() end
                local state = default or false

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 24)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.8, 0, 1, 0)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(0, 16, 0, 16)
                Box.Position = UDim2.new(1, -16, 0.5, -8)
                Box.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                Box.Text = ""
                Box.Parent = Frame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = Box

                local Check = Instance.new("Frame")
                Check.Size = UDim2.new(1, -4, 1, -4)
                Check.Position = UDim2.new(0, 2, 0, 2)
                Check.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                Check.BackgroundTransparency = state and 0 or 1
                Check.Parent = Box

                local CheckCorner = Instance.new("UICorner")
                CheckCorner.CornerRadius = UDim.new(0, 2)
                CheckCorner.Parent = Check

                Box.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(Check, {BackgroundTransparency = state and 0 or 1})
                    callback(state)
                end)
            end

            -- BUTTON
            function Card:AddButton(text, callback)
                callback = callback or function() end

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 28)
                Btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
                Btn.Text = text
                Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 12
                Btn.Parent = Container

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 6)
                Corner.Parent = Btn

                Btn.MouseButton1Click:Connect(callback)
            end

            -- SLIDER
            function Card:AddSlider(text, min, max, default, callback)
                callback = callback or function() end
                local val = default or min

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 36)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.5, 0, 0, 18)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local ValLbl = Instance.new("TextLabel")
                ValLbl.Text = tostring(val) .. "%"
                ValLbl.Size = UDim2.new(0.5, 0, 0, 18)
                ValLbl.Position = UDim2.new(0.5, 0, 0, 0)
                ValLbl.TextColor3 = Color3.fromRGB(140, 140, 150)
                ValLbl.Font = Enum.Font.Gotham
                ValLbl.TextSize = 12
                ValLbl.TextXAlignment = Enum.TextXAlignment.Right
                ValLbl.BackgroundTransparency = 1
                ValLbl.Parent = Frame

                local Track = Instance.new("TextButton")
                Track.Size = UDim2.new(1, 0, 0, 4)
                Track.Position = UDim2.new(0, 0, 0, 24)
                Track.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
                Track.Text = ""
                Track.Parent = Frame

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                Fill.Parent = Track

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 10, 0, 10)
                Knob.Position = UDim2.new(1, -5, 0.5, -5)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Fill

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local dragging = false
                local function Update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * pos)
                    ValLbl.Text = tostring(val) .. "%"
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    callback(val)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
                end)
            end

            -- DROPDOWN
            function Card:AddDropdown(text, list, callback)
                callback = callback or function() end

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 28)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(0, 90, 0, 22)
                DropBtn.Position = UDim2.new(1, -90, 0.5, -11)
                DropBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                DropBtn.Text = list[1] or "Option 1"
                DropBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
                DropBtn.Font = Enum.Font.Gotham
                DropBtn.TextSize = 11
                DropBtn.Parent = Frame

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = DropBtn
            end

            -- TEXTBOX
            function Card:AddTextbox(text, placeholder, callback)
                callback = callback or function() end

                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, 0, 0, 28)
                Input.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
                Input.PlaceholderText = placeholder or "Text"
                Input.Text = ""
                Input.TextColor3 = Color3.fromRGB(220, 220, 230)
                Input.Font = Enum.Font.Gotham
                Input.TextSize = 11
                Input.TextXAlignment = Enum.TextXAlignment.Left
                Input.Parent = Container

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 6)
                InputCorner.Parent = Input

                local Pad = Instance.new("UIPadding")
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Input

                Input.FocusLost:Connect(function(enter)
                    callback(Input.Text, enter)
                end)
            end

            return Card
        end

        return SubTab
    end

    return Page
end

return Library
