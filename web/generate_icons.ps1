# Campus Market Icon Generator
# PowerShell script to help generate web icons

Write-Host "========================================" -ForegroundColor Green
Write-Host "Campus Market Icon Generator" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Create icons directory
if (!(Test-Path "icons")) {
    New-Item -ItemType Directory -Name "icons"
    Write-Host "Created icons directory" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REQUIRED ICON SIZES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Favicon (favicon.ico):" -ForegroundColor White
Write-Host "  - 16x16 pixels (browser tab)" -ForegroundColor Gray
Write-Host "  - 32x32 pixels (browser bookmark)" -ForegroundColor Gray
Write-Host "  - 48x48 pixels (Windows desktop)" -ForegroundColor Gray
Write-Host ""

Write-Host "PNG Icons (icons/ directory):" -ForegroundColor White
$iconSizes = @(16, 32, 48, 72, 96, 144, 180, 192, 512)
foreach ($size in $iconSizes) {
    $appleNote = if ($size -eq 180) { " - Apple touch" } else { "" }
    Write-Host "  - Icon-$size.png ($size x $size)$appleNote" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Maskable Icons:" -ForegroundColor White
Write-Host "  - Icon-maskable-192.png (192x192)" -ForegroundColor Gray
Write-Host "  - Icon-maskable-512.png (512x512)" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "CAMPUS MARKET BRANDING COLORS" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Primary Green: #2E7D32" -ForegroundColor Green
Write-Host "Accent Yellow: #FBC02D" -ForegroundColor Yellow
Write-Host "Secondary Orange: #FF7043" -ForegroundColor Red
Write-Host ""

Write-Host "========================================" -ForegroundColor Blue
Write-Host "RECOMMENDED TOOLS" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

Write-Host "Online Tools:" -ForegroundColor White
Write-Host "1. https://realfavicongenerator.net/" -ForegroundColor Cyan
Write-Host "2. https://appicon.co/" -ForegroundColor Cyan
Write-Host "3. https://www.pwabuilder.com/imageGenerator" -ForegroundColor Cyan
Write-Host ""

Write-Host "Desktop Tools:" -ForegroundColor White
Write-Host "1. GIMP (Free)" -ForegroundColor Cyan
Write-Host "2. Photoshop" -ForegroundColor Cyan
Write-Host "3. Figma (Free)" -ForegroundColor Cyan
Write-Host "4. Canva" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "NEXT STEPS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "1. Use your Campus Market logo as source" -ForegroundColor White
Write-Host "2. Create favicon.ico with multiple sizes" -ForegroundColor White
Write-Host "3. Generate all PNG icons in required sizes" -ForegroundColor White
Write-Host "4. Create maskable icons for Android" -ForegroundColor White
Write-Host "5. Test with icon_test.html" -ForegroundColor White
Write-Host "6. Verify favicon appears in browser tab" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "TESTING" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "After creating icons, open icon_test.html in your browser" -ForegroundColor White
Write-Host "to verify all icons are working correctly." -ForegroundColor White
Write-Host ""

# Check if source logo exists
$sourceLogo = "../assets/onboarding/Campus Connect Logo - Yellow Accent (1).png"
if (Test-Path $sourceLogo) {
    Write-Host "✅ Found source logo: $sourceLogo" -ForegroundColor Green
    Write-Host "You can use this as your base for creating icons." -ForegroundColor Green
} else {
    Write-Host "⚠️  Source logo not found at: $sourceLogo" -ForegroundColor Yellow
    Write-Host "Please locate your Campus Market logo file." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
