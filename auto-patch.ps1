# SmartSteamEmu Auto Patcher
# Автоматически скачивает, патчит и компилирует SmartSteamEmu

param(
    [string]$OutputDir = ".\build"
)

$ErrorActionPreference = "Stop"

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║   SmartSteamEmu Auto Patcher                                  ║" -ForegroundColor Cyan
Write-Host "║   Автоматический патчинг для GC Redirect                      ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Проверка Git
Write-Host "🔍 Проверка Git..." -ForegroundColor Cyan
try {
    $gitVersion = git --version
    Write-Host "✅ Git установлен: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git не установлен!" -ForegroundColor Red
    Write-Host "   Скачай с https://git-scm.com/" -ForegroundColor Yellow
    exit 1
}

# Проверка Visual Studio
Write-Host "🔍 Проверка Visual Studio..." -ForegroundColor Cyan
$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath 2>$null

if ($vsPath) {
    Write-Host "✅ Visual Studio найден: $vsPath" -ForegroundColor Green
} else {
    Write-Host "❌ Visual Studio не найден!" -ForegroundColor Red
    Write-Host "   Установи Visual Studio 2019 или новее" -ForegroundColor Yellow
    Write-Host "   https://visualstudio.microsoft.com/" -ForegroundColor Yellow
    exit 1
}

# Создаём рабочую папку
Write-Host ""
Write-Host "📁 Создание рабочей папки..." -ForegroundColor Cyan
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}
Set-Location $OutputDir

# Клонируем SmartSteamEmu
Write-Host "📥 Клонирование SmartSteamEmu..." -ForegroundColor Cyan
if (Test-Path "SmartSteamEmu") {
    Write-Host "⚠️  Папка уже существует, удаляю..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "SmartSteamEmu"
}

git clone https://github.com/MAXBURAOT/SmartSteamEmu.git
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка клонирования!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Репозиторий склонирован" -ForegroundColor Green

# Копируем патч
Write-Host ""
Write-Host "📝 Применение патча..." -ForegroundColor Cyan
Copy-Item "..\SteamGameCoordinator_Redirect.h" "SmartSteamEmu\src\" -Force

Write-Host "✅ Патч скопирован" -ForegroundColor Green

# Инструкции для ручного патчинга
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "⚠️  ТРЕБУЕТСЯ РУЧНОЕ РЕДАКТИРОВАНИЕ" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Открой файл: $OutputDir\SmartSteamEmu\src\SteamGameCoordinator.cpp" -ForegroundColor White
Write-Host ""
Write-Host "И примени изменения согласно INTEGRATION_GUIDE.md" -ForegroundColor White
Write-Host ""
Write-Host "После редактирования запусти:" -ForegroundColor White
Write-Host "  .\auto-patch.ps1 -Compile" -ForegroundColor Yellow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Открываем папку в проводнике
Start-Process "explorer.exe" -ArgumentList "$OutputDir\SmartSteamEmu\src"

# Открываем INTEGRATION_GUIDE.md
Start-Process "notepad.exe" -ArgumentList "..\INTEGRATION_GUIDE.md"
