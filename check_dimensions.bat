@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

echo Проверка директорий измерений Minecraft
echo =====================================

set "PROJECT_ROOT=%~dp0"
set "MAP_BACKUP_PATH=%PROJECT_ROOT%map_backup"

echo Проверка директорий в %MAP_BACKUP_PATH%...

REM Check for level.dat
if exist "%MAP_BACKUP_PATH%\level.dat" (
    echo [НАЙДЕНО] Файл level.dat
) else (
    echo [НЕ НАЙДЕНО] Файл level.dat
    echo Ошибка: Файл level.dat не найден. Убедитесь, что вы скопировали правильный мир Minecraft.
    goto :end
)

REM Check for region directory
if exist "%MAP_BACKUP_PATH%\region" (
    echo [НАЙДЕНО] Директория region (обычный мир)
) else (
    echo [НЕ НАЙДЕНО] Директория region (обычный мир)
    echo Создание директории region...
    mkdir "%MAP_BACKUP_PATH%\region"
)

REM Check for DIM-1 directory (Nether)
if exist "%MAP_BACKUP_PATH%\DIM-1" (
    echo [НАЙДЕНО] Директория DIM-1 (Нижний мир)
    
    REM Check for region directory inside DIM-1
    if exist "%MAP_BACKUP_PATH%\DIM-1\region" (
        echo [НАЙДЕНО] Директория DIM-1\region
    ) else (
        echo [НЕ НАЙДЕНО] Директория DIM-1\region
        echo Создание директории DIM-1\region...
        mkdir "%MAP_BACKUP_PATH%\DIM-1\region"
    )
) else (
    echo [НЕ НАЙДЕНО] Директория DIM-1 (Нижний мир)
    echo Создание директорий DIM-1 и DIM-1\region...
    mkdir "%MAP_BACKUP_PATH%\DIM-1"
    mkdir "%MAP_BACKUP_PATH%\DIM-1\region"
)

REM Check for DIM1 directory (End)
if exist "%MAP_BACKUP_PATH%\DIM1" (
    echo [НАЙДЕНО] Директория DIM1 (Край)
    
    REM Check for region directory inside DIM1
    if exist "%MAP_BACKUP_PATH%\DIM1\region" (
        echo [НАЙДЕНО] Директория DIM1\region
    ) else (
        echo [НЕ НАЙДЕНО] Директория DIM1\region
        echo Создание директории DIM1\region...
        mkdir "%MAP_BACKUP_PATH%\DIM1\region"
    )
) else (
    echo [НЕ НАЙДЕНО] Директория DIM1 (Край)
    echo Создание директорий DIM1 и DIM1\region...
    mkdir "%MAP_BACKUP_PATH%\DIM1"
    mkdir "%MAP_BACKUP_PATH%\DIM1\region"
)

echo.
echo Проверка завершена. Все необходимые директории созданы.
echo Теперь вы можете запустить generate_map.bat для генерации карты.
echo.
echo Примечание: Если директории DIM-1 или DIM1 были созданы скриптом,
echo но в них нет файлов .mca, соответствующие измерения не будут
echo отображены на карте. Вам нужно скопировать файлы .mca в эти
echo директории, если вы хотите видеть Нижний мир и Край на карте.

:end
pause
endlocal 