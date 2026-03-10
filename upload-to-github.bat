@echo off
chcp 65001 >nul
title Upload to GitHub

echo ╔════════════════════════════════════════════════════════════════╗
echo ║   ЗАГРУЗКА НА GITHUB                                          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo 📋 ЧТО НУЖНО СДЕЛАТЬ:
echo ═══════════════════════════════════════════════════════════════
echo 1. Создай репозиторий на GitHub.com
echo 2. Скопируй URL репозитория
echo 3. Введи его ниже
echo ═══════════════════════════════════════════════════════════════
echo.

set /p REPO_URL="Введи URL репозитория (например: https://github.com/username/repo.git): "

if "%REPO_URL%"=="" (
    echo ❌ URL не введён!
    pause
    exit /b 1
)

echo.
echo 🔧 Инициализация Git...
git init

echo.
echo 📝 Добавление файлов...
git add .

echo.
echo 💾 Создание коммита...
git commit -m "Initial commit: SmartSteamEmu with GC Redirect patch"

echo.
echo 🔗 Подключение к GitHub...
git remote add origin %REPO_URL%

echo.
echo 📤 Загрузка на GitHub...
git branch -M main
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ═══════════════════════════════════════════════════════════════
    echo ✅ УСПЕШНО ЗАГРУЖЕНО!
    echo.
    echo Теперь:
    echo 1. Зайди на GitHub.com в свой репозиторий
    echo 2. Вкладка Actions
    echo 3. Run workflow
    echo 4. Дождись компиляции (5-10 минут^)
    echo 5. Скачай готовые DLL из Artifacts
    echo ═══════════════════════════════════════════════════════════════
) else (
    echo.
    echo ❌ Ошибка загрузки!
    echo.
    echo Возможные причины:
    echo - Неправильный URL
    echo - Нет доступа к репозиторию
    echo - Нужна авторизация в Git
    echo.
    echo Попробуй через GitHub Desktop или вручную
)

echo.
pause
