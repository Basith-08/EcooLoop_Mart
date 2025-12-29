@echo off
REM EcoLoop Mart - Build Windows Desktop

echo ========================================
echo  EcoLoop Mart - Building Windows App
echo ========================================
echo.

echo [1/2] Getting dependencies...
call flutter pub get

echo.
echo [2/2] Building for Windows...
call flutter build windows --release

echo.
echo ========================================
echo Build completed!
echo ========================================
echo.
echo Output: build\windows\runner\Release\
echo.
echo You can now run: build\windows\runner\Release\ecoloop_mart.exe
echo.
pause
