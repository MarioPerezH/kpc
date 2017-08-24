@echo off

set AUTOR="Mario Perez"
set VERSION="1.0.0"


call :initParameters

call :logo

call :kpc

:kpc
       set OPTION=
       set ERROR=
       set RESULT=

        call :options 

        if "%OPTION%" == "0" if "%DEBUG%" == "1" (
			call :variables
		)  

        if "%OPTION%" == "1" (
            call :existFileConfig
            
            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            call :readFileConfig 

            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            set MESSAGE=Las credenciales de autenticacion se cargaron correctamente.
            call :message
        )

        if "%OPTION%" == "2" (
            call :inputCredentials

            call :isValidConfig

            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            call :questionSaveConfig
          
            set MESSAGE=Las credenciales de autenticacion se cargaron correctamente.
            call :message
        )

        if "%OPTION%" == "3" (
            call :isValidConfig

            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            call :sync

            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            set MESSAGE=La sincronizacion se realizo correctamente.
            call :message
        )

        if "%OPTION%" == "4" ( 
            call :isValidConfig

            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            call :download

            set MESSAGE=La descarga de archivos se realizo correctamente.
            call :message
        )

        if "%OPTION%" == "5" ( 
            call :isValidConfig

            if defined ERROR ( 
                call :error 
                goto :kpc
            )

            call :getFilesForTransfer

            call :questionDownloadFile

            call :downloadFile

            set MESSAGE=El archivo se ha descargado exitosamente
            call :message
        )

        if "%OPTION%" == "6" ( 
            cls
            exit
        )

        goto :kpc
goto :eof

call :%1
goto :eof

:existFileConfig
	if not exist "%TXTCONFIG%" (
		set ERROR="No se ha logrado localizar el archivo de configuracion. En el menu principal, seleccione la opcion 2 para crear el archivo de configuracion.""
	)
goto :eof

:inputCredentials
	set FTP=
	set USER=
	set PASS=
	set FOLDERBASE=

	echo.
	set /p FTP="Ingrese direccion IP: "
	set /p USER="Ingrese usuario: "
	set /p PASS="Ingrese PASSword:"
	set /p FOLDERBASE="Ingrese carpeta raiz del directorio FTP:"
goto :eof

:readFileConfig
	setlocal EnableDelayedExpansion
		for /f "tokens=1,2,3,4 delims= " %%a in (%TXTCONFIG%) do (
			set _f=%%a
			set _u=%%b
			set _p=%%c
			set _b=%%d
		)
	endlocal & (
		set FTP=%_f%
		set USER=%_u%
		set PASS=%_p%
		set FOLDERBASE=%_b%
		set RESULT=y
	)
goto :eof

:createFileConfig
	setlocal EnableDelayedExpansion
		set config=%FTP% %USER% %PASS% %FOLDERBASE%
		
		type nul> %TXTCONFIG%
		
		echo !config!>> %TXTCONFIG%
	endlocal
goto :eof

:isValidConfig
	setlocal EnableDelayedExpansion
	set value=
		if not defined FTP (
			set value=n
		)
		
		if not defined USER  (
			set value=n
		)
		
		if not defined PASS (
			set value=n
		) 
		
		if not defined FOLDERBASE (
			set value=n
		)

		if "!value!" == "n" (
			set value="Los datos para la coneccion no se han cargado (opcion 1 o 2)."
		)
	endlocal & set ERROR=%value%
goto :eof

:questionSaveConfig
	echo.
	set /p saveconfig="Guadar datos en archivo de configuracion? (y/n): "

	if not "%saveconfig%" == "y" if not "%saveconfig%" == "n" (
		goto :questionSaveConfig
	)

	if "%saveconfig%" == "y" (
		call :createFileConfig
	)
goto :eof

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
        echo ** SYNC: %SYNC%
        echo ** EXECUTE: %EXECUTE%
        echo ** POSITION: %POSITION%
        echo ** folder: %folder%
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

call :%1
goto :eof

:download
    call :generateTreeFolders %TXTFOLDERS% %DESTINATTION% %FOLDERBASE%

	call :writeScriptTransferFiles %TXTFILES% %DESTINATTION% %FOLDERBASE% %BATTRANSFERDATA%

	ftp -s:%BATTRANSFERDATA% %FTP%
