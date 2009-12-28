@echo off
 title=[ Windows Update ]
 setlocal
 cls
 echo.

rem ## This file once made sense to Josh Enders on 7.13.07
rem ## This script is meant for users who manually update windows and 
rem ## do not want the BITS and wuauserv services set to "Automatic".

rem ## check current startup type of BITS
 for /f "usebackq tokens=3" %%a in (`reg query HKLM\SYSTEM\CurrentControlSet\Services\BITS /v "Start"`) do set _BITS-type=%%a
 if "%_BITS-type%"=="0x2" echo BITS startup type is "Automatic", no changes will be made, startup type is Already "Automatic"
 if "%_BITS-type%"=="0x3" echo BITS startup type is "Manual", it will temporarily be set to Automatic
 if "%_BITS-type%"=="0x4" echo BITS startup type is "Disabled", it will temporarily be set to Automatic 
 if "%_BITS-type%"==""    echo BITS startup type is Undeterminable, something is terribly wrong...

rem ## if not already Automatic set BITS service to Automatic
 if not "%_BITS-type%"=="0x2" (
 echo Modifying startup type of BITS to "Automatic"
 sc config bits start= auto
 echo.
)

rem ## check current startup type of wuauserv
 for /f "usebackq tokens=3" %%a in (`reg query HKLM\SYSTEM\CurrentControlSet\Services\wuauserv /v "Start"`) do set _wuauserv-type=%%a
 if "%_wuauserv-type%"=="0x2" echo wuauserv startup type is "Automatic", no changes will be made, startup type is Already "Automatic"
 if "%_wuauserv-type%"=="0x3" echo wuauserv startup type is "Manual", it will temporarily be set to Automatic
 if "%_wuauserv-type%"=="0x4" echo wuauserv startup type is "Disabled", it will temporarily be set to Automatic 
 if "%_wuauserv-type%"==""    echo wuauserv startup type is Undeterminable, something is terribly wrong...

rem ## if not already Automatic set wuauserv to Automatic
 if not "%_wuauserv-type%"=="0x2" (
 echo Modifying startup type of wuauserv to "Automatic"
 sc config wuauserv start= auto
 echo.
)

rem ## now that we are sure that both services are set to Automatic, let's see if they are running 
rem ## note: "for" does not allow piping, so an intermediary file is used. If this bothers you, fix it and tell me
 sc query BITS| find "STATE" > %tmp%\BITS.txt
 for /f "tokens=3" %%a in (%tmp%\BITS.txt) do set _BITS-state=%%a
 del /q %tmp%\BITS.txt

 sc query wuauserv| find "STATE" > %tmp%\wuauserv.txt
 for /f "tokens=3" %%a in (%tmp%\wuauserv.txt) do set _wuauserv-state=%%a
 del /q %tmp%\wuauserv.txt

rem ## if the services haven't been started, we'll start them now 
 if not "%_BITS-state%"=="4" net start BITS
 if not "%_wuauserv-state%"=="4" net start wuauserv

rem ## now we start windows update and wait for it to finish executing 
 start /wait iexplore update.microsoft.com

rem ## return the services to their upright and pre-wupdate positions
 if "%_BITS-state%"=="1" net stop BITS
 if "%_wuauserv-state%"=="1" net stop wuauserv

rem ## return the startup types to their upright and pre-wupdate positions
 if "%_BITS-type%"=="0x3" (
 echo Reverting startup type of BITS to "Manual"
 sc config bits start= demand
 echo.
)

 if "%_BITS-type%"=="0x4" (
 echo Reverting startup type of BITS to "Disabled"
 sc config bits start= disabled
 echo.
)
 
 if "%_wuauserv-type%"=="0x3" (
 echo Reverting startup type of wuauserv to "Manual"
 sc config wuauserv start= demand
 echo.
)

 if "%_wuauserv-type%"=="0x4" ( 
 echo Reverting startup type of wuauserv to "Disabled"
 sc config wuauserv start= disabled
 echo.
)

rem ## doing my part for the enviroment
 endlocal
 title=%comspec%
 exit

