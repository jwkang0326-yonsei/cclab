from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_gradient(width, height, start_color, end_color):
    base = Image.new('RGB', (width, height), start_color)
    top = Image.new('RGB', (width, height), end_color)
    mask = Image.new('L', (width, height))
    mask_data = []
    for y in range(height):
        for x in range(width):
            mask_data.append(int(255 * (x / width))) # Horizontal gradient
    mask.putdata(mask_data)
    base.paste(top, (0, 0), mask)
    return base

# Config
WIDTH = 1024
HEIGHT = 500
BG_START = (245, 245, 220) # Beige
BG_END = (156, 175, 136)   # Sage Green
ICON_PATH = '/Users/jwkang/dev/cclab/app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png'
SCREEN1_PATH = '/Users/jwkang/dev/cclab/app/screenshots/android/phone/02_home.png'
SCREEN2_PATH = '/Users/jwkang/dev/cclab/app/screenshots/android/phone/04_statistics.png'
OUTPUT_PATH = '/Users/jwkang/Downloads/WithBible_Feature_Graphic_Final.png'
PROJECT_PATH = '/Users/jwkang/dev/cclab/app/screenshots/android/feature_graphic_1024x500.png'

# 1. Create Background
canvas = create_gradient(WIDTH, HEIGHT, BG_START, BG_END)

# 2. Place Icon (Left)
try:
    icon = Image.open(ICON_PATH).convert("RGBA")
    # Resize icon to 300x300
    icon = icon.resize((300, 300), Image.Resampling.LANCZOS)
    
    # Add shadow to icon
    shadow = Image.new('RGBA', icon.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.ellipse((10, 280, 290, 300), fill=(0, 0, 0, 50))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    
    # Paste icon at (100, 100)
    canvas.paste(shadow, (100, 100), shadow)
    canvas.paste(icon, (100, 100), icon)
    
except Exception as e:
    print(f"Error loading icon: {e}")

# 3. Place Screenshots (Right)
try:
    # Load screenshots
    scr1 = Image.open(SCREEN1_PATH).convert("RGBA")
    scr2 = Image.open(SCREEN2_PATH).convert("RGBA")
    
    # Resize screenshots (maintain aspect ratio, height 350)
    target_h = 350
    ratio1 = target_h / scr1.height
    ratio2 = target_h / scr2.height
    
    scr1 = scr1.resize((int(scr1.width * ratio1), target_h), Image.Resampling.LANCZOS)
    scr2 = scr2.resize((int(scr2.width * ratio2), target_h), Image.Resampling.LANCZOS)
    
    # Add simple border/shadow to screenshots
    def add_border(img):
        bg = Image.new('RGBA', (img.width + 20, img.height + 20), (50, 50, 50, 100)) # Shadow
        bg.paste((255, 255, 255), (2, 2, img.width+18, img.height+18)) # Border
        bg.paste(img, (10, 10))
        return bg

    scr1_framed = add_border(scr1)
    scr2_framed = add_border(scr2)
    
    # Paste screenshots
    # Screen 2 (Back)
    canvas.paste(scr2_framed, (700, 75), scr2_framed)
    # Screen 1 (Front)
    canvas.paste(scr1_framed, (500, 75), scr1_framed)

except Exception as e:
    print(f"Error loading screenshots: {e}")

# 4. Add Text (Optional - if font available, otherwise skip or draw simple)
# Simplest way to add text without specific font file is tricky. 
# We'll stick to visual elements (Icon + Screens) which is cleaner.

# Save
canvas.save(OUTPUT_PATH)
canvas.save(PROJECT_PATH)
print(f"saved to {OUTPUT_PATH}")
