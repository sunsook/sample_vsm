@echo off
chcp 65001 > nul
set CT_GCC=%USERPROFILE%\CT\CodeScroll\Compiler\gcc\9.5.0\32bit\bin
if exist "%CT_GCC%\gcc.exe" goto ok

echo.
echo [config] CT 컴파일러가 없습니다: %CT_GCC%
echo   CT 를 설치할 때 전역 데이터 경로를 기본값으로 두면 컴파일러가 %APPDATA%\CodeScroll 아래에 설치됩니다.
if exist "%APPDATA%\CodeScroll\Compiler" (
  echo   아래 명령으로 컴파일러 폴더를 복사한 뒤 config.bat 을 다시 실행하십시오.
  echo.
  echo   xcopy "%APPDATA%\CodeScroll\Compiler" "%USERPROFILE%\CT\CodeScroll\Compiler\" /E /I
) else (
  echo   %APPDATA%\CodeScroll\Compiler 도 없습니다. CT 설치를 확인하고 강사에게 알려 주십시오.
)
echo.
exit /b 1

:ok
set PATH=%CT_GCC%;%PATH%
