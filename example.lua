-- Example Generous UI
-- ====================
-- Loadsting library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bappewgw-byte/AAAAA/refs/heads/main/library.lua?v=" .. tick()))()
-- ====================
-- Global Config Table untuk menyimpan state
local ConfigData = {}
local ConfigFolder = "Fernove Hub"

-- Pastikan folder ada
if isfolder and not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end

local function GetConfigs()
    local list = {}
    if listfiles then
        for _, file in pairs(listfiles(ConfigFolder)) do
            local name = file:match("([^/^\\]+)%.json$")
            if name then table.insert(list, name) end
        end
    end
    if #list == 0 then return {"None"} end
    return list
end

-- ====================
-- Window
local Window = Library.new({
    Name = "Fernove",
    SubTitle = "Premium",
    KeySystem = true,
    --[[KeySettings = {
        Title = "Fernove Key System",
        Description = "Please enter your access key to continue.",
        Key = {"123", "World123"},
        Link = "https://example.com/getkey",
        }]]--
})
-- ====================
-- Page
local Page1 = Window:CreatePage("Home", "house")
-- ====================
-- Tabs Index
local MenuSub1 = Page1:CreateSubTab("Tabs 1")
local MenuSub2 = Page1:CreateSubTab("Tabs 2")
local MenuSub3 = Page1:CreateSubTab("Tabs 3")
-- ====================
-- Card Container di dalam Combat Sub-Tab
local ExampleCard = MenuSub1:CreateCard("Example 1", "atom")

-- Table untuk menyimpan reference ke UI Elements agar bisa di-Set() saat Load Config
local Elements = {}

-- Toggle
Elements["AutoFarm"] = ExampleCard:AddToggle("Enable Toggle", false, function(val)
    ConfigData["AutoFarm"] = val
    print("Auto Farm:", val)
end)

-- Button
ExampleCard:AddButton("Button", function()
    Window:Notify("Berhasil", "Tombol udah diklik!", 3, "check-circle")
end)

-- Slider
Elements["FarmSpeed"] = ExampleCard:AddSlider("Example Slider", 0, 100, 50, function(val)
    ConfigData["FarmSpeed"] = val
    print("Farm Speed:", val)
end)

-- Dropdown Single Select
Elements["Weapon"] = ExampleCard:AddDropdown("Single Dropdown", {"Sword", "Bow", "Magic"}, "Sword", function(selected)
    ConfigData["Weapon"] = selected
    print("Weapon Selected:", selected)
end)

-- Dropdown Multi Select
Elements["MultiDrop1"] = ExampleCard:AddMultiDropdown("Multi Dropdown", {"Option 1", "Option 2", "Option 3"}, {"Option 1"}, function(selected)
    ConfigData["MultiDrop1"] = selected
    print("Selected list:")
    for _, v in ipairs(selected) do
        print(" -", v)
    end
end)

-- Textbox
Elements["TextConfig"] = ExampleCard:AddTextbox("Input Text", "Enter text...", function(txt)
    print("Input:", txt)
end)

Elements["DelayConfig"] = ExampleCard:AddTextbox("Input Number", "Masukkan angka...", function(txt)
    local angkaDelay = tonumber(txt)

    if angkaDelay then
        print("Anda memasukkan angka yang valid:", angkaDelay)
        -- Anda bisa memakai angkaDelay untuk logika script Anda
        -- Contoh: task.wait(angkaDelay)
    else
        warn("Input yang dimasukkan bukan sekadar angka!")
    end
end)

-- Label
ExampleCard:AddLabel("Example Label")

local ExampleCard2 = MenuSub2:CreateCard("Example 2", "atom")
local ExampleCard3 = MenuSub3:CreateCard("Example 3", "atom")

-- ========================================================================
-- Settings Page
local SettingsPage = Window:CreatePage("Settings", "settings")
local GeneralSub = SettingsPage:CreateSubTab("General")

-- Preferences Card
local GeneralCard = GeneralSub:CreateCard("Preferences", "settings-2")

GeneralCard:AddSlider("UI Size", 50, 150, 100, function(val)
    if Window.SetScale then
        Window:SetScale(val / 100)
    end
end)

GeneralCard:AddButton("Copy Place ID", function()
    setclipboard(tostring(game.PlaceId))
	Window:Notify("Place ID", "Coppied Success", 2, "copy")
end)

GeneralCard:AddButton("Copy Game ID", function()
    setclipboard(tostring(game.GameId))
	Window:Notify("Game ID", "Coppied Success", 2, "copy")
end)

-- Config Manager Card
local ConfigCard = GeneralSub:CreateCard("Config Manager", "folder")
local ConfigName = "MyConfig"
local SelectedConfig = "None"

