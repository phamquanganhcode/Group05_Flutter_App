@echo off
chcp 65001 >nul
echo =====================================================================
echo  KIEM TRA MOI TRUONG VA CAI DAT CONG CU FIREBASE CHO DU AN FLUTTER
echo =====================================================================
echo.

echo [1/4] Kiem tra Flutter SDK...
flutter --version
if %errorlevel% neq 0 (
    echo [LOI] Khong tim thay Flutter. Vui long cai dat Flutter SDK hoac them vao PATH!
    pause
    exit /b
)
echo -- Flutter OK!
echo.

echo [2/4] Kiem tra Node.js va NPM...
node -v
npm -v
if %errorlevel% neq 0 (
    echo [LOI] Khong tim thay Node.js. Vui long cai dat Node.js tu https://nodejs.org/!
    pause
    exit /b
)
echo -- Node.js OK!
echo.

echo [3/4] Cai dat Firebase CLI toan cuc...
call npm install -g firebase-tools
echo.

echo [4/4] Cai dat FlutterFire CLI toan cuc...
call dart pub global activate flutterfire_cli
echo.

echo =====================================================================
echo  HOAN TAT CAI DAT CONG CU!
echo  Tiep theo, ban hay chay lenh:
echo    1. firebase login
echo    2. flutterfire configure
echo =====================================================================
echo.
pause
