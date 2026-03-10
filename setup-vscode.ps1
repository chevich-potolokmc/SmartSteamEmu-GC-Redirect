# Setup SmartSteamEmu для компиляции через VS Code

$ErrorActionPreference = "Stop"

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   SmartSteamEmu Setup для VS Code                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Клонируем правильный репозиторий
Write-Host "📥 Клонирование SmartSteamEmu..." -ForegroundColor Cyan
if (Test-Path "SmartSteamEmu") {
    Write-Host "⚠️  Папка существует, удаляю..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "SmartSteamEmu"
}

git clone https://github.com/MAXBURAOT/SmartSteamEmu.git
Set-Location SmartSteamEmu

# Копируем патч
Write-Host "`n📝 Копирование патча..." -ForegroundColor Cyan
Copy-Item "..\SteamGameCoordinator_Redirect.h" "src\" -Force

# Создаём .vscode папку
if (!(Test-Path ".vscode")) {
    New-Item -ItemType Directory -Path ".vscode" | Out-Null
}

# Создаём tasks.json для компиляции
$tasksJson = @'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build SmartSteamEmu (x86)",
            "type": "shell",
            "command": "msbuild",
            "args": [
                "SmartSteamEmu.sln",
                "/p:Configuration=Release",
                "/p:Platform=Win32",
                "/m"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": "$msCompile"
        }
    ]
}
'@

$tasksJson | Out-File -FilePath ".vscode\tasks.json" -Encoding UTF8

Write-Host "✅ tasks.json создан" -ForegroundColor Green

# Создаём инструкцию
$readme = @'
# Компиляция SmartSteamEmu через VS Code

## Шаг 1: Установи расширения

В VS Code установи:
1. C/C++ (Microsoft)
2. C/C++ Extension Pack

## Шаг 2: Примени патч

Открой `src/SteamGameCoordinator.cpp` и примени изменения из `INTEGRATION_GUIDE.md`

## Шаг 3: Компиляция

Нажми `Ctrl+Shift+B` или:
- Terminal → Run Build Task
- Выбери "Build SmartSteamEmu (x86)"

## Шаг 4: Результат

Скомпилированная DLL будет в:
`Release/SmartSteamEmu.dll`

## Требования

- Visual Studio Build Tools (или полная VS)
- MSBuild должен быть в PATH

Проверь:
```powershell
msbuild -version
```

Если не найден, добавь в PATH:
`C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin`
'@

$readme | Out-File -FilePath "BUILD_VSCODE.md" -Encoding UTF8

Write-Host "`n✅ Готово!" -ForegroundColor Green
Write-Host "`nОткрой папку SmartSteamEmu в VS Code:" -ForegroundColor White
Write-Host "  code ." -ForegroundColor Yellow
Write-Host "`nСледуй инструкциям в BUILD_VSCODE.md" -ForegroundColor White
