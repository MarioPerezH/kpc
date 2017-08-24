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