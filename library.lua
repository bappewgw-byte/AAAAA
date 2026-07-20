-- ========================================================
-- GENEROUS UI LIBRARY V2 (MOBILE & PC + LUCIDE ICONS)
-- ========================================================
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local function Tween(instance, properties, duration)
    duration = duration or 0.15
    local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Helper Draggable System (Support PC & Mobile Touch)
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos

    local function OnInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    handle.InputBegan:Connect(OnInputBegan)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.03)
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

    -- Main Scale Container (Untuk Pengaturan Scale UI)
    local ScaleContainer = Instance.new("UIScale")
    ScaleContainer.Scale = 1
    ScaleContainer.Parent = ScreenGui

    -- Main Window Container (Responsive Mobile & PC)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.85, 0, 0.8, 0)
    MainFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
    MainFrame.Size = UDim2.new(0, math.clamp(workspace.CurrentCamera.ViewportSize.X * 0.7, 340, 620), 0, math.clamp(workspace.CurrentCamera.ViewportSize.Y * 0.75, 300, 440))
    MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.5, -MainFrame.Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- SIDEBAR (LEFT)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0.32, 0, 1, -20)
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame

    -- Header Card
    local HeaderCard = Instance.new("Frame")
    HeaderCard.Size = UDim2.new(1, 0, 0, 60)
    HeaderCard.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    HeaderCard.BorderSizePixel = 0
    HeaderCard.Parent = Sidebar

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = HeaderCard

    MakeDraggable(MainFrame, HeaderCard)

    local LogoBox = Instance.new("Frame")
    LogoBox.Size = UDim2.new(0, 38, 0, 38)
    LogoBox.Position = UDim2.new(0, 10, 0.5, -19)
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
    TitleLbl.Size = UDim2.new(1, -55, 0, 20)
    TitleLbl.Position = UDim2.new(0, 54, 0, 10)
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Parent = HeaderCard

    local SubLbl = Instance.new("TextLabel")
    SubLbl.Text = gameSubTitle or "for Game"
    SubLbl.Size = UDim2.new(1, -55, 0, 18)
    SubLbl.Position = UDim2.new(0, 54, 0, 28)
    SubLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
    SubLbl.Font = Enum.Font.Gotham
    SubLbl.TextSize = 10
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubLbl.BackgroundTransparency = 1
    SubLbl.Parent = HeaderCard

    -- Nav Scroll Container
    local NavContainer = Instance.new("ScrollingFrame")
    NavContainer.Size = UDim2.new(1, 0, 1, -135)
    NavContainer.Position = UDim2.new(0, 0, 0, 68)
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
    FooterCard.Size = UDim2.new(1, 0, 0, 55)
    FooterCard.Position = UDim2.new(0, 0, 1, -55)
    FooterCard.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    FooterCard.BorderSizePixel = 0
    FooterCard.Parent = Sidebar

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 8)
    FooterCorner.Parent = FooterCard

    local SubExpiryLbl = Instance.new("TextLabel")
    SubExpiryLbl.Text = "Sub expires in 23d"
    SubExpiryLbl.Size = UDim2.new(1, -15, 0, 18)
    SubExpiryLbl.Position = UDim2.new(0, 10, 0, 8)
    SubExpiryLbl.TextColor3 = Color3.fromRGB(130, 130, 140)
    SubExpiryLbl.Font = Enum.Font.Gotham
    SubExpiryLbl.TextSize = 10
    SubExpiryLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubExpiryLbl.BackgroundTransparency = 1
    SubExpiryLbl.Parent = FooterCard

    local SessionLbl = Instance.new("TextLabel")
    SessionLbl.Text = "Session duration: 00:00"
    SessionLbl.Size = UDim2.new(1, -15, 0, 18)
    SessionLbl.Position = UDim2.new(0, 10, 0, 26)
    SessionLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    SessionLbl.Font = Enum.Font.GothamBold
    SessionLbl.TextSize = 11
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
    MainContent.Size = UDim2.new(0.68, -15, 1, -20)
    MainContent.Position = UDim2.new(0.32, 10, 0, 10)
    MainContent.BackgroundTransparency = 1
    MainContent.Parent = MainFrame

    local PageTitle = Instance.new("TextLabel")
    PageTitle.Text = "Page Title"
    PageTitle.Size = UDim2.new(1, 0, 0, 28)
    PageTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextSize = 16
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.BackgroundTransparency = 1
    PageTitle.Parent = MainContent

    -- Notification Holder
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotifHolder"
    NotifHolder.Size = UDim2.new(0, 240, 1, -20)
    NotifHolder.Position = UDim2.new(1, -250, 0, 10)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 6)
    NotifLayout.Parent = NotifHolder

    self.Gui = ScreenGui
    self.ScaleContainer = ScaleContainer
    self.MainFrame = MainFrame
    self.NavContainer = NavContainer
    self.MainContent = MainContent
    self.PageTitle = PageTitle
    self.NotifHolder = NotifHolder
    self.Pages = {}

    return self