goto :eof

:generateTreeFolders
	%TRACE% Ejecutando%0
	
	set txtfolders=%1
	set destination=%2
	set folderbase=%3
	
	setlocal EnableDelayedExpansion
		for /f "delims=" %%a in (%TXTFOLDERS%) do (
			
			set line=%%a
			
			set pathclean=!line:%FOLDERBASE%=%DESTINATTION%%FOLDERBASE%\!
			
			if not exist "!pathclean!" (
					
				%TRACE% Generando carpeta "!pathclean!"
				mkdir "!pathclean!"
			)
		)
	endlocal
goto :eof

:writeScriptTransferFiles
	%TRACE% Ejecutando%0

	set txtfiles=%1
	set destination=%2
	set folderbase=%3
	set battransferdata=%4
	set pathclean=
	set numberFile=%5
	
	echo %USER%>>%BATTRANSFERDATA%
	echo %PASS%>>%BATTRANSFERDATA%
	echo prompt>>%BATTRANSFERDATA%

	setlocal EnableDelayedExpansion
		set i=1

		for /f "delims=" %%a in (%TXTFILES%) do (
			
			set pathname=%%~pa
			set filename=%%~nxa

			set pathclean=!pathname:\%FOLDERBASE%\=%DESTINATTION%%FOLDERBASE%\!
				
			set pathclean=!pathclean:~0,-1!

			if not defined numberFile (
				
				%TRACE% Copiando archivo a !pathname!
				echo lcd "!pathclean!">>%BATTRANSFERDATA%
				echo get "!pathname!!filename!">>%BATTRANSFERDATA%

			) else (
				if "!i!" == "%numberFile%" (
					
					if not exist "!pathclean!\nul" (
						mkdir "!pathclean!"
					)

					%TRACE% Copiando archivo a !pathclean!
					echo lcd "!pathclean!">>%BATTRANSFERDATA%
					echo get "!pathname!!filename!">>%BATTRANSFERDATA%
					
				)
			)
			set /a i+=1
		)
	endlocal
	
	echo disconnect>>%BATTRANSFERDATA%
	echo bye>>%BATTRANSFERDATA%	
goto :eof


:questionDownloadFile
	echo.

	set /p result="Ingrese el numero del archivo que desea descargar: (s=salir) "

	if "%result%" == "s" (
		goto :eof
	)

	if not "%result%" LEQ "1" if "%result%" GEQ "%TOTALFILESDOWNLOAD%" (
		call :questionDownloadFile
	)

	set OPTION=%result%
goto :eof

:downloadFile
	%TRACE% Ejecutando%0

	type nul> %BATTRANSFERDATA%	
	
	call :writeScriptTransferFiles %TXTFILES% %DESTINATTION% %FOLDERBASE% %BATTRANSFERDATA% %OPTION%

	ftp -s:%BATTRANSFERDATA% %FTP%
goto :eof

@echo off

call :%FUNCTION%

goto :eof

:init
	set folder=%FOLDERBASE%

	call :clean

	call :process

	call :generateTreeFolders %TXTFOLDERS% %DESTINATTION% %FOLDERBASE%

	call :writeScriptTransferFiles %TXTFILES% %DESTINATTION% %FOLDERBASE% %BATTRANSFERDATA%

	call :executeScriptToFTP %FTP% %BATTRANSFERDATA%

	if not "%DEBUG%" == "1" (
		call :removeTempFiles
	)
goto :eof

:process
	%TRACE% Evaluando arbol para: %folder%
	
	call :writeScriptExtractData %USER% %PASS% "%folder%" %BATEXTRACTDATA%

	call :executeScriptToFTP %FTP% %BATEXTRACTDATA%
	
	call :filterAndwriteFiles
	
	call :filterAndwriteFolders
	
	call :getNextFolder %POSITION% folder
	
	%TRACE%.
	
	if defined folder (
		set /a position+=1
		
		call :process
	)
	
goto :eof

:clean
	%TRACE% Limpiando archivos temporales
	
	call :createFile %TXTFOLDERS%
	
	call :createFile %TXTFILES%
	
	call :createFile %BATEXTRACTDATA%
	
	call :createFile %BATTRANSFERDATA%
