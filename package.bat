@Echo off
REM Module Packaging script. To be called from ..\..\CodeProject.AI-Server\devops\build\create_packages.bat

set moduleId=%~1
set version=%~2

tar -caf %moduleId%-%version%.zip --exclude=__pycache__  --exclude=*.development.* --exclude=*.log ^
    patch\* utils\* *.py modulesettings.* requirements.* install.sh install.bat post_install.sh post_install.bat explore.html
