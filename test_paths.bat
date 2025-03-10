@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

echo Тестирование путей для Minecraft Overviewer
echo =========================================

set "PROJECT_ROOT=%~dp0"
set "OVERVIEWER_PATH=%PROJECT_ROOT%overviwer"
set "CONFIG_PATH=%PROJECT_ROOT%overviewer.conf"
set "MAP_BACKUP_PATH=%PROJECT_ROOT%map_backup"
set "MAP_OUTPUT_PATH=%PROJECT_ROOT%map"
set "TEXTURE_PATH=%PROJECT_ROOT%minecraft_assets\1.21.4_optifine\client.jar"

echo Корневая директория проекта: %PROJECT_ROOT%
echo Путь к Overviewer: %OVERVIEWER_PATH%
echo Путь к конфигурации: %CONFIG_PATH%
echo Путь к файлам мира: %MAP_BACKUP_PATH%
echo Путь к выходной директории: %MAP_OUTPUT_PATH%
echo Путь к текстурам: %TEXTURE_PATH%

echo.
echo Проверка существования файлов и директорий:
echo -----------------------------------------

if exist "%OVERVIEWER_PATH%" (
    echo [НАЙДЕНО] Директория Overviewer
) else (
    echo [НЕ НАЙДЕНО] Директория Overviewer
)

if exist "%OVERVIEWER_PATH%\overviewer.exe" (
    echo [НАЙДЕНО] Исполняемый файл Overviewer
) else (
    echo [НЕ НАЙДЕНО] Исполняемый файл Overviewer
)

if exist "%CONFIG_PATH%" (
    echo [НАЙДЕНО] Файл конфигурации
) else (
    echo [НЕ НАЙДЕНО] Файл конфигурации
)

if exist "%MAP_BACKUP_PATH%" (
    echo [НАЙДЕНО] Директория с файлами мира
) else (
    echo [НЕ НАЙДЕНО] Директория с файлами мира
)

if exist "%MAP_BACKUP_PATH%\level.dat" (
    echo [НАЙДЕНО] Файл level.dat
) else (
    echo [НЕ НАЙДЕНО] Файл level.dat
)

if exist "%MAP_BACKUP_PATH%\region" (
    echo [НАЙДЕНО] Директория region
) else (
    echo [НЕ НАЙДЕНО] Директория region
)

if exist "%TEXTURE_PATH%" (
    echo [НАЙДЕНО] Файл текстур
) else (
    echo [НЕ НАЙДЕНО] Файл текстур
)

echo.
echo Содержимое директории с файлами мира:
dir "%MAP_BACKUP_PATH%"

echo.
echo Содержимое директории с текстурами:
dir "%PROJECT_ROOT%minecraft_assets\1.21.4_optifine"

echo.
echo Тестирование завершено.
pause

endlocal 