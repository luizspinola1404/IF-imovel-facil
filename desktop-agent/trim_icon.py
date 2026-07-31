from PIL import Image, ImageChops

def trim(im):
    bg = Image.new(im.mode, im.size, im.getpixel((0,0)))
    diff = ImageChops.difference(im, bg)
    diff = ImageChops.add(diff, diff, 2.0, -100)
    bbox = diff.getbbox()
    if bbox:
        return im.crop(bbox)
    return im

try:
    im = Image.open('../client/public/favicon.png')
    trimmed = trim(im)
    # Ensure it's square for Tauri
    width, height = trimmed.size
    size = max(width, height)
    # Create a transparent background image
    new_im = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    # Paste trimmed image in center
    new_im.paste(trimmed, ((size - width) // 2, (size - height) // 2))
    new_im.save('app-icon-trimmed.png')
    print("Success!")
except Exception as e:
    print(f"Error: {e}")
