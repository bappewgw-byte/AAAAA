-- ========================================================
-- GENEROUS UI LIBRARY  (v2)
-- Changelog:
--   • FIXED: dropdown tidak muncul (options sekarang di-render di
--     overlay layer terpisah, jadi tidak ke-clip sama ScrollingFrame)
--   • NEW: Single Select Dropdown & Multi Select Dropdown
--   • NEW: Resizable window (drag handle di pojok kanan bawah)
--   • NEW: Responsive (auto scale utk mobile & pc, drag pakai touch)
--   • NEW: Icon Lucide (500+ icon, tinggal panggil nama iconnya)
--   • NEW: Notification system (Library:Notify)
--   • NEW: Slider lebih smooth (gak pake tween tiap gerak, langsung ikut mouse)
--   • Cards sekarang auto-size sesuai isi (gak ada spasi kosong lagi)
-- ========================================================

local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ========================================================
-- ICONS (Lucide -> rbxassetid, community port)
-- Pakai: Icon("home"), Icon("settings"), dst. Kalau nama gak ada
-- di tabel, otomatis fallback ke icon "circle".
-- Bisa juga langsung pass "rbxassetid://123456" buat icon custom.
-- ========================================================
local FetchIcons, Icons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
    ))()
end)

local function GetLucideIcon(IconName)
    if not FetchIcons then return nil end
    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if Success then return Icon end
    return nil
end

