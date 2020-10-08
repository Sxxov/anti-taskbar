REM setlocal EnableDelayedExpansion

:core

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

:: ----------- GLOBALS -----------
set "DOLLAR_CHAR=$"

:: ----------- $ -----------
:: @type	keyword
:: @example	`%$%func param1 param2`
set "$=call "

:: ----------- > -----------
:: @type	keyword
:: @example	`%$%func param1 param2`
set "^>=& set "$=^^^!returned^^^!""

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
REM			set "[[arguments]].values[%%b]=%%~a" 2>nul
REM 		set "![[arguments]].keys[%%b]!=%%~a" 2>nul
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
set "function=set /a [[i]]=0&&set [[arguments]].keysString=$&&(for %%a in ("^^^![[arguments]].keysString:, =" "^^^!") do (set [[arguments]].keys[^^^![[i]]^^^!]=%%~a&&set /a [[i]]+=1 ))&&set /a [[arguments]].keys.length=^^^![[i]]^^^! + 1&&set /a [[i]]=0&&call set [[arguments]].valuesString=%%*&&(for %%a in (^^^![[arguments]].valuesString^^^!) do ((for %%b in (^^^![[i]]^^^!) do (set "[[arguments]].values[%%b]=%%~a" 2>nul&&set "^^^![[arguments]].keys[%%b]^^^!=%%~a"2>nul))&&set /a [[i]]+=1))&&set /a [[arguments]].values.length=^^^![[i]]^^^! + 1&&set [[i]]="

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
REM if "$" == "!DOLLAR_CHAR!" (
REM 	set [[returned]].value=0
REM )
REM for /l %%i in (0, 1, ^^^![[arguments]].keys.length^^^!) do (
REM 	set ![[arguments]].keys[%%i]!=2>nul
REM )
REM exit /b
set "[[return]].value="
set "returned="
set "return=set [[return]].value=$&(if "$" == "^^^!DOLLAR_CHAR^^^!" (set [[return]].value=))&set returned=^^^![[return]].value^^^!&(for /l %%i in (0, 1, ^^^![[arguments]].keys.length^^^!) do (set ^^^![[arguments]].keys[%%i]^^^!=2>nul))&goto :eof"

:: ----------- core -----------
if not "%*" == "" (
	call :%*
)
rem else, just load side effects
goto :eof

:: ----------- noop -----------
:noop
(
	goto :eof
)

:: ----------- su -----------
set "su.isEnabled="
:su
%function:$=newState%
(
	if "!newState!" == "" (
		if "!su.isEnabled!" == "true" (
			set newState=false
		) else (
			set newState=true
		)
	)

	set "su.isEnabled=!newState!"

	%return%
)

:: ----------- echo -----------
:echo 
%function:$=level, tag, message%
(
	set "tagDelimiter="

	rem if no tag provided, tag becomes the message
	if not "!message!" == "" (
		set "tagDelimiter=, "
	)

	echo !level!: !tag!!tagDelimiter!!message!

	%return%
)
:echo.log
%function:$=tag, message%
(
	!$!::echo Log !tag! !message!

	%return%
)
:echo.warn
%function:$=tag, message%
(
	!$!::echo Warn !tag! !message!

	%return%
)
:echo.error
%function:$=tag, message%
(
	!$!::echo Error !tag! !message!

	%return%
)

:: ----------- performance -----------
:performance.now
%function:$=%
(
	for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
		set /a "now=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
	)

	%return:$=!now!%
)
set "performance.measure.lastTime="
:performance.measure
%function:$=%
(
	if "!performance.measure.lastTime!" == "" (
		!$!::performance.now

		echo !returned!

		set /a "performance.measure.lastTime=!returned!"

		%return:$=0%
	)

	!$!::performance.now

	set /a "difference=!returned! - !performance.measure.lastTime!"
	set /a "performance.measure.lastTime=!returned!"

	%return:$=!difference!%
)

:: ----------- time -----------
:time.msToHuman
%function:$=ms%
(
	set /A "hh=ms/(60*60*100)"
	set /A "rest=ms%%(60*60*100)"
	set /A "mm=rest/(60*100)"
	set /A "rest%%=60*100"
	set /A "ss=rest/100"
	set /A "cc=rest%%100"

	set hh=0!hh!
	set mm=0!mm!
	set ss=0!ss!
	set cc=0!cc!

	echo !hh:~-2!:!mm:~-2!:!ss:~-2!:!cc:~-2!

	set "humanTime=!hh:~-2!:!mm:~-2!:!ss:~-2!:!cc:~-2!"

	%return:$=!humanTime!%
)

:: ----------- [[onUncaughtException]] -----------
:[[onUncaughtException]]
%function:$=id%
(
    for /f "tokens=1 delims=: usebackq" %%l in (`findstr /N "!id!" "%~f0"`) do (
        set /a "lineNumber=%%l"
    )

    !$!::echo.error UncaughtException ^(!id! at line !lineNumber!^)
    !$!::echo.error UncaughtException Press any key to terminate...

    pause >nul

	!$!::exit 1
)