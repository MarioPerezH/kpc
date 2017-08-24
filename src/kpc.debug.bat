call :%1
goto :eof

:init
    if "%DEBUG%" == "1" (
        set TRACE=echo
    ) else (
        set TRACE=rem
        echo.
        echo ************************
        echo ****** Procesando ******
        echo ************************
        echo.
    )
goto :eof

:variables
    if "%DEBUG%" == "1" (
        echo ************************
        echo *** DEBUG VARIABLES ****
        echo ************************
        echo ** FTP: %FTP%
        echo ** USER: %USER%
        echo ** PASS: %PASS%
        echo ** POSITION: %POSITION%
        echo ** FOLDERBASE: %FOLDERBASE%
        echo ************************
        echo.
    )
goto :eof

:finish
    if "%DEBUG%" == "1" (
        echo.
        echo ************************
        echo ** Proceso terminado. **
        echo ************************
        echo.
    )
goto :eof