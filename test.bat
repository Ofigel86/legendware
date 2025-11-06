@echo off
setlocal EnableDelayedExpansion

:: =============================================
:: АВТО-КОМПИЛЯЦИЯ LEGENDWARE DLL (x64, Release)
:: =============================================

echo ========================================
echo    КОМПИЛЯЦИЯ LEGENDWARE DLL
echo ========================================
echo.

:: Проверяем, запущен ли от админа (нужно для некоторых путей)
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [ОШИБКА] Запусти батник от имени АДМИНИСТРАТОРА!
    pause
    exit /b
)

:: Автоматически находим VS Build Tools (vcvarsall.bat)
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [ОШИБКА] Не найден vswhere.exe — установи Build Tools 2022!
    pause
    exit /b
)

for /f "usebackq tokens=*" %%a in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VS_PATH=%%a"
)

if not defined VS_PATH (
    echo [ОШИБКА] Не найдена установка Visual Studio Build Tools!
    pause
    exit /b
)

call "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" x64

:: Пути к SDK и DirectX (обычно уже в PATH после vcvarsall)
set "INCLUDE=%INCLUDE%;%WindowsSdkDir%\Include\%WindowsSDKVersion%\um;%WindowsSdkDir%\Include\%WindowsSDKVersion%\shared;%WindowsSdkDir%\Include\%WindowsSDKVersion%\winrt"
set "LIB=%LIB%;%WindowsSdkDir%\Lib\%WindowsSDKVersion%\um\x64"

:: Имя выходной DLL
set "DLL_NAME=legendware.dll"

:: Папки с исходниками
set "SOURCES=main.cpp"
set "CPP_FILES=utils\*.cpp nSkinz\*.cpp"
for %%f in (%CPP_FILES%) do set "SOURCES=!SOURCES! %%f"

:: Библиотеки (статическая линковка + нужные либы)
set "LIBS=user32.lib kernel32.lib gdi32.lib winmm.lib dbghelp.lib psapi.lib shell32.lib advapi32.lib ws2_32.lib crypt32.lib"

:: Флаги компиляции
set "CFLAGS=/D "RELEASE" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" /D "WIN32" /D "_WIN64" /O2 /Oi /GL /MT /EHsc /Gy /Zi /TP /arch:AVX2"
set "LFLAGS=/DLL /MACHINE:X64 /SUBSYSTEM:WINDOWS /LTCG /INCREMENTAL:NO /OPT:REF /OPT:ICF /DEBUG:FULL /PDB:"%DLL_NAME%.pdb""

echo.
echo [INFO] Компиляция исходников...
cl.exe %CFLAGS% /I. /Iutils /InSkinz /Fe"%DLL_NAME%" %SOURCES% /link %LFLAGS% %LIBS%

if %errorlevel% EQU 0 (
    echo.
    echo ========================================
    echo    УСПЕШНО! DLL скомпилирована: %DLL_NAME%
    echo ========================================
    echo.
    echo Нажми любую клавишу, чтобы запустить инжектор + CS:GO...
    pause >nul

    :: === АВТО-ЗАПУСК CS:GO + ИНЖЕКТ (опционально) ===
    start "" "steam.exe" steam://rungameid/730
    timeout /t 15 >nul
    start "" "Xenos64.exe" -inject "%DLL_NAME%" csgo.exe
) else (
    echo.
    echo [ОШИБКА] Компиляция провалилась! Проверь ошибки выше.
    pause
)

endlocal