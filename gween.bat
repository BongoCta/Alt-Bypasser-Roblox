@echo off
title Roblox Alt Ban Bypasser
mode con: cols=70 lines=20
color 0a
setlocal EnableDelayedExpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo. && echo   [33m# This file needs to be opened as administrator.[0m && echo.
    echo   [33mPlease right-click the file and select "Run as administrator".[0m
    echo.
    pause
    exit /b
)

set "reg_path=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"

:MAIN_MENU
cls
echo.
echo  [1;36m============================================================[0m
echo  [1;33m          Roblox Alt Ban Bypasser by BongDevelopment            [0m
echo  [1;36m============================================================[0m
echo.
echo  [1;32mThis tool deletes Roblox LocalStorage data or spoofs MAC address.[0m
echo.
echo  [1;35mChoose an option:[0m
echo  [1;34m[1] Run Ban Bypass Script[0m
echo  [1;34m[2] Run Randomized Ban Bypass Script[0m
echo  [1;34m[3] Spoof MAC Address[0m
echo  [1;34m[4] Exit[0m
echo.
echo  [1;36m============================================================[0m
echo.

set /p choice=[1;33mEnter your choice (1-4): [0m

if "%choice%"=="1" goto run_script
if "%choice%"=="2" goto run_randomized
if "%choice%"=="3" goto select_nic
if "%choice%"=="4" exit
echo [1;31mInvalid choice! Please select 1, 2, 3, or 4.[0m
pause
goto MAIN_MENU

:run_script
cls
echo.
echo [1;36m============================================================[0m
echo [1;33m          Running Ban Bypass Script...            [0m
echo [1;36m============================================================[0m
echo.
echo [1;32mDeleting Roblox LocalStorage data...[0m
CMD.EXE /C @DEL /F/Q %LOCALAPPDATA%\Roblox\LocalStorage\*.dat
if %ERRORLEVEL%==0 (
    echo [1;32mSuccessfully deleted Roblox LocalStorage data![0m
) else (
    echo [1;31mError: Could not delete files. Check permissions.[0m
)
echo.
echo [1;36m============================================================[0m
pause
goto MAIN_MENU

:run_randomized
cls
echo.
echo [1;36m============================================================[0m
echo [1;33m          Running Randomized Ban Bypass Script... [0m
echo [1;36m============================================================[0m
echo.
echo [1;32mGenerating random delay (1-5 seconds)...[0m
set /a delay=(%RANDOM% %% 5) + 1
echo [1;32mDelaying for %delay% seconds...[0m
timeout /t %delay% /nobreak >nul
echo [1;32mDeleting Roblox LocalStorage data...[0m
CMD.EXE /C @DEL /F/Q %LOCALAPPDATA%\Roblox\LocalStorage\*.dat
if %ERRORLEVEL%==0 (
    echo [1;32mSuccessfully deleted Roblox LocalStorage data![0m
) else (
    echo [1;31mError: Could not delete files. Check permissions.[0m
)
echo.
echo [1;36m============================================================[0m
pause
goto MAIN_MENU

:select_nic
set "count=0"
cls
echo.
echo [1;36m============================================================[0m
echo [1;33m          Select Network Adapter            [0m
echo [1;36m============================================================[0m
echo.
echo [1;35mAvailable Network Adapters:[0m
for /f "skip=2 tokens=2 delims=," %%A in ('wmic nic get NetConnectionId /format:csv') do (
    for /f "delims=" %%B in ("%%~A") do (
        set /a "count+=1"
        set "nic[!count!]=%%B"
        echo   [1;34m[!count!] %%B[0m
    )
)
echo.
echo [1;34m[0] Back to Main Menu[0m
echo.
echo [1;36m============================================================[0m
echo.
set /p nic_selection=[1;33mEnter NIC number (0-%count%): [0m
set /a "nic_selection=nic_selection"
if %nic_selection%==0 goto MAIN_MENU
if %nic_selection% GTR 0 if %nic_selection% LEQ %count% (
    for /f "delims=" %%A in ("%nic_selection%") do set "NetworkAdapter=!nic[%%A]!"
    goto spoof_mac
)
echo [1;31mInvalid selection! Please choose a valid NIC number.[0m
pause
goto select_nic

:spoof_mac
cls
echo.
echo [1;36m============================================================[0m
echo [1;33m          Spoofing MAC Address...            [0m
echo [1;36m============================================================[0m
echo.
echo [1;32mSelected NIC: %NetworkAdapter%[0m
call :get_current_mac
echo [1;32mCurrent MAC: %MAC%[0m
call :gen_mac
echo [1;32mNew MAC: %mac_address_print%[0m
>nul 2>&1 (
    netsh interface set interface "%NetworkAdapter%" admin=disable
    reg add "%reg_path%\%Index%" /v "NetworkAddress" /t REG_SZ /d "%mac_address%" /f
    netsh interface set interface "%NetworkAdapter%" admin=enable
)
if %ERRORLEVEL%==0 (
    echo [1;32mMAC address successfully spoofed![0m
) else (
    echo [1;31mError: Could not spoof MAC address. Check permissions.[0m
)
echo.
echo [1;36m============================================================[0m
pause
goto MAIN_MENU

:get_current_mac
for /f "tokens=2 delims=[]" %%A in ('wmic nic where "NetConnectionId='%NetworkAdapter%'" get Caption /format:value ^| find "Caption"') do (
    set "Index=%%A"
    set "Index=!Index:~-4!"
)
for /f "tokens=2 delims==" %%A in ('wmic nic where "Index='%Index%'" get MacAddress /format:value ^| find "MACAddress"') do (
    set "MAC=%%A"
)
exit /b

:gen_mac
set #hex_chars=0123456789ABCDEF`AE26
set mac_address=
for /l %%A in (1,1,11) do (
    set /a "random_index=!random! %% 16"
    for %%B in (!random_index!) do (
        set mac_address=!mac_address!!#hex_chars:~%%B,1!
    )
)
set /a "random_index=!random! %% 4 + 17"
set mac_address=!mac_address:~0,1!!#hex_chars:~%random_index%,1!!mac_address:~1!
set mac_address_print=!mac_address:~0,2!:!mac_address:~2,2!:!mac_address:~4,2!:!mac_address:~6,2!:!mac_address:~8,2!:!mac_address:~10,2!
exit /b
