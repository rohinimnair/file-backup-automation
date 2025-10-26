@echo off
setlocal enabledelayedexpansion

:: Display script title
echo SafeEdit Script - A tool to safely edit files with backup and logging
echo =====================================================================

:: Set log file location (relative to script directory)
set "logfile=%~dp0backup_log.txt"

:: ------------------------------------------------------------------------------------------------------
:: Check if the user provided a command-line argument
if "%~1"=="" (
    echo.
    echo What File Do You Wish to Edit?

    :ask_filename
    set "filename="
    set /p "filename=Enter file name: "

    :: Trim leading/trailing spaces
    for /f "tokens=* delims= " %%a in ("!filename!") do set "filename=%%a"

    :: Check if filename is empty
    if "!filename!"=="" (
        echo Error: No filename entered. Please enter a valid filename.
	:check
	set "user="
	echo Do you want to Continue?
	set /p user="Y/N:"
	if /i "!user!"=="y" (
	    goto ask_filename
	)else if /i "!user!"=="n" (
	    echo Exiting...
	    pause
	    exit /b
	)else (
	    echo Invalid Input
	    goto check
	) 
    )

    :: Check for multiple words
    for /f "tokens=2*" %%a in ("!filename!") do (
        echo Error: Too many parameters entered.
	goto check
    )

    :: Validate file extension
    for %%x in ("!filename!") do set "ext=%%~xx"
    if /i not "!ext!"==".txt" if /i not "!ext!"==".bat" (
        echo Error: Invalid filename. Only .txt and .bat files are allowed.
	goto check
    )

    if not exist "!filename!" (
        echo Error: File "!filename!" does not exist.
:scroll
	    echo Would you like to create a new one?
	    set /p take_user="Y/N:"
		if /i "!take_user!"=="y" (
		    echo Opening Notepad...
                    notepad !filename!
		    echo File "!filename!" was edited successfully.
		    goto check
		)else if /i "!take_user!"=="n" (
		    echo Closing creation...
		    goto check
		)else (
		    echo Invalid Input!
		    goto scroll
		) 
    )

    call :backup_file "!filename!"
    if "!backup_result!" NEQ "0" (
        echo Error: Backup failed.
        goto check
    )

    call :log_backup "!filename!"
    start /wait notepad "!filename!"
    echo File "!filename!" was edited successfully.
    goto check
)

:: ------------------------------------------------------------------------------------------------------
:: Command-line mode (non-interactive)
if not "%~2"=="" (
    echo Error: Too many parameters entered.
    goto check    
)

set "filename=%~1"

:: Trim spaces (in case user put quotes or trailing spaces)
for /f "tokens=* delims= " %%a in ("%filename%") do set "filename=%%~nxa"

:: Validate file extension
for %%x in ("%filename%") do set "ext=%%~xx"
if /i not "!ext!"==".txt" if /i not "!ext!"==".bat" (
    echo Error: Invalid filename. Only .txt and .bat files are allowed.
    goto check
)

if not exist "!filename!" (
    echo Error: File "!filename!" does not exist!
    goto scroll
)

call :backup_file "!filename!"
if "!backup_result!" NEQ "0" (
    echo Error: Backup failed.
    goto check
)

call :log_backup "!filename!"
start /wait notepad "!filename!"
echo File "!filename!" was edited successfully.
goto check

:: ------------------------------------------------------------------------------------------------------
:backup_file
:: %1 = input filename
:: Sets global variable backup_result to 0 (success) or 1 (failure)

set "filename=%~1"

:: Extract base name and directory
for %%f in ("%filename%") do (
    set "base=%%~nf"
    set "dir=%%~dpf"
)
set "backup_file=!dir!!base!.bak"

:: Delete old backup if it exists
if exist "!backup_file!" (
    del /f /q "!backup_file!" >nul 2>&1
    if exist "!backup_file!" (
        set "backup_result=1"
        exit /b
    )
)

:: Perform backup
copy /y "!filename!" "!backup_file!" >nul
if errorlevel 1 (
    set "backup_result=1"
    exit /b
)

set "backup_result=0"
exit /b

:: ------------------------------------------------------------------------------------------------------
:log_backup
set "backup_file=%~1"
set "timestamp=%date% %time%"
set "bak_file=%~n1.bak"
echo [%timestamp%] Backup created: %backup_file% → %bak_file% >> "%logfile%"

:: Limit log file to 5 entries
set count=0
for /f %%A in ('find /c /v "" ^< "%logfile%"') do set count=%%A

:check_log_size
if %count% GTR 5 (
    more +1 "%logfile%" > "%logfile%.tmp"
    move /y "%logfile%.tmp" "%logfile%" >nul
    set count=0
    for /f %%A in ('find /c /v "" ^< "%logfile%"') do set count=%%A
    goto check_log_size
)
exit /b