@echo off
REM EcoLoop Mart - Build Web (Windows Batch)

echo ========================================
echo  EcoLoop Mart - Building Web App
echo ========================================
echo.

echo [1/2] Getting dependencies...
call flutter pub get

echo.
echo [2/2] Building for Web...
call flutter build web --release

echo.
echo ========================================
echo Build completed!
echo ========================================
echo.
echo Output: build\web\
echo.
echo To serve locally, run:
echo   cd build\web
echo   python -m http.server 8000
echo.
pause
