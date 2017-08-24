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
