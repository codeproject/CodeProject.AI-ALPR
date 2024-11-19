:: Installation script :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::                          ALPR
::
:: This script is called from the ALPR directory using: 
::
::    ..\..\CodeProject.AI-Server\src\setup.bat
::
:: This script is only called from ..\..\CodeProject.AI-Server\src\setup.bat in
:: Dev setup, or ..\..\src\setup.bat in production
::
:: For help with install scripts, notes on variables and methods available, tips,
:: and explanations, see /src/modules/install_script_help.md

@if "%1" NEQ "install" (
    echo This script is only called from ..\..\CodeProject.AI-Server\src\setup.bat
    @pause
    @goto:eof
)

REM Backwards compatibility with Server 2.6.5
if "!utilsScript!" == "" if "!sdkScriptsDirPath!" NEQ "" set utilsScript=%sdkScriptsDirPath%\utils.bat

:: Download the ALPR models and store in /paddleocr
call "%utilsScript%" GetFromServer "models/" "ocr-en-pp_ocrv4-paddle.zip" "paddleocr" "Downloading ALPR models..."

call "!utilsScript!" Write "Checking CPU compatibility..." 

REM Intel i7 920 CPUs have trouble with paddlepaddle
REM Not everyone has WMIC installed
:: for /f "tokens=2 delims==" %%I in ('wmic cpu get name /value') do (
::     set "cpu_name=%%I"
::     goto :break_loop
:: )
:: :break_loop
for /f "tokens=*" %%A in ('powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty Name"') do set cpu_name=%%A

REM Check if CPU name contains "Intel(R) Core(TM) i7 CPU 920"
echo %cpu_name% | find "Intel(R) Core(TM) i7 CPU 920" > nul
if %errorlevel% equ 0 (
    call "!utilsScript!" WriteLine "** WARNING: PaddlePaddle may fail on the Intel 920 CPU"
) else (
    call "!utilsScript!" WriteLine "All good" !color_success!
)

REM Empty command to clear errorlevel
cd > nul

REM PaddlePaddle is very, very fussy
if %hasCUDA% == "true" (
    call "!utilsScript!" Write "Checking cuDNN version..." 
    if "!cuDNN_major_version!" neq "8" (
        call "!utilsScript!" WriteLine
        call "!utilsScript!" WriteLine "** WARNING: PaddlePaddle requires cuDNN 8 but instead found !cuDNN_major_version!." !color_error!
        call "!utilsScript!" WriteLine "            Disabling CUDA support. Consider installing cuDNN 8 and " !color_error!
        call "!utilsScript!" WriteLine "            reinstalling this module in order to enable GPU support." !color_error!
        call "!utilsScript!" WriteLine
        set hasCUDA=false
    ) else (
        call "!utilsScript!" WriteLine "All good" !color_success!
    )
)

REM TODO: Check paddleocr created and has files
REM set moduleInstallErrors=...

