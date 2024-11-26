@echo off
title %0

set ERROR_CODE=0
set CURRENT_PATH=%CD%
set INFO_LOG=[[94mINFO[0m]
set ERROR_LOG=[[31mERROR[0m]

:: check system build version
@setlocal EnableExtensions EnableDelayedExpansion
for /F %%I in ('powershell -Command "(Get-WmiObject Win32_OperatingSystem).BuildNumber"') do set "osBuildNumber=%%I"
@endlocal & set osBuildNumber=%osBuildNumber%
set lowestSystemVersion=17063
if "%lowestSystemVersion%" LEQ "%osBuildNumber%" goto checkIdea64exe
goto systemVersionNotValid

:: check where is idea64.exe
:checkIdea64exe
set idea64exe=idea64.exe
if not exist "%IDEA_HOME_PATH%\bin\%idea64exe%" goto foreachSystemPath
set idea64exePath=%IDEA_HOME_PATH%\bin\%idea64exe%
goto foundIdea64exe

:foreachSystemPath
set remain=%PATH%
:loop
for /f "tokens=1* delims=;" %%a in ("%remain%") do (
	if exist "%%a\%idea64exe%" set idea64exePath=%%a\%idea64exe%&goto foundIdea64exe
	set remain=%%b
)
if defined remain goto :loop
goto idea64exeNotFound

:foundIdea64exe
goto checkZipFileBegin

::check zip file format
:checkZipFileBegin
set zipFileName=%~nx1
if "%zipFileName%" == "" goto zipNotDefind
goto checkZipExists

:checkZipExists
set zipFile=%CURRENT_PATH%\%zipFileName%
if not exist "%zipFile%" goto zipNotDefind
goto checkZipExtension

:checkZipExtension
for %%a in ("%zipFile%") do set "extension=%%~xa"
if /i "%extension%" neq ".zip" goto zipFormatNotValid
goto checkZipFormat

:checkZipFormat
for /f "delims=" %%a in ('cmd /C tar -tf "%zipFile%" ^| findstr /C:build.gradle /C:build.gradle.kts /C:pom.xml') do (
    set "buildFileEntry=%%a"
)
if not defined buildFileEntry goto zipFormatNotValid
goto checkUnzipFolder

:checkUnzipFolder
for /f "tokens=1,* delims=/" %%a in ("%buildFileEntry%") do set "unzipFolder=%%a" & set "buildFile=%%b" 
set TRUE=
if not defined unzipFolder set TRUE=1
if not defined buildFile set TRUE=1
if defined TRUE goto zipFormatNotValid
goto checkBuildFile

:checkBuildFile
if "%buildFile%" == "pom.xml" goto checkMavneWrapperFolder
if "%buildFile%" == "build.gradle" goto checkGraleWrapperFolder
if "%buildFile%" == "build.gradle.kts" goto checkGraleWrapperFolder
goto zipFormatNotValid

:checkGraleWrapperFolder
for /f "delims=" %%a in ('cmd /C tar -tf "%zipFile%" ^| findstr /C:gradle/wrapper/gradle-wrapper.properties') do (
    set "hasWrapperPropertiesFileEntry=%%a"
)
if not defined hasWrapperPropertiesFileEntry goto zipFormatNotValid
set wrapperDistributionUrl=https\://mirrors.aliyun.com/macports/distfiles/gradle/
set wrapperPropertiesFile=gradle\wrapper\gradle-wrapper.properties
goto checkZipFileEnd

:checkMavneWrapperFolder
for /f "delims=" %%a in ('cmd /C tar -tf "%zipFile%" ^| findstr /C:.mvn/wrapper/maven-wrapper.properties') do (
    set "hasWrapperPropertiesFileEntry=%%a"
)
if not defined hasWrapperPropertiesFileEntry goto zipFormatNotValid
set wrapperPropertiesFile=.mvn\wrapper\maven-wrapper.properties
goto checkZipFileEnd

:checkZipFileEnd
set buildFilePath=%CURRENT_PATH%\%unzipFolder%\%buildFile%
set wrapperPropertiesFilePath=%CURRENT_PATH%\%unzipFolder%\%wrapperPropertiesFile%
goto unzipWithTar

:unzipWithTar
for /f "tokens=*" %%a in ('cmd /C tar -xmvpf "%zipFile%" -C "%CURRENT_PATH%" 2^>^&1') do (
    echo %INFO_LOG% %%a>&2
)
goto checkSkipInput

:checkSkipInput
if "%2" == "skipReplaceWrapper" goto echoBuildInformation
goto replaceWrapperMirrors

:replaceWrapperMirrors
for /F "usebackq eol=# tokens=1,2 delims==" %%a in ("%wrapperPropertiesFilePath%") do (
    if "%%a"=="distributionUrl" (
		set defaultDistributionUrl=%%b
		set wrapperFileName=%%~nxb
	)
)
set remaining_string=%wrapperFileName:~13%
set version=%remaining_string:~0,5%
set wrapperDistributionUrl=https://mirrors.aliyun.com/apache/maven/maven-3/%version%/binaries/
set defaultDistributionUrl=distributionUrl=%defaultDistributionUrl%
set replacedDistributionUrl=distributionUrl=%wrapperDistributionUrl%%wrapperFileName%
echo %INFO_LOG% The default distributionUrl will be replaced with %wrapperDistributionUrl%%wrapperFileName%.
powershell -Command "&{"^
						"$content = Get-Content -Path \"%wrapperPropertiesFilePath%\" -Raw | "^
						"ForEach-Object {$_ -replace [regex]::Escape(\"%defaultDistributionUrl%\"), \"%replacedDistributionUrl%\"}; "^
						"$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False; "^
						"[System.IO.File]::WriteAllLines(\"%wrapperPropertiesFilePath%\", $content, $Utf8NoBomEncoding); "^
					"}"
goto echoBuildInformation

:echoBuildInformation
echo %INFO_LOG% Script execution path: "%CURRENT_PATH%". >&2
echo %INFO_LOG% IntelliJ IDEA executable path: "%idea64exePath%". >&2
echo %INFO_LOG% Project build file path: "%buildFilePath%". >&2
goto openWithIdea64exe

:openWithIdea64exe
"%idea64exePath%" "%buildFilePath%"  
goto end

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:systemVersionNotValid
echo %ERROR_LOG% Check your Windows build number to make sure you have build 17063 or later. >&2
goto error

:idea64exeNotFound
echo %ERROR_LOG% Seems 'idea64.exe' not found. Add IDEA bin folder to system path or set IDEA_HOME_PATH. >&2
goto error

:zipFormatNotValid
echo %ERROR_LOG% The input file "%zipFileName%" is not a valid Spring Initializr ZIP file. >&2
goto error

:zipNotDefind
echo %ERROR_LOG% Spring Initializr ZIP file not specified. You can run it like "uao demo.zip". >&2
goto error

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:error
set ERROR_CODE=1
echo %ERROR_LOG% An error occurred. Please fix the indicated issue before continuing. >&2
goto end

:end
exit /b %EXIT_CODE% 