end

-- ==================== NOTIFICATION SYSTEM ====================
function Library:Notify(title, text, duration)
    duration = duration or 3

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 52)
    Notif.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    Notif.BackgroundTransparency = 1
    Notif.BorderSizePixel = 0
    Notif.Parent = self.NotifHolder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Notif

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = title or "Notification"
    TitleLbl.Size = UDim2.new(1, -20, 0, 18)
    TitleLbl.Position = UDim2.new(0, 10, 0, 6)
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 12
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Parent = Notif

    local TextLbl = Instance.new("TextLabel")
    TextLbl.Text = text or ""
    TextLbl.Size = UDim2.new(1, -20, 0, 20)
    TextLbl.Position = UDim2.new(0, 10, 0, 24)
    TextLbl.TextColor3 = Color3.fromRGB(160, 160, 170)
    TextLbl.Font = Enum.Font.Gotham
    TextLbl.TextSize = 10
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

-- ==================== UI SCALE SYSTEM ====================
function Library:SetScale(scaleFactor)
    if self.ScaleContainer then
        self.ScaleContainer.Scale = math.clamp(scaleFactor or 1, 0.5, 2)
    end
end

-- ADD CATEGORY LABEL TO SIDEBAR
function Library:AddCategory(categoryName)
    local Label = Instance.new("TextLabel")
    Label.Text = categoryName
    Label.Size = UDim2.new(1, 0, 0, 22)
    Label.TextColor3 = Color3.fromRGB(100, 100, 110)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = self.NavContainer
end

