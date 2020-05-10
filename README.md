# anti-taskbar

Taskbars are overrated, join the movement of abolishment!



## Features used

Don't know why there are so many of them, but here they are:

* Subset of "modern" language keywords:
  * `%return:val=foo%`
  * `%throw:err=fooErr_unique%`
  * `%try% (...) %catch:err=fooErr% (...)`

* Subroutine access restriction (already better than javascript):
  * `:foo %private% (...)`
  * `:foo %public% (...)`
* Tagged logging:
  * `%secho:code=foo%`
  * `%eecho:code=fooErr%`
* Asynchronous code execution:
  * `call :onNextTick echo foo`

## What it does

TL;DR:

* CLI for commands in
* Hides & shows, taskbar & icons, on demand
* Install to run at startup
* Prevents user from enabling

## TODO

idk what else you're supposed to put into a damn batch file, but

* Updating (???)
* Persistence (?????)