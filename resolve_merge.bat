@echo off
cd /d "d:\Nightfall-fortress\nightfall-fortress"

echo Current git status:
git status

echo.
echo Adding resolved files...
git add "scenes/character/player/player.tscn"
git add "main_menu.tscn"
git add "Mines/Sunnyside_World_Assets/UI/axe.png.import"
git add "Mines/Sunnyside_World_Assets/Tileset/1.png.import"
git add "scripts/exit.gd"
git add "scripts/exit.gd.uid"

echo.
echo Removing old files...
git rm "exit.gd" 2>nul
git rm "exit.gd.uid" 2>nul

echo.
echo Final status:
git status

echo.
echo To complete the merge, run: git commit -m "Resolve merge conflicts"
pause
