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
set "^!=call :"

:: ----------- function -----------
:: @type	keyword
:: @param	", " delimited array string of function parameters
:: @example	`
::				:func
:: 				%function:$=param1, param2%
::				(
::					rem ...
::				)
::			`
:: @source
REM set /a [[i]]=0
REM set [[arguments]].keys=$
REM for %%a in ("%[[arguments]].keys:, =" "%") do (
REM 	rem echo ![[i]]!, %%~a, %![[i]]!%
REM 	set [[arguments]].keys[![[i]]!]=%%~a
REM 	set /a [[i]]+=1
REM )
REM set /a [[i]]=0
REM call set [[arguments]].values=%%*
REM for %%a in (![[arguments]].values!) do (
REM 	for %%b in (![[i]]!) do (
REM 		rem echo ![[arguments]].keys[%%b]!
REM 		set ![[arguments]].keys[%%b]!=%%~a
REM 	)
REM 	set /a [[i]]+=1
REM )
set "function=set /a [[i]]=0&&set [[arguments]].keys=$&&(for %%a in ("^^^![[arguments]].keys:, =" "^^^!") do (set [[arguments]].keys[^^^![[i]]^^^!]=%%~a&&set /a [[i]]+=1 ))&&set /a [[i]]=0&&call set [[arguments]].values=%%*&&(for %%a in (^^^![[arguments]].values^^^!) do ((for %%b in (^^^![[i]]^^^!) do (set ^^^![[arguments]].keys[%%b]^^^!=%%~a))&&set /a [[i]]+=1))"

:: ----------- noop -----------
set "noop=rem"

:: ----------- return -----------
set "[[return.value]]="
set "return=set [[return.value]]=$"

call :su aa bb cc dd
exit /b

:su
%function:$=newState, a%
echo !newState!
(
	
	echo !newState! !a! %1 %2
	rem set a return value
	rem clear input variables
	goto :eof
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