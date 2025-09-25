@echo off
echo ========================================
echo Campus Market Icon Generator
echo ========================================
echo.

echo Creating icons directory...
if not exist "icons" mkdir icons

echo.
echo ========================================
echo REQUIRED ICON SIZES
echo ========================================
echo.
echo Favicon (favicon.ico):
echo   - 16x16 pixels (browser tab)
echo   - 32x32 pixels (browser bookmark)  
echo   - 48x48 pixels (Windows desktop)
echo.
echo PNG Icons (icons/ directory):
echo   - Icon-16.png (16x16)
echo   - Icon-32.png (32x32)
echo   - Icon-48.png (48x48)
echo   - Icon-72.png (72x72)
echo   - Icon-96.png (96x96)
echo   - Icon-144.png (144x144)
echo   - Icon-180.png (180x180) - Apple touch
echo   - Icon-192.png (192x192)
echo   - Icon-512.png (512x512)
echo.
echo Maskable Icons:
echo   - Icon-maskable-192.png (192x192)
echo   - Icon-maskable-512.png (512x512)
echo.

echo ========================================
echo CAMPUS MARKET BRANDING COLORS
echo ========================================
echo Primary Green: #2E7D32
echo Accent Yellow: #FBC02D
echo Secondary Orange: #FF7043
echo.

echo ========================================
echo RECOMMENDED TOOLS
echo ========================================
echo.
echo Online Tools:
echo 1. https://realfavicongenerator.net/
echo 2. https://appicon.co/
echo 3. https://www.pwabuilder.com/imageGenerator
echo.
echo Desktop Tools:
echo 1. GIMP (Free)
echo 2. Photoshop
echo 3. Figma (Free)
echo 4. Canva
echo.

echo ========================================
echo NEXT STEPS
echo ========================================
echo.
echo 1. Use your Campus Market logo as source
echo 2. Create favicon.ico with multiple sizes
echo 3. Generate all PNG icons in required sizes
echo 4. Create maskable icons for Android
echo 5. Test with icon_test.html
echo 6. Verify favicon appears in browser tab
echo.

echo ========================================
echo TESTING
echo ========================================
echo.
echo After creating icons, open icon_test.html in your browser
echo to verify all icons are working correctly.
echo.

pause
