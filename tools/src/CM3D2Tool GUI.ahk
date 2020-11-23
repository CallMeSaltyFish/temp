#NoTrayIcon
#SingleInstance OFF
SetWorkingDir, %A_ScriptDir%

IfNotExist, CM3D2Tool.exe
{
	MsgBox, CM3D2Tool.exe のある場所で実行してください
	ExitApp
}
argv_max = %0%
if (argv_max == 0) {
	Loop {
		if (file_path == "") {
			default_path := GetDefaultPath()
			FileSelectFile, file_path, 3, %default_path%, 対応ファイルを選択してください, 対応ファイル(*.arc;*.tex;*.png)
		}
		if (ErrorLevel == 1) {
			ExitApp
		}
		if (FileExist(file_path) == "") {
			Msgbox, ファイルが存在しません
			file_path := ""
		}
		else {
			argv_max = 1
			1 := file_path
			break
		}
	}
}
commands := ""
Loop, %argv_max% {
	path := %A_Index%
	SplitPath, path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	StringLower, OutExtension, OutExtension
	IfNotInString, path, "
	{
		path = "%path%"
	}
	if (OutExtension == "arc") {
		commands = %commands%CM3D2Tool.exe -e %path%`n
	}
	else if (OutExtension == "") {
		arc_path := Trim(path, """") . ".arc"
		if (FileExist(arc_path)) {
			commands = %commands%CM3D2Tool.exe -i %path%`n
		}
		else {
			MsgBox, オリジナルのarcファイルが見つかりません`n展開前のarcファイルを同じフォルダに置いてください`n終了します
			ExitApp
		}
	}
	else if (OutExtension == "tex") {
		commands = %commands%CM3D2Tool.exe -c -m TEX -f \.tex %path%`n
	}
	else if (OutExtension == "png") {
		commands = %commands%CM3D2Tool.exe -c -m TEX -f \.png %path%`n
	}
	else {
		MsgBox, 未対応のファイル拡張子です(%OutFileName%)`n無視します
		continue
	}
}
if (commands != "") {
	temp_bat = %A_ScriptName%.bat
	FileDelete, %temp_bat%
	FileAppend, %commands%PAUSE, %temp_bat%
	RunWait, "%temp_bat%", %A_ScriptDir%
	;FileDelete, %temp_bat%
}
ExitApp

GetDefaultPath() {
	RegRead, path, HKEY_CURRENT_USER, Software\KISS\カスタムメイド3D2, InstallPath
	if (ErrorLevel == 0) {
		path = %path%GameData\
	}
	else {
		path := A_ScriptDir
	}
	return path
}
