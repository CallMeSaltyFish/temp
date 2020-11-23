@ECHO off
set PATH=%PATH%;%~dp0
echo CM3D2Tool - Png2Tex Script
:loop
IF {%1}=={} GOTO end

REM Call Converter for each file
CM3D2Tool -c -m TEX -f \.png %1
SHIFT

GOTO loop
:end
PAUSE