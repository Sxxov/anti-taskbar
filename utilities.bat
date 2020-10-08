@echo on
setlocal EnableDelayedExpansion

rem util: ""language features""
set "return=set returned=val&& goto :eof"
set "returnTo=set returned=val&& goto "
set "returned="
set "throw=set __thrown=err&& if ^"^^^!__isTryBlock^^^!^" == ^"true^" ^(goto :eof ^) else ^(call :__exception err^)"
set "throwing=set __thrown=err"
set "try=set __thrown=null&&set __isTryBlock=true&&if a==a "
set "catch=&&set __isTryBlock=false&&if not ^".^^^!__thrown^^^!^" == ^".^^^!__thrown:err=^^^!^""
set "public=if ^^^!__intent^^^! == query set query.result=granted&& (goto :eof)"
set "private=if ^^^!__intent^^^! == query if ^^^!su.isEnabled^^^! == true (set query.result=granted) else (set query.result=denied)&& (goto :eof)"

rem util: APIs
set "echo.log=set __echoPrefix=Log: code,& set __rawC=code& set __cSubstr=^^^!__rawC:cod=^^^!&& (if .^^^!__cSubstr^^^! == .e set __echoPrefix=Log:) && echo ^^^!__echoPrefix^^^!"
set "echo.warn=!echo.log:Log=Warn!"
set "echo.error=!echo.log:Log=Error!"
set "query.result="
set "query.ifAccessible=set query.result=& set __intent=query& call :function >nul 2>&1 & set __intent=& if ^^^!query.result^^^!==granted "
set "query.ifExists=set query.result=null& set __intent=query& call :function >nul 2>&1 & set __intent=& if not ^^^!query.result^^^!==null "
set "su.isEnabled=false"

:: ----------- $ -----------
:: @type	keyword
:: @example	`%$%func param1 param2`
set "$=call :"

:: ----------- function -----------
:: @type	keyword
:: @param	<ArrayString>, function parameters
:: @example	`
::				:func
:: 				%function:$=param1, param2%
::				(
::					rem ...
::				)
::			`
:: @source
REM set /a [[i]]=0
REM set [[arguments]].keysString=$
REM for %%a in ("%[[arguments]].keysString:, =" "%") do (
REM 	rem echo ![[i]]!, %%~a, %![[i]]!%
REM 	set [[arguments]].keys[![[i]]!]=%%~a
REM 	set /a [[i]]+=1
REM )
REM set /a [[arguments]].keys.length=![[i]]! + 1
REM set /a [[i]]=0
REM call set [[arguments]].valuesString=%%*
REM for %%a in (![[arguments]].valuesString!) do (
REM 	for %%b in (![[i]]!) do (
REM 		rem echo ![[arguments]].keys[%%b]!
REM			set [[arguments]].values[%%b]=%%~a 2>nul
REM 		set ![[arguments]].keys[%%b]!=%%~a 2>nul
REM 	)
REM 	set /a [[i]]+=1
REM )
REM set /a [[arguments]].values.length=![[i]]! + 1
REM set [[i]]=
set "[[i]]="
set "[[arguments]].keyString="
set "[[arguments]].keys="
set "[[arguments]].keys.length="
set "[[arguments]].valuesString="
set "[[arguments]].values="
set "[[arguments]].values.length="
set "function=set /a [[i]]=0&&set [[arguments]].keysString=$&&(for %%a in ("^^^![[arguments]].keysString:, =" "^^^!") do (set [[arguments]].keys[^^^![[i]]^^^!]=%%~a&&set /a [[i]]+=1 ))&&set /a [[arguments]].keys.length=^^^![[i]]^^^! + 1&&set /a [[i]]=0&&call set [[arguments]].valuesString=%%*&&(for %%a in (^^^![[arguments]].valuesString^^^!) do ((for %%b in (^^^![[i]]^^^!) do (set [[arguments]].values[%%b]=%%~a 2>nul&&set ^^^![[arguments]].keys[%%b]^^^!=%%~a 2>nul))&&set /a [[i]]+=1))&&set /a [[arguments]].values.length=^^^![[i]]^^^! + 1&&set [[i]]="

:: ----------- noop -----------
set "noop=rem"

:: ----------- return -----------
:: @type	keyword
:: @param	<any>, value to return
:: @example	`
::				:func
:: 				%function:$=param1, param2%
::				(
::					if "!param1!" == false %return:$=1%
::
::					rem ...
::					%return:$=0%
::				)
::			`
:: @source
REM set [[returned]].value=$
REM set [[cachedExitcode]]=!=exitcode!
REM cmd /c exit 36 || (
REM 	if "$" == "^^^!=exitcodeAscii^^^!" (
REM 		set [[returned]].value=0
REM 	)
REM 	cmd /c exit ![[cachedExitcode]]!
REM 	for /l %%i in (0, 1, ^^^![[arguments]].keys.length^^^!) do (
REM 		set ![[arguments]].keys[%%i]!=2>nul
REM 	)
REM )
REM exit /b
set "[[return]].value="
set "returned="
set "return=set [[return]].value=$&&set [[cachedExitcode]]=^^^!=exitcode^^^!&&cmd /c exit 36||(if "$" == "^^^!=exitcodeAscii^^^!" set [[return]].value=0&&set returned=^^^![[return]].value^^^!&&cmd /c exit ^^^![[cachedExitcode]]^^^!&((for /l %%i in (0, 1, ^^^![[arguments]].keys.length^^^!) do (set ^^^![[arguments]].keys[%%i]^^^!=2>nul))&exit /b))"

!$!su true
echo !returned!
exit /b

:su
%function:$=newState%
(
	echo !newState!
	%return%
)

:exception (id)
%!%private
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

:__call
(

)