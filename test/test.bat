@echo off

cd..

if not exist temp\nul (
    mkdir temp
)

cd temp

set LOCATION=%cd%

cd..
cd src

call kpc.bat
