@ECHO off
set PATH=%PATH%;%~dp0
echo CM3D2Tool - Injector Script
:loop
IF {%1}=={} GOTO end

REM Call Injector for each file
CM3D2Tool -i %1
SHIFT

GOTO loop
:end
PAUSE