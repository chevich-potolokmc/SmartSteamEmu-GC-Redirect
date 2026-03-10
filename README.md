# SmartSteamEmu GC Redirect Patch

Модификация SmartSteamEmu для перенаправления Game Coordinator трафика на кастомный TCP сервер.

## 🚀 Быстрый старт (GitHub Actions)

### Шаг 1: Создай репозиторий на GitHub

1. Зайди на https://github.com/new
2. Название: `SmartSteamEmu-GC-Redirect`
3. Public репозиторий
4. Create repository

### Шаг 2: Загрузи файлы

```bash
cd custom-gc/sse-patch
.\upload-to-github.bat
```

Введи URL своего репозитория когда попросит.

### Шаг 3: Запусти компиляцию

1. Зайди в репозиторий на GitHub
2. Вкладка **Actions**
3. **Run workflow** → **Run workflow**
4. Дождись завершения (5-10 минут)

### Шаг 4: Скачай DLL

1. Actions → последний run
2. Artifacts → **SmartSteamEmu-GC-Redirect.zip**
3. Скачай и распакуй

### Шаг 5: Установка

```bash
# Бэкап
copy SmartSteamEmu.dll SmartSteamEmu.dll.backup

# Установка
copy SmartSteamEmu.dll G:\SteamLibrary\steamapps\common\csgo-old\
```

Добавь в SmartSteamEmu.ini:
```ini
[GameCoordinator]
EnableRedirect = 1
ServerIP = 127.0.0.1
ServerPort = 27016
```

### Шаг 6: Запуск

```bash
# Запусти GC сервер
node custom-gc/gc-server-v3.js

# Запусти игру через SSELauncher
# Открой меню ИГРАТЬ
# UI Matchmaking должен работать!
```

## 📁 Файлы

- `.github/workflows/build.yml` - GitHub Actions workflow
- `SteamGameCoordinator_Redirect.h` - Патч для ISteamGameCoordinator
- `SmartSteamEmu.ini` - Конфиг с настройками GC
- `upload-to-github.bat` - Скрипт загрузки на GitHub
- `GITHUB_ACTIONS_GUIDE.md` - Подробная инструкция
- `INTEGRATION_GUIDE.md` - Ручная интеграция (если нужно)

## ✅ Что это даёт?

- UI Matchmaking работает через Custom GC
- Нет runtime injection - нет детекта игрой
- Работает без `-insecure`
- Можно играть на обычных серверах
- Не нужен Visual Studio на твоём ПК

## 🔧 Ручная компиляция

Если не хочешь использовать GitHub Actions, см. `INTEGRATION_GUIDE.md`

## 📖 Документация

- `GITHUB_ACTIONS_GUIDE.md` - Полная инструкция по GitHub Actions
- `INTEGRATION_GUIDE.md` - Ручная интеграция патча
- `INSTALL_VISUAL_STUDIO.md` - Установка Visual Studio

## ⚠️ Требования

- Аккаунт на GitHub (бесплатно)
- Git установлен
- Интернет для загрузки

## 🎮 Использование

После установки модифицированной DLL:

1. Запусти GC сервер: `node custom-gc/gc-server-v3.js`
2. Запусти CS:GO через SSELauncher
3. Открой меню "ИГРАТЬ"
4. UI Matchmaking должен подключиться к твоему серверу

## 🐛 Troubleshooting

См. раздел Troubleshooting в `GITHUB_ACTIONS_GUIDE.md`

## 📝 Лицензия

Патч распространяется под той же лицензией что и SmartSteamEmu.
