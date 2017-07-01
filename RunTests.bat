@Echo OFF
.\win32\debug\TestTLabelledEnum.exe
set Result=%ERRORLEVEL%
IF %Result% EQU 1 (
   Echo 1 test failed.
) else IF %Result% NEQ 0 (
   Echo %Result% tests failed
)

