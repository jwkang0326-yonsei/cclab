from PIL import Image

# Create a 1024x500 blank canvas with a soft beige background
width = 1024
height = 500
background_color = (245, 245, 220) # Beige
image = Image.new('RGB', (width, height), background_color)

# Save the image
image.save('/Users/jwkang/.gemini/antigravity/brain/cc90ceae-0e93-44d8-9b25-467b1e1db497/canvas_1024x500.png')
print("Canvas created successfully")
