@echo off

set AUTOR="Mario Perez"
set VERSION="1.0.0"


call kpc.parameters.bat initParameters

call kpc.logo.bat logo

call :kpc

:kpc
       set OPTION=
       set ERROR=
       set RESULT=

        call kpc.menu.bat options 

        if "%OPTION%" == "0" if "%DEBUG%" == "1" (
			call :variables
		)  

        if "%OPTION%" == "1" (
            call kpc.config.bat existFileConfig
            
            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            call kpc.config.bat readFileConfig 

            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            set MESSAGE=Las credenciales de autenticacion se cargaron correctamente.
            call kpc.utils.bat message
        )

        if "%OPTION%" == "2" (
            call kpc.config.bat inputCredentials

            call kpc.config.bat isValidConfig

            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            call kpc.config.bat questionSaveConfig
          
            set MESSAGE=Las credenciales de autenticacion se cargaron correctamente.
            call kpc.utils.bat message
        )

        if "%OPTION%" == "3" (
            call kpc.config.bat isValidConfig

            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            call kpc.synchronizer.bat sync

            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            set MESSAGE=La sincronizacion se realizo correctamente.
            call kpc.utils.bat message
        )

        if "%OPTION%" == "4" ( 
            call kpc.config.bat isValidConfig

            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            call kpc.download.bat download

            set MESSAGE=La descarga de archivos se realizo correctamente.
            call kpc.utils.bat message
        )

        if "%OPTION%" == "5" ( 
            call kpc.config.bat isValidConfig

            if defined ERROR ( 
                call kpc.utils.bat error 
                goto :kpc
            )

            call kpc.synchronizer.bat getFilesForTransfer

            call kpc.download.bat questionDownloadFile

            call kpc.download.bat downloadFile

            set MESSAGE=El archivo se ha descargado exitosamente
            call kpc.utils.bat message
        )

        if "%OPTION%" == "6" ( 
            cls
            exit
        )

        goto :kpc
goto :eof