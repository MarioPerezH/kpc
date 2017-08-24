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