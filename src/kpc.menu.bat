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