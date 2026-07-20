-- Example Generous UI
-- ====================
-- Loadsting library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bappewgw-byte/AAAAA/refs/heads/main/library.lua?v=" .. tick()))()
-- ====================
-- Global Config Table untuk menyimpan state
local ConfigData = {}
local ConfigFolder = "SaphireHub"

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
local Window = Library.new("Saphire", "Roblox")
-- =====================
-- Category
Window:AddCategory("Category")
-- ====================
-- Page
local Page1 = Window:CreatePage("Home", "home")
-- ====================
-- Tabs Index
local MenuSub1 = Page1:CreateSubTab("Tabs 1")
-- ====================
-- Card Container di dalam Combat Sub-Tab
local ExampleCard = MenuSub1:CreateCard("Example", "target")

-- Table untuk menyimpan reference ke UI Elements agar bisa di-Set() saat Load Config
local Elements = {}

-- Toggle
Elements["AutoFarm"] = ExampleCard:AddToggle("Auto Farm", false, function(val)
    ConfigData["AutoFarm"] = val
    print("Auto Farm:", val)
end)

-- Button
ExampleCard:AddButton("Button", function()
    Window:Notify("Berhasil", "Tombol udah diklik!", 3, "check-circle")
end)

-- Slider
Elements["FarmSpeed"] = ExampleCard:AddSlider("Farm Speed", 0, 100, 50, function(val)
    ConfigData["FarmSpeed"] = val
    print("Farm Speed:", val)
end)

-- Dropdown Single Select
Elements["Weapon"] = ExampleCard:AddDropdown("Weapon", {"Sword", "Bow", "Magic"}, "Sword", function(selected)
    ConfigData["Weapon"] = selected
    print("Weapon Selected:", selected)
end)

-- ====================
-- Settings Page
Window:AddCategory("Settings")
local SettingsPage = Window:CreatePage("Settings", "settings")
local GeneralSub = SettingsPage:CreateSubTab("General")

-- Preferences Card
local GeneralCard = GeneralSub:CreateCard("Preferences", "sliders")

GeneralCard:AddSlider("UI Size", 50, 150, 100, function(val)
    if Window.SetScale then
        Window:SetScale(val / 100)
    end
end)

-- Config Manager Card
local ConfigCard = GeneralSub:CreateCard("Config Manager", "folder")
local ConfigName = "MyConfig"
local SelectedConfig = "None"

ConfigCard:AddTextbox("Masukan nama config", "Nama config...", function(txt)
    ConfigName = txt
end)

ConfigCard:AddButton("Simpan Config", function()
    if ConfigName ~= "" and writefile then
        local HttpService = game:GetService("HttpService")
        local json = HttpService:JSONEncode(ConfigData)
        writefile(ConfigFolder .. "/" .. ConfigName .. ".json", json)
        Window:Notify("Config", "Berhasil menyimpan: " .. ConfigName, 3, "check-circle")
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

-- Notifikasi
Window:Notify("Welcome Sir", "Script berhasil dimuat", 4, "gamepad-2")