goto :eof

:createFile
	type nul >%1
goto :eof

:removeTempFiles
	del %TXTFOLDERS%
	
	del %TXTFILES%
	
	del %BATEXTRACTDATA%
	
	del %TXTOUTPUT%
	
	del %BATTRANSFERDATA%
goto :eof

:executeScriptToFTP
	%TRACE% Ejecutando%0
		
	ftp -s:%2 %1 
goto :eof

:writeScriptExtractData
	%TRACE% Ejecutando%0

	setlocal
		set user=%1
		set pass=%2
		set folder=%3
		set bat=%4

		echo %USER%> %bat%
		echo %PASS%>> %bat%
		echo cd %folder%>> %bat%
		echo ls -ltr %TXTOUTPUT%>> %bat%
		echo disconnect>> %bat%
		echo bye>>%bat%
	endlocal
goto :eof

:filterAndwriteFiles
	%TRACE% Ejecutando%0
	
	set cmmd='findstr /C:":" %TXTOUTPUT%'
	set cmmd='findstr /r /v "<DIR> File(s) Dir(s) Volume Directory of" %TXTOUTPUT%'
		
	for /f "tokens=4* delims= " %%a in (%cmmd%) do (
		
		echo n:\%folder%\%%a %%b>>%TXTFILES%
	)
	
goto :eof

:filterAndwriteFolders
	%TRACE% Ejecutando%0
	
	set cmmd='findstr /C:"<DIR>" %TXTOUTPUT%'
		
	for /f "tokens=4* delims= " %%a in (%cmmd%) do (
		
		if not "%%a" == "." if not "%%a" == ".." (
		
			set evaluate=%%b
										
			if defined evaluate (
				echo %folder%\%%a %%b>>%TXTFOLDERS%
			)else (
				echo %folder%\%%a>>%TXTFOLDERS%
			)
		)
	)
goto :eof
	
:getNextFolder
	%TRACE% Ejecutando%0
	
	setlocal EnableDelayedExpansion
		set i=0
		set position=%1
		set folder=
		
		for /f "delims=" %%l in (%TXTFOLDERS%) do (
			
			if %POSITION% == !i! (
				
				set folder=%%l
			)
			
			set /a i+=1
		)
	endlocal & set %2=%folder%
goto :eof



call :%1
goto :eof

:logo
    echo.
    echo *************************************************************************
    echo * 	888    d8P  8888888b.   .d8888b.  				* 
    echo * 	888   d8P   888   Y88b d88P  Y88b 				* 
    echo * 	888  d8P    888    888 888    888 				* 
    echo * 	888d88K     888   d88P 888        				* 
    echo * 	8888888b    8888888P"  888        				* 
    echo * 	888  Y88b   888        888    888 	Dacto			* 
    echo * 	888   Y88b  888        Y88b  d88P 	KPC batch v. %VERSION%	* 
    echo * 	888    Y88b 888         "Y8888P"  	Autor: %AUTOR%	* 
    echo *************************************************************************
    echo.
goto :eof

call :%1
goto :eof

:options
	
	echo Opciones:
	echo    1: Leer credenciales desde archivo de configuracion.
	echo    2: Ingresar credenciales manualmente.
	echo    3: Sincronizar tabla de archivos.
	echo    4: Obtener todos los archivos desde FTP (sobreescritura).
	echo    5: Obtener archivo desde FTP (sobreescritura).
	echo    6: Salir
	echo.

	set /p option="Seleccione una opcion: "

	if not "%option%" LEQ "0" if "%option%" GEQ "7" (
		call :options
	)

	set OPTION=%option%
goto :eof

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

call :%1
goto :eof

:sync
	set folder=%FOLDERBASE%

    call :clean

	call :synProccess
goto :eof

:synProccess
	%TRACE% Evaluando arbol para: %folder%

	call :writeScriptExtractData %USER% %PASS% "%folder%" %BATEXTRACTDATA%

	call :executeScriptToFTP %FTP% %BATEXTRACTDATA%
	
	call :filterAndwriteFiles
	
	call :filterAndwriteFolders
	
	call :getNextFolder %POSITION% folder
	
	%TRACE%.
	
	if defined folder (
		set /a POSITION+=1
		
		call :synProccess
	)
