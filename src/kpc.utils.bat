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