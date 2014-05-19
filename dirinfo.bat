@echo off
:: dirinfo.bat --- get some info on a directory
:: Evans Winner, 2014.4.18

:: Validate command line... sort of.
if "%1"==""  goto wrongargs
if not exist "%1" goto nonexist
set dir=%~f1
pushd %dir%
shift
if not "%1"=="" goto wrongargs

:: Make the raw data
echo.
echo Beginning process for ... %dir%

:: Summary
echo|set /p="Total objects ........... "
for /f %%i in ('dir /s /b %dir% ^| find /c /v ""') do echo %%i
echo|set /p="Total subdirectories ..... "
call :getNumberOfSubdirectories %dir% & echo.
echo|set /p="Total files ............. "
call :getNumberOfFiles %dir% & echo.
echo|set /p="Total size .............. "
call :getDirSize %dir%

echo.
echo.

:: Detail
echo ^| DIR	^| SUBDIRS ^| FILES ^| SIZE ^|
echo ^|--------------------------------
for /d %%j in (*) do (
  echo|set /p="| %%~nj | "
  call :getNumberOfSubdirectories %%~fsj
  echo|set /p=" | "  
  call :getNumberOfFiles %%~fsj
  echo|set /p=" | "
  call :getDirSize %%~fsj & echo.
)

:: Cleanup
echo.
echo|set /p="CLEANING UP .............. "
popd
echo Done.
goto exit

:: Procedures
:getNumberOfSubdirectories
  for /f %%i in ('dir /s /b /ad %1 ^| find /c /v ""') do echo|set /p="%%i"
goto :EOF

:getNumberOfFiles
  dir /s /b /a-d %1 > tmp.tmp 2>&1 | findstr "File Not Found" 
  if errorlevel 1 (
    for /f %%i in ('dir /s /b /a-d %1 ^| find /c /v ""') do echo|set /p=%%i
    ) else (
    echo|set /p=0
  )
  del tmp.tmp
  REM attrib.exe /s "%1\*" | find /c /v ""
goto :EOF

:getDirSize
  for /f "tokens=1,2,3,4 delims= " %%A in ('dir /s /-c %1 ^| findstr "bytes" ^| findstr "File(s)"') do (
    set size=%%C
  )
  echo|set /p=%size%
goto :EOF

:wrongargs
  echo Usage: dirinfo directory   
  goto exit

:nonexist
  echo %dir%: Directory does not exist
  goto exit

:exit