-- CREATE PAGE
function Library:CreatePage(pageName, iconId)
    local Page = {}

    local PageBtn = Instance.new("TextButton")
    PageBtn.Size = UDim2.new(1, 0, 0, 32)
    PageBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    PageBtn.BackgroundTransparency = 1
    PageBtn.Text = ""
    PageBtn.Parent = self.NavContainer

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = PageBtn

    -- Lucide Icon Image Support
    local IconImg = Instance.new("ImageLabel")
    IconImg.Size = UDim2.new(0, 16, 0, 16)
    IconImg.Position = UDim2.new(0, 10, 0.5, -8)
    IconImg.BackgroundTransparency = 1
    IconImg.Image = iconId or "rbxassetid://10723415903" -- Default Lucide Icon
    IconImg.ImageColor3 = Color3.fromRGB(140, 140, 150)
    IconImg.Parent = PageBtn

    local BtnLbl = Instance.new("TextLabel")
    BtnLbl.Text = pageName
    BtnLbl.Size = UDim2.new(1, -35, 1, 0)
    BtnLbl.Position = UDim2.new(0, 32, 0, 0)
    BtnLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
    BtnLbl.Font = Enum.Font.GothamMedium
    BtnLbl.TextSize = 12
    BtnLbl.TextXAlignment = Enum.TextXAlignment.Left
    BtnLbl.BackgroundTransparency = 1
    BtnLbl.Parent = PageBtn

    -- Page Container
    local PageFrame = Instance.new("Frame")
    PageFrame.Size = UDim2.new(1, 0, 1, -30)
    PageFrame.Position = UDim2.new(0, 0, 0, 30)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.Parent = self.MainContent

    -- Sub-Tabs Bar (Pills)
    local SubTabBar = Instance.new("Frame")
    SubTabBar.Size = UDim2.new(1, 0, 0, 28)
    SubTabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    SubTabBar.Parent = PageFrame

    local SubCorner = Instance.new("UICorner")
    SubCorner.CornerRadius = UDim.new(0, 6)
    SubCorner.Parent = SubTabBar

    local SubList = Instance.new("UIListLayout")
    SubList.FillDirection = Enum.FillDirection.Horizontal
    SubList.Padding = UDim.new(0, 4)
    SubList.Parent = SubTabBar

    local SubPad = Instance.new("UIPadding")
    SubPad.PaddingLeft = UDim.new(0, 4)
    SubPad.PaddingTop = UDim.new(0, 2)
    SubPad.Parent = SubTabBar

    local SubContentHolder = Instance.new("Frame")
    SubContentHolder.Size = UDim2.new(1, 0, 1, -36)
    SubContentHolder.Position = UDim2.new(0, 0, 0, 36)
    SubContentHolder.BackgroundTransparency = 1
    SubContentHolder.Parent = PageFrame

    Page.Frame = PageFrame
    Page.SubTabBar = SubTabBar
    Page.SubContentHolder = SubContentHolder
    Page.SubTabs = {}

    PageBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do
            p.Frame.Visible = false
            Tween(p.Button, {BackgroundTransparency = 1})
            p.BtnLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
            p.IconImg.ImageColor3 = Color3.fromRGB(120, 120, 130)
        end
        PageFrame.Visible = true
        self.PageTitle.Text = pageName
        Tween(PageBtn, {BackgroundTransparency = 0})
        BtnLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        IconImg.ImageColor3 = Color3.fromRGB(240, 240, 240)
    end)

    if #self.Pages == 0 then
        PageFrame.Visible = true
        self.PageTitle.Text = pageName
        PageBtn.BackgroundTransparency = 0
        BtnLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        IconImg.ImageColor3 = Color3.fromRGB(240, 240, 240)
    end

    Page.Button = PageBtn
    Page.BtnLbl = BtnLbl
    Page.IconImg = IconImg
    table.insert(self.Pages, Page)

    -- CREATE SUB TAB
    function Page:CreateSubTab(subName)
        local SubTab = {}

        local SubBtn = Instance.new("TextButton")
        SubBtn.Size = UDim2.new(0, 65, 0, 24)
        SubBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        SubBtn.BackgroundTransparency = 1
        SubBtn.Text = subName
        SubBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
        SubBtn.Font = Enum.Font.GothamMedium
        SubBtn.TextSize = 11
        SubBtn.Parent = Page.SubTabBar

        local SubBtnCorner = Instance.new("UICorner")
        SubBtnCorner.CornerRadius = UDim.new(0, 4)
        SubBtnCorner.Parent = SubBtn

        local ContentScroll = Instance.new("ScrollingFrame")
        ContentScroll.Size = UDim2.new(1, 0, 1, 0)
        ContentScroll.BackgroundTransparency = 1
        ContentScroll.BorderSizePixel = 0
        ContentScroll.ScrollBarThickness = 2
        ContentScroll.Visible = false
        ContentScroll.ClipsDescendants = false -- FIX BUG DROPDOWN DIPOTONG FRAME
        ContentScroll.Parent = Page.SubContentHolder

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 8)
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
        function SubTab:CreateCard(cardTitle, iconId)
            local Card = {}

            local CardFrame = Instance.new("Frame")
            CardFrame.Size = UDim2.new(1, -5, 0, 260)
            CardFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
            CardFrame.ClipsDescendants = false -- FIX BUG DROPDOWN HIDDEN
            CardFrame.Parent = ContentScroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            local CardIcon = Instance.new("ImageLabel")
            CardIcon.Size = UDim2.new(0, 14, 0, 14)
            CardIcon.Position = UDim2.new(0, 10, 0, 10)
            CardIcon.BackgroundTransparency = 1
            CardIcon.Image = iconId or "rbxassetid://10723415903"
            CardIcon.ImageColor3 = Color3.fromRGB(160, 160, 170)
            CardIcon.Parent = CardFrame

            local CardHeader = Instance.new("TextLabel")
            CardHeader.Text = cardTitle
            CardHeader.Size = UDim2.new(1, -30, 0, 20)
            CardHeader.Position = UDim2.new(0, 28, 0, 7)
            CardHeader.TextColor3 = Color3.fromRGB(160, 160, 170)
            CardHeader.Font = Enum.Font.GothamBold
            CardHeader.TextSize = 12
            CardHeader.TextXAlignment = Enum.TextXAlignment.Left
            CardHeader.BackgroundTransparency = 1
            CardHeader.Parent = CardFrame

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 1, -35)
            Container.Position = UDim2.new(0, 10, 0, 30)
            Container.BackgroundTransparency = 1
            Container.ClipsDescendants = false
            Container.Parent = CardFrame

            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.Parent = Container

            -- TOGGLE
            function Card:AddToggle(text, default, callback)
                callback = callback or function() end
                local state = default or false

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 22)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.8, 0, 1, 0)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 11
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

            -- ULTRA SMOOTH SLIDER
            function Card:AddSlider(text, min, max, default, callback)
                callback = callback or function() end
                local val = default or min

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 32)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.5, 0, 0, 16)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 11
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local ValLbl = Instance.new("TextLabel")
                ValLbl.Text = tostring(val) .. "%"
                ValLbl.Size = UDim2.new(0.5, 0, 0, 16)
                ValLbl.Position = UDim2.new(0.5, 0, 0, 0)
                ValLbl.TextColor3 = Color3.fromRGB(140, 140, 150)
                ValLbl.Font = Enum.Font.Gotham
                ValLbl.TextSize = 11
                ValLbl.TextXAlignment = Enum.TextXAlignment.Right
                ValLbl.BackgroundTransparency = 1
                ValLbl.Parent = Frame

                local Track = Instance.new("TextButton")
                Track.Size = UDim2.new(1, 0, 0, 4)
                Track.Position = UDim2.new(0, 0, 0, 20)
                Track.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
                Track.Text = ""
                Track.Parent = Frame

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                Fill.Parent = Track

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 8, 0, 8)
                Knob.Position = UDim2.new(1, -4, 0.5, -4)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Parent = Fill

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local dragging = false
                local Connection

                local function Update()
                    local mousePos = UserInputService:GetMouseLocation().X
                    local pos = math.clamp((mousePos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * pos)
                    ValLbl.Text = tostring(val) .. "%"
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    callback(val)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Connection = RunService.RenderStepped:Connect(Update)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                        dragging = false
                        if Connection then Connection:Disconnect() end
                    end
                end)
            end

            -- SINGLE DROPDOWN (FIX BUG DROPDOWN HIDDEN)
            function Card:AddDropdown(text, list, callback)
                callback = callback or function() end
                local open = false

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 26)
                Frame.BackgroundTransparency = 1
                Frame.ZIndex = 5
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 11
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(0, 95, 0, 22)
                DropBtn.Position = UDim2.new(1, -95, 0.5, -11)
                DropBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                DropBtn.Text = list[1] or "Select"
                DropBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
                DropBtn.Font = Enum.Font.Gotham
                DropBtn.TextSize = 10
                DropBtn.ZIndex = 6
                DropBtn.Parent = Frame

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = DropBtn

                local OptionHolder = Instance.new("Frame")
                OptionHolder.Size = UDim2.new(1, 0, 0, #list * 20)
                OptionHolder.Position = UDim2.new(0, 0, 1, 4)
                OptionHolder.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
                OptionHolder.Visible = false
                OptionHolder.ZIndex = 20
                OptionHolder.Parent = DropBtn

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptionHolder

                local OptLayout = Instance.new("UIListLayout")
                OptLayout.Parent = OptionHolder

                for _, opt in ipairs(list) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 20)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 10
                    OptBtn.ZIndex = 21
                    OptBtn.Parent = OptionHolder

                    OptBtn.MouseButton1Click:Connect(function()
                        DropBtn.Text = opt
                        OptionHolder.Visible = false
                        open = false
                        callback(opt)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    OptionHolder.Visible = open
                end)
            end

            -- MULTI SELECT DROPDOWN
            function Card:AddMultiDropdown(text, list, callback)
                callback = callback or function() end
                local selected = {}
                local open = false

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 26)
                Frame.BackgroundTransparency = 1
                Frame.ZIndex = 5
                Frame.Parent = Container

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = text
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 11
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.BackgroundTransparency = 1
                Lbl.Parent = Frame

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(0, 95, 0, 22)
                DropBtn.Position = UDim2.new(1, -95, 0.5, -11)
                DropBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                DropBtn.Text = "None"
                DropBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
                DropBtn.Font = Enum.Font.Gotham
                DropBtn.TextSize = 10
                DropBtn.ZIndex = 6
                DropBtn.Parent = Frame

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = DropBtn

                local OptionHolder = Instance.new("Frame")
                OptionHolder.Size = UDim2.new(1, 0, 0, #list * 20)
                OptionHolder.Position = UDim2.new(0, 0, 1, 4)
                OptionHolder.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
                OptionHolder.Visible = false
                OptionHolder.ZIndex = 20
                OptionHolder.Parent = DropBtn

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptionHolder

                local OptLayout = Instance.new("UIListLayout")
                OptLayout.Parent = OptionHolder

                for _, opt in ipairs(list) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 20)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 10
                    OptBtn.ZIndex = 21
                    OptBtn.Parent = OptionHolder

                    OptBtn.MouseButton1Click:Connect(function()
                        if table.find(selected, opt) then
                            table.remove(selected, table.find(selected, opt))
                            OptBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
                        else
                            table.insert(selected, opt)
                            OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end

                        if #selected == 0 then
                            DropBtn.Text = "None"
                        else
                            DropBtn.Text = table.concat(selected, ", ")
                        end
                        callback(selected)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    OptionHolder.Visible = open
                end)
            end

            -- TEXTBOX
            function Card:AddTextbox(text, placeholder, callback)
                callback = callback or function() end

                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, 0, 0, 26)
                Input.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
                Input.PlaceholderText = placeholder or "Text"
                Input.Text = ""
                Input.TextColor3 = Color3.fromRGB(220, 220, 230)
                Input.Font = Enum.Font.Gotham
                Input.TextSize = 10
                Input.TextXAlignment = Enum.TextXAlignment.Left
                Input.Parent = Container

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = Input

                local Pad = Instance.new("UIPadding")
                Pad.PaddingLeft = UDim.new(0, 8)
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