local function IsCustomAssetIcon(Icon, IncludeAssetId)
    return typeof(Icon) == "string" and (Icon:match("^content://") or Icon:match("^rbxasset://%x+/") or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

local function IsValidCustomIcon(Icon)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function GetIconData(IconName)
    if not IconName then return nil end
    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IsCustomAssetIcon(IconName, true) then
        return { Url = IconName }
    elseif IsValidCustomIcon(IconName) then
        return { Url = IconName, Custom = true }
    end

    local LucideIcon = GetLucideIcon(IconName)
    if LucideIcon then return LucideIcon end

    return GetLucideIcon("circle") -- fallback
end

local function ApplyIcon(imageLabel, iconName)
    local iconData = GetIconData(iconName)
    if iconData then
        imageLabel.Image = iconData.Url or ""
        if iconData.ImageRectOffset then
            imageLabel.ImageRectOffset = iconData.ImageRectOffset
        else
            imageLabel.ImageRectOffset = Vector2.zero
        end
        if iconData.ImageRectSize then
            imageLabel.ImageRectSize = iconData.ImageRectSize
        else
            imageLabel.ImageRectSize = Vector2.zero
        end
    end
end

-- ========================================================
-- HELPERS
-- ========================================================
local function Tween(instance, properties, duration, style)
    duration = duration or 0.2
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function IsTouchInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if IsTouchInput(input) then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Makes a frame resizable by dragging a handle at its bottom-right corner
local function MakeResizable(frame, handle, minSize, maxSize)
    minSize = minSize or Vector2.new(480, 320)
    maxSize = maxSize or Vector2.new(1000, 760)
    local resizing, startPos, startSize

    handle.InputBegan:Connect(function(input)
        if IsTouchInput(input) then
            resizing = true
            startPos = input.Position
            startSize = frame.Size

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            local newX = math.clamp(startSize.X.Offset + delta.X, minSize.X, maxSize.X)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, minSize.Y, maxSize.Y)
            frame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- Keeps `overlayFrame` (a dropdown's option list, living in the top-level
-- Overlay layer) glued directly under `anchorButton` every frame while it's
-- visible. Without this, dragging or resizing the window leaves the popup
-- floating in its old screen position, disconnected from the button that
-- opened it. Returns a connection; caller should :Disconnect() it on close.
local function FollowAnchor(overlayFrame, anchorButton, optH)
    return RunService.RenderStepped:Connect(function()
        if not overlayFrame.Visible then return end
        local abs = anchorButton.AbsolutePosition
        local size = anchorButton.AbsoluteSize
        local screenH = (Camera and Camera.ViewportSize.Y) or 720
        local posY = abs.Y + size.Y + 4
        if posY + optH > screenH and abs.Y - optH - 4 > 0 then
            posY = abs.Y - optH - 4 -- flip upward if no room below
        end
        overlayFrame.Position = UDim2.new(0, abs.X, 0, posY)
        overlayFrame.Size = UDim2.new(0, size.X, 0, optH)
    end)
end

-- ========================================================
-- LIBRARY.NEW
-- ========================================================
function Library.new(options, gameSubTitle)
    if type(options) == "string" then
        options = { Name = options, SubTitle = gameSubTitle }
    end
    local hubName = options.Name or "Hub"
    gameSubTitle = options.SubTitle or ""

    local self = setmetatable({}, Library)
    self.Options = options

    local parentTarget
    if gethui then
        parentTarget = gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        parentTarget = CoreGui
    else
        parentTarget = CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local guiName = options.GuiName or HttpService:GenerateGUID(false)

    if parentTarget:FindFirstChild(guiName) then
        parentTarget[guiName]:Destroy()
    end
    if parentTarget:FindFirstChild("GenerousUI") then
        parentTarget.GenerousUI:Destroy()
    end

    local ScreenGui = New("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, parentTarget)

    -- Detect mobile / small screen for responsive scaling
    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)

    -- Main Window
    local MainFrame = New("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 620, 0, 440),
        Position = UDim2.new(0.5, -310, 0.5, -220),
        BackgroundColor3 = Color3.fromRGB(12, 12, 14),
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, ScreenGui)

    New("UICorner", {CornerRadius = UDim.new(0, 10)}, MainFrame)

    -- Responsive scaling: shrinks the whole UI down on small / mobile screens
    local UIScaleObj = New("UIScale", {Scale = 1}, MainFrame)
    local function UpdateScale()
        local vp = Camera and Camera.ViewportSize or viewport
        local scale = 1
        if vp.X < 700 or isMobile then
            scale = math.clamp(vp.X / 720, 0.55, 1)
        end
        Tween(UIScaleObj, {Scale = scale}, 0.2)
    end
    UpdateScale()
    if Camera then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
    end

    local ToggleBtn = New("ImageButton", {
        Name = "ToggleBtn",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundColor3 = Color3.fromRGB(20, 20, 22),
        Image = "rbxassetid://127242944781300",
        Visible = false,
        ZIndex = 100,
    }, ScreenGui)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, ToggleBtn)
    MakeDraggable(ToggleBtn, ToggleBtn)

    local CloseBtn = New("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -34, 0, 10),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        Text = "",
        ZIndex = 10,
    }, MainFrame)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, CloseBtn)
    New("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = Icons["x"] or "rbxassetid://7743878857",
        ImageColor3 = Color3.fromRGB(220, 220, 220),
        ZIndex = 11,
    }, CloseBtn)

    local MinimizeBtn = New("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -64, 0, 10),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        Text = "",
        ZIndex = 10,
    }, MainFrame)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, MinimizeBtn)
    New("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = Icons["minus"] or "rbxassetid://7734000129",
        ImageColor3 = Color3.fromRGB(220, 220, 220),
        ZIndex = 11,
    }, MinimizeBtn)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        ToggleBtn.Visible = true
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        ToggleBtn.Visible = false
        MainFrame.Visible = true
    end)

    -- Overlay layer for dropdown menus / notifications so nothing gets clipped
    -- by ScrollingFrames underneath
    local Overlay = New("Frame", {
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 50,
    }, ScreenGui)

    local NotifHolder = New("Frame", {
        Name = "NotifHolder",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.new(0, 280, 1, -28),
        BackgroundTransparency = 1,
        ZIndex = 100,
    }, ScreenGui)
    local NotifList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, NotifHolder)

    -- SIDEBAR (LEFT)
    local Sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 200, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
    }, MainFrame)

    -- Header Card
    local HeaderCard = New("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = Color3.fromRGB(20, 20, 22),
        BorderSizePixel = 0,
    }, Sidebar)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, HeaderCard)

    MakeDraggable(MainFrame, HeaderCard)

    local LogoBox = New("Frame", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 12, 0.5, -21),
        BackgroundColor3 = Color3.fromRGB(10, 10, 12),
    }, HeaderCard)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, LogoBox)

    New("ImageLabel", {
        Image = "rbxassetid://127242944781300",
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
    }, LogoBox)

    New("TextLabel", {
        Text = hubName or "Balright",
        Size = UDim2.new(1, -65, 0, 20),
        Position = UDim2.new(0, 62, 0, 14),
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, HeaderCard)

    New("TextLabel", {
        Text = gameSubTitle or "for Game",
        Size = UDim2.new(1, -65, 0, 18),
        Position = UDim2.new(0, 62, 0, 32),
        TextColor3 = Color3.fromRGB(120, 120, 130),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, HeaderCard)

    -- Nav Scroll Container
    local NavContainer = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -150),
        Position = UDim2.new(0, 0, 0, 75),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Sidebar)

    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, NavContainer)

    -- Footer Card
    local FooterCard = New("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 1, -60),
        BackgroundColor3 = Color3.fromRGB(20, 20, 22),
        BorderSizePixel = 0,
    }, Sidebar)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, FooterCard)

    local LocalPlayer = game.Players.LocalPlayer
    local AvatarImg = New("ImageLabel", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 9, 0.5, -21),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
    }, FooterCard)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, AvatarImg)

    task.spawn(function()
        if LocalPlayer then
            pcall(function()
                AvatarImg.Image = game.Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end)
        end
    end)

    local realName = LocalPlayer and LocalPlayer.Name or "Player"
    local hiddenName = string.rep("*", #realName)
    local isHidden = false

    local NameLbl = New("TextLabel", {
        Text = realName,
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 60, 0.5, -18),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, FooterCard)

    local HideBtn = New("TextButton", {
        Text = "Hide Username",
        Size = UDim2.new(1, -60, 0, 15),
        Position = UDim2.new(0, 60, 0.5, 2),
        TextColor3 = Color3.fromRGB(150, 150, 160),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, FooterCard)

    HideBtn.MouseEnter:Connect(function() Tween(HideBtn, {TextColor3 = Color3.fromRGB(200, 200, 210)}, 0.1) end)
    HideBtn.MouseLeave:Connect(function() Tween(HideBtn, {TextColor3 = Color3.fromRGB(150, 150, 160)}, 0.1) end)

    HideBtn.MouseButton1Click:Connect(function()
        isHidden = not isHidden
        if isHidden then
            NameLbl.Text = hiddenName
            HideBtn.Text = "Show Username"
        else
            NameLbl.Text = realName
            HideBtn.Text = "Hide Username"
        end
    end)

    -- MAIN CONTENT (RIGHT)
    local MainContent = New("Frame", {
        Size = UDim2.new(1, -230, 1, -20),
        Position = UDim2.new(0, 220, 0, 10),
        BackgroundTransparency = 1,
    }, MainFrame)

    local PageTitle = New("TextLabel", {
        Text = "Page Title",
        Size = UDim2.new(1, 0, 0, 30),
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, MainContent)

    -- Resize handle (bottom-right corner)
    local ResizeHandle = New("TextButton", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -18, 1, -18),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 20,
    }, MainFrame)
    local ResizeImg = New("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(90, 90, 98),
        ImageTransparency = 0.2,
    }, ResizeHandle)
    ApplyIcon(ResizeImg, "move-diagonal-2")
    MakeResizable(MainFrame, ResizeHandle, Vector2.new(480, 340), Vector2.new(980, 740))

    self.Gui = ScreenGui
    self.Overlay = Overlay
    self.NotifHolder = NotifHolder
    self.MainFrame = MainFrame
    self.NavContainer = NavContainer
    self.MainContent = MainContent
    self.PageTitle = PageTitle
    self.Pages = {}
    self._openDropdown = nil       -- OptionsFrame currently open (or nil)
    self._openDropdownClose = nil  -- function to call to close it
    self._openDropdownButton = nil -- the DropBtn that opened it (clicking it again = its own toggle)

    -- Global click-outside-to-close: if a dropdown is open and the user
    -- presses anywhere that isn't the option list itself or the button
    -- that opened it, close it. This is what actually makes dropdowns
    -- closable when the option list happens to sit over other UI.
    UserInputService.InputBegan:Connect(function(input)
        if not self._openDropdown or not self._openDropdown.Visible then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local pos = Vector2.new(input.Position.X, input.Position.Y)

        local function InBounds(frame)
            if not frame then return false end
            local ap, asz = frame.AbsolutePosition, frame.AbsoluteSize
            return pos.X >= ap.X and pos.X <= ap.X + asz.X and pos.Y >= ap.Y and pos.Y <= ap.Y + asz.Y
        end

        if InBounds(self._openDropdown) or InBounds(self._openDropdownButton) then
            return -- let the option button / toggle button handle it themselves
        end

        if self._openDropdownClose then
            self._openDropdownClose()
        end
    end)

    self.SetScale = function(_, val)
        Tween(UIScaleObj, {Scale = val}, 0.2)
    end

    if options.KeySystem then
        MainFrame.Visible = false
        
        local KeyFrame = New("Frame", {
            Name = "KeyFrame",
            Size = UDim2.new(0, 400, 0, 250),
            Position = UDim2.new(0.5, -200, 0.5, -125),
            BackgroundColor3 = Color3.fromRGB(16, 16, 18),
            BorderSizePixel = 0,
            ZIndex = 200,
        }, ScreenGui)
        New("UICorner", {CornerRadius = UDim.new(0, 10)}, KeyFrame)

        local KeyTitle = New("TextLabel", {
            Text = options.KeySettings and options.KeySettings.Title or "Key System",
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 10),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            ZIndex = 201,
        }, KeyFrame)

        local KeyDesc = New("TextLabel", {
            Text = options.KeySettings and options.KeySettings.Description or "Please enter your access key",
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.new(0, 20, 0, 50),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(150, 150, 160),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextWrapped = true,
            ZIndex = 201,
        }, KeyFrame)

        local KeyInputHolder = New("Frame", {
            Size = UDim2.new(1, -60, 0, 40),
            Position = UDim2.new(0, 30, 0, 100),
            BackgroundColor3 = Color3.fromRGB(24, 24, 28),
            ZIndex = 201,
        }, KeyFrame)
        New("UICorner", {CornerRadius = UDim.new(0, 6)}, KeyInputHolder)
        
        local KeyInput = New("TextBox", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            PlaceholderText = "Enter Key Here...",
            Text = "",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            ClearTextOnFocus = false,
            ZIndex = 202,
        }, KeyInputHolder)

        local CheckBtn = New("TextButton", {
            Size = UDim2.new(0.5, -35, 0, 36),
            Position = UDim2.new(0, 30, 0, 160),
            BackgroundColor3 = Color3.fromRGB(30, 215, 96),
            Text = "Check Key",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            AutoButtonColor = false,
            ZIndex = 201,
        }, KeyFrame)
        New("UICorner", {CornerRadius = UDim.new(0, 6)}, CheckBtn)

        local GetBtn = New("TextButton", {
            Size = UDim2.new(0.5, -35, 0, 36),
            Position = UDim2.new(0.5, 5, 0, 160),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = "Get Key",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            AutoButtonColor = false,
            ZIndex = 201,
        }, KeyFrame)
        New("UICorner", {CornerRadius = UDim.new(0, 6)}, GetBtn)

        local function CheckValidKey(inputKey)
            local validKeys = options.KeySettings and options.KeySettings.Key
            if type(validKeys) == "string" then
                return inputKey == validKeys
            elseif type(validKeys) == "table" then
                for _, k in ipairs(validKeys) do
                    if inputKey == k then return true end
                end
            elseif type(validKeys) == "function" then
                return validKeys(inputKey)
            end
            return false
        end

        CheckBtn.MouseButton1Click:Connect(function()
            if CheckValidKey(KeyInput.Text) then
                Tween(KeyFrame, {BackgroundTransparency = 1}, 0.3)
                for _, child in ipairs(KeyFrame:GetChildren()) do
                    if child:IsA("GuiObject") then
                        Tween(child, {BackgroundTransparency = 1}, 0.3)
                        if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                            Tween(child, {TextTransparency = 1}, 0.3)
                        end
                    end
                end
                task.delay(0.3, function()
                    KeyFrame:Destroy()
                    MainFrame.Visible = true
                    MainFrame.Size = UDim2.new(0, 600, 0, 420)
                    Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 440)}, 0.4, Enum.EasingStyle.Back)
                    self:Notify("Key System", "Valid key! Welcome.", 3, "check-circle")
                end)
            else
                local oldColor = KeyInputHolder.BackgroundColor3
                Tween(KeyInputHolder, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.1)
                task.delay(0.2, function()
                    Tween(KeyInputHolder, {BackgroundColor3 = oldColor}, 0.3)
                end)
                KeyInput.Text = ""
            end
        end)

        GetBtn.MouseButton1Click:Connect(function()
            local link = options.KeySettings and options.KeySettings.Link
            if link and setclipboard then
                setclipboard(link)
                self:Notify("Key System", "Link copied to clipboard!", 3, "copy")
            elseif not setclipboard then
                self:Notify("Key System", "setclipboard not supported!", 3, "alert-circle")
            end
        end)
    end

    return self
