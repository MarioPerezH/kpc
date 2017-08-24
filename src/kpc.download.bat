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