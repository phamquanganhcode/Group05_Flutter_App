@echo off
chcp 65001 >nul
title Chay Ung Dung Quan Ly Tai Lieu - Web Port 51428
echo ====================================================================
echo   DANG KHOI CHAY UNG DUNG FLUTTER TREN CHROME (PORT: 51428)
echo ====================================================================
echo.
cd /d "d:\65KTPM\nam4\flutter\study_materials_app"

echo Dang chay lenh: flutter run -d chrome --web-port=51428 ...
echo Vui long doi vai giay de Chrome tu dong mo len...
echo.

flutter run -d chrome --web-port=51428

pause
