import re

def refactor_library():
    with open('library.lua', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fonts
    content = content.replace("Enum.Font.GothamBold", "Enum.Font.BuilderSansBold")
    content = content.replace("Enum.Font.GothamMedium", "Enum.Font.BuilderSansMedium")
    content = content.replace("Enum.Font.Gotham", "Enum.Font.BuilderSans")
    
    # Colors Mapping
    color_map = {
        "Color3.fromRGB(12, 12, 14)": '"Theme:Background"',
        "Color3.fromRGB(16, 16, 18)": '"Theme:Container"',
        "Color3.fromRGB(18, 18, 20)": '"Theme:Card"',
        
        "Color3.fromRGB(24, 24, 28)": '"Theme:Element"',
        "Color3.fromRGB(28, 28, 32)": '"Theme:Element"',
        "Color3.fromRGB(32, 32, 36)": '"Theme:Element"',
        
        "Color3.fromRGB(35, 35, 40)": '"Theme:ElementHover"',
        "Color3.fromRGB(38, 38, 42)": '"Theme:ElementHover"',
        
        "Color3.fromRGB(0, 170, 255)": '"Theme:Accent"',
        
        "Color3.fromRGB(240, 240, 240)": '"Theme:Text"',
        
        "Color3.fromRGB(200, 200, 210)": '"Theme:SubText"',
        "Color3.fromRGB(180, 180, 190)": '"Theme:SubText"',
        "Color3.fromRGB(170, 170, 180)": '"Theme:SubText"',
        
        "Color3.fromRGB(150, 150, 160)": '"Theme:Muted"',
        "Color3.fromRGB(100, 100, 110)": '"Theme:Muted"',
        "Color3.fromRGB(90, 90, 98)": '"Theme:Muted"',
        
        "Color3.fromRGB(40, 40, 45)": '"Theme:Stroke"',
    }
    
    for old_color, new_color in color_map.items():
        content = content.replace(old_color, new_color)
        
    with open('library_refactored.lua', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    refactor_library()
