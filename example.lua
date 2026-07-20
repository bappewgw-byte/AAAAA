-- Example Generous UI
-- ====================
-- Loadsting library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bappewgw-byte/AAAAA/refs/heads/main/library.lua?v=" .. tick()))()
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
local MenuSub2 = Page1:CreateSubTab("Tabs 2")
local MenuSub3 = Page1:CreateSubTab("Tabs 3")
-- ====================
-- Card Container di dalam Combat Sub-Tab
local ExampleCard = MenuSub1:CreateCard("Example", "target")

-- Toggle
ExampleCard:AddToggle("Toggle", false, function(val)
    print("Toggle:", val)
end)

-- Button
ExampleCard:AddButton("Button", function()
    Window:Notify("Berhasil", "Tombol udah diklik!", 3, "check-circle")
end)

-- Slider
ExampleCard:AddSlider("Slider", 0, 100, 50, function(val)
    print("Slider:", val)
end)

-- Dropdown Single Select
ExampleCard:AddDropdown("Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
    print("Selected:", selected)
end)

-- Dropdown Multi Select
ExampleCard:AddMultiDropdown("Multi Dropdown", {"Option 1", "Option 2", "Option 3"}, {"Option 1"}, function(selected)
    print("Selected list:")
    for _, v in ipairs(selected) do
        print(" -", v)
    end
end)

-- Textbox
ExampleCard:AddTextbox("Text", "Enter text...", function(txt)
    print("Input:", txt)
end)

-- Label 
ExampleCard:AddLabel("Status: Idle")

-- ====================
-- Group Kategori Kiri 2
Window:AddCategory("Settings")
local SettingsPage = Window:CreatePage("Settings", "settings")
local GeneralSub = SettingsPage:CreateSubTab("General")
local GeneralCard = GeneralSub:CreateCard("Preferences", "sliders")

GeneralCard:AddToggle("Auto Save", true, function(val)
    print("Auto Save:", val)
end)

-- Notifikasi
Window:Notify("Welcome Sir", "Script berhasil dimuat", 4, "gamepad-2")
