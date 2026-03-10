# SmartSteamEmu Patch - Integration Guide

## Цель
Модифицировать SmartSteamEmu для перенаправления Game Coordinator трафика на кастомный TCP сервер.

## Требования
- Visual Studio 2019 или новее
- Windows SDK
- Git

## Шаг 1: Скачать исходники SmartSteamEmu

```bash
git clone https://github.com/MAXBURAOT/SmartSteamEmu.git
cd SmartSteamEmu
```

## Шаг 2: Найти файл с ISteamGameCoordinator

Обычно это файл `SteamGameCoordinator.cpp` или `SteamGameCoordinator001.cpp` в папке `src/`.

Пример структуры:
```
SmartSteamEmu/
├── src/
│   ├── SteamGameCoordinator.cpp
│   ├── SteamGameCoordinator.h
│   └── ...
└── ...
```

## Шаг 3: Добавить наш патч

1. Скопируй `SteamGameCoordinator_Redirect.h` в папку `src/`

2. Открой `SteamGameCoordinator.cpp`

3. Добавь в начало файла:
```cpp
#include "SteamGameCoordinator_Redirect.h"
```

4. Найди класс `CSteamGameCoordinator` (или похожий)

5. Добавь приватное поле:
```cpp
private:
    CSteamGameCoordinator_Redirect* m_pRedirect;
```

6. В конструкторе добавь:
```cpp
CSteamGameCoordinator::CSteamGameCoordinator()
{
    m_pRedirect = new CSteamGameCoordinator_Redirect();
    // ... остальной код
}
```

7. В деструкторе добавь:
```cpp
CSteamGameCoordinator::~CSteamGameCoordinator()
{
    if (m_pRedirect)
    {
        delete m_pRedirect;
        m_pRedirect = NULL;
    }
    // ... остальной код
}
```

8. Замени методы SendMessage, IsMessageAvailable, RetrieveMessage:

```cpp
EGCResults CSteamGameCoordinator::SendMessage(uint32 unMsgType, const void* pubData, uint32 cubData)
{
    // Если включен redirect, используем его
    if (m_pRedirect)
    {
        int result = m_pRedirect->SendMessage(unMsgType, pubData, cubData);
        return result ? k_EGCResultOK : k_EGCResultNoMessage;
    }
    
    // Иначе используем старую логику
    // ... оригинальный код
}

bool CSteamGameCoordinator::IsMessageAvailable(uint32* pcubMsgSize)
{
    if (m_pRedirect)
    {
        return m_pRedirect->IsMessageAvailable(pcubMsgSize);
    }
    
    // ... оригинальный код
}

EGCResults CSteamGameCoordinator::RetrieveMessage(uint32* punMsgType, void* pubDest, uint32 cubDest, uint32* pcubMsgSize)
{
    if (m_pRedirect)
    {
        int result = m_pRedirect->RetrieveMessage(punMsgType, pubDest, cubDest, pcubMsgSize);
        return result ? k_EGCResultOK : k_EGCResultNoMessage;
    }
    
    // ... оригинальный код
}
```

## Шаг 4: Добавить настройки в SmartSteamEmu.ini

Добавь новую секцию в конец файла:

```ini
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                   Game Coordinator Redirect
;
; Перенаправление GC трафика на кастомный сервер
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
[GameCoordinator]

; EnableRedirect
;    Включить перенаправление GC на кастомный сервер
;    0 = использовать встроенную эмуляцию (по умолчанию)
;    1 = перенаправлять на ServerIP:ServerPort
EnableRedirect = 1

; ServerIP
;    IP адрес кастомного GC сервера
ServerIP = 127.0.0.1

; ServerPort
;    TCP порт кастомного GC сервера
ServerPort = 27016
```

## Шаг 5: Компиляция

1. Открой `SmartSteamEmu.sln` в Visual Studio

2. Выбери конфигурацию:
   - Release
   - x86 (для 32-bit игр)

3. Build → Build Solution (Ctrl+Shift+B)

4. Скомпилированная DLL будет в:
   - `Release/SmartSteamEmu.dll` (32-bit)
   - `x64/Release/SmartSteamEmu64.dll` (64-bit)

## Шаг 6: Установка

1. Сделай бэкап оригинальных DLL:
```bash
copy SmartSteamEmu.dll SmartSteamEmu.dll.backup
copy SmartSteamEmu64.dll SmartSteamEmu64.dll.backup
```

2. Скопируй новые DLL в папку с игрой:
```bash
copy Release\SmartSteamEmu.dll G:\SteamLibrary\steamapps\common\csgo-old\
copy x64\Release\SmartSteamEmu64.dll G:\SteamLibrary\steamapps\common\csgo-old\
```

3. Обнови SmartSteamEmu.ini:
```ini
[GameCoordinator]
EnableRedirect = 1
ServerIP = 127.0.0.1
ServerPort = 27016
```

## Шаг 7: Тестирование

1. Запусти GC сервер:
```bash
node custom-gc/gc-server-v3.js
```

2. Запусти CS:GO через SSELauncher

3. Открой меню "ИГРАТЬ"

4. Проверь логи GC сервера - должны появиться TCP подключения:
```
[TCP] 🔌 Подключение: 127.0.0.1:xxxxx
[TCP] 📨 Данные от 127.0.0.1:xxxxx
```

5. В игре статус должен измениться с "Connecting..." на "Connected"

## Troubleshooting

### Ошибка компиляции
- Проверь что установлен Windows SDK
- Проверь что все include пути правильные
- Проверь версию Visual Studio (нужна 2019+)

### DLL не загружается
- Проверь что DLL в правильной папке
- Проверь что SSELauncher настроен на Inject SmartSteamEmu
- Проверь логи в DebugView

### GC не подключается
- Проверь что EnableRedirect = 1 в SmartSteamEmu.ini
- Проверь что GC сервер запущен
- Проверь что порт 27016 не занят
- Проверь firewall

### Игра крашится
- Проверь что компилировал правильную архитектуру (x86 для CS:GO)
- Проверь что нет конфликтов с другими DLL
- Попробуй отключить EnableRedirect и проверить работает ли оригинальная эмуляция

## Альтернатива: Готовая DLL

Если не хочешь компилировать сам, можешь:
1. Попросить кого-то скомпилировать
2. Поискать готовую модифицированную версию
3. Использовать CI/CD для автоматической компиляции

## Дополнительные улучшения

После базовой интеграции можно добавить:
- Автоматическое переподключение при разрыве связи
- Логирование GC трафика
- Поддержку нескольких GC серверов
- Шифрование трафика
- Компрессию данных
