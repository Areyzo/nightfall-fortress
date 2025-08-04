# PowerShell script to resolve merge conflicts
Set-Location "d:\Nightfall-fortress\nightfall-fortress"

# Show git status
Write-Host "Current git status:" -ForegroundColor Yellow
git status

# Mark resolved files as resolved
Write-Host "`nMarking conflicts as resolved..." -ForegroundColor Green

# Add resolved files
git add "scenes/character/player/player.tscn"
git add "main_menu.tscn"
git add "Mines/Sunnyside_World_Assets/UI/axe.png.import"
git add "Mines/Sunnyside_World_Assets/Tileset/1.png.import"

# Add the moved script files
git add "scripts/exit.gd"
git add "scripts/exit.gd.uid"

# Remove the old script files from git tracking
git rm "exit.gd" "exit.gd.uid" 2>$null

# Check if tree1 (1).png.import exists and add it if it does
if (Test-Path "assets/game/Objects/trees/tree1 (1).png.import") {
    git add "assets/game/Objects/trees/tree1 (1).png.import"
    Write-Host "Added tree1 (1).png.import" -ForegroundColor Green
} else {
    Write-Host "tree1 (1).png.import file not found - may have been deleted" -ForegroundColor Yellow
}

# Check for any other unmerged files
Write-Host "`nChecking for remaining conflicts..." -ForegroundColor Yellow
$conflicts = git diff --name-only --diff-filter=U
if ($conflicts) {
    Write-Host "Remaining conflicts in:" -ForegroundColor Red
    $conflicts | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
} else {
    Write-Host "No remaining conflicts found" -ForegroundColor Green
}

# Show final status
Write-Host "`nFinal git status:" -ForegroundColor Yellow
git status

Write-Host "`nTo complete the merge, run: git commit" -ForegroundColor Cyan
Write-Host "Or if you want to add a commit message: git commit -m 'Resolve merge conflicts'" -ForegroundColor Cyan