end

-- ========================================================
-- NOTIFICATIONS
-- ========================================================
-- Library:Notify("Title", "Some text", 4, "check-circle")
function Library:Notify(title, text, duration, icon)
    duration = duration or 3.5

    local Toast = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(18, 18, 20),
        LayoutOrder = -os.clock(),
        Position = UDim2.new(1, 40, 0, 0),
        ClipsDescendants = true,
    }, self.NotifHolder)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, Toast)
    New("UIStroke", {Color = Color3.fromRGB(35, 35, 40), Thickness = 1}, Toast)
    New("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
    }, Toast)

    if icon then
        local IconImg = New("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(240, 240, 240),
        }, Toast)
        ApplyIcon(IconImg, icon)
    end

    local TextOffset = icon and 26 or 0

    New("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -TextOffset, 0, 16),
        Position = UDim2.new(0, TextOffset, 0, 0),
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, Toast)

    New("TextLabel", {
        Text = text or "",
        Size = UDim2.new(1, -TextOffset, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, TextOffset, 0, 20),
        TextColor3 = Color3.fromRGB(150, 150, 160),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, Toast)

    Toast.Position = UDim2.new(1, 40, 0, 0)
    Tween(Toast, {Position = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Back)

    task.delay(duration, function()
        local t = Tween(Toast, {Position = UDim2.new(1, 40, 0, 0)}, 0.2)
        t.Completed:Connect(function()
            Toast:Destroy()
        end)
    end)
end

-- ADD CATEGORY LABEL TO SIDEBAR
function Library:AddCategory(categoryName)
    -- Disabled / Deprecated per user request. Kept for backward compatibility so scripts don't break.
end

-- ========================================================
-- CREATE PAGE
-- ========================================================
function Library:CreatePage(pageName, icon)
    local Page = {}
    local library = self

    local PageBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(18, 18, 20),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, self.NavContainer)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, PageBtn)

    local IconImg
    if icon then
        IconImg = New("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(120, 120, 130),
        }, PageBtn)
        ApplyIcon(IconImg, icon)
    end

    local PageLabel = New("TextLabel", {
        Text = pageName,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        TextColor3 = Color3.fromRGB(120, 120, 130),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, PageBtn)

    -- Page Container Frame
    local PageFrame = New("Frame", {
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1,
        Visible = false,
    }, self.MainContent)

    -- Sub-Tabs Bar (Pills)
    local SubTabBar = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(18, 18, 20),
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ClipsDescendants = true,
    }, PageFrame)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, SubTabBar)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
    }, SubTabBar)
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
    }, SubTabBar)

    local SubContentHolder = New("Frame", {
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
    }, PageFrame)

    Page.Frame = PageFrame
    Page.SubTabBar = SubTabBar
    Page.SubContentHolder = SubContentHolder
    Page.SubTabs = {}

    local function SelectPage()
        for _, p in pairs(library.Pages) do
            p.Frame.Visible = false
            Tween(p.Button, {BackgroundTransparency = 1})
            Tween(p.Label, {TextColor3 = Color3.fromRGB(120, 120, 130)})
            if p.Icon then Tween(p.Icon, {ImageColor3 = Color3.fromRGB(120, 120, 130)}) end
        end
        PageFrame.Visible = true
        library.PageTitle.Text = pageName
        Tween(PageBtn, {BackgroundTransparency = 0})
        Tween(PageLabel, {TextColor3 = Color3.fromRGB(240, 240, 240)})
        if IconImg then Tween(IconImg, {ImageColor3 = Color3.fromRGB(240, 240, 240)}) end
    end

    PageBtn.MouseButton1Click:Connect(SelectPage)

    if #self.Pages == 0 then
        PageFrame.Visible = true
        self.PageTitle.Text = pageName
        PageBtn.BackgroundTransparency = 0
        PageLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        if IconImg then IconImg.ImageColor3 = Color3.fromRGB(240, 240, 240) end
    end

    Page.Button = PageBtn
    Page.Label = PageLabel
    Page.Icon = IconImg
    table.insert(self.Pages, Page)

    -- ====================================================
    -- CREATE SUB TAB
    -- ====================================================
    function Page:CreateSubTab(subName)
        local SubTab = {}

        local SubBtn = New("TextButton", {
            Size = UDim2.new(0, 76, 0, 24),
            BackgroundColor3 = Color3.fromRGB(28, 28, 32),
            BackgroundTransparency = 1,
            Text = subName,
            TextColor3 = Color3.fromRGB(120, 120, 130),
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            AutoButtonColor = false,
        }, Page.SubTabBar)
        New("UICorner", {CornerRadius = UDim.new(0, 6)}, SubBtn)

        local ContentScroll = New("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65),
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, Page.SubContentHolder)

        New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, ContentScroll)

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

        -- ================================================
        -- CREATE CARD / SECTION
        -- ================================================
        function SubTab:CreateCard(cardTitle, cardIcon)
            local Card = {}

            local CardFrame = New("Frame", {
                Size = UDim2.new(1, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(18, 18, 20),
            }, ContentScroll)
            New("UICorner", {CornerRadius = UDim.new(0, 8)}, CardFrame)

            local headerOffset = 12
            if cardIcon then
                headerOffset = 32
                local IconImg = New("ImageLabel", {
                    Size = UDim2.new(0, 15, 0, 15),
                    Position = UDim2.new(0, 12, 0, 10),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(160, 160, 170),
                }, CardFrame)
                ApplyIcon(IconImg, cardIcon)
            end

            New("TextLabel", {
                Text = cardTitle,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, headerOffset, 0, 5),
                TextColor3 = Color3.fromRGB(160, 160, 170),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, CardFrame)

            local Container = New("Frame", {
                Size = UDim2.new(1, -24, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 12, 0, 35),
                BackgroundTransparency = 1,
            }, CardFrame)

            New("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, Container)

            New("UIPadding", {PaddingBottom = UDim.new(0, 12)}, Container)

            -- TOGGLE
            function Card:AddToggle(text, default, callback)
                callback = callback or function() end
                local state = default or false

                local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1}, Container)

                New("TextLabel", {
                    Text = text, Size = UDim2.new(0.8, 0, 1, 0),
                    TextColor3 = Color3.fromRGB(180, 180, 190),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                }, Frame)

                local Box = New("TextButton", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -16, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(28, 28, 32),
                    Text = "",
                }, Frame)
                New("UICorner", {CornerRadius = UDim.new(0, 4)}, Box)
                
                Box.MouseEnter:Connect(function() Tween(Box, {BackgroundColor3 = Color3.fromRGB(38, 38, 42)}, 0.15) end)
                Box.MouseLeave:Connect(function() Tween(Box, {BackgroundColor3 = Color3.fromRGB(28, 28, 32)}, 0.15) end)


                local Check = New("Frame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = Color3.fromRGB(240, 240, 240),
                    BackgroundTransparency = state and 0 or 1,
                }, Box)
                New("UICorner", {CornerRadius = UDim.new(0, 2)}, Check)

                Box.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(Check, {BackgroundTransparency = state and 0 or 1})
                    callback(state)
                end)

                return {
                    Set = function(_, v)
                        state = v
                        Check.BackgroundTransparency = state and 0 or 1
                        callback(state)
                    end,
                }
            end

            -- BUTTON
            function Card:AddButton(text, callback)
                callback = callback or function() end
                local Btn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Color3.fromRGB(24, 24, 28),
                    Text = text,
                    TextColor3 = Color3.fromRGB(220, 220, 230),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                }, Container)
                New("UICorner", {CornerRadius = UDim.new(0, 6)}, Btn)
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(34, 34, 38)}, 0.15) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(24, 24, 28)}, 0.15) end)
                Btn.MouseButton1Click:Connect(callback)
            end

            -- SLIDER (smoother: no per-frame tween while dragging, follows input directly)
            function Card:AddSlider(text, min, max, default, callback)
                callback = callback or function() end
                local val = default or min

                local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1}, Container)

                New("TextLabel", {
                    Text = text, Size = UDim2.new(0.5, 0, 0, 18),
                    TextColor3 = Color3.fromRGB(180, 180, 190),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                }, Frame)

                local ValLbl = New("TextLabel", {
                    Text = tostring(val) .. "%",
                    Size = UDim2.new(0.5, 0, 0, 18),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    TextColor3 = Color3.fromRGB(140, 140, 150),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                }, Frame)

                local Track = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Color3.fromRGB(32, 32, 36),
                    Text = "",
                    AutoButtonColor = false,
                }, Frame)
                New("UICorner", {CornerRadius = UDim.new(1, 0)}, Track)

                local initialPct = (val - min) / (max - min)
                local Fill = New("Frame", {
                    Size = UDim2.new(initialPct, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(240, 240, 240),
                }, Track)
                New("UICorner", {CornerRadius = UDim.new(1, 0)}, Fill)

                local Knob = New("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(1, -5, 0.5, -5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                }, Fill)
                New("UICorner", {CornerRadius = UDim.new(1, 0)}, Knob)

                local dragging = false
                local function Update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * pos + 0.5)
                    ValLbl.Text = tostring(val) .. "%"
                    -- direct set (no tween) = follows the cursor/finger 1:1, feels smoother
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    callback(val)
                end

                Track.InputBegan:Connect(function(input)
                    if IsTouchInput(input) then dragging = true; Update(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if IsTouchInput(input) then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)

                return {
                    Set = function(_, v)
                        v = math.clamp(v, min, max)
                        val = v
                        local pos = (v - min) / (max - min)
                        ValLbl.Text = tostring(v) .. "%"
                        Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.15)
                        callback(v)
                    end,
                }
            end

            -- ============================================
            -- DROPDOWN (fixed) — Single Select
            -- Options render in the top-level Overlay layer so they are
            -- never clipped by the ScrollingFrame, which was the bug.
            -- ============================================
            function Card:AddDropdown(text, list, default, callback)
                callback = callback or function() end
                list = list or {}
                local selected = default or list[1]

                local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, ZIndex = 5}, Container)

                New("TextLabel", {
                    Text = text, Size = UDim2.new(0.35, 0, 1, 0),
                    TextColor3 = Color3.fromRGB(180, 180, 190),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                }, Frame)

                local DropBtn = New("TextButton", {
                    Size = UDim2.new(0.65, 0, 0, 26),
                    Position = UDim2.new(0.35, 0, 0.5, -13),
                    BackgroundColor3 = Color3.fromRGB(28, 28, 32),
                    Text = "",
                    AutoButtonColor = false,
                }, Frame)
                New("UICorner", {CornerRadius = UDim.new(0, 6)}, DropBtn)
                
                DropBtn.MouseEnter:Connect(function() Tween(DropBtn, {BackgroundColor3 = Color3.fromRGB(38, 38, 42)}, 0.15) end)
                DropBtn.MouseLeave:Connect(function() Tween(DropBtn, {BackgroundColor3 = Color3.fromRGB(28, 28, 32)}, 0.15) end)

                local SelectedLbl = New("TextLabel", {
                    Text = tostring(selected or "Select"),
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.Gotham, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                }, DropBtn)

                local Chevron = New("ImageLabel", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -20, 0.5, -6),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(150, 150, 160),
                }, DropBtn)
                ApplyIcon(Chevron, "chevron-down")

                local OptionsFrame = New("Frame", {
                    Visible = false,
                    BackgroundColor3 = Color3.fromRGB(24, 24, 28),
                    BorderSizePixel = 0,
                    ZIndex = 60,
                    ClipsDescendants = true,
                }, library.Overlay)
                New("UICorner", {CornerRadius = UDim.new(0, 6)}, OptionsFrame)
                New("UIStroke", {Color = Color3.fromRGB(40, 40, 45), Thickness = 1}, OptionsFrame)

                local SearchBox = New("TextBox", {
                    Size = UDim2.new(1, -8, 0, 26),
                    Position = UDim2.new(0, 4, 0, 4),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
                    PlaceholderText = "Search...",
                    Text = "",
                    TextColor3 = Color3.fromRGB(220, 220, 230),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    ZIndex = 61,
                }, OptionsFrame)
                New("UICorner", {CornerRadius = UDim.new(0, 4)}, SearchBox)

                local OptionsScroll = New("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, -34),
                    Position = UDim2.new(0, 0, 0, 34),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 60,
                }, OptionsFrame)
                New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, OptionsScroll)
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
                }, OptionsScroll)

                local isOpen = false
                local followConn = nil
                local function CloseDropdown()
                    isOpen = false
                    OptionsFrame.Visible = false
                    Tween(Chevron, {Rotation = 0}, 0.15)
                    if followConn then
                        followConn:Disconnect()
                        followConn = nil
                    end
                    if library._openDropdown == OptionsFrame then
                        library._openDropdown = nil
                        library._openDropdownClose = nil
                        library._openDropdownButton = nil
                    end
                end

                local function OpenDropdown()
                    if library._openDropdown and library._openDropdown ~= OptionsFrame and library._openDropdownClose then
                        library._openDropdownClose()
                    end
                    SearchBox.Text = "" -- Reset search when opened
                    local visibleItems = 0
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") and child.Visible then
                            visibleItems = visibleItems + 1
                        end
                    end
                    local optH = math.min(visibleItems * 26 + 42, 200)
                    OptionsFrame.Visible = true
                    isOpen = true
                    library._openDropdown = OptionsFrame
                    library._openDropdownClose = CloseDropdown
                    library._openDropdownButton = DropBtn
                    Tween(Chevron, {Rotation = 180}, 0.15)
                    if followConn then followConn:Disconnect() end
                    followConn = FollowAnchor(OptionsFrame, DropBtn, optH)
                end

                local function RenderOptions()
                    OptionsScroll:ClearAllChildren()
                    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, OptionsScroll)
                    for _, optionValue in ipairs(list) do
                        local OptBtn = New("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = Color3.fromRGB(32, 32, 36),
                            BackgroundTransparency = optionValue == selected and 0 or 1,
                            Text = tostring(optionValue),
                            TextColor3 = optionValue == selected and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(170, 170, 180),
                            Font = Enum.Font.Gotham,
                            TextSize = 11,
                            ZIndex = 61,
                        }, OptionsScroll)
                        New("UICorner", {CornerRadius = UDim.new(0, 4)}, OptBtn)

                        OptBtn.MouseButton1Click:Connect(function()
                            selected = optionValue
                            SelectedLbl.Text = tostring(optionValue)
                            callback(optionValue)
                            CloseDropdown()
                        end)
                    end
                end
                RenderOptions()

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = string.lower(SearchBox.Text)
                    local visibleItems = 0
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            if query == "" or string.find(string.lower(child.Text), query, 1, true) then
                                child.Visible = true
                                visibleItems = visibleItems + 1
                            else
                                child.Visible = false
                            end
                        end
                    end
                    if isOpen and followConn then
                        local optH = math.min(visibleItems * 26 + 42, 200)
                        followConn:Disconnect()
                        followConn = FollowAnchor(OptionsFrame, DropBtn, optH)
                    end
                end)

                DropBtn.MouseButton1Click:Connect(function()
                    if isOpen then
                        CloseDropdown()
                    else
                        OpenDropdown()
                    end
                end)

                return {
                    Set = function(_, v)
                        selected = v
                        SelectedLbl.Text = tostring(v)
                        RenderOptions()
                        callback(v)
                    end,
                    Refresh = function(_, newList)
                        list = newList
                        RenderOptions()
                    end,
                }
            end

            -- ============================================
            -- MULTI-SELECT DROPDOWN
            -- ============================================
            function Card:AddMultiDropdown(text, list, defaultList, callback)
                callback = callback or function() end
                list = list or {}
                local selected = {}
                for _, v in ipairs(defaultList or {}) do selected[v] = true end

                local function GetLabelText()
                    local count = 0
                    for _ in pairs(selected) do count = count + 1 end
                    if count == 0 then return "None" end
                    return count .. " Selected"
                end

                local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, ZIndex = 5}, Container)

                New("TextLabel", {
                    Text = text, Size = UDim2.new(0.35, 0, 1, 0),
                    TextColor3 = Color3.fromRGB(180, 180, 190),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                }, Frame)

                local DropBtn = New("TextButton", {
                    Size = UDim2.new(0.65, 0, 0, 26),
                    Position = UDim2.new(0.35, 0, 0.5, -13),
                    BackgroundColor3 = Color3.fromRGB(28, 28, 32),
                    Text = "",
                    AutoButtonColor = false,
                }, Frame)
                New("UICorner", {CornerRadius = UDim.new(0, 6)}, DropBtn)
                
                DropBtn.MouseEnter:Connect(function() Tween(DropBtn, {BackgroundColor3 = Color3.fromRGB(38, 38, 42)}, 0.15) end)
                DropBtn.MouseLeave:Connect(function() Tween(DropBtn, {BackgroundColor3 = Color3.fromRGB(28, 28, 32)}, 0.15) end)

                local SelectedLbl = New("TextLabel", {
                    Text = GetLabelText(),
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.Gotham, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                }, DropBtn)

                local Chevron = New("ImageLabel", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -20, 0.5, -6),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(150, 150, 160),
                }, DropBtn)
                ApplyIcon(Chevron, "chevron-down")

                local OptionsFrame = New("Frame", {
                    Visible = false,
                    BackgroundColor3 = Color3.fromRGB(24, 24, 28),
                    BorderSizePixel = 0,
                    ZIndex = 60,
                    ClipsDescendants = true,
                }, library.Overlay)
                New("UICorner", {CornerRadius = UDim.new(0, 6)}, OptionsFrame)
                New("UIStroke", {Color = Color3.fromRGB(40, 40, 45), Thickness = 1}, OptionsFrame)

                local SearchBox = New("TextBox", {
                    Size = UDim2.new(1, -8, 0, 26),
                    Position = UDim2.new(0, 4, 0, 4),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
                    PlaceholderText = "Search...",
                    Text = "",
                    TextColor3 = Color3.fromRGB(220, 220, 230),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ClearTextOnFocus = false,
                    ZIndex = 61,
                }, OptionsFrame)
                New("UICorner", {CornerRadius = UDim.new(0, 4)}, SearchBox)

                local OptionsScroll = New("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, -34),
                    Position = UDim2.new(0, 0, 0, 34),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 60,
                }, OptionsFrame)
                New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, OptionsScroll)
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
                }, OptionsScroll)

                local isOpen = false
                local followConn = nil
                local function CloseDropdown()
                    isOpen = false
                    OptionsFrame.Visible = false
                    Tween(Chevron, {Rotation = 0}, 0.15)
                    if followConn then
                        followConn:Disconnect()
                        followConn = nil
                    end
                    if library._openDropdown == OptionsFrame then
                        library._openDropdown = nil
                        library._openDropdownClose = nil
                        library._openDropdownButton = nil
                    end
                end

                local function OpenDropdown()
                    if library._openDropdown and library._openDropdown ~= OptionsFrame and library._openDropdownClose then
                        library._openDropdownClose()
                    end
                    SearchBox.Text = "" -- Reset search when opened
                    local visibleItems = 0
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") and child.Visible then
                            visibleItems = visibleItems + 1
                        end
                    end
                    local optH = math.min(visibleItems * 26 + 42, 200)
                    OptionsFrame.Visible = true
                    isOpen = true
                    library._openDropdown = OptionsFrame
                    library._openDropdownClose = CloseDropdown
                    library._openDropdownButton = DropBtn
                    Tween(Chevron, {Rotation = 180}, 0.15)
                    if followConn then followConn:Disconnect() end
                    followConn = FollowAnchor(OptionsFrame, DropBtn, optH)
                end

                local function RenderOptions()
                    OptionsScroll:ClearAllChildren()
                    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, OptionsScroll)
                    for _, optionValue in ipairs(list) do
                        local isSelected = selected[optionValue] == true

                        local OptBtn = New("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = Color3.fromRGB(32, 32, 36),
                            BackgroundTransparency = isSelected and 0 or 1,
                            Text = "",
                            ZIndex = 61,
                        }, OptionsScroll)
                        New("UICorner", {CornerRadius = UDim.new(0, 4)}, OptBtn)

                        local Label = New("TextLabel", {
                            Text = tostring(optionValue),
                            Size = UDim2.new(1, -26, 1, 0),
                            Position = UDim2.new(0, 8, 0, 0),
                            TextColor3 = isSelected and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(170, 170, 180),
                            Font = Enum.Font.Gotham, TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            ZIndex = 61,
                        }, OptBtn)

                        local CheckIcon = New("ImageLabel", {
                            Size = UDim2.new(0, 12, 0, 12),
                            Position = UDim2.new(1, -18, 0.5, -6),
                            BackgroundTransparency = 1,
                            ImageColor3 = Color3.fromRGB(240, 240, 240),
                            ImageTransparency = isSelected and 0 or 1,
                            ZIndex = 61,
                        }, OptBtn)
                        ApplyIcon(CheckIcon, "check")

                        OptBtn.MouseButton1Click:Connect(function()
                            selected[optionValue] = not selected[optionValue] or nil
                            local nowSelected = selected[optionValue] == true
                            Tween(OptBtn, {BackgroundTransparency = nowSelected and 0 or 1}, 0.1)
                            Tween(CheckIcon, {ImageTransparency = nowSelected and 0 or 1}, 0.1)
                            Label.TextColor3 = nowSelected and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(170, 170, 180)
                            SelectedLbl.Text = GetLabelText()
                            local out = {}
                            for k, v in pairs(selected) do
                                if v then table.insert(out, k) end
                            end
                            callback(out)
                        end)
                    end
                end
                RenderOptions()

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = string.lower(SearchBox.Text)
                    local visibleItems = 0
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            local label = child:FindFirstChildOfClass("TextLabel")
                            local matchText = label and label.Text or child.Text
                            if query == "" or string.find(string.lower(matchText), query, 1, true) then
                                child.Visible = true
                                visibleItems = visibleItems + 1
                            else
                                child.Visible = false
                            end
                        end
                    end
                    if isOpen and followConn then
                        local optH = math.min(visibleItems * 26 + 42, 200)
                        followConn:Disconnect()
                        followConn = FollowAnchor(OptionsFrame, DropBtn, optH)
                    end
                end)

                DropBtn.MouseButton1Click:Connect(function()
                    if isOpen then CloseDropdown() else OpenDropdown() end
                end)

                return {
                    Set = function(_, newList)
                        selected = {}
                        for _, v in ipairs(newList) do selected[v] = true end
                        SelectedLbl.Text = GetLabelText()
                        RenderOptions()
                    end,
                }
            end

            -- TEXTBOX
            function Card:AddTextbox(text, placeholder, callback)
                callback = callback or function() end

                local Frame = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1}, Container)

                New("TextLabel", {
                    Text = text, Size = UDim2.new(0.35, 0, 1, 0),
                    TextColor3 = Color3.fromRGB(180, 180, 190),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                }, Frame)

                local Input = New("TextBox", {
                    Size = UDim2.new(0.65, 0, 0, 26),
                    Position = UDim2.new(0.35, 0, 0.5, -13),
                    BackgroundColor3 = Color3.fromRGB(24, 24, 28),
                    PlaceholderText = placeholder or "Text",
                    Text = "",
                    TextColor3 = Color3.fromRGB(220, 220, 230),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                }, Frame)
                New("UICorner", {CornerRadius = UDim.new(0, 6)}, Input)
                New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, Input)

                Input.FocusLost:Connect(function(enter)
                    callback(Input.Text, enter)
                end)

                return {
                    Set = function(_, newText)
                        Input.Text = newText
                        callback(newText, false)
                    end,
                    Get = function() return Input.Text end
                }
            end

            -- LABEL (simple text row, useful for status readouts)
            function Card:AddLabel(text)
                local Lbl = New("TextLabel", {
                    Text = text,
                    Size = UDim2.new(1, 0, 0, 18),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    TextColor3 = Color3.fromRGB(150, 150, 160),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundTransparency = 1,
                }, Container)
                return {
                    Set = function(_, newText) Lbl.Text = newText end,
                }
            end

            return Card
        end

        return SubTab
    end

    return Page
end

return Library
