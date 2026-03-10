// SmartSteamEmu Patch - ISteamGameCoordinator with TCP redirect
// Перенаправляет GC трафик на кастомный сервер

#pragma once

#include <winsock2.h>
#include <ws2tcpip.h>
#include <string>
#include <queue>
#include <mutex>

#pragma comment(lib, "ws2_32.lib")

// Steam типы
typedef unsigned int AppId_t;
typedef unsigned int uint32;

// GC Message структура
struct GCMessage {
    uint32 msgType;
    std::vector<uint8_t> data;
};

class CSteamGameCoordinator_Redirect
{
private:
    SOCKET m_socket;
    bool m_connected;
    std::string m_serverIP;
    int m_serverPort;
    std::queue<GCMessage> m_messageQueue;
    std::mutex m_queueMutex;
    HANDLE m_receiveThread;
    bool m_running;

    // Поток для приёма сообщений от сервера
    static DWORD WINAPI ReceiveThreadProc(LPVOID lpParam)
    {
        CSteamGameCoordinator_Redirect* pThis = (CSteamGameCoordinator_Redirect*)lpParam;
        return pThis->ReceiveThread();
    }

    DWORD ReceiveThread()
    {
        char buffer[65536];
        
        while (m_running && m_connected)
        {
            // Проверяем есть ли данные
            fd_set readSet;
            FD_ZERO(&readSet);
            FD_SET(m_socket, &readSet);
            
            timeval timeout;
            timeout.tv_sec = 0;
            timeout.tv_usec = 100000; // 100ms
            
            int result = select(0, &readSet, NULL, NULL, &timeout);
            if (result > 0)
            {
                // Читаем заголовок (8 байт: msgType + size)
                int received = recv(m_socket, buffer, 8, MSG_WAITALL);
                if (received == 8)
                {
                    uint32 msgType = *(uint32*)buffer;
                    uint32 msgSize = *(uint32*)(buffer + 4);
                    
                    if (msgSize > 0 && msgSize < 65536)
                    {
                        // Читаем данные
                        received = recv(m_socket, buffer + 8, msgSize, MSG_WAITALL);
                        if (received == msgSize)
                        {
                            GCMessage msg;
                            msg.msgType = msgType;
                            msg.data.assign(buffer + 8, buffer + 8 + msgSize);
                            
                            std::lock_guard<std::mutex> lock(m_queueMutex);
                            m_messageQueue.push(msg);
                        }
                    }
                }
                else if (received == 0 || received == SOCKET_ERROR)
                {
                    // Соединение закрыто
                    m_connected = false;
                    break;
                }
            }
        }
        
        return 0;
    }

public:
    CSteamGameCoordinator_Redirect()
        : m_socket(INVALID_SOCKET)
        , m_connected(false)
        , m_serverIP("127.0.0.1")
        , m_serverPort(27016)
        , m_receiveThread(NULL)
        , m_running(false)
    {
        // Инициализация Winsock
        WSADATA wsaData;
        WSAStartup(MAKEWORD(2, 2), &wsaData);
        
        // Читаем настройки из SmartSteamEmu.ini
        char iniPath[MAX_PATH];
        GetModuleFileNameA(NULL, iniPath, MAX_PATH);
        std::string path(iniPath);
        size_t pos = path.find_last_of("\\/");
        if (pos != std::string::npos)
        {
            path = path.substr(0, pos + 1) + "SmartSteamEmu.ini";
        }
        
        char buffer[256];
        GetPrivateProfileStringA("GameCoordinator", "ServerIP", "127.0.0.1", buffer, sizeof(buffer), path.c_str());
        m_serverIP = buffer;
        
        m_serverPort = GetPrivateProfileIntA("GameCoordinator", "ServerPort", 27016, path.c_str());
        
        bool enableRedirect = GetPrivateProfileIntA("GameCoordinator", "EnableRedirect", 0, path.c_str()) != 0;
        
        if (enableRedirect)
        {
            Connect();
        }
    }

    ~CSteamGameCoordinator_Redirect()
    {
        Disconnect();
        WSACleanup();
    }

    bool Connect()
    {
        if (m_connected)
            return true;

        m_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (m_socket == INVALID_SOCKET)
            return false;

        sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(m_serverPort);
        inet_pton(AF_INET, m_serverIP.c_str(), &addr.sin_addr);

        if (connect(m_socket, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR)
        {
            closesocket(m_socket);
            m_socket = INVALID_SOCKET;
            return false;
        }

        m_connected = true;
        m_running = true;
        
        // Запускаем поток приёма
        m_receiveThread = CreateThread(NULL, 0, ReceiveThreadProc, this, 0, NULL);
        
        return true;
    }

    void Disconnect()
    {
        m_running = false;
        
        if (m_receiveThread)
        {
            WaitForSingleObject(m_receiveThread, 1000);
            CloseHandle(m_receiveThread);
            m_receiveThread = NULL;
        }
        
        if (m_socket != INVALID_SOCKET)
        {
            closesocket(m_socket);
            m_socket = INVALID_SOCKET;
        }
        
        m_connected = false;
    }

    // ISteamGameCoordinator::SendMessage
    int SendMessage(uint32 unMsgType, const void* pubData, uint32 cubData)
    {
        if (!m_connected)
        {
            if (!Connect())
                return 0; // Failed
        }

        // Отправляем заголовок + данные
        char buffer[65536];
        *(uint32*)buffer = unMsgType;
        *(uint32*)(buffer + 4) = cubData;
        
        if (cubData > 0 && pubData != NULL)
        {
            memcpy(buffer + 8, pubData, cubData);
        }

        int sent = send(m_socket, buffer, 8 + cubData, 0);
        
        return (sent == 8 + cubData) ? 1 : 0; // 1 = Success, 0 = Failed
    }

    // ISteamGameCoordinator::IsMessageAvailable
    bool IsMessageAvailable(uint32* pcubMsgSize)
    {
        std::lock_guard<std::mutex> lock(m_queueMutex);
        
        if (m_messageQueue.empty())
            return false;

        if (pcubMsgSize)
        {
            *pcubMsgSize = (uint32)m_messageQueue.front().data.size();
        }

        return true;
    }

    // ISteamGameCoordinator::RetrieveMessage
    int RetrieveMessage(uint32* punMsgType, void* pubDest, uint32 cubDest, uint32* pcubMsgSize)
    {
        std::lock_guard<std::mutex> lock(m_queueMutex);
        
        if (m_messageQueue.empty())
            return 0;

        GCMessage& msg = m_messageQueue.front();
        
        if (punMsgType)
            *punMsgType = msg.msgType;
        
        if (pcubMsgSize)
            *pcubMsgSize = (uint32)msg.data.size();

        if (pubDest && cubDest >= msg.data.size())
        {
            memcpy(pubDest, msg.data.data(), msg.data.size());
            m_messageQueue.pop();
            return 1; // Success
        }

        return 0; // Buffer too small
    }
};
