from PIL import Image, ImageChops

def crop_icon(image_path, output_path):
    img = Image.open(image_path).convert("RGBA")
    
    # Get the color of the top-left pixel to use as the background color
    bg_color = img.getpixel((0, 0))
    
    # Create a background image of the same color
    bg = Image.new("RGBA", img.size, bg_color)
    diff = ImageChops.difference(img, bg)
    
    # getbbox() finds the bounding box of non-zero pixels in the diff
    bbox = diff.getbbox()
    
    if bbox:
        img_cropped = img.crop(bbox)
        
        width, height = img_cropped.size
        max_dim = max(width, height)
        
        # The user requested the icon to "fill the entire circle".
        # So we use a very minimal padding (about 5-10%) so the green ring touches the edges.
        final_size = int(max_dim * 1.1)
        
        # Create a new completely transparent background
        new_img = Image.new("RGBA", (final_size, final_size), (0, 0, 0, 0))
        
        x_offset = (final_size - width) // 2
        y_offset = (final_size - height) // 2
        
        new_img.paste(img_cropped, (x_offset, y_offset))
        new_img.save(output_path)
        print(f"Image cropped. Original size: {img.size}, New final bounds size: {final_size}x{final_size}")
    else:
        print("Could not find bounds to crop. Image might be solid color.")

if __name__ == "__main__":
    crop_icon("assets/images/mc_icon.png", "assets/images/mc_icon.png")
