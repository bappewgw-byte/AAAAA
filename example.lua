local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bappewgw-byte/AAAAA/refs/heads/main/library.lua?v=" .. tick()))()

local Window = Library.new("Balright", "for PUBG")

-- Group / Kategori Kiri
Window:AddCategory("Main")

-- Page Kiri 1 — icon sekarang pake nama Lucide, bukan emoji lagi
local Page1 = Window:CreatePage("Page", "crosshair")

-- Sub-Tabs (Pills Kanan)
local CombatSub = Page1:CreateSubTab("Combat")
local WeaponSub = Page1:CreateSubTab("Weapon")
local FovSub    = Page1:CreateSubTab("FoV")

-- Card Container di dalam Combat Sub-Tab
local AimbotCard = CombatSub:CreateCard("Aimbot", "target")

-- Toggle
AimbotCard:AddToggle("Toggle", false, function(val)
    print("Toggle:", val)
end)

-- Button
AimbotCard:AddButton("Click Me", function()
    Window:Notify("Berhasil", "Tombol udah diklik!", 3, "check-circle")
end)

-- Slider
AimbotCard:AddSlider("Slider", 0, 100, 50, function(val)
    print("Slider:", val)
end)

-- Dropdown Single Select (sekarang ada parameter "default" sebelum callback)
AimbotCard:AddDropdown("Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
    print("Selected:", selected)
end)

-- Dropdown Multi Select (baru)
AimbotCard:AddMultiDropdown("Multi Dropdown", {"Head", "Chest", "Legs"}, {"Head"}, function(selected)
    print("Selected list:")
    for _, v in ipairs(selected) do
        print(" -", v)
    end
end)

-- Textbox
AimbotCard:AddTextbox("Text", "Enter text...", function(txt)
    print("Input:", txt)
end)

-- Label (baru, buat status/info doang)
AimbotCard:AddLabel("Status: Idle")

-- Group Kategori Kiri 2
Window:AddCategory("Settings")
local SettingsPage = Window:CreatePage("Settings", "settings")
local GeneralSub = SettingsPage:CreateSubTab("General")
local GeneralCard = GeneralSub:CreateCard("Preferences", "sliders")

GeneralCard:AddToggle("Auto Save", true, function(val)
    print("Auto Save:", val)
end)

-- Notifikasi bisa dipanggil kapan aja, dari mana aja
Window:Notify("Selamat Datang", "UI berhasil dimuat", 4, "gamepad-2")
