# Campus Market Web Icons Generation Guide

## Required Icon Sizes

Based on your Campus Market branding, you need to create the following icon sizes:

### Favicon (favicon.ico)
- **16x16 pixels** - Browser tab icon
- **32x32 pixels** - Browser bookmark icon  
- **48x48 pixels** - Windows desktop icon

### Web App Icons (PNG format)
- **16x16** - Icon-16.png
- **32x32** - Icon-32.png
- **48x48** - Icon-48.png
- **72x72** - Icon-72.png
- **96x96** - Icon-96.png
- **144x144** - Icon-144.png
- **180x180** - Icon-180.png (Apple touch icon)
- **192x192** - Icon-192.png
- **512x512** - Icon-512.png

### Maskable Icons (for Android)
- **192x192** - Icon-maskable-192.png
- **512x512** - Icon-maskable-512.png

## Design Guidelines

### Campus Market Branding Colors
- **Primary Green**: #2E7D32
- **Accent Yellow**: #FBC02D  
- **Secondary Orange**: #FF7043
- **Background**: White or transparent

### Icon Design Requirements
1. **Simple and recognizable** - Should work at small sizes (16x16)
2. **High contrast** - Must be visible on various backgrounds
3. **Consistent branding** - Use your Campus Market logo elements
4. **Scalable** - Should look good from 16px to 512px

### Recommended Design Elements
- Use your existing "Campus Connect Logo - Yellow Accent" as base
- Simplify for smaller sizes (remove text, keep main icon)
- Ensure the icon works on both light and dark backgrounds
- For maskable icons, ensure important elements are within the safe zone (center 80%)

## Tools for Icon Generation

### Online Tools
1. **Favicon Generator**: https://realfavicongenerator.net/
2. **App Icon Generator**: https://appicon.co/
3. **PWA Icon Generator**: https://www.pwabuilder.com/imageGenerator

### Desktop Tools
1. **GIMP** (Free) - Image editing
2. **Photoshop** - Professional image editing
3. **Figma** (Free) - Vector design
4. **Canva** (Free/Paid) - Simple design tool

## Step-by-Step Process

### 1. Prepare Your Source Image
- Use your existing logo: `assets/onboarding/Campus Connect Logo - Yellow Accent (1).png`
- Ensure it's high resolution (at least 512x512)
- Remove any text if present, keep only the icon/symbol

### 2. Create Favicon.ico
- Resize to 16x16, 32x32, and 48x48
- Use an online ICO converter
- Save as `web/favicon.ico`

### 3. Generate PNG Icons
- Create all required sizes (16, 32, 48, 72, 96, 144, 180, 192, 512)
- Save in `web/icons/` directory
- Use consistent naming: `Icon-{size}.png`

### 4. Create Maskable Icons
- Same as regular icons but ensure important elements are in center 80%
- Save as `Icon-maskable-192.png` and `Icon-maskable-512.png`

### 5. Test Your Icons
- Open your website in different browsers
- Check favicon appears in browser tab
- Test on mobile devices
- Verify PWA installation works

## Current Status
✅ HTML meta tags updated
✅ Manifest.json configured  
✅ Icon references added
⏳ **NEXT**: Create actual icon files using your Campus Market logo

## Quick Start Command
```bash
# Navigate to web directory
cd web

# Create icons directory if it doesn't exist
mkdir -p icons

# Copy your logo to web directory for processing
cp ../assets/onboarding/"Campus Connect Logo - Yellow Accent (1).png" ./logo-source.png
```

## Validation Checklist
- [ ] favicon.ico created and working
- [ ] All PNG icons generated (16, 32, 48, 72, 96, 144, 180, 192, 512)
- [ ] Maskable icons created (192, 512)
- [ ] Icons display correctly in browser tab
- [ ] PWA installation shows correct icon
- [ ] Icons work on mobile devices
- [ ] Icons are optimized for web (compressed)
