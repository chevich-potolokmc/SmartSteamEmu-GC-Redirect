# Установка Visual Studio для компиляции SmartSteamEmu

## Что нужно установить

**Visual Studio Community 2022** (бесплатная версия)

## Шаг 1: Скачать

Скачай с официального сайта:
https://visualstudio.microsoft.com/vs/community/

Или прямая ссылка:
https://aka.ms/vs/17/release/vs_community.exe

Размер: ~3 ГБ установщик + ~10 ГБ компоненты

## Шаг 2: Установка

1. Запусти `vs_community.exe`

2. В установщике выбери **Workloads**:
   - ✅ **Desktop development with C++**
   
   Это установит:
   - MSVC компилятор
   - Windows SDK
   - CMake
   - Все необходимые инструменты

3. Нажми **Install**

4. Подожди 30-60 минут (зависит от интернета)

## Шаг 3: Проверка

После установки проверь:

```powershell
# Проверка компилятора
"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\bin\Hostx64\x86\cl.exe"
```

Если файл существует - всё ОК.

## Альтернатива: Build Tools (без IDE)

Если не хочешь устанавливать полную Visual Studio, можно установить только Build Tools:

1. Скачай: https://aka.ms/vs/17/release/vs_buildtools.exe

2. Выбери:
   - ✅ **C++ build tools**
   - ✅ **Windows 10 SDK**

3. Размер: ~5 ГБ (меньше чем полная VS)

Но с Build Tools нужно компилировать через командную строку:
```bash
msbuild SmartSteamEmu.sln /p:Configuration=Release /p:Platform=Win32
```

## Рекомендация

Установи **Visual Studio Community** - проще работать через GUI.

## После установки

1. Запусти Visual Studio
2. Открой `SmartSteamEmu.sln`
3. Выбери конфигурацию: **Release | x86**
4. Build → Build Solution (Ctrl+Shift+B)

## Если диск C переполнен

Visual Studio можно установить на другой диск:

1. В установщике нажми **More** → **Change**
2. Выбери диск G:
3. Установка пойдёт на G:\Program Files\Microsoft Visual Studio\

Но кэш всё равно будет на C: (~2 ГБ)

## Минимальные требования

- Windows 10/11
- 10 ГБ свободного места
- 4 ГБ RAM (рекомендуется 8 ГБ)
- Процессор: любой современный

## Время установки

- Скачивание: 10-30 минут
- Установка: 20-40 минут
- Итого: ~1 час

## Что делать если нет места на диске C

У тебя диск C полностью заполнен (0 байт свободно). Варианты:

1. **Освободить место на C:**
   - Удали временные файлы: `cleanmgr`
   - Удали старые обновления Windows
   - Перенеси файлы на диск G

2. **Установить VS на диск G:**
   - Возможно, но кэш всё равно на C
   - Нужно минимум 5 ГБ на C для кэша

3. **Использовать онлайн компиляцию:**
   - GitHub Actions (бесплатно)
   - Попросить друга скомпилировать

## GitHub Actions (альтернатива)

Если совсем нет места, можно использовать GitHub Actions для автоматической компиляции:

1. Создай репозиторий на GitHub
2. Загрузи пропатченный SmartSteamEmu
3. Создай workflow для компиляции
4. GitHub скомпилирует и выдаст готовую DLL

Создать workflow файл?