ConfigCard:AddTextbox("Config Name", "", function(txt)
    ConfigName = txt
end)

ConfigCard:AddButton("Save Config", function()
    if ConfigName ~= "" and writefile then
        local HttpService = game:GetService("HttpService")
        local json = HttpService:JSONEncode(ConfigData)
        writefile(ConfigFolder .. "/" .. ConfigName .. ".json", json)
        Window:Notify("Config", "Saved: " .. ConfigName, 3, "check-circle")
    end
end)

local ConfigDropdown = ConfigCard:AddDropdown("Select Config", GetConfigs(), "None", function(selected)
    SelectedConfig = selected
end)

ConfigCard:AddButton("Refresh List", function()
    ConfigDropdown:Refresh(GetConfigs())
    Window:Notify("Config", "List diperbarui!", 2, "refresh-cw")
end)

ConfigCard:AddButton("Load Config", function()
    if SelectedConfig ~= "None" and readfile and isfile(ConfigFolder .. "/" .. SelectedConfig .. ".json") then
        local HttpService = game:GetService("HttpService")
        local json = readfile(ConfigFolder .. "/" .. SelectedConfig .. ".json")
        local success, decoded = pcall(function() return HttpService:JSONDecode(json) end)

        if success and decoded then
            -- Set data dari Config ke UI
            if decoded["AutoFarm"] ~= nil and Elements["AutoFarm"] then
                Elements["AutoFarm"]:Set(decoded["AutoFarm"])
            end

            if decoded["FarmSpeed"] ~= nil and Elements["FarmSpeed"] then
                -- Note: Library perlu support Set untuk Slider jika ingin auto update slider UI,
                -- saat ini kita set manual callbacknya:
                ConfigData["FarmSpeed"] = decoded["FarmSpeed"]
            end

            if decoded["Weapon"] ~= nil and Elements["Weapon"] then
                Elements["Weapon"]:Set(decoded["Weapon"])
            end

            if decoded["MultiDrop1"] ~= nil and Elements["MultiDrop1"] then
                -- Method :Set() bawaan dari UI akan menata ulang UI centangnya
                Elements["MultiDrop1"]:Set(decoded["MultiDrop1"])
            end

            if decoded["DelayConfig"] ~= nil and Elements["DelayConfig"] then
                -- Method :Set() bawaan dari UI akan menata ulang UI centangnya
                Elements["DelayConfig"]:Set(decoded["DelayConfig"])
            end

            Window:Notify("Config", "Berhasil memuat: " .. SelectedConfig, 3, "check-circle")
        else
            Window:Notify("Error", "Gagal memuat Config", 3, "x")
        end
    end
end)

ConfigCard:AddButton("Delete Config", function()
    if SelectedConfig ~= "None" and delfile and isfile(ConfigFolder .. "/" .. SelectedConfig .. ".json") then
        delfile(ConfigFolder .. "/" .. SelectedConfig .. ".json")
        ConfigDropdown:Refresh(GetConfigs())
        Window:Notify("Config", "Berhasil dihapus: " .. SelectedConfig, 3, "trash")
    end
end)

-- ====================
-- Settings Page
local Page2 = Window:CreatePage("Settings", "settings")

local ThemeTab = Page2:CreateSubTab("Themes")
local ThemeCard = ThemeTab:CreateCard("Theme Engine", "palette")

local ThemesList = {"Default", "Ocean", "Dracula", "Midnight"}
local SelectedTheme = "Default"

-- Mengambil konfigurasi tema dari Github
local success, Themes = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/bappewgw-byte/AAAAA/main/themes.lua"))()
end)
if not success or type(Themes) ~= "table" then
    Themes = {} -- Fallback jika gagal fetch
end

ThemeCard:AddDropdown("Select Theme", ThemesList, "Default", function(selected)
    SelectedTheme = selected
end)

ThemeCard:AddButton("Set Theme", function()
    if Themes[SelectedTheme] then
        Library.ThemeManager:SetTheme(Themes[SelectedTheme])
        Window:Notify("Theme Manager", "Tema berhasil diubah ke " .. SelectedTheme, 3, "brush")
    else
        Window:Notify("Theme Error", "Gagal memuat tema " .. SelectedTheme, 3, "x")
    end
end)

ThemeCard:AddButton("Reset Theme (Default)", function()
    if Themes["Default"] then
        Library.ThemeManager:SetTheme(Themes["Default"])
        Window:Notify("Theme Manager", "Tema di-reset ke Default", 3, "rotate-ccw")
    end
end)

-- Notifikasi
Window:Notify("Welcome Sir", "Script berhasil dimuat", 4, "gamepad-2")
