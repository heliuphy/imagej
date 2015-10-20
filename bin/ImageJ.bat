@echo off

setlocal ENABLEEXTENSIONS
set DIR=%~dp0
set DIR=%DIR:~0,-1%

if exist %DIR%\java\win32 (
    set JAVA_PATH=%DIR%\java\win32\jdk1.6.0_24\jre
)
if exist %DIR%\java\win64 (
    set JAVA_PATH=%DIR%\java\win64\jdk1.6.0_24\jre
)

if exist "%JAVA_PATH%" goto pathOK

::
:: Detect Java installation from the registry.
::
:: Credit to:
:: http://www.rgagnon.com/javadetails/java-0642.html
::

set KEY_NAME="HKLM\SOFTWARE\JavaSoft\Java Runtime Environment"
set VALUE_NAME=CurrentVersion

::
:: Get the current version
::
FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set ValueValue=%%A
)
if defined ValueValue (
    @echo The current Java runtime is: %ValueValue%
) else (
    @echo %KEY_NAME%\%VALUE_NAME% not found.
    goto end
)
set JAVA_CURRENT="HKLM\SOFTWARE\JavaSoft\Java Runtime Environment\%ValueValue%"
set JAVA_HOME=JavaHome

::
:: Get the java path
::
FOR /F "usebackq skip=2 tokens=3*" %%A IN (`REG QUERY %JAVA_CURRENT% /v %JAVA_HOME% 2^>nul`) DO (
    set JAVA_PATH=%%A %%B
)

if not exist %JAVA_PATH% (
    echo.
    echo No Java installation could be found!
    echo.
    goto end
)

:pathOK
echo.
echo Discovered Java at:
echo %JAVA_PATH%
echo.

::
:: Launch ImageJ
::
echo Launching ImageJ.
%JAVA_PATH%\bin\java.exe -cp "%DIR%\jars\*;%DIR%\jars\bio-formats\*;%DIR%\plugins\*" net.imagej.Main

:end
