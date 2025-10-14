#!/usr/bin/env python3
"""
Icon generator script for Flutter app
Generates all required icon sizes for Android, iOS, macOS, and Web platforms
"""

import os
import sys
from PIL import Image
import shutil

def create_directory(path):
    """Create directory if it doesn't exist"""
    os.makedirs(path, exist_ok=True)

def resize_icon(source_path, output_path, size):
    """Resize icon to specified size"""
    try:
        with Image.open(source_path) as img:
            # Convert to RGBA if not already
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Resize with high quality resampling
            resized = img.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save as PNG
            resized.save(output_path, 'PNG', optimize=True)
            print(f"Generated {output_path} ({size}x{size})")
            return True
    except Exception as e:
        print(f"Error generating {output_path}: {e}")
        return False

def main():
    # Source icon path
    source_icon = "assets/images/app_icon.png"
    
    if not os.path.exists(source_icon):
        print(f"Error: Source icon not found at {source_icon}")
        sys.exit(1)
    
    print("Generating app icons for all platforms...")
    
    # Android icons
    print("\nGenerating Android icons...")
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    for folder, size in android_sizes.items():
        output_dir = f"android/app/src/main/res/{folder}"
        create_directory(output_dir)
        resize_icon(source_icon, f"{output_dir}/ic_launcher.png", size)
    
    # iOS icons
    print("\nGenerating iOS icons...")
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024
    }
    
    ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    create_directory(ios_dir)
    
    for filename, size in ios_sizes.items():
        resize_icon(source_icon, f"{ios_dir}/{filename}", size)
    
    # macOS icons
    print("\nGenerating macOS icons...")
    macos_sizes = {
        'app_icon_16.png': 16,
        'app_icon_32.png': 32,
        'app_icon_64.png': 64,
        'app_icon_128.png': 128,
        'app_icon_256.png': 256,
        'app_icon_512.png': 512,
        'app_icon_1024.png': 1024
    }
    
    macos_dir = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    create_directory(macos_dir)
    
    for filename, size in macos_sizes.items():
        resize_icon(source_icon, f"{macos_dir}/{filename}", size)
    
    # Web icons
    print("\nGenerating Web icons...")
    web_sizes = {
        'favicon.png': 32,
        'icons/Icon-192.png': 192,
        'icons/Icon-512.png': 512,
        'icons/Icon-maskable-192.png': 192,
        'icons/Icon-maskable-512.png': 512
    }
    
    web_dir = "web"
    create_directory(f"{web_dir}/icons")
    
    for filename, size in web_sizes.items():
        resize_icon(source_icon, f"{web_dir}/{filename}", size)
    
    # Windows icon
    print("\nGenerating Windows icon...")
    try:
        with Image.open(source_icon) as img:
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Create ICO file with multiple sizes
            sizes = [16, 32, 48, 64, 128, 256]
            icons = []
            for size in sizes:
                resized = img.resize((size, size), Image.Resampling.LANCZOS)
                icons.append(resized)
            
            # Save as ICO
            icons[0].save("windows/runner/resources/app_icon.ico", 
                         format='ICO', sizes=[(icon.width, icon.height) for icon in icons])
            print("Generated windows/runner/resources/app_icon.ico")
    except Exception as e:
        print(f"Error generating Windows icon: {e}")
    
    print("\nAll icons generated successfully!")
    print("\nGenerated icons for:")
    print("  Android (5 sizes)")
    print("  iOS (14 sizes)")
    print("  macOS (7 sizes)")
    print("  Web (5 sizes)")
    print("  Windows (1 ICO file)")

if __name__ == "__main__":
    main()
