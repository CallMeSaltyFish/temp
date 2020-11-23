@ECHO off
set PATH=%PATH%;%~dp0
echo CM3D2Tool - Extractor Script
:loop
IF {%1}=={} GOTO end

REM Call Extractor for each file
REM To Filter files add -f  followed by a regular expression (i.e '\.tex' or '.*mizugi.*')
CM3D2Tool -e %1
SHIFT

GOTO loop
:end
PAUSE