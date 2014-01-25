@echo off
rem the purpose of this script is to change the wallpaper to a file that is inside your dropbox folder

rem step 1. check if dropbox folder exists
IF exist %HOMEPATH%\Dropbox (

	rem step 2. check if desktop folder exists
	IF exist %HOMEPATH%\Dropbox\Desktop (

		rem step 3. check if file exists
		if exist %HOMEPATH%\Dropbox\Desktop\wallpaper.bmp (

			rem step 4. change the wallpaper now
			reg add "hkcu\control panel\desktop" /v wallpaper /t REG_SZ /d "" /f 
			reg add "hkcu\control panel\desktop" /v wallpaper /t REG_SZ /d "%HOMEPATH%\Dropbox\Desktop\wallpaper.bmp" /f 
			reg delete "hkcu\Software\Microsoft\Internet Explorer\Desktop\General" /v WallpaperStyle /f
			reg add "hkcu\control panel\desktop" /v WallpaperStyle /t REG_SZ /d 2 /f
			RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters 
			exits

		}

	)

)
