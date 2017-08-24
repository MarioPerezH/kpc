call :%1
goto :eof

:initParameters
    set DEBUG=1
    set TRACE=rem
    set EXECUTE=
    set SYNC=

    set FTP=
    set USER=
    set PASS=
    set FOLDERBASE=

    set DIRTEMP=%tmp%
    set TXTOUTPUT=%DIRTEMP%\kpc.data.tmp
    set TXTFOLDERS=%DIRTEMP%\kpc.folders.tmp
    set TXTFILES=%DIRTEMP%\kpc.files.tmp
    set BATEXTRACTDATA=%DIRTEMP%\kpc.ftp-extract-data.bat
    set BATTRANSFERDATA=%DIRTEMP%\kpc.ftp-transfer-data.bat
    set BATSCRIPT=%DIRTEMP%\kpc.script.bat
    set TOTALFILESDOWNLOAD=

    set POSITION=0

    if not defined LOCATION (
        set LOCATION=%cd%
    )

    set TXTCONFIG=%LOCATION%\ftp-config.txt
    set DESTINATTION=%LOCATION%\

    if "%DEBUG%" == "1" (
        set TRACE=echo
    )
goto :eof