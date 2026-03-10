# GitHub Actions - Автоматическая компиляция SmartSteamEmu

## Что это даёт?

✅ Компиляция в облаке (не нужен Visual Studio)  
✅ Автоматическая сборка при каждом коммите  
✅ Готовые DLL файлы для скачивания  
✅ Бесплатно (2000 минут в месяц)  

## Шаг 1: Создай репозиторий на GitHub

1. Зайди на https://github.com
2. Нажми **New repository**
3. Название: `SmartSteamEmu-GC-Redirect`
4. Visibility: **Public** (для бесплатных Actions)
5. Нажми **Create repository**

## Шаг 2: Загрузи файлы

В папке `custom-gc/sse-patch` выполни:

```bash
# Инициализация Git
git init
git add .
git commit -m "Initial commit with GC Redirect patch"

# Подключение к GitHub
git remote add origin https://github.com/ТвойЮзернейм/SmartSteamEmu-GC-Redirect.git
git branch -M main
git push -u origin main
```

Или через GitHub Desktop:
1. File → Add Local Repository
2. Выбери папку `custom-gc/sse-patch`
3. Publish repository

## Шаг 3: Запусти компиляцию

1. Зайди в свой репозиторий на GitHub
2. Вкладка **Actions**
3. Выбери workflow **Build SmartSteamEmu with GC Redirect**
4. Нажми **Run workflow** → **Run workflow**

GitHub начнёт компиляцию (займёт 5-10 минут)

## Шаг 4: Скачай готовые DLL

После завершения компиляции:

1. Вкладка **Actions**
2. Кликни на последний успешный run (зелёная галочка)
3. Внизу страницы **Artifacts**
4. Скачай **SmartSteamEmu-GC-Redirect.zip**

В архиве будут:
- `SmartSteamEmu.dll` (32-bit)
- `SmartSteamEmu64.dll` (64-bit)
- `SmartSteamEmu.ini` (конфиг)
- `README.txt` (инструкция)

## Шаг 5: Установка

1. Распакуй архив

2. Сделай бэкап оригинальных DLL:
```bash
copy SmartSteamEmu.dll SmartSteamEmu.dll.backup
copy SmartSteamEmu64.dll SmartSteamEmu64.dll.backup
```

3. Скопируй новые DLL в папку с игрой:
```bash
copy SmartSteamEmu.dll G:\SteamLibrary\steamapps\common\csgo-old\
copy SmartSteamEmu64.dll G:\SteamLibrary\steamapps\common\csgo-old\
```

4. Скопируй SmartSteamEmu.ini или добавь в существующий:
```ini
[GameCoordinator]
EnableRedirect = 1
ServerIP = 127.0.0.1
ServerPort = 27016
```

## Шаг 6: Тестирование

1. Запусти GC сервер:
```bash
node custom-gc/gc-server-v3.js
```

2. Запусти CS:GO через SSELauncher

3. Открой меню "ИГРАТЬ"

4. Проверь логи GC сервера - должны быть TCP подключения

5. В игре статус должен измениться на "Connected"

## Автоматические релизы

Workflow автоматически создаёт релизы при push в main ветку:

1. Вкладка **Releases**
2. Последний релиз содержит готовые DLL
3. Можно скачать без входа в Actions

## Обновление патча

Если нужно изменить патч:

1. Отредактируй `SteamGameCoordinator_Redirect.h`
2. Закоммить и запушить:
```bash
git add .
git commit -m "Update GC Redirect patch"
git push
```
3. GitHub автоматически пересоберёт

## Troubleshooting

### Workflow не запускается
- Проверь что репозиторий Public
- Проверь что Actions включены в Settings → Actions

### Компиляция падает
- Проверь логи в Actions
- Проверь что все файлы загружены
- Проверь синтаксис в .yml файле

### Не могу скачать артефакты
- Нужен аккаунт GitHub
- Артефакты хранятся 90 дней
- Используй Releases для постоянного хранения

## Альтернатива: Fork репозитория

Можно форкнуть готовый репозиторий с патчем:

1. Зайди на https://github.com/MAXBURAOT/SmartSteamEmu
2. Нажми **Fork**
3. Добавь файлы патча в свой форк
4. Настрой Actions

## Лимиты GitHub Actions

Бесплатный план:
- 2000 минут в месяц
- Одна компиляция ~5-10 минут
- Можно сделать ~200-400 сборок в месяц

Этого более чем достаточно!

## Приватный репозиторий

Если хочешь приватный репозиторий:
- GitHub Pro ($4/месяц) - 3000 минут
- Или используй GitLab CI (бесплатно для приватных)

## Дополнительные возможности

Можно добавить:
- Автоматическое тестирование
- Уведомления в Discord/Telegram
- Деплой на сервер
- Версионирование