goto :eof

:createTempFiles
    %TRACE% Creando archivos temporales
	
	if not exist %TXTFOLDERS% (
		type nul> %TXTFOLDERS%
	)
	
	if not exist %TXTFILES% (
		type nul> %TXTFILES%
	)
	
	if not exist %BATEXTRACTDATA% (
		type nul> %BATEXTRACTDATA%
	)
	
	if not exist %BATTRANSFERDATA% (
		type nul> %BATTRANSFERDATA%	
	)
goto :eof

:clean
    %TRACE% Limpiando archivos temporales
	
	type nul> %TXTFOLDERS%
	
	type nul> %TXTFILES%
	
	type nul> %BATEXTRACTDATA%
	
	type nul> %BATTRANSFERDATA%	

	set POSITION=0
goto :eof

:writeScriptExtractData
	%TRACE% Ejecutando%0

	setlocal
		set user=%1
		set pass=%2
		set folder=%3
		set bat=%4

		echo %USER%> %bat%
		echo %PASS%>> %bat%
		echo cd %folder%>> %bat%
		echo ls -ltr %TXTOUTPUT%>> %bat%
		echo disconnect>> %bat%
		echo bye>>%bat%
	endlocal
goto :eof

:executeScriptToFTP
	%TRACE% Ejecutando%0
		
	ftp -s:%2 %1 
goto :eof

:filterAndwriteFiles
	%TRACE% Ejecutando%0
	
	set cmmd='findstr /C:":" %TXTOUTPUT%'
	set cmmd='findstr /r /v "<DIR> File(s) Dir(s) Volume Directory of" %TXTOUTPUT%'
		
	for /f "tokens=4* delims= " %%a in (%cmmd%) do (
		
		echo n:\%folder%\%%a %%b>>%TXTFILES%
	)
	
goto :eof

:filterAndwriteFolders
	%TRACE% Ejecutando%0
	
	set cmmd='findstr /C:"<DIR>" %TXTOUTPUT%'
		
	for /f "tokens=4* delims= " %%a in (%cmmd%) do (
		
		if not "%%a" == "." if not "%%a" == ".." (
		
			set evaluate=%%b
										
			if defined evaluate (
				echo %folder%\%%a %%b>>%TXTFOLDERS%
			)else (
				echo %folder%\%%a>>%TXTFOLDERS%
			)
		)
	)
goto :eof
	
:getNextFolder
	%TRACE% Ejecutando%0
	
	setlocal EnableDelayedExpansion
		set i=0
        set position=%1
		set folder=
		
		for /f "delims=" %%l in (%TXTFOLDERS%) do (
			
			if %POSITION% == !i! (
				set folder=%%l
			)
			
			set /a i+=1
		)
	endlocal & set %2=%folder%
goto :eof

:getFilesForTransfer
	%TRACE% Ejecutando%0
	
	setlocal EnableDelayedExpansion
		set i=1

		echo.
		echo Listado de archivos sincronizados.
		echo.
		
		for /f "delims=" %%l in (%TXTFILES%) do (
			
			set pathname=%%~pl
			set filename=%%~nxl

			echo      [!i!] !pathname!!filename!

			set /a i+=1
		)

		echo.
	endlocal & set /a TOTALFILESDOWNLOAD=%i%
goto :eof


call :%1
goto :eof

:writeScriptUp
    type nul>%BATSCRIPT%

    set file=%1

    echo %USER%> %BATSCRIPT%
	echo %PASS%>> %BATSCRIPT%
    echo put %file%>> %BATSCRIPT%
    echo disconnect>> %BATSCRIPT%
	echo bye>>%BATSCRIPT%
goto :eof

:upload
    set file=%1

    call :writeScriptUp %file%

    ftp -s:%BATEXTRACTDATA% %FTP% 

    echo Archivo subido exitosamente
goto :eof

call :%1
goto :eof

:createFile
    type nul >%1
goto :eof

:error
	echo.
	echo ******************
	echo ** ERROR: %ERROR%
	echo ******************
	echo.
goto :eof

:message
	echo.
	echo ******************
	echo ** MSG: %MESSAGE%
	echo ******************
	echo.
goto :eof