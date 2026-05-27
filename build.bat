@echo off
chcp 65001 >nul 2>&1
setlocal
cd /d "%~dp0"

echo.
echo  NUSspli 构建
echo  ===========
echo.

where python >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 python。请安装 Python 3 并勾选 "Add to PATH"。
    echo        https://www.python.org/downloads/
    goto :fail
)

echo 使用: 
python --version
echo.

REM 必须用 python 调用，不要直接 .\build.py（可能无窗口、无输出）
python -u "%~dp0build.py" %*
set ERR=%ERRORLEVEL%

if %ERR% equ 0 goto :ok

echo.
echo [构建失败，退出码 %ERR%]
if %ERR% equ 2 (
    echo.
    echo 这是预期行为：请按上方说明用 Docker 或 WSL 编译。
    echo.
    where docker >nul 2>&1
    if not errorlevel 1 (
        echo 检测到 docker，可尝试:
        echo   docker build -t nussplibuilder .
        echo   docker run --rm -v "%CD%:/project" nussplibuilder python3 build.py
    ) else (
        echo 未检测到 docker。请安装 Docker Desktop:
        echo   https://www.docker.com/products/docker-desktop/
    )
)
goto :fail

:ok
echo.
echo 构建完成。
pause
exit /b 0

:fail
echo.
pause
exit /b %ERR%